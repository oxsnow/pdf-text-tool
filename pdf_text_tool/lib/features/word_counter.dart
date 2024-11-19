import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_text_tool/screens/word_counter_screen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WordCounter {
  WordCounter();

  List<String> count(String path, List<String> keywords){

    //extract text from pdf
    PdfDocument document = PdfDocument(inputBytes: File(path).readAsBytesSync());
    String text = PdfTextExtractor(document).extractText();
    List<String> splitSentences = text.split('.');
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