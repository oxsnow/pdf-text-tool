import 'package:flutter/material.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_text_tool/features/sentiment_analysis.dart';

class SentimentAnalysisScreen extends StatefulWidget with FeatureScreen {
  SentimentAnalysisScreen({super.key});

  final SentimentAnalysis sentimentAnalysis = SentimentAnalysis();

  @override
  String get title => "Sentiment Analysis";

  @override
  Icon get classIcon => const Icon(Icons.chat);

  @override
  State<SentimentAnalysisScreen> createState() => _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  // keywords
  final List<Widget> _wordFields = [];
  final List<TextEditingController> _controllers = [];

  // file meta data
  String _filePath = "";
  final List<String> _fileNames = [];
  final int _maxNameLength = 30;

  // results
  Map<String, int> _sentimentMap = {};

  // class members
  
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      setState(() {
        _filePath = result.files.first.path!;
          debugPrint('File path: $_filePath');
      });
    }
  }

  // @override
  // void initState() {
  //   // _sentimentAnalysis.populateKeywords();
  //   // widget.sentimentAnalysis.printkey();
  //   super.initState();
  // }

  void calculateSentiment(){
    setState(() {
      _sentimentMap = widget.sentimentAnalysis.calculateWords(_filePath);
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration( border: Border.all(color: Colors.blue), ),
              child: Column(
                  children: [
                    ElevatedButton(onPressed: pickFile, child: const Text("Browse File")),
                    Text(_filePath),
                    ElevatedButton(onPressed: calculateSentiment, child: const Text("Calculate Sentiment")),
                  ],
                ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._sentimentMap.entries.map((entry) {
                    return SelectableText("${entry.key} : ${entry.value}");
                  })
                ]
              )
            )
          ],
        ),
      );
  }
}