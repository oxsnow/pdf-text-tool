import 'package:flutter/material.dart';
import 'package:pdf_text_tool/screens/word_counter_screen.dart';
import 'package:pdf_text_tool/screens/sentiment_analysis_screen.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:pdf_text_tool/utils/placeholder_tab.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider_windows/path_provider_windows.dart';

List<FeatureScreen> features = [
  const WordCounterScreen(),
  SentimentAnalysisScreen(),
  const PlaceholderTabScreen(),
];

void _startPythonServer() async {
  // Command to start the Python server in a terminal window
  // PathProviderWindows provider = PathProviderWindows();
  // String executablePath = await provider.getPath();
  var currentDirectory = Directory.current.path;
    
  const command = 'cmd.exe';
  // print('$currentDirectory\\assets\\app.exe && pause');

  final arguments = ['/c', 'start', command, '/K', '$currentDirectory\\assets\\app.exe'];

  // Start the process
  await Process.start(command, arguments);

  // Handle process output (optional)
  // process.stdout.transform(SystemEncoding().decoder).listen((output) {
  //   // print(output);
  // });

  // process.stderr.transform(SystemEncoding().decoder).listen((error) {
  //   // print('Error: $error');
  // });
}


void main() {
  runApp(const MyApp());
  _startPythonServer();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData( 
        primarySwatch: Colors.pink,  
        appBarTheme: const AppBarTheme( color: Colors.pink, ),),
      home: HomePage(key: key),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: features.length, // Number of tabs
      child: Scaffold(
        appBar: TabBar(
            tabs: features.map((feature) {
              return Tab(icon: feature.classIcon, text: feature.title);
            },
          ).toList()
        ),
        body: TabBarView(
          children: features.map((feature) {
            return feature as Widget;
          }).toList(),
        ),
      ),
    );
  }
}
