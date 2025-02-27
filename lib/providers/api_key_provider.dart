import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path/path.dart';

final apiKeyProvider =
    StateNotifierProvider<ApiKeyNotifier, String?>((ref) => ApiKeyNotifier());

class ApiKeyNotifier extends StateNotifier<String?> {
  ApiKeyNotifier() : super(null);

  Future<void> saveApiKey(String apiKey, String projectPath) async {
    if (apiKey.isEmpty) {
      print('API Key cannot be empty');
      return;
    }
    state = apiKey;

    // Update Android and iOS configurations concurrently with the project path
    await Future.wait([
      _updateAndroidManifest(apiKey, projectPath),
      _updateInfoPlist(apiKey, projectPath), // Replaced _updateIOSDelegate
    ]);

    print('API Key saved successfully for both platforms');
  }

  Future<void> _updateAndroidManifest(String apiKey, String projectPath) async {
    final manifestPath =
        join(projectPath, "android/app/src/main/AndroidManifest.xml");
    final file = File(manifestPath);

    if (!file.existsSync()) {
      print("❌ AndroidManifest.xml not found at $manifestPath!");
      return;
    }

    try {
      String content = await file.readAsString();

      // Define the location permissions
      final permissionFine =
          '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>';
      final permissionCoarse =
          '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>';

      // Remove existing permissions if they are already present
      content = content
          .replaceAll(permissionFine, '')
          .replaceAll(permissionCoarse, '');

      // Ensure the permissions are added right after the <manifest> tag
      int manifestTagIndex = content.indexOf('<manifest');
      if (manifestTagIndex != -1) {
        int manifestTagEndIndex = content.indexOf('>', manifestTagIndex) + 1;

        // Insert permissions just after <manifest> if they were removed
        content = content.substring(0, manifestTagEndIndex) +
            '\n' +
            permissionFine +
            '\n' +
            permissionCoarse +
            content.substring(manifestTagEndIndex);
      } else {
        print("❌ No <manifest> tag found in AndroidManifest.xml.");
        return;
      }

      // Replace or add the API key in AndroidManifest.xml
      final apiKeyPattern = RegExp(
          r'<meta-data android:name="com.google.android.geo.API_KEY" android:value="(.*?)"/>');

      String updatedContent = content.replaceAll(apiKeyPattern,
          '<meta-data android:name="com.google.android.geo.API_KEY" android:value="$apiKey"/>');

      // If no API key was found, add the new one before the </application> tag
      if (!content.contains(apiKeyPattern)) {
        updatedContent = updatedContent.replaceFirst("</application>",
            '<meta-data android:name="com.google.android.geo.API_KEY" android:value="$apiKey"/>\n</application>');
      }

      // Write the updated content back to the file
      await file.writeAsString(updatedContent);
      print(
          '✅ AndroidManifest.xml updated successfully with the new API Key and permissions.');
    } catch (e) {
      print("❌ Error updating AndroidManifest.xml: $e");
    }
  }

  Future<void> _updateInfoPlist(String apiKey, String projectPath) async {
    final plistPath = join(projectPath, "ios/Runner/Info.plist");
    final file = File(plistPath);

    if (!file.existsSync()) {
      print("Info.plist not found at $plistPath!");
      return;
    }

    try {
      String content = await file.readAsString();

      if (content.contains("<key>GMSApiKey</key>")) {
        // Replace the existing key value
        content = content.replaceAll(
            RegExp(r'<key>GMSApiKey</key>\s*<string>.*?</string>'),
            '<key>GMSApiKey</key>\n\t<string>$apiKey</string>');
      } else {
        // Add the new key if it doesn't exist
        content = content.replaceFirst("</dict>",
            '\t<key>GMSApiKey</key>\n\t<string>$apiKey</string>\n</dict>');
      }

      // Add location usage descriptions for iOS
      final locationUsage = '''
      <key>NSLocationWhenInUseUsageDescription</key>
      <string>We need your location for map functionality</string>
      <key>NSLocationAlwaysUsageDescription</key>
      <string>We need your location for map functionality</string>
      ''';

      if (!content.contains(locationUsage)) {
        content = content.replaceFirst("</dict>", '$locationUsage\n</dict>');
      }

      await file.writeAsString(content);
      print(
          'Info.plist updated successfully with the new API Key and location permissions.');
    } catch (e) {
      print("Error updating Info.plist: $e");
    }
  }
}
