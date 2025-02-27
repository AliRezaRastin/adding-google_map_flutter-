import 'dart:io';

void addGoogleMapToMain(String projectPath) {
  final libPath = Directory('$projectPath/lib');
  final mainFile = File('${libPath.path}/main.dart');

  if (!libPath.existsSync()) {
    print('❌ lib folder not found in the selected path.');
    return;
  }

  if (!mainFile.existsSync()) {
    print('❌ main.dart file not found in the lib folder.');
    return;
  }

  String content = mainFile.readAsStringSync();

  // Check if GoogleMap already exists in main.dart
  if (content.contains('GoogleMap(')) {
    print('✅ GoogleMap code already exists in main.dart.');
    return;
  }

  // Add import if it doesn't exist
  if (!content.contains(
      "import 'package:google_maps_flutter/google_maps_flutter.dart';")) {
    content =
        "import 'package:google_maps_flutter/google_maps_flutter.dart';\n" +
            content;
  }

  // Add GoogleMapWidget if it doesn't exist
  if (!content.contains('class GoogleMapWidget extends StatefulWidget')) {
    content += '''

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _mapController;
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
    zoom: 10,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _initialPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
''';
  }

  // Replace runApp() to use GoogleMapWidget
  if (content.contains('runApp(')) {
    content = content.replaceFirstMapped(
      RegExp(r'runApp\(\s*(const\s+)?(\w+)\s*\(\)\s*\);', multiLine: true),
      (match) {
        print(
            'runApp() replaced successfully: ${match.group(2)} -> GoogleMapWidget');
        return 'runApp(const GoogleMapWidget());';
      },
    );
  } else {
    print('❌ runApp() method not found in main.dart.');
    return;
  }

  // Write the updated content back to the file
  mainFile.writeAsStringSync(content);
  print('✅ GoogleMapWidget successfully replaced MyApp() in runApp().');
}
