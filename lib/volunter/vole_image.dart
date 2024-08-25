import 'dart:async';
import 'dart:io';
import 'package:camera_app/color.dart';
import 'package:camera_app/video.dart';
import 'package:camera_app/volunter/vol_video.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class VolTakePictureScreen extends StatefulWidget {
  // final String epidNumber;
  final String first_name;
  final String last_name;
  final String region;
  final String zone;
  final String woreda;
  final String lat;
  final String long;
  final String selected_health_officer;
  final String gender;

  final String phonNo;

  VolTakePictureScreen({
    // required this.epidNumber,
    required this.first_name,
    required this.last_name,
    required this.region,
    required this.zone,
    required this.woreda,
    required this.lat,
    required this.long,
    required this.phonNo,
    required this.gender,
    required this.selected_health_officer,
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<VolTakePictureScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? cameras;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  Future<void> _initializeCamera() async {
    if (await Permission.camera.request().isGranted) {
      try {
        cameras = await availableCameras();
        _controller = CameraController(
          cameras!.first,
          ResolutionPreset.high,
        );
        _initializeControllerFuture = _controller.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        print(e);
      }
    } else {
      // Handle permission not granted case
      print('Camera permission not granted');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = join(directory.path, '${DateTime.now()}.png');
      await image.saveTo(imagePath);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => DisplayPictureScreen(
            imagePath: imagePath,
            first_name: widget.first_name ?? '',
            last_name: widget.last_name ?? '',
            region: widget.region ?? '',
            zone: widget.zone ?? '',
            woreda: widget.woreda ?? '',
            lat: widget.lat,
            long: widget.long,
            gender: widget.gender,
            phonNo: widget.phonNo,
            selected_health_officer: widget.selected_health_officer ?? '',
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Picture'),
        backgroundColor: CustomColors.testColor1,
      ),
      body: !_isCameraInitialized
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FloatingActionButton(
                            onPressed: _takePicture,
                            backgroundColor: CustomColors.testColor1,
                            child: ScaleTransition(
                              scale: _animation,
                              child: Icon(Icons.camera_alt),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String first_name;
  final String gender;

  final String phonNo;

  final String last_name;
  final String region;
  final String zone;
  final String woreda;
  final String lat;
  final String long;
  final String selected_health_officer;
  // final String epid_number;

  DisplayPictureScreen({
    // required this.epid_number,
    required this.imagePath,
    required this.first_name,
    required this.last_name,
    required this.region,
    required this.zone,
    required this.woreda,
    required this.lat,
    required this.long,
    required this.gender,
    required this.phonNo,
    required this.selected_health_officer,
  });

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Please capture a quality and unblurred video. If the video is blurred, you will be requested again.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
                onConfirm(); // Calls the callback to navigate to TakeMediaScreen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Picture'),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(imagePath)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showConfirmationDialog(context, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => VolTakeMediaScreen(
                          imagePath: imagePath,
                          first_name: first_name,
                          last_name: last_name,
                          region: region,
                          zone: zone,
                          woreda: woreda,
                          lat: lat,
                          long: long,
                          phonNo: phonNo,
                          gender: gender,
                          selected_health_officer: selected_health_officer
                          // epid_number: epid_number,
                          ),
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    CustomColors.testColor1, // Change the text color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust the border radius
                ),
                elevation: 14, // Add elevation
              ),
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
