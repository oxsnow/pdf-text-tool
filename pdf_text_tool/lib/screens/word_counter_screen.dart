import 'package:flutter/material.dart';
import 'package:pdf_text_tool/features/word_counter.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class WordCounterScreen extends StatefulWidget with FeatureScreen {
  const WordCounterScreen({super.key});

  @override
  String get title => "Word Counter";

  @override
  Icon get classIcon => const Icon(Icons.bookmark);

  @override
  State<WordCounterScreen> createState() => _WordCounterScreenState();
}

class _WordCounterScreenState extends State<WordCounterScreen> {
  final List<Widget> _wordFields = [];
  final List<TextEditingController> _controllers = [];
  String _filePath = "";
  final WordCounter _wordCounter = WordCounter();
  int _wordFound = 0;
  final List<String> _sentencesList = [];
  bool _isloading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      debugPrint('File name: ${file.name}');
      debugPrint('File path: ${file.path}');
      setState(() {
        _filePath = file.path!;
      });
    }
  }

  void startSearch(){
    _sentencesList.clear();
    setState(() {
      _isloading = true;
      debugPrint("before future");
    });

    List<String> keywords = [];
    for (var controller in _controllers) {
      keywords.add(controller.text);
    }
    _wordCounter.count(_filePath, keywords).then((ret) {
      setState(() {
        _isloading = false;
        _sentencesList.addAll(ret);
        // debugPrint('Found sentences: $_sentencesList');
        _wordFound = _sentencesList.length;
      });
      debugPrint("future");
    });
    debugPrint("wait future");
  }

  void removeFormField() { 
    if (_controllers.isNotEmpty) { 
      setState(() { 
        _controllers.removeLast(); 
        _wordFields.removeLast(); 
      }); 
    } 
  }

  void addField() {
    setState(() {
      final controller = TextEditingController();
      _controllers.add(controller);
      _wordFields.add(
        Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            child: Row(
                    children: [
                      Expanded(child: TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder()
                        ),
                      ),
                      )
                    ],
                )
          ),
        )
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: const CircularProgressIndicator(),
      inAsyncCall: _isloading,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration( border: Border.all(color: Colors.blue), ),
              child: SingleChildScrollView(
      
                child: Column(
                  children: [
                    ElevatedButton(onPressed: pickFile, child: const Text("Browse File")),
                    Text(_filePath),
                    const Center(child: Text("Keywords List"),),
                    ..._wordFields,
                    Center(
                      child: Row(children: [
                        ElevatedButton(onPressed: addField, child: const Icon(Icons.add)),
                        _wordFields.isNotEmpty ? 
                        ElevatedButton(onPressed: startSearch, child: const Text("Search")) :
                        Container(),
                        _wordFields.isNotEmpty ? 
                        ElevatedButton(onPressed: removeFormField, child: const Icon(Icons.remove)) :
                        Container(),
                      ],),
                    )
                  ],
                ),
              ),
            ),
            Center(child: Text("Keywords Result $_wordFound"),),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: 
                    _sentencesList.map((item) => Card(child: Align(alignment: Alignment.centerLeft, child: SelectableText("$item\n")))).toList()
                ),
              ))
          ],
        ),
      ),
    );
  }
}