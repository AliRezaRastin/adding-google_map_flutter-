import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_task/utils/directory_widgetsl.dart';

/// 🔹 Display the Selected Directory
Widget buildSelectionBox(String? selectedDirectory) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blueAccent, width: 1.5),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
      ],
    ),
    child: Column(
      children: [
        selectedDirectory != null
            ? Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(height: 10),
                  Text("Selected Directory:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(
                    selectedDirectory,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 30),
                  SizedBox(height: 10),
                  Text("No directory selected",
                      style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                ],
              ),
      ],
    ),
  );
}

/// 🔹 Loading Button for Dependency Update
Widget buildLoadingButton(BuildContext context, WidgetRef ref, bool isLoading) {
  return ElevatedButton(
    onPressed: isLoading
        ? null
        : () => pickDirectoryAndUpdate(context, ref), // Disable if loading
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.blue,
      elevation: 5,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          )
        else
          Icon(Icons.refresh, color: Colors.white),
        SizedBox(width: 10),
        Text(isLoading ? "Updating Dependency..." : "Update Dependency",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ],
    ),
  );
}
