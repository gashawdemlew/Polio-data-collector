import 'package:camera_app/home.dart';
import 'package:camera_app/image.dart';
import 'package:camera_app/kk.dart';
import 'package:camera_app/login.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/qrcode_example.dart';
import 'package:camera_app/sms.dart';
import 'package:camera_app/sqflite/database_helper.dart';
import 'package:camera_app/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera_app/controler/upload_file_server.dart';
import 'home_page.dart';

void main() async {
  runApp(MyApp());
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
    _loadUserInfo();
    // _setupConnectivityListener();
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
      theme: ThemeData(
        canvasColor: Colors.black87,
        highlightColor: Colors.grey,
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: email.isEmpty ? LoginPage() : PolioDashboard(),
    );
  }
}
