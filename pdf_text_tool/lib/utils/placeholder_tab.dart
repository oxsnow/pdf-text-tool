import 'package:flutter/material.dart';
import 'package:pdf_text_tool/utils/feature_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';


class PlaceholderTabScreen extends StatefulWidget with FeatureScreen {
  const PlaceholderTabScreen({super.key});

  @override
  String get title => "Info Board";
  @override
  Icon get classIcon => const Icon(Icons.info);

  @override
  State<PlaceholderTabScreen> createState() => _PlaceholderTabScreenState();
}

class _PlaceholderTabScreenState extends State<PlaceholderTabScreen> {
  String _version = 'Unknown'; 

  @override 
  void initState() { 
    super.initState(); 
    _getVersion(); 
  }

  Future<void> _getVersion() async { 
    final PackageInfo packageInfo = await PackageInfo.fromPlatform(); 
    setState(() { 
      _version = '${packageInfo.version}+${packageInfo.buildNumber}'; 
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text("From Ijul for RR "),
          const Icon(Icons.favorite),
          Text("App Version: $_version")
        ],
      ),
    );
  }
}