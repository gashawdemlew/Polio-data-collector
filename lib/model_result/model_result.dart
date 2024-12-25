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

class MidelResult extends StatefulWidget {
  final String epidNumber;

  const MidelResult({Key? key, required this.epidNumber}) : super(key: key);

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
            "View Model Data",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
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
  final VoidCallback onEdit;
  final String epidNumber; // Add epid_number to fetch data dynamically

  const EpidDataDisplay({
    Key? key,
    required this.data,
    required this.onEdit,
    required this.epidNumber, // Initialize epid_number
  }) : super(key: key);

  @override
  _EpidDataDisplayState createState() => _EpidDataDisplayState();
}

class _EpidDataDisplayState extends State<EpidDataDisplay> {
  Map<String, dynamic>? apiData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchEpidData(); // Fetch data when the widget initializes
  }

  bool isSubmitting = false;

  Map<String, dynamic>? apiResponse;

  Future<void> postToApi(Map<String, dynamic> results) async {
    setState(() {
      isSubmitting = true;
      apiResponse = null; // Reset the response
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
      print(inputData);
      const String apiUrl =
          "https://gashudemman-poliosuspectedcaseprediction.hf.space/predict";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(inputData),
      );

      if (response.statusCode == 200) {
        setState(() {
          apiResponse = json.decode(response.body);
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Epid Data Display")),
      body: Center(
        child: isSubmitting
            ? const CircularProgressIndicator()
            : apiResponse != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Response Result",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .blueAccent, // Make the text color more vibrant
                          letterSpacing: 1.5, // Add spacing between letters
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0), // Offset for shadow
                              blurRadius: 3.0, // Blur for shadow
                              color: Colors.grey, // Shadow color
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Result: ${apiResponse}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      postToApi(widget.data['results']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "View Model Result",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
      ),
    );
  }
}

// Placeholder widget for video player (you need to implement this)

// Placeholder widget for video player (you need to implement this)
