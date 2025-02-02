import 'dart:io';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/video.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this line

class TakePictureScreen1 extends StatefulWidget {
  final String epid_number;

  const TakePictureScreen1({
    super.key,
    required this.epid_number,
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen1>
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
    _checkAndRequestPermission();
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

  Future<void> _checkAndRequestPermission() async {
    if (await Permission.camera.isGranted) {
      _initializeCamera();
    } else {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        _initializeCamera();
      } else {
        setState(() {
          _isCameraInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to use this feature.'),
          ),
        );
      }
    }
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
      print('Error initializing camera: $e');
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
    if (_isCameraInitialized) {
      _controller.dispose();
    }
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

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final String epid_number;
  final String languge;

  const DisplayPictureScreen({
    super.key,
    required this.epid_number,
    required this.languge,
    required this.imagePath,
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool _isImageLoaded = false;
  double _imageScale = 1.0;
  String? _errorMessage;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      _imageFile = File(widget.imagePath);
      if (await _imageFile!.exists()) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _isImageLoaded = true;
        });
      } else {
        _errorMessage = 'Image file not found.';
        setState(() {});
      }
    } on PlatformException catch (e) {
      _errorMessage = 'Error loading image: $e';
      setState(() {});
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while loading the image.';
      setState(() {});
    }
  }

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.languge == "Amharic" ? 'አረጋግጥ' : 'Confirmation'),
          content: Text(widget.languge == "Amharic"
              ? 'እባክዎን ጥራት ያለው እና ያልደበዘዘ ቪዲዮ ይቅረጹ። ቪዲዮው ከተደበዘዘ እንደገና ይጠየቃሉ።'
              : widget.languge == "AfanOromo"
                  ? 'Odeeffannoon barbaachisu akka hin dhabamnetti suura qulqullina qabu kaasaa. '
                  : 'Please capture a quality and unblurred video. If the video is blurred, you will be requested again.'),
          actions: <Widget>[
            TextButton(
              child: Text(widget.languge == "Amharic" ? 'አጥፋ' : 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(widget.languge == "Amharic" ? 'እሽ' : 'ok'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
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
          title:
              Text(widget.languge == "Amharic" ? 'ምስሉን እይ' : 'Preview Image'),
          backgroundColor: CustomColors.testColor1,
          centerTitle: true,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (_errorMessage == null && !_isImageLoaded)
                const Center(child: CircularProgressIndicator()),
              AnimatedOpacity(
                opacity: _isImageLoaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Container(
                      // height: double.infinity,
                      child: Image.file(File(widget.imagePath)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _isImageLoaded
                            ? () {
                                _showConfirmationDialog(context, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          TakeMediaScreen(
                                        imagePath: widget.imagePath,
                                        epid_number: widget.epid_number,
                                      ),
                                    ),
                                  );
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: _isImageLoaded
                              ? CustomColors.testColor1
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 16,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          widget.languge == "Amharic" ? 'ቀጣይ' : 'Next',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
