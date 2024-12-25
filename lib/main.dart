import 'package:camera_app/home.dart';
import 'package:camera_app/image.dart';
import 'package:camera_app/kk.dart';
import 'package:camera_app/login.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/qrcode_example.dart';
import 'package:camera_app/sms.dart';
import 'package:camera_app/sqflite/database_helper.dart';
import 'package:camera_app/video.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String userType = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadUserInfo();
  }

  Future<void> _checkPermissionsAndLoadUserInfo() async {
    await _requestCameraPermission();
    _loadUserInfo();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      // Permission already granted
      debugPrint('Camera permission already granted');
      return;
    }

    if (status.isDenied) {
      // Request permission if it was denied
      final requestStatus = await Permission.camera.request();
      handlePermissionStatus(requestStatus);
    } else if (status.isPermanentlyDenied) {
      // Open settings dialog for permanently denied permissions
      _showPermissionSettingsDialog();
    }
  }

  void handlePermissionStatus(PermissionStatus status) {
    if (status.isGranted) {
      debugPrint('Camera permission granted');
    } else if (status.isDenied) {
      debugPrint('Camera permission denied');
      _showPermissionDeniedDialog();
    } else if (status.isPermanentlyDenied) {
      debugPrint('Camera permission permanently denied');
      _showPermissionSettingsDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Camera access is required for this feature. Please allow camera access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Camera access is permanently denied. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: email.isEmpty ? const LoginPage() : MainPage(),
    );
  }
}
