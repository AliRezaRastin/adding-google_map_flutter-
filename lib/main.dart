import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_task/screens/pick_flutter_project.dart';

void main() {
  runApp(ProviderScope(child: MaterialApp(home: PickFlutterProject())));
}
