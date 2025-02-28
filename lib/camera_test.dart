import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/image.dart';
import 'package:camera_app/util/color/color.dart';
import 'package:camera_app/video.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Constants for better code maintainability.
const double _blurSigma = 10.0; // Standard blur radius
const double _initialRectSize = 20.0;

class TakePictureScreen extends StatefulWidget {
  final String epid_number;

  const TakePictureScreen({
    super.key,
    required this.epid_number,
  });

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  Future<void>? _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _loadUserDetails();
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // Handle the app going inactive (e.g., user switched to another app)
      _cameraController?.dispose();
      setState(() {
        _isCameraInitialized = false;
        _isLoading = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera when the app is resumed
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showErrorSnackBar("No camera found.");
        setState(() => _isLoading = false);
        return;
      }
      _startCameraController(_cameras![_selectedCameraIndex]);
    } catch (e) {
      _showErrorSnackBar("Failed to initialize camera: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startCameraController(
      CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!
          .dispose(); // Ensure the previous controller is disposed
    }
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    _initializeControllerFuture = _cameraController!.initialize();
    _initializeControllerFuture!.then((_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isCameraInitialized = true;
      });
    });
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _isLoading) return;

    try {
      final image = await _cameraController!.takePicture();
      final directory = await getTemporaryDirectory();
      final path = join(directory.path, '${DateTime.now()}.jpg');

      await image.saveTo(path);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlurImageScreen(
              imagePath: path,
              epid_number: widget.epid_number,
            ),
          ),
        );
      }
    } on CameraException catch (e) {
      _showErrorSnackBar("Error taking picture: $e");
    } catch (e) {
      _showErrorSnackBar("An unexpected error occurred: $e");
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: languge == "Amharic"
              ? "ካሜራ"
              : languge == "AfanOromo"
                  ? "kaameraa"
                  : "Camera"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _takePicture,
        child: const Icon(Icons.camera, color: Colors.white),
      ),
    );
  }
}

class BlurImageScreen extends StatefulWidget {
  final String imagePath;
  final String epid_number;
  // final String language;
  const BlurImageScreen({
    required this.imagePath,
    required this.epid_number,
    // required this.language
  });

  @override
  _BlurImageScreenState createState() => _BlurImageScreenState();
}

class _BlurImageScreenState extends State<BlurImageScreen> {
  ui.Image? _image;
  bool _isLoading = true;
  List<Rect> _blurAreas = [];
  double _scaleX = 1.0;
  double _scaleY = 1.0;
  late Size _imageSize;
  Offset? _startPoint;
  late double offsetX;
  late double offsetY;
  bool isFirstFrame = true; // to prevent multiple loads at start

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadImage();
  }

  // Loads the image and handles any errors
  Future<void> _loadImage() async {
    try {
      final data = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _image = frame.image;
          _imageSize =
              Size(_image!.width.toDouble(), _image!.height.toDouble());
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Failed to load image: $e");
        setState(() => _isLoading = false);
      }
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

  // Calculate the scaling factors for the image
  void _updateScale(Size canvasSize) {
    if (_image == null) return; // Prevents potential null errors

    final imageWidth = _image!.width.toDouble();
    final imageHeight = _image!.height.toDouble();

    _scaleX = canvasSize.width / imageWidth;
    _scaleY = canvasSize.height / imageHeight;

    final scale = _scaleX < _scaleY ? _scaleX : _scaleY;

    _scaleX = scale;
    _scaleY = scale;
    final scaledWidth = imageWidth * _scaleX;
    final scaledHeight = imageHeight * _scaleY;
    offsetX = (canvasSize.width - scaledWidth) / 2;
    offsetY = (canvasSize.height - scaledHeight) / 2;
  }

  // Adds a new blur area to the list of blur areas
  void _addBlurArea(Offset start, Offset end) {
    if (_image == null) return; // Prevents potential null errors
    final startX = start.dx / _scaleX;
    final startY = start.dy / _scaleY;
    final endX = end.dx / _scaleX;
    final endY = end.dy / _scaleY;

    if (mounted) {
      setState(() {
        _blurAreas
            .add(Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)));
      });
    }
  }

  // Saves the blurred image to disk
  Future<void> _saveBlurredImage() async {
    if (_image == null) return; // Avoid rendering when there's no image
    setState(() {
      _isLoading = true; // Show loader while saving
    });
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      canvas.drawImage(_image!, Offset.zero, paint);

      // Apply blur to defined areas
      for (var rect in _blurAreas) {
        paint
          ..imageFilter =
              ui.ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma)
          ..blendMode = BlendMode.srcOver;

        canvas.drawRect(rect, paint);
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(_image!.width, _image!.height);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);

      if (data == null) {
        _showErrorSnackBar("Error: Unable to save blurred image.");
        setState(() => _isLoading = false); // Hide loader after saving
        return;
      }

      final directory = await getTemporaryDirectory();
      final path = join(directory.path, 'blurred_${DateTime.now()}.jpg');
      final file = File(path);
      await file.writeAsBytes(data.buffer.asUint8List());

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreview(
              imagePath: path,
              epid_number: widget.epid_number,
              languge: languge,
            ),
          ),
        );
      }
      // _showSnackBar('Blurred image saved to $path');
    } catch (e) {
      _showErrorSnackBar("Error processing image: $e");
    } finally {
      if (mounted)
        setState(() => _isLoading = false); // Hide loader after saving
    }
  }

  // Shows a snack bar with the specified message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper to show a snackbar message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: CustomColors.testColor1,
            title: Text(
              languge == "Amharic"
                  ? "ምስልን አደብዝዝ"
                  : languge == "AfanOromo"
                      ? "suuraa jaamsuu"
                      : "Blur Image",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.save), onPressed: _saveBlurredImage)
            ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(builder: (context, constraints) {
                if (isFirstFrame) {
                  _updateScale(constraints.biggest);
                  isFirstFrame = false;
                }

                return GestureDetector(
                    onPanStart: (details) {
                      final startPoint = details.localPosition;
                      _startPoint = startPoint; // Store the start point

                      final start = Offset(startPoint.dx - _initialRectSize / 2,
                          startPoint.dy - _initialRectSize / 2);
                      final end = Offset(startPoint.dx + _initialRectSize / 2,
                          startPoint.dy + _initialRectSize / 2);

                      _addBlurArea(start, end); // Initial rectangular blur
                    },
                    onPanUpdate: (details) {
                      if (_startPoint != null) {
                        setState(() {
                          _blurAreas.removeLast();
                          _addBlurArea(_startPoint!, details.localPosition);
                        });
                      }
                    },
                    onPanEnd: (details) {
                      _startPoint = null;
                    },
                    child: CustomPaint(
                        painter: BlurPainter(_image!, _blurAreas, _scaleX,
                            _scaleY, offsetX, offsetY),
                        child: Container()));
              }));
  }
}

class BlurPainter extends CustomPainter {
  final ui.Image image;
  final List<Rect> blurAreas;
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;

  BlurPainter(this.image, this.blurAreas, this.scaleX, this.scaleY,
      this.offsetX, this.offsetY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Scale image to fit the canvas
    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

    final scaledWidth = image.width.toDouble() * scaleX;
    final scaledHeight = image.height.toDouble() * scaleY;

    final dstRect = Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledHeight);

    canvas.drawImageRect(image, srcRect, dstRect, paint);

    // Apply blur to blur areas
    for (var rect in blurAreas) {
      final scaledRect = Rect.fromLTRB(
          rect.left * scaleX + offsetX,
          rect.top * scaleY + offsetY,
          rect.right * scaleX + offsetX,
          rect.bottom * scaleY + offsetY);

      paint
        ..imageFilter =
            ui.ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma)
        ..blendMode = BlendMode.srcOver;

      canvas.drawRect(scaledRect, paint);
    }
  }

  @override
  bool shouldRepaint(BlurPainter oldDelegate) => true;
}

class ImagePreview extends StatefulWidget {
  final String imagePath;
  final String languge;
  final String epid_number;

  const ImagePreview({
    Key? key,
    required this.imagePath,
    required this.languge,
    required this.epid_number,
  }) : super(key: key);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  String? _errorMessage;
  String? _apiResponse;
  bool _isLoading = false;

  Future<void> _uploadImage(String imagePath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiResponse = null;
    });

    final String url =
        'https://polio-image-classification-api.vercel.app/polio_classification?epid_number=${widget.epid_number}';

    print("Image path: ${widget.imagePath}");
    File imageFile = File(imagePath);
    print("File exists: ${await imageFile.exists()}");
    if (!await imageFile.exists()) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: The file '$imagePath' does not exist.";
      });
      return;
    }
    // Compress the image
    XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      "${imagePath.substring(0, imagePath.lastIndexOf('.'))}-compressed.jpg",
      quality: 85,
    );
    print("Compressed file path: ${compressedFile?.path}");

    if (compressedFile == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: Could not compress the image.";
      });
      return;
    }
    File compressedImageFile = File(compressedFile.path);
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath(
          'input_image',
          compressedImageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send().timeout(const Duration(seconds: 120));
      print("Response status code: ${response.statusCode}"); // ADD THIS LINE
      print("Response data: ${response}"); // ADD THIS LINE

      var responseData = await http.Response.fromStream(response);
      print("Response data: ${responseData.body}"); // ADD THIS LINE

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var decodedResponse = json.decode(responseData.body);
        setState(() {
          _isLoading = false;
          _apiResponse = decodedResponse.toString();
        });

        _showConfirmationDialog(context, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => TakeMediaScreen(
                imagePath: widget.imagePath,
                epid_number: widget.epid_number,
              ),
            ),
          );
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Error: ${response.statusCode} ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: $e";
      });

      _showConfirmationDialog(context, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => TakeMediaScreen(
              imagePath: widget.imagePath,
              epid_number: widget.epid_number,
            ),
          ),
        );
      });
    }
  }

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.languge == "Amharic"
              ? 'አረጋግጥ'
              : widget.languge == "AfanOromo"
                  ? 'mirkaneeffannaa'
                  : 'Confirmation'),
          content: Text(widget.languge == "Amharic"
              ? 'እባክዎን ጥራት ያለው እና ያልደበዘዘ ቪዲዮ ይቅረጹ። ቪዲዮው ከተደበዘዘ እንደገና ይጠየቃሉ።'
              : widget.languge == "AfanOromo"
                  ? 'Mee viidiyoo qulqullina hin qabne kan waa\'ee dhukkubsataa odeeffannoo barbaachisaa ta\'e osoo hin dhabin qabadhaa'
                  : 'Please capture a quality and unblurred video. If the video is blurred, you will be requested again.'),
          actions: <Widget>[
            TextButton(
              child: Text(widget.languge == "Amharic"
                  ? 'አጥፋ'
                  : widget.languge == "AfanOromo"
                      ? 'Haqi'
                      : 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(widget.languge == "Amharic"
                  ? 'እሽ'
                  : widget.languge == "AfanOromo"
                      ? 'Tole'
                      : 'ok'),
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
      appBar: CustomAppBar(
        title: widget.languge == "Amharic"
            ? "ምስልን አስቀድመው ይመልከቱ"
            : widget.languge == "AfanOromo"
                ? "Suuraa kaafame ilaali"
                : "Preview image",
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(
                            16.0), // Added padding around image
                        alignment: Alignment.center,
                        child: Image.file(File(widget.imagePath)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                          onPressed: () {
                            print("Upload button pressed!"); // ADD THIS LINE
                            _uploadImage(widget.imagePath);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                CustomColors.testColor1, // Set background color
                            foregroundColor: Colors.white, // Set text color
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 5, // Add shadow
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : widget.languge == "AfanOromo"
                                  ? Text('Kan itti aanu')
                                  : widget.languge == "Amharic"
                                      ? Text('ቀጥል')
                                      : Text('Next')),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_apiResponse != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Api Response: $_apiResponse",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    const SizedBox(height: 20), // Added spacing at bottom
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
