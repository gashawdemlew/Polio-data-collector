import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera_app/ReviewPage.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/qrcode_example.dart';
import 'package:camera_app/stool/date_stool.collected.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakeMediaScreen extends StatefulWidget {
  final String imagePath;
  final String epid_number;

  const TakeMediaScreen({
    super.key,
    required this.epid_number,
    required this.imagePath,
  });

  @override
  _TakeMediaScreenState createState() => _TakeMediaScreenState();
}

class _TakeMediaScreenState extends State<TakeMediaScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  late String _videoPath;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _timer;
  int _elapsedSeconds = 0;

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
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
    });

    setState(() {
      languge = userDetails['selectedLanguage'];
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras.first, ResolutionPreset.high);
        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;
        setState(() {});
      } else {
        print('No cameras available');
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null) return;

    try {
      await _initializeControllerFuture;
      final directory = await getApplicationDocumentsDirectory();
      _videoPath = join(directory.path, '${DateTime.now()}.mp4');

      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
        _startTimer();
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= 10) {
          _stopRecording();
        }
      });
    });
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      XFile videoFile = await _controller!.stopVideoRecording();
      final File video = File(videoFile.path);
      setState(() {
        _isRecording = false;
        _timer?.cancel();
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DisplayVideoScreen(
            videoPath: video.path,
            imagePath: widget.imagePath,
            epid_number: widget.epid_number,
          ),
        ),
      );
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatTime(int seconds) {
      final int minutes = seconds ~/ 60;
      final int remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      body: Stack(
        children: [
          _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: 9 / 16, // Fullscreen portrait aspect ratio
                  child: CameraPreview(_controller!),
                )
              : const Center(child: CircularProgressIndicator()),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _isRecording
                    ? Column(
                        children: [
                          FadeTransition(
                            opacity: _animation,
                            child: const Icon(
                              Icons.fiber_manual_record,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            formatTime(_elapsedSeconds),
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                          ElevatedButton(
                            onPressed: _stopRecording,
                            child: Text(
                              languge == "Amharic"
                                  ? "መቅረጽ አቁም"
                                  : "Stop Recording",
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _startRecording,
                        child: Text(
                          languge == "Amharic"
                              ? "መቅረጽ ይጀምሩ"
                              : "Start Recording",
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayVideoScreen extends StatefulWidget {
  final String imagePath;
  final String videoPath;
  final String epid_number;

  const DisplayVideoScreen({
    super.key,
    required this.videoPath,
    required this.epid_number,
    required this.imagePath,
  });

  @override
  _DisplayVideoScreenState createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  bool isSaving = false;
  bool showMessage = false;
  // const { hofficer_name, hofficer_phonno, epid_number } = req.body;
  Map<String, dynamic> userDetails = {};
  @override
  void initState() {
    super.initState();
    // getCurrentLocation();
    _loadUserDetails();
  }

  // Map<String, dynamic> userDetails = {};
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
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
    });

    setState(() {
      languge = userDetails['selectedLanguage'];
    });
  }

  Future<void> postClinicalData(BuildContext context) async {
    setState(() {
      isSaving = true; // Start saving
      showMessage = true; // Show message when the saving starts
    });
    Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          showMessage = false;
        });
      }
    });
    final url = '${baseUrl}clinic/create';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Content-Type'] = 'multipart/form-data';

    // Adding JSON fields
    request.fields.addAll({
      "epid_number": widget.epid_number,
      "hofficer_name": userDetails['firstName'],
      "hofficer_phonno": userDetails['phoneNo']
    });

    // Adding image file
    if (widget.imagePath.isNotEmpty) {
      var imageFile = File(widget.imagePath);
      var imageMimeType = lookupMimeType(widget.imagePath) ?? 'image/jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(imageMimeType),
      ));
    }

    // Adding video file
    if (widget.videoPath.isNotEmpty) {
      var videoFile = File(widget.videoPath);
      var videoMimeType = lookupMimeType(widget.videoPath) ?? 'video/mp4';

      request.files.add(await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
        contentType: MediaType.parse(videoMimeType),
      ));
    }

    var response = await request.send();
    String? firstName;
    String? lastName;
    String? region;

    String? zone;
    String? woreda;
    String? hofficerName;
    String? hofficerPhonno;
    if (response.statusCode == 201) {
      final responseBody =
          await response.stream.bytesToString(); // Convert ByteStream to String
      final responseData =
          json.decode(responseBody); // Decode the response body
      print("KKKKKKKKKKKKKKKKKKKKKKKK$responseData");
      setState(() {
        firstName = responseData['first_name'];
        lastName = responseData['last_name'];

        region = responseData['region'];
        zone = responseData['zone'];

        woreda = responseData['woreda'];
        hofficerPhonno = responseData['hofficer_phonno'];

        hofficerName = responseData['hofficer_name'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data submitted successfully')),
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DateStoolcollected(
              epid_Number: widget.epid_number,
            ),
          ));

      print('Data posted successfully');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post data: ${response.statusCode}')),
      );

      print('Failed to post data: ${response.statusCode}');
    }

    setState(() {
      isSaving = false; // Stop saving
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(languge == "Amharic"
            ? 'Upload Video and  Audio'
            : 'Upload Video and  Audio'),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Column(
        children: [
          if (showMessage)
            Container(
              width: double.infinity,
              color: Colors.orangeAccent,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                languge == "Amharic"
                    ? 'እባክዎን ቪዲዮ እና ምስል ለመምዝገብ ትንሽ ይጠብቁ.'
                    : 'Please wait to upload video and image',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(
            height: 300,
          ),
          Center(
            child: ElevatedButton(
              onPressed: isSaving ? null : () => postClinicalData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.testColor1,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      languge == "Amharic" ? "መዝግብ" : "Upload",
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
