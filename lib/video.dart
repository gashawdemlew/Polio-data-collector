import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyVideoApp());

class MyVideoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        hintColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: TakeMediaScreen(),
    );
  }
}

class TakeMediaScreen extends StatefulWidget {
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
          builder: (BuildContext context) =>
              DisplayVideoScreen(videoPath: video.path),
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
      appBar: AppBar(
        title: Text('Capture Video'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controller != null && _controller!.value.isInitialized
                ? Expanded(
                    child: Stack(
                      children: [
                        CameraPreview(_controller!),
                        if (_isRecording)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                formatTime(_elapsedSeconds),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            _isRecording
                ? ElevatedButton(
                    onPressed: _stopRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    child: Icon(Icons.stop, color: Colors.white, size: 30),
                  )
                : ElevatedButton(
                    onPressed: _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    child: ScaleTransition(
                      scale: _animation,
                      child:
                          Icon(Icons.videocam, color: Colors.white, size: 30),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DisplayVideoScreen extends StatelessWidget {
  final String videoPath;

  const DisplayVideoScreen({Key? key, required this.videoPath})
      : super(key: key);

  Future<void> _uploadVideo(File video) async {
    final uri = Uri.parse('http://192.168.75.120:7476/clinic/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['epid_number'] = '12345' // Adjust as necessary
      ..files.add(await http.MultipartFile.fromPath('image', video.path));
    final response = await request.send();

    if (response.statusCode == 201) {
      print(response.toString());
    } else {
      print('Video upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Video'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Video saved at: $videoPath',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _uploadVideo(File(videoPath));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: Text('Send to API', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
