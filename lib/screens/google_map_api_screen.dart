import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_task/providers/api_key_provider.dart';
import 'package:test_task/utils/google_map_api_widgts.dart';

class GoogleMapsApiScreen extends ConsumerStatefulWidget {
  final String projectPath;

  GoogleMapsApiScreen({required this.projectPath, Key? key}) : super(key: key);

  @override
  _GoogleMapsApiScreenState createState() => _GoogleMapsApiScreenState();
}

class _GoogleMapsApiScreenState extends ConsumerState<GoogleMapsApiScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isConfigured = false;

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(apiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: Text("API Key Configuration")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                _isConfigured
                    ? '✅ Configuration completed successfully'
                    : 'Enter Google Maps API Key',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (!_isConfigured)
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.vpn_key, color: Colors.blueAccent),
                  ),
                ),
              SizedBox(height: 20),
              if (!_isConfigured)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () async {
                    String enteredApiKey = _apiKeyController.text.trim();
                    if (widget.projectPath.isNotEmpty) {
                      await ref
                          .read(apiKeyProvider.notifier)
                          .saveApiKey(enteredApiKey, widget.projectPath);

                      addGoogleMapToMain(widget.projectPath);
                      print(widget.projectPath);

                      setState(() {
                        _isConfigured = true; // Operation successful
                      });

                      _apiKeyController.clear();
                    } else {
                      print('No directory selected.');
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '✅ API Key configured and Google Map added!')),
                    );
                  },
                  child: Text('Save API Key',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              SizedBox(height: 20),
              if (_isConfigured)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Return to the main screen
                  },
                  child: Text('Return to Main Screen',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
