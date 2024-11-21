import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class WordCounter {
  WordCounter();

  Future<List<String>> count(String path, List<String> keywords) async {

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

    return sentences;
  }
}