import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

final directoryProvider = StateProvider<String?>((ref) => null);

Future<void> pickDirectory(WidgetRef ref) async {
  String? directoryPath = await FilePicker.platform.getDirectoryPath();
  if (directoryPath != null) {
    ref.read(directoryProvider.notifier).state = directoryPath;
  } else {
    ref.read(directoryProvider.notifier).state =
        null; // Set state to null if no directory is selected
  }
}
