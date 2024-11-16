import 'package:flutter/material.dart';
import 'package:pdf_text_tool/utils/feature_class.dart';
import 'package:pdf_text_tool/screens/word_counter_screen.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';

class WordCounter extends Featureclass {
  @override
  Widget? get screen => const WordCounterScreen();

  WordCounter();
}