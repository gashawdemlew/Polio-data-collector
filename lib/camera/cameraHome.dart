import 'dart:io';

import 'package:camera_app/camera/camera.dart';
import 'package:camera_app/section/custom_camera.dart';
import 'package:camera_app/section/image_page.dart';
import 'package:camera_app/section/video_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class cameraHome extends StatefulWidget {
  const cameraHome({Key? key}) : super(key: key);

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<cameraHome> with WidgetsBindingObserver {
  //rotate BuilderFuture
  int quarterTurns = 0;

  @override
  void initState() {
    checkUserConnection();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    xx();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      quarterTurns = 1;
    }
    return CustomCamera1(
      color: Colors.white70,
      onImageCaptured: (value) async {
        File file = File(value.path);
        final path = value.path;
        if (path.contains('.jpg')) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ImagePage(file: file)));
        }
      },
      onVideoRecorded: (value) async {
        File file = File(value.path);
        final path = value.path;
        if (path.contains('.mp4')) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoPage(filePath: path, file: file)));
        }
      },
    );
  }

//Please capture the image correctly
  void xx() {
    setState(() {
      Fluttertoast.showToast(
        msg: "Please Capture  the image  correctly.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 18.0,
      );
    });
  }

  Future<void> checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          // Fluttertoast.showToast(
          //   msg: "Have internet connection",
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.CENTER,
          //   timeInSecForIosWeb: 2,
          //   backgroundColor: Colors.black54,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
        });
      }
    } on SocketException catch (_) {
      setState(() {
        Fluttertoast.showToast(
          msg:
              "Please connect to the internet to be able to upload to the server",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });
    }
  }
}
