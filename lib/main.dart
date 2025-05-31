import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/markdown_screenshot_screen.dart';

void main() {
  runApp(const MarkdownScreenshotApp());
}

class MarkdownScreenshotApp extends StatelessWidget {
  const MarkdownScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Screenshot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PermissionWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return const MarkdownScreenshotScreen();
  }
}