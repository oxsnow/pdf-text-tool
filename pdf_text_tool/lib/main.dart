import 'package:flutter/material.dart';
import 'package:pdf_text_tool/screens/word_counter_screen.dart';
import 'package:pdf_text_tool/features/word_counter.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:pdf_text_tool/utils/placeholder_tab.dart';

List<FeatureScreen> features = [
  const WordCounterScreen(),
  const PlaceholderTabScreen(),
];

void main() {
  runApp(const MyApp());
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
