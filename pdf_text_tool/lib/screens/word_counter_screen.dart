import 'package:flutter/material.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';

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
  List<Widget> _wordFields = [];

  void addField() {
    setState(() {
      _wordFields.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: DropdownButton(
                          alignment: AlignmentDirectional.centerStart,
                          borderRadius: BorderRadius.circular(10),
                          value: "And",
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          items: const [
                            DropdownMenuItem(value: "And",child: Center(child : Text("And")),),
                            DropdownMenuItem(value: "Or",child: Center(child: Text("Or")),)
                          ],
                          onChanged: (input){},
                          underline: Container(),
                        ),
                      ),
                      SizedBox(width: 100,child: TextFormField(),)
                    ],
                )
          ),
          )
      );
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
            child: SingleChildScrollView(

              child: Column(
                children: [
                  const Center(child: Text("Keywords List"),),
                  ..._wordFields,
                  ElevatedButton(onPressed: addField, child: const Icon(Icons.add))
                ],
              ),
            ),
          ),
          const Center(child: Text("Keywords Result"),),
        ],
      ),
    );
  }
}