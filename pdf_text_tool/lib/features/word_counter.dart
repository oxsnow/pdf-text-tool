import 'dart:io';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WordCounter {
  WordCounter();

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