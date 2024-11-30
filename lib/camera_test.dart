import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();

    final directory = await getTemporaryDirectory();
    final path = join(directory.path, '${DateTime.now()}.png');

    await image.saveTo(path);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlurImageScreen(imagePath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: _controller == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }
}

class BlurImageScreen extends StatefulWidget {
  final String imagePath;

  const BlurImageScreen({required this.imagePath});

  @override
  _BlurImageScreenState createState() => _BlurImageScreenState();
}

class _BlurImageScreenState extends State<BlurImageScreen> {
  late ui.Image _image;
  bool _isLoading = true;
  List<Rect> _blurAreas = [];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await File(widget.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _isLoading = false;
    });
  }

  void _addBlurArea(Offset start, Offset end) {
    setState(() {
      _blurAreas.add(Rect.fromPoints(start, end));
    });
  }

  Future<void> _saveBlurredImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint();

    // Draw the original image
    canvas.drawImage(_image, Offset.zero, paint);

    // Apply blur to defined areas
    for (var rect in _blurAreas) {
      paint
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10)
        ..blendMode = BlendMode.srcOver;

      canvas.drawRect(rect, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(_image.width, _image.height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    final directory = await getTemporaryDirectory();
    final path = join(directory.path, 'blurred_${DateTime.now()}.png');
    final file = File(path);
    await file.writeAsBytes(data!.buffer.asUint8List());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blurred image saved to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blur Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveBlurredImage,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onPanStart: (details) {
                _addBlurArea(details.localPosition, details.localPosition);
              },
              onPanUpdate: (details) {
                setState(() {
                  final lastRect = _blurAreas.removeLast();
                  _addBlurArea(lastRect.topLeft, details.localPosition);
                });
              },
              child: CustomPaint(
                painter: BlurPainter(_image, _blurAreas),
                child: Container(),
              ),
            ),
    );
  }
}

class BlurPainter extends CustomPainter {
  final ui.Image image;
  final List<Rect> blurAreas;

  BlurPainter(this.image, this.blurAreas);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Scale image to fit the canvas
    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, srcRect, dstRect, paint);

    // Apply blur to blur areas
    for (var rect in blurAreas) {
      paint
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10)
        ..blendMode = BlendMode.srcOver;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(BlurPainter oldDelegate) => true;
}
