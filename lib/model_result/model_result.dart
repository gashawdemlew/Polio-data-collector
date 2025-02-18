import 'dart:io';

import 'package:camera_app/color.dart';
import 'package:camera_app/commite/list_petients.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MidelResult extends StatefulWidget {
  final String epidNumber;
  final String imagePath;

  const MidelResult(
      {Key? key, required this.epidNumber, required this.imagePath})
      : super(key: key);

  @override
  State<MidelResult> createState() => _EpidDataPageState();
}

class _EpidDataPageState extends State<MidelResult> {
  late Future<Map<String, dynamic>> _dataFuture;
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedResult = 'Positive';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _dataFuture = fetchEpidData(widget.epidNumber);
  }

  Future<Map<String, dynamic>> fetchEpidData(String epidNumber) async {
    final encodedEpidNumber = Uri.encodeComponent(epidNumber);
    final url =
        Uri.parse('${baseUrl}clinic/getDataFormodels/$encodedEpidNumber');

    print(url);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Map<String, dynamic> userDetails = {};

  String xx = "";
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
      xx = userDetails['selectedLanguage'];
    });
  }

  Future<Map<String, String>> getSharedPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve values, using an empty string if they are null
    String last_name = prefs.getString('last_name') ?? '';
    String first_name = prefs.getString('first_name') ?? '';

    return {
      'phone_no': prefs.getString('phoneNo') ?? '',
      'full_name': "$first_name $last_name"
          .trim(), // Trim to avoid leading/trailing spaces
      'user_id':
          (prefs.getInt('id')?.toString() ?? ''), // Convert int to String
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            xx == "Amharic"
                ? 'የሞዴል ውጤቶችን ይመልከቱ'
                : xx == "AfanOromo"
                    ? 'Bu’aa moodelaa ilaali'
                    : 'View Model Results',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.testColor1, Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: 26),
              onPressed: () {
                // Implement notification functionality
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.people_alt, size: 26),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ),
                );
              },
              color: Colors.white,
            ),
            SizedBox(width: 10), // Add spacing for better alignment
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final sharedPrefsData = snapshot.data!;

            return EpidDataDisplay(
              imagePath: widget.imagePath,
              epidNumber: widget.epidNumber,
              data: data,
              onEdit: () async {
                final sharedPrefsData = await getSharedPreferencesData();
                // _showEditModal(context, sharedPrefsData);
              },
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}

class EpidDataDisplay extends StatefulWidget {
  final Map<String, dynamic> data;
  final String imagePath;
  final VoidCallback onEdit;
  final String epidNumber;

  const EpidDataDisplay({
    Key? key,
    required this.data,
    required this.onEdit,
    required this.imagePath,
    required this.epidNumber,
  }) : super(key: key);

  @override
  _EpidDataDisplayState createState() => _EpidDataDisplayState();
}

class _EpidDataDisplayState extends State<EpidDataDisplay> {
  Map<String, dynamic>? apiData;
  bool isLoading = true;
  String? errorMessage;

  bool isSubmitting = false;
  Map<String, dynamic>? apiResponse;

  String? _filePath;
  String? _fileName;
  bool _isLoading = false;
  String? _errorMessage;
  String? _apiResponse;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    uploadImage();
    _loadUserDetails();
    fetchEpidData();
  }
  // Map<String, dynamic>? _apiResponse;

  String _responseMessage = '';
  bool _isUploading = false;
  Map<String, dynamic>? _responseData;
  Map<String, dynamic>? _responseData1;

  String message = "";
  String suspected = "";
  String confidence_interval = "";

  String message1 = "";
  String prediction = "";
  String confidence_interval1 = "";

  Future<void> uploadImage() async {
    final String url =
        'https://polio-image-classification-api.vercel.app/polio_classification';

    File imageFile = File(widget.imagePath);
    if (!await imageFile.exists()) {
      setState(() {
        _responseMessage =
            "Error: The file '${widget.imagePath}' does not exist.";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _responseMessage = '';
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'input_image',
          widget.imagePath,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        setState(() {
          _responseData = json.decode(responseData.body);

          _responseMessage = "Output: ${responseData.body}";
        });

        print("XXXXXXXXXXXXXXXXXXX ${_responseData}");
        print("prediction ${_responseData!['prediction']}");
        print("confidence_interval ${_responseData!['confidence_interval']}");
        print("message ${_responseData!['message']}");
      } else {
        setState(() {
          _responseMessage =
              "Error: ${response.statusCode} ${response.reasonPhrase}";

          suspected = _responseData!['suspected'];
          confidence_interval = _responseData!['prediction'];
          message = _responseData!['message'];
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> postData() async {
    final url = Uri.parse(
        "${baseUrl}ModelRoute/data"); // Replace with your API endpoint

    // Sample data to be sent in the POST request
    final Map<String, dynamic> data = {
      "epid_number": widget.epidNumber,
      'message': message,
      'suspected': suspected,
      "confidence_interval": confidence_interval1,
      'message1': message1,
      'suspected1': prediction,
      "confidence_interval1": confidence_interval1
    };
    print(data);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set the content type
        },
        body: jsonEncode(data), // Convert map to JSON
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> postToApi(Map<String, dynamic> results) async {
    setState(() {
      isSubmitting = true;
      apiResponse = null;
    });

    try {
      final String region =
          results['Patient Demography']['region']?.toString() ?? "";
      final String gender =
          results['Patient Demography']['gender']?.toString() ?? "";
      final String birthOfPlace =
          results['Patient Demography']['birth_of_place']?.toString() ?? "";
      final String totalOpvDoses =
          results['Clinical History']['total_opv_doses']?.toString() ?? "0";
      final String temperature =
          results['Environment Info']['tempreture']?.toString() ?? "0";
      final String rainfall =
          results['Environment Info']['rainfall']?.toString() ?? "0";
      final String humidity =
          results['Environment Info']['humidity']?.toString() ?? "0";

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
      print('API Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        _responseData1 = json.decode(response.body);

        try {
          setState(() {
            apiResponse = json.decode(response.body);
            message1 = _responseData1!['prediction'] ?? "";

            prediction = _responseData1!['suspected'] ?? "";
            double confidence_interval1 = double.tryParse(
                    _responseData1!['confidence_interval']?.toString() ?? "") ??
                0.0;
          });
        } catch (e) {
          setState(() {
            apiResponse = {"message": "Invalid Json Format : $e"};
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
        });
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() {
        apiResponse = {"message": "An error occurred: $e"};
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

  Future<void> fetchEpidData() async {
    final String endpoint = "clinic/getAllMultimedia";
    final String baseUrl = "https://testgithub.polioantenna.org/api/v1/";

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint?epid_number=${widget.epidNumber}'),
      );

      print('$baseUrl$endpoint?epid_number=${widget.epidNumber}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          setState(() {
            apiData = data.first;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No data found for this EPID Number.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Error: ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "An error occurred: $error";
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> userDetails = {};

  String xx = "";
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
      xx = userDetails['selectedLanguage'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // Text(apiResponse.toString()),

        if (_isUploading) CircularProgressIndicator(),
        SizedBox(height: 20),

        // Text(_responseData['message']??""),

        Text(_responseMessage),
        // Text(widget.imagePath),
        isSubmitting
            ? const CircularProgressIndicator()
            : apiResponse != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildResultTitle(),
                      const SizedBox(height: 20),
                      if (apiResponse != null)
                        buildApiResponseDisplay(apiResponse!),
                      const SizedBox(height: 16),
                      const SizedBox(height: 8),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      postToApi(widget.data['results']);
                      // uploadImage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "Fech MethrologyModel",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            await postData(); // Make sure postData is async if it involves a future
            // Optionally you can uncomment this if you're uploading an image
            // await uploadImage();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainPage()), // Replace MainPage() with your actual main page widget
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Save To Db",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildResultTitle() {
    return Text(
      xx == "Amharic"
          ? 'የምላሽ ውጤት'
          : xx == "AfanOromo"
              ? 'Bu’aa duubdeebii'
              : 'Response Result',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Colors.deepPurple[600],
        letterSpacing: 1.8,
        shadows: const [
          Shadow(
            offset: Offset(3.0, 3.0),
            blurRadius: 4.0,
            color: Colors.black26,
          ),
        ],
        decoration: TextDecoration.underline,
        decorationColor: Colors.deepPurple[200],
        decorationThickness: 2,
      ),
    );
  }

  Widget buildApiResponseDisplay(Map<String, dynamic> response) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildResponseRow("Prediction:", response["prediction"] ?? "N/A",
              icon: Icons.analytics),
          buildResponseRow(
              "Confidence:", "${response["confidence_interval"] ?? "N/A"}%",
              icon: Icons.thumb_up),
          const SizedBox(
            height: 8,
          ),
          buildResponseRow("Message:", response["message"] ?? "N/A",
              icon: Icons.info),
        ],
      ),
    );
  }

  Widget buildResponseRow(String title, String value, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, color: Colors.grey[700], size: 20),
          ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
