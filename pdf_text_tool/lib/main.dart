import 'package:flutter/material.dart';
import 'package:pdf_text_tool/utils/feature_class.dart';
import 'package:pdf_text_tool/features/word_counter.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:pdf_text_tool/utils/placeholder_tab.dart';

List<Featureclass> features = [
  WordCounter(),
  PlaceholderTab(),
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
              FeatureScreen item = feature.screen! as FeatureScreen;
              return Tab(icon: item.classIcon, text: item.title);
            },
          ).toList()
        ),
        body: TabBarView(
          children: features.map((feature) {
            return feature.screen!;
          }).toList(),
        ),
      ),
    );
  }
}
