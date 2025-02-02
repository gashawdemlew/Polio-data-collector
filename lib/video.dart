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
import 'package:video_player/video_player.dart';

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
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = join(directory.path, '${DateTime.now()}.mp4');

      // Move or rename the file to the desired location with the `.mp4` extension
      final File newVideoFile = await File(videoFile.path).rename(newPath);

      setState(() {
        _isRecording = false;
        _timer?.cancel();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DisplayVideoScreen(
            videoPath: newVideoFile.path,
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
            bottom: 2,
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
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15), // Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Rounded corners
                              ),
                              elevation: 5, // Shadow elevation
                            ),
                            child: Text(
                              languge == "Amharic"
                                  ? "መቅረጽ አቁም"
                                  : languge == "AfanOromo"
                                      ? "Waraabbii Dhaabi"
                                      : "Stop Recording",
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _startRecording,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green, // Text color
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded corners
                          ),
                          elevation: 5, // Shadow elevation
                        ),
                        child: Text(
                          languge == "Amharic"
                              ? "መቅረጽ ይጀምሩ"
                              : languge == "AfanOromo"
                                  ? "Waraabbii Jalqabi"
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

// import 'package:camera/camera.dart';

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
  String _responseMessage = '';
  bool _isUploading = false;
  Map<String, dynamic>? _responseData;
  Map<String, dynamic>? _responseData1;

  String message = "";
  String suspected = "";
  String confidence_interval = "";

  String message1 = "";
  String prediction1 = "";
  String prediction = "";

  double confidence_interval1 = 0.0;
  bool isSaving = false;
  bool showMessage = false;
  Map<String, dynamic> userDetails = {};
  late VideoPlayerController _videoPlayerController;
  bool _videoInitialized = false;
  double _mediaWidth = 0.0;
  double _mediaHeight = 0.0;
  bool _showFullMedia = false;
  String _selectedMedia = "";
  Map<String, dynamic>? apiData;
  bool isLoading = true;
  String? errorMessage;
  bool isSubmitting = false;
  Map<String, dynamic>? apiResponse;
  // Add a new state to indicate if API call is done and successfull
  bool _apiCallSuccessful = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    //getApiModelData(); // Fetch data right away
  }

  Future<void> _loadInitialData() async {
    await _loadUserDetails();
    await fetchEpidData();
    await getApiModelData(); // Fetch data right away
    await _initializeVideoPlayer();
    _calculateMediaSize();
  }

  void _calculateMediaSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _mediaWidth = screenWidth - 32;
      _mediaHeight = screenWidth - 32;
    });
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoPath.isNotEmpty) {
      _videoPlayerController =
          VideoPlayerController.file(File(widget.videoPath));
      await _videoPlayerController.initialize();
      setState(() {
        _videoInitialized = true;
      });
      _videoPlayerController.setLooping(true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

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

  Future<void> fetchEpidData() async {
    final encodedEpidNumber = Uri.encodeComponent(widget.epid_number);
    final url =
        Uri.parse('${baseUrl}clinic/getDataFormodels/$encodedEpidNumber');

    print(url);

    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      jsonDecode(response.body);
      setState(() {
        apiData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> getApiModelData() async {
    setState(() {
      isSubmitting = true;
      apiResponse = null;
      _responseData1 = null; // Reset the response data
      _apiCallSuccessful = false; // Reset the api call status
    });

    try {
      if (apiData == null) {
        setState(() {
          apiResponse = {"message": "Error: apiData not found"};
        });
        print("Error: apiData not found");
        return;
      }
      final String region =
          apiData!['results']['Patient Demography']['region']?.toString() ?? "";
      final String gender =
          apiData!['results']['Patient Demography']['gender']?.toString() ?? "";
      final String birthOfPlace = apiData!['results']['Patient Demography']
                  ['birth_of_place']
              ?.toString() ??
          "";
      final String totalOpvDoses = apiData!['results']['Clinical History']
                  ['total_opv_doses']
              ?.toString() ??
          "0";
      final String temperature =
          apiData!['results']['Environment Info']['tempreture']?.toString() ??
              "0";
      final String rainfall =
          apiData!['results']['Environment Info']['rainfall']?.toString() ??
              "0";
      final String humidity =
          apiData!['results']['Environment Info']['humidity']?.toString() ??
              "0";

      final DateTime currentDate = DateTime.now();
      final int currentYear = currentDate.year;
      final int birthYear =
          int.tryParse(birthOfPlace.split('-').first) ?? currentYear;
      final double ageInYears = (currentYear - birthYear).toDouble();

      String ageGroup;
      if (ageInYears <= 5) {
        ageGroup = "high risk age";
      } else if (ageInYears <= 15) {
        ageGroup = "mid risk age";
      } else {
        ageGroup = "low risk age";
      }
      final inputData = {
        'province': region.toLowerCase(),
        'district': region.toLowerCase(),
        'sex': gender.toLowerCase(),
        'age_in_years': ageInYears,
        'opv_doses': int.tryParse(totalOpvDoses) ?? 0,
        'age_group': ageGroup,
        'temperature_2m_mean': double.tryParse(temperature) ?? 0.0,
        'rain_sum': double.tryParse(rainfall) ?? 0.0,
        'daily_avg_humidity': double.tryParse(humidity) ?? 0.0,
        'month': currentDate.month,
        'season': getSeason(currentDate.month),
      };
      print("API Input: $inputData");
      const String apiUrl =
          "https://gashudemman-poliosuspectedcaseprediction.hf.space/predict";

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(inputData),
          )
          .timeout(const Duration(seconds: 60));
      print('http    Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        _responseData1 = json.decode(response.body);

        try {
          setState(() {
            apiResponse = json.decode(response.body);
            message1 = apiResponse!['message'] ?? "";
            confidence_interval1 =
                apiResponse!['confidence_interval'].toDouble() ?? 0.0;
            prediction1 = apiResponse!['prediction'] ?? "";
            _apiCallSuccessful = true; // set the api call flag to true
          });
        } catch (e) {
          setState(() {
            apiResponse = {"message": "Invalid Json Format : $e"};
            _apiCallSuccessful = false; // set the api call flag to false
          });
          print("JSON decode error: $e");
        }
        print("API Response: ${response.body}");
      } else {
        setState(() {
          apiResponse = {
            "message":
                "Error: ${response.statusCode} - ${response.reasonPhrase}"
          };
          _apiCallSuccessful = false; // set the api call flag to false
        });
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() {
        apiResponse = {"message": "An error occurred: $e"};
        _apiCallSuccessful = false; // set the api call flag to false
      });
      print("An error occurred: $e");
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  String getSeason(int month) {
    if ([12, 1, 2].contains(month)) {
      return "winter";
    } else if ([3, 4, 5].contains(month)) {
      return "spring";
    } else if ([6, 7, 8].contains(month)) {
      return "summer";
    } else {
      return "autumn";
    }
  }

  final String endpoint = "clinic/getAllMultimedia";

  Future<void> postClinicalData(BuildContext context) async {
    setState(() {
      isSaving = true;
      showMessage = true;
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

    request.fields.addAll({
      "epid_number": widget.epid_number,
      "hofficer_name": userDetails['firstName'],
      "hofficer_phonno": userDetails['phoneNo'],
      "message": message1,
      "confidence_interval": confidence_interval1.toString(),
      "prediction": prediction1
    });

    if (widget.imagePath.isNotEmpty) {
      var imageFile = File(widget.imagePath);
      var imageMimeType = lookupMimeType(widget.imagePath) ?? 'image/jpeg';

      print("Additional Data:");
      print("message1: $message1");
      print("confidence_interval: $confidence_interval1");
      print("prediction1: $prediction1");

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(imageMimeType),
      ));
    }

    if (widget.videoPath.isNotEmpty) {
      var videoFile = File(widget.videoPath);
      var videoMimeType = 'video/mp4';

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
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream
            .bytesToString(); // Convert ByteStream to String
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
            builder: (context) => QRCodeScreen(
              languge: languge,
              imagePath: widget.imagePath,
              epid_number: widget.epid_number,
              first_name: firstName ?? "",
              last_name: lastName ?? "",
              region: region ?? "",
              woreda: woreda ?? "",
              zone: zone ?? "",
              hofficer_name: userDetails['firstName'],
              hofficer_phonno: userDetails['phoneNo'],
            ),
          ),
        );

        print('Data posted successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to post data: ${response.statusCode}')),
        );
        print('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print('An error occurred: $e');
    }

    setState(() {
      isSaving = false;
    });
  }

  void _showFullScreenMedia(String mediaType) {
    setState(() {
      _showFullMedia = true;
      _selectedMedia = mediaType;
    });
  }

  void _hideFullScreenMedia() {
    setState(() {
      _showFullMedia = false;
      _selectedMedia = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Display prediction from _responseData1 or a default message
          message1.isNotEmpty ? "Upload Multimedia Info" : 'Loading...',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            // Added for content overflow
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (widget.imagePath.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullScreenMedia("image"),
                      child: Container(
                        width: _mediaWidth,
                        height: _mediaHeight,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional rounded corners
                            border: Border.all(color: Colors.grey)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  if (widget.videoPath.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullScreenMedia("video"),
                      child: SizedBox(
                          width: _mediaWidth,
                          height: _mediaHeight,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Optional rounded corners
                                border: Border.all(color: Colors.grey)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: _videoInitialized
                                    ? VideoPlayer(_videoPlayerController)
                                    : const Center(
                                        child: CircularProgressIndicator()),
                              ),
                            ),
                          )),
                    ),
                  if (widget.videoPath.isNotEmpty && _videoInitialized)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _videoPlayerController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 30.0,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_videoPlayerController.value.isPlaying) {
                                  _videoPlayerController.pause();
                                } else {
                                  _videoPlayerController.play();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.replay, size: 30.0),
                            onPressed: () {
                              _videoPlayerController.seekTo(Duration.zero);
                            },
                          ),
                        ],
                      ),
                    ),
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
                    height: 20,
                  ),
                  Text(
                    // Viidiyoo fi Suuraa Olkaa'aa
                    '$prediction',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: message1 != ""
                          ? isSaving
                              ? null
                              : () => postClinicalData(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: message1 != ""
                            ? CustomColors.testColor1
                            : Colors.grey,
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
            ),
          ),
          if (_showFullMedia)
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideFullScreenMedia,
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  alignment: Alignment.center,
                  child: _selectedMedia == "image"
                      ? Image.file(File(widget.imagePath), fit: BoxFit.contain)
                      : SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController.value.aspectRatio,
                            child: _videoInitialized
                                ? VideoPlayer(_videoPlayerController)
                                : const Center(
                                    child: CircularProgressIndicator()),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
