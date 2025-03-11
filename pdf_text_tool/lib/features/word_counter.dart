import 'dart:io';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordCounter {
  WordCounter();

  String taskId = "";

  Future<Map<String, List<String>>> count(List<String> paths, List<String> keywords) async {
    Map<String, List<String>> resultMap = {};
    for (var path in paths) {
      //extract text from pdf
      PdfDocument document = PdfDocument(inputBytes: File(path).readAsBytesSync());
      String text = PdfTextExtractor(document).extractText();
      List<String> splitSentences = text.replaceAll("\n", " ").split('.');
      document.dispose();

      List<String> sentences = [];

      for (var sentence in splitSentences) {
        for (String keyword in keywords) { 
          if (sentence.toLowerCase().contains(keyword.toLowerCase())) { 
            sentences.add(sentence);
          } 
        }
      }
      resultMap[path.split("\\").last] = sentences;
    }
    

    return resultMap;
  }

  Future<void> clientWordCount(List<String> paths, List<String> keywords) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/start_word_count'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'file_paths': paths,
        'keywords': keywords
      }),
    );

    final data = json.decode(response.body);
    taskId = data["task_id"];
  }

  Future<Map<String, dynamic>> checkStatus() async{
    Map<String,dynamic> result = {};
    final response = await http.get(Uri.parse('http://localhost:5000/word_count_status/$taskId'));
    final data = json.decode(response.body);
    result = data;
    await Future.delayed(const Duration(seconds: 2));
    return result;
  }

  List<dynamic> exportExcel(String path, Map<String,List<String>> data){
    // Create a new Excel document 
    var excel = Excel.createExcel(); 

    // Create a sheet 
    Sheet sheetObject = excel['Sheet1']; 

    // Add some data 
    sheetObject.appendRow([TextCellValue('File Name'), TextCellValue('Sentence')]);
    for (var key in data.keys) {
      for (var element in data[key]!) {
        sheetObject.appendRow([TextCellValue(key), TextCellValue(element)]);
      }
    }
    
    // Directory documentsDirectory = await getApplicationDocumentsDirectory(); 
    // String path = '${documentsDirectory.path}/file.xlsx'; 

    // Save the Excel file 
    try {
    final file = File("$path/export.xlsx") 
    ..createSync(recursive: true) 
    ..writeAsBytesSync(excel.save()!); 
      return [true, ""];
    } catch (e) {
      return [false, e.toString()];
    } 
  }
}