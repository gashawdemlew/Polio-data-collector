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

class EpidDataPage extends StatefulWidget {
  final String epidNumber;

  const EpidDataPage({Key? key, required this.epidNumber}) : super(key: key);

  @override
  State<EpidDataPage> createState() => _EpidDataPageState();
}

class _EpidDataPageState extends State<EpidDataPage> {
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
        Uri.parse('${baseUrl}clinic/getDataByEpidNumber/$encodedEpidNumber');

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

  void _showEditModal(
      BuildContext context, Map<String, String> sharedPrefsData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Descion',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedResult,
                    items: ['Positive', 'Negative', 'pending']
                        .map((result) => DropdownMenuItem(
                              value: result,
                              child: Text(
                                result,
                                style: TextStyle(color: Colors.black),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedResult = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Result',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle form submission
                        _submitForm(sharedPrefsData);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            CustomColors.testColor1, // Blue background color
                        padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal:
                                70), // Adjust padding for better appearance
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Rounded corners for the button
                        ),
                        elevation: 5, // Shadow for a more modern look
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.white), // White text color for contrast
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm(Map<String, String> sharedPrefsData) async {
    final encodedEpidNumber = Uri.encodeComponent(widget.epidNumber);

    final data = {
      ...sharedPrefsData,
      'result': _selectedResult,
      'description': _descriptionController.text,
    };

    // Send data to your API endpoint
    final url =
        Uri.parse('${baseUrl}clinic/updateCommiteResult/$encodedEpidNumber');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    print(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data updated successfully!')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PatientDataPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            "ViewAll Data",
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
                MaterialPageRoute(builder: (context) => PatientDataPage()),
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
              epidNumber: widget.epidNumber,
              data: data,
              onEdit: () async {
                final sharedPrefsData = await getSharedPreferencesData();
                _showEditModal(context, sharedPrefsData);
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
    final results = widget.data['results'] as Map<String, dynamic>?;
    final multimediaInfo = results?['Multimedia Info'] as Map<String, dynamic>?;

    // Safely extracting imagePath and videoPath from the API data or widget data
    final imagePath =
        apiData?['image_url'] ?? multimediaInfo?['iamge_path'] ?? "";
    final videoPath =
        apiData?['video_url'] ?? multimediaInfo?['viedeo_path'] ?? "";

    return Container(
      color: const Color.fromARGB(251, 232, 229, 229),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'EPID Number: ${widget.data['epid_number']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          results != null
              ? Column(
                  children: results.entries.map((entry) {
                    return SectionCard(
                      title: entry.key,
                      data: entry.value,
                    );
                  }).toList(),
                )
              : const Text('No results available'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.testColor1,
            ),
            child: const Text(
              'Add Decision',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Display image if imagePath is available
          if (imagePath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Image.network(
                imagePath,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Error loading image: $error");
                  return const Text(
                    "Failed to load image",
                    style: TextStyle(color: Colors.red),
                  );
                },
              ),
            ),

          if (videoPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayerWidget(videoUrl: videoPath),
              ),
            ),
          if (widget.data['errors'] != null)
            Text(
              'Errors: ${widget.data['errors']}',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

// Placeholder widget for video player (you need to implement this)

// Placeholder widget for video player (you need to implement this)
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video Player Placeholder\nURL: $videoUrl',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final dynamic data;

  const SectionCard({Key? key, required this.title, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return SizedBox(); // Skip if no data
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 255, 255),
          // width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.grey.withOpacity(0.3),
          //   spreadRadius: 3,
          //   blurRadius: 8,
          //   offset: Offset(0, 3),
          // ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            ..._buildDetails(data),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetails(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.entries.map((entry) {
        final key = entry.key;
        final value = entry.value ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon for added visual enhancement
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.info_outline,
                    color: Colors.blueAccent, size: 20),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  key.replaceAll('_', ' '),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();
    } else {
      return [
        Text(
          data.toString(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ];
    }
  }
}
