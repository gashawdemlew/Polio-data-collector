import 'dart:io';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/video.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this line

class TakePictureScreen extends StatefulWidget {
  final String epid_number;

  const TakePictureScreen({
    super.key,
    required this.epid_number,
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
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
    _loadUserDetails();
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
  }

  Map<String, dynamic> userDetails = {};
  String languge = '';
  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'userType': prefs.getString('userType') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
        'zone': prefs.getString('zone') ?? 'N/A',
        'woreda': prefs.getString('woreda') ?? 'N/A',
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
    });

    setState(() {
      languge = userDetails['selectedLanguage'];
    });
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DisplayPictureScreen(
            imagePath: imagePath,
            languge: languge,
            epid_number: widget.epid_number,
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
        title: Text(
          languge == "Amharic" ? 'ፎቶ አንሳ' : 'Take Picture',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
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
                              child: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String epid_number;
  final String languge;

  const DisplayPictureScreen({
    super.key,
    required this.epid_number,
    required this.languge,
    required this.imagePath,
  });

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languge == "Amharic" ? 'አረጋግጥ' : 'Confirmation'),
          content: Text(languge == "Amharic"
              ? 'እባክዎን ጥራት ያለው እና ያልደበዘዘ ቪዲዮ ይቅረጹ። ቪዲዮው ከተደበዘዘ እንደገና ይጠየቃሉ።'
              : languge == "AfanOromo"
                  ? 'Odeeffannoon barbaachisu akka hin dhabamnetti suura qulqullina qabu kaasaa. '
                  : 'Please capture a quality and unblurred video. If the video is blurred, you will be requested again.'),
          actions: <Widget>[
            TextButton(
              child: Text(languge == "Amharic" ? 'አጥፋ' : 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
            TextButton(
              child: Text(languge == "Amharic" ? 'እሽ' : 'ok'),
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
        title: Text(languge == "Amharic" ? 'ምስሉን እይ' : 'Preview Image'),
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
                      builder: (BuildContext context) => TakeMediaScreen(
                        imagePath: imagePath,
                        epid_number: epid_number,
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
              child: Text(languge == "Amharic" ? 'ቀጣይ' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
