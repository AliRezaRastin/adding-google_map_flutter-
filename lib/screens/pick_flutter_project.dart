import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_task/providers/loding_provide.dart';

import 'package:test_task/utils/directory_widgetsl.dart';
import 'package:test_task/utils/pick_flutter_project_widgets.dart';

final directoryProvider = StateProvider<String?>((ref) => null);

final isLoadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

class PickFlutterProject extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDirectory = ref.watch(directoryProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Flutter Project Directory"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Container(
          width: 450,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blueGrey, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPickButton(ref, context),
              SizedBox(height: 20),
              buildSelectionBox(selectedDirectory),
              SizedBox(height: 20),
              if (selectedDirectory != null)
                buildLoadingButton(context, ref, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Pick Flutter Project Directory
  Widget _buildPickButton(WidgetRef ref, BuildContext context) {
    return ElevatedButton(
      onPressed: () => pickDirectory(ref, context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, color: Colors.white),
          SizedBox(width: 10),
          Text("Pick a Flutter Project",
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
