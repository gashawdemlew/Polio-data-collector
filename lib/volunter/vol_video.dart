import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera_app/ReviewPage.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/qrcode_example.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolTakeMediaScreen extends StatefulWidget {
  final String imagePath;
  final String gender;

  final String phonNo;

  final String first_name;
  final String last_name;
  final String region;
  final String zone;
  final String woreda;
  final String lat;
  final String long;
  final String selected_health_officer;
  // final String epid_number;

  VolTakeMediaScreen({
    // required this.epid_number,
    required this.imagePath,
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
  _TakeMediaScreenState createState() => _TakeMediaScreenState();
}

class _TakeMediaScreenState extends State<VolTakeMediaScreen>
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
          builder: (BuildContext context) => DisplayVideoScreen1(
              videoPath: video.path,
              imagePath: widget.imagePath,
              first_name: widget.first_name,
              last_name: widget.last_name,
              region: widget.region,
              zone: widget.zone,
              woreda: widget.woreda,
              gender: widget.gender,
              phonNo: widget.phonNo,
              lat: widget.lat,
              long: widget.long,
              selected_health_officer: widget.selected_health_officer

              // epid_number: widget.epid_number,
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
              : Center(child: CircularProgressIndicator()),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
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
                            child: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            formatTime(_elapsedSeconds),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          ElevatedButton(
                            onPressed: _stopRecording,
                            child: Text('Stop Recording'),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _startRecording,
                        child: Text('Start Recording'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayVideoScreen1 extends StatefulWidget {
  final String imagePath;
  final String videoPath;
  final String phonNo;
  final String gender;

  final String first_name;
  final String last_name;
  final String region;
  final String zone;
  final String woreda;
  final String lat;
  final String long;
  final String selected_health_officer;
  // final String epid_number;

  DisplayVideoScreen1({
    required this.videoPath,
    // required this.epid_number,
    required this.imagePath,
    required this.gender,
    required this.phonNo,
    required this.first_name,
    required this.last_name,
    required this.region,
    required this.zone,
    required this.woreda,
    required this.lat,
    required this.long,
    required this.selected_health_officer,
  });

  @override
  _DisplayVideoScreenState createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen1> {
  bool isSaving = false;
  bool showMessage = false; // New state variable to control message visibility
  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

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
      };
    });
  }

  Future<void> postClinicalData(BuildContext context) async {
    setState(() {
      isSaving = true;
      showMessage = true; // Show message when the saving starts
    });

    // Timer to hide the message after 15 seconds
    Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          showMessage = false;
        });
      }
    });

    final url = '${baseUrl}clinic/upload';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Content-Type'] = 'multipart/form-data';

    // Adding JSON fields
    request.fields.addAll({
      "first_name": widget.first_name,
      "last_name": widget.last_name,
      "hofficer_name": widget.selected_health_officer,
      'region': widget.region,
      'woreda': widget.woreda,
      'zone': widget.zone,
      'gender': widget.gender,
      'phonNo': widget.phonNo
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

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data submitted successfully')),
      );

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => PolioDashboard(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post data: ${response.statusCode}')),
      );
    }

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video And Image'),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Column(
        children: [
          if (showMessage)
            Container(
              width: double.infinity,
              color: Colors.orangeAccent,
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Please wait to upload video and image",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 20), // Add some spacing below the message
          Center(
            child: ElevatedButton(
              onPressed: isSaving ? null : () => postClinicalData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.testColor1,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: isSaving
                  ? SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        color: Colors.white,
                      ),
                    )
                  : Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
