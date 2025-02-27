import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:test_task/screens/google_map_api_screen.dart';
import 'package:test_task/screens/pick_flutter_project.dart';

/// 🔹 Directory Picker
Future<void> pickDirectory(WidgetRef ref, BuildContext context) async {
  String? directoryPath = await FilePicker.platform.getDirectoryPath();
  if (directoryPath != null) {
    if (isValidFlutterProject(directoryPath)) {
      ref.read(directoryProvider.notifier).state = directoryPath;
      checkAndAddDependency(
          directoryPath); // 🔹 Auto-add Google Maps dependency
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Not a valid Flutter project!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

bool isValidFlutterProject(String path) {
  return File(join(path, 'pubspec.yaml')).existsSync();
}

/// 🔹 Add Dependency and Run flutter pub get
Future<void> checkAndAddDependency(String path) async {
  final file = File(join(path, 'pubspec.yaml'));
  if (!file.existsSync()) return;

  List<String> lines = file.readAsLinesSync();
  int dependenciesIndex = -1;

  // Find the "dependencies:" section in the YAML file
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim() == 'dependencies:') {
      dependenciesIndex = i;
      break;
    }
  }

  if (dependenciesIndex == -1) return;

  // Find the position of the "flutter:" dependency within the "dependencies:" section
  int flutterIndex = -1;
  for (int i = dependenciesIndex + 1; i < lines.length; i++) {
    if (lines[i].trim().startsWith('cupertino_icons:')) {
      flutterIndex = i;
      break;
    }
  }

  if (flutterIndex == -1) return;

  // Add the google_maps_flutter dependency after the flutter section
  bool hasGoogleMapsDependency = false;
  for (int i = flutterIndex + 1; i < lines.length; i++) {
    if (lines[i].trim().startsWith('google_maps_flutter')) {
      hasGoogleMapsDependency = true;
      break;
    }
  }

  if (!hasGoogleMapsDependency) {
    int insertIndex = flutterIndex + 1;
    for (int i = flutterIndex + 1; i < lines.length; i++) {
      if (!lines[i].startsWith(' ')) {
        insertIndex = i;
        break;
      }
    }

    lines.insert(insertIndex, '  google_maps_flutter: ^2.10.1');
    file.writeAsStringSync(lines.join('\n'));
  }
}

Future<void> pickDirectoryAndUpdate(BuildContext context, WidgetRef ref) async {
  final selectedDirectory = ref.read(directoryProvider);

  if (selectedDirectory == null || selectedDirectory.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No project directory selected!")),
    );
    return;
  }

  ref.read(isLoadingProvider.notifier).startLoading();

  try {
    var result = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: selectedDirectory,
      runInShell: true,
    );
    if (result.exitCode == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dependencies updated successfully!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoogleMapsApiScreen(
              projectPath:
                  ref.read(directoryProvider.notifier).state.toString()),
        ),
      ).then((_) {
        ref.read(directoryProvider.notifier).state = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("error: ${result.stderr}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" error process : $e")),
    );
  } finally {
    ref.read(isLoadingProvider.notifier).stopLoading();
  }
}
