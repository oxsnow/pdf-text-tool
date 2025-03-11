import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_text_tool/features/word_counter.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:file_picker/file_picker.dart';
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
  // keywords
  final List<Widget> _wordFields = [];
  final List<TextEditingController> _controllers = [];

  // file meta data
  final List<String> _filePaths = [];
  final List<String> _fileNames = [];
  final int _maxNameLength = 30;

  // results
  Map<String, int> _wordFound = {};
  Map<String, List<String>> _sentencesList = {};

  // class members
  final WordCounter _wordCounter = WordCounter();
  bool _isloading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      _filePaths.clear();
      setState(() {
        for (var file in result.files) {
          _filePaths.add(file.path!);
          _fileNames.add(file.name);
          debugPrint('File path: ${file.path}');
        }
      });
    }
  }

  Future<void> pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      var dir = Directory(result);
      List<String> dirs = [];
      await for (FileSystemEntity entity in dir.list(recursive: true, followLinks: false)){
        if (entity is Directory){
          dirs.add(entity.path);
        }
      }
    List<String> selectedDirs = [];
    Map<String, bool> checkboxState = {for (var folder in dirs) folder: false};
    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Select Folders'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: dirs.map((folder) {
                return CheckboxListTile(
                  title: Text(folder),
                  value: checkboxState[folder],
                  onChanged: (bool? value) {
                    setState(() {
                      checkboxState[folder] = value!;
                      if(value){
                        selectedDirs.add(folder);
                        print("add $folder");
                      }
                      else{
                        selectedDirs.remove(folder);
                        print("remove $folder");
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async{
              print("check $selectedDirs");
              _filePaths.clear();
              for (var path in selectedDirs) {
                print("check $path");
                var checkDir = Directory(path);
                await for(FileSystemEntity entity in checkDir.list(recursive: true, followLinks: false)){
                  if(entity is File && entity.path.endsWith(".pdf")){
                    _filePaths.add(entity.path);
                    _fileNames.add(entity.path);
                  }
                }
              }
              setState(() {});
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    });
    }
  }

  void startSearch() async{
    _sentencesList.clear();
    setState(() {
      _isloading = true;
      debugPrint("before future");
    });

    List<String> keywords = [];
    for (var controller in _controllers) {
      keywords.add(controller.text);
    }
    await _wordCounter.clientWordCount(_filePaths, keywords);
    debugPrint("done request");
    while(true){
      debugPrint("iterate status");
      var data = await _wordCounter.checkStatus();
      if(data.containsKey("result")){
        if(data["result"]!.isNotEmpty){
          debugPrint("${data["result"]}");
          // _sentencesList = data.map((key, value) {
          //   debugPrint("$key,$value");
          //   return MapEntry(key, List<String>.from(value));
          // },);
          dynamic sentences = data["result"];
          sentences.forEach((key, value) {
            // Overwrite the value in map2 with the value from map1
            _sentencesList[key] = List<String>.from(value);
            _wordFound[key] = _sentencesList[key]!.length;
          });
          _isloading = false;
        }
      }
      if(data.containsKey("status")){
        if(data["status"] == "completed"){
          break;
        }
      }
      setState(() {
        
      });
    }
    // _wordCounter.count(_filePaths, keywords).then((ret) {
    //   _sentencesList = {};
    //   setState(() {
    //     _isloading = false;
    //     _sentencesList = ret;
    //     // debugPrint('Found sentences: $_sentencesList');
    //     for (var key in _sentencesList.keys) {
    //       _wordFound[key] = _sentencesList[key]!.length;
    //     }
    //   });
    //   debugPrint("future");
    // });
    // debugPrint("wait future");
  }

  void removeFormField() { 
    if (_controllers.isNotEmpty) { 
      setState(() { 
        _controllers.removeLast(); 
        _wordFields.removeLast(); 
      }); 
    } 
  }

  void deleteSentence(String key, int index) { 
    setState(() { 
      _sentencesList[key]!.removeAt(index); 
    }); 
  }

  void exportExcel() async{
    String? path = await FilePicker.platform.getDirectoryPath();
    if(path!=null){
      var retVal = _wordCounter.exportExcel(path, _sentencesList);
      if(!retVal[0]){
        if(mounted){
          showDialog(
            context: context, 
            builder: (BuildContext context) { 
              return AlertDialog( 
                title: const Text('Save Error'), 
                content: Text('${retVal[1]}'), 
                actions: [ 
                  TextButton( 
                    child: const Text('OK'), 
                    onPressed: () { 
                      Navigator.of(context).pop();
                    }
                  )
                ],
              );
            });
        }
      }
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
    String browsedFiles = _fileNames.join(',');
    if(browsedFiles.length > _maxNameLength*2){
      String nameList = _fileNames.join(',');
      browsedFiles = '${nameList.substring(0,_maxNameLength)} ... ${nameList.substring(nameList.length - _maxNameLength)}';
    }
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: pickFile, child: const Text("Browse File")),
                        ElevatedButton(onPressed: pickFolder, child: const Text("Browse Folder")),
                      ],
                    ),
                    Text(browsedFiles),
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
            Expanded(
              child: ListView(
                children: 
                  _sentencesList.entries.map((entry) {
                    return Card(
                      child: ExpansionTile(
                        title: SelectableText(entry.key),
                        subtitle: Text("Keywords Result ${_wordFound[entry.key]}"),
                        // children: entry.value.map((value) {
                        //           return ListTile(
                        //             title: Card(child: SelectableText("$value\n")),
                        //           );
                        //         }).toList()

                        // children: [
                        //   ListView.builder(
                        //     itemCount: _sentencesList[entry.key]!.length,
                        //     itemBuilder: (context, index) {
                        //       return Card(
                        //         child: ListTile(
                        //           title: SelectableText("${_sentencesList[entry.key]![index]}\n"),
                        //           subtitle: ElevatedButton(onPressed: () => deleteSentence(entry.key, index), child: const Icon(Icons.delete)),
                        //         ),
                        //       );
                        //     })
                        // ],

                        children: [
                          for(int i = 0; i < _sentencesList[entry.key]!.length; i++)
                            Card(
                              child: ListTile(
                                  title: SelectableText("${_sentencesList[entry.key]![i]}\n"),
                                  subtitle: ElevatedButton(onPressed: () => deleteSentence(entry.key, i), child: const Icon(Icons.delete)),
                              ),
                            ) 
                        ],
                        ),
                    );
                  }).toList()
              )
            )
          ],
        ),
        floatingActionButton: ElevatedButton(onPressed: exportExcel, child: const Text("Export to Excel")),
      ),
    );
  }
}