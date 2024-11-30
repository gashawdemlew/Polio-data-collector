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
    _requestCameraPermission();
    _loadUserInfo();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Permission granted, proceed with camera functionality
      debugPrint('Camera permission granted');
    } else if (status.isDenied) {
      // Permission denied, show a message to the user
      debugPrint('Camera permission denied');
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      await openAppSettings();
    }
  }

  _loadUserInfo() async {
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
      home: email.isEmpty ? LoginPage() : MainPage(),
    );
  }
}
