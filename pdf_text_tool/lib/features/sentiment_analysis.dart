import 'dart:io';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SentimentAnalysis {

  List<String> negativeWords = [];
  List<String> positiveWords = [];
  List<String> fullWords = [];

  SentimentAnalysis() {

    var fullText = File('assets/full_words.txt');
    fullText.readAsString().then((strings){
      fullWords = strings.toLowerCase().split('\r\n');
    });

    var negativeText = File('assets/negative_words.txt');
    negativeText.readAsString().then((strings){
      negativeWords = strings.toLowerCase().split('\r\n');
    });

    var positiveText = File('assets/positive_words.txt');
    positiveText.readAsString().then((strings){
      positiveWords = strings.toLowerCase().split('\r\n');
    });
  }

  Map<String,int> calculateWords(String filePath){
    Map<String, int> calculatedMap = {};
    PdfDocument document = PdfDocument(inputBytes: File(filePath).readAsBytesSync());
    String text = PdfTextExtractor(document).extractText();
    List<String> words = text.toLowerCase().replaceAll("\n", " ").split(' ');
    document.dispose();

    words = words.where((word) => fullWords.contains(word)).toList();
    print(words.length);

    calculatedMap['total'] = words.length;
    int negNumber = 0;
    int posNumber = 0;

    for (var word in words) {
      // print("word: $word");
      for (var negWord in negativeWords) {
        if(word.contains(negWord)){
          // print("negWord: $negWord");
          negNumber += 1;
        }
      }
      for (var posWord in positiveWords) {
        if(word.contains(posWord)){
          // print("posWord: $posWord");
          posNumber += 1;
        }
      }
    }
    calculatedMap['negative'] = negNumber;
    calculatedMap['positive'] = posNumber;

    return calculatedMap;
  }

  void printkey(){
    print(negativeWords);
  }


}