import 'package:camera_app/image.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionCheckScreen extends StatefulWidget {
  final String epid_number;

  const PermissionCheckScreen({super.key, required this.epid_number});

  @override
  _PermissionCheckScreenState createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (await Permission.camera.isGranted) {
      _navigateToTakePictureScreen();
    } else {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        _navigateToTakePictureScreen();
      } else {
        // Handle the case where the permission is not granted
        // You can show an alert or navigate back to the previous screen
      }
    }
  }

  void _navigateToTakePictureScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TakePictureScreen(epid_number: widget.epid_number),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
