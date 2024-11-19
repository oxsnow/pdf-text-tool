import 'package:flutter/material.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';

class PlaceholderTabScreen extends StatefulWidget with FeatureScreen {
  const PlaceholderTabScreen({super.key});

  @override
  String get title => "placeholder title";
  @override
  Icon get classIcon => const Icon(Icons.space_bar);

  @override
  State<PlaceholderTabScreen> createState() => _PlaceholderTabScreenState();
}

class _PlaceholderTabScreenState extends State<PlaceholderTabScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}