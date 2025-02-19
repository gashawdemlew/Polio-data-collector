import 'package:camera_app/color.dart';
import 'package:camera_app/commite/list_petients.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/modelResults/model_detail.dart';
import 'package:camera_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class EpidDataPage extends StatefulWidget {
  final String epidNumber;
  final String type;

  const EpidDataPage({Key? key, required this.epidNumber, required this.type})
      : super(key: key);

  @override
  State<EpidDataPage> createState() => _EpidDataPageState();
}

class _EpidDataPageState extends State<EpidDataPage> {
  late Future<Map<String, dynamic>> _dataFuture;
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedResult = 'Positive';

  Map<String, dynamic>? _apiData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchEpidData(widget.epidNumber);
    fetchApiData();
  }

  Future<void> fetchApiData() async {
    final encodedEpidNumber = Uri.encodeComponent(widget.epidNumber);

    try {
      Uri.parse('"${baseUrl}ModelRoute/data/$encodedEpidNumber');

      final response = await http
          .get(Uri.parse("${baseUrl}ModelRoute/data/$encodedEpidNumber"));
      if (response.statusCode == 200) {
        setState(() {
          _apiData = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _error = 'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error during API call: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchEpidData(String epidNumber) async {
    final encodedEpidNumber = Uri.encodeComponent(epidNumber);
    final url =
        Uri.parse('${baseUrl}clinic/getDataByEpidNumber/$encodedEpidNumber');

    final response = await http.get(url);

    print(response.body);

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
            "Case Detail",
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
                bottom: Radius.circular(6),
              ),
            ),
          ),
          actions: [
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

            return _buildBody(data);
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    return Container(
      color: const Color.fromARGB(251, 232, 229, 229),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Text(
          //   'EPID Number: ${data['epid_number']}',
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 16),
          if (data['results'] != null)
            Column(
              children: (data['results'] as Map<String, dynamic>)
                  .entries
                  .map((entry) {
                return SectionCard(
                  title: entry.key,
                  data: entry.value,
                );
              }).toList(),
            ),

          // Existing multimedia display logic
          _buildMultimedia(data),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsPage(
                    epidNumber: widget.epidNumber,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.testColor1,
            ),
            child: const Text(
              'AI-Model Prediction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          widget.type == "committe"
              ? ElevatedButton(
                  onPressed: () async {
                    final sharedPrefsData = await getSharedPreferencesData();
                    _showEditModal(context, sharedPrefsData);
                  },
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
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget _buildDataItem(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: item.entries.map((entry) {
            return Text('${entry.key}: ${entry.value}');
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMultimedia(Map<String, dynamic> data) {
    final results = data['results'] as Map<String, dynamic>?;
    final multimediaInfo = results?['Multimedia Info'] as Map<String, dynamic>?;

    final imagePath =
        _apiData?['image_url'] ?? multimediaInfo?['iamge_path'] ?? "";
    final videoPath =
        _apiData?['video_url'] ?? multimediaInfo?['viedeo_path'] ?? "";

    double screenWidth = MediaQuery.of(context).size.width;
    double desiredWidth = screenWidth - 32; // Adjust for padding
    double desiredHeight = desiredWidth; // Make it square

    return Column(
      children: [
        Text(
          "Multimedia Data",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (imagePath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              width: desiredWidth,
              height: desiredHeight,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(8.0), // Optional rounded corners
                child: Image.network(
                  imagePath,
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
                    return Container(
                        color: Colors.grey[200], // Placeholder background
                        child: Center(
                          child: Text(
                            "Failed to load image",
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ));
                  },
                ),
              ),
            ),
          ),
        if (videoPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              width: desiredWidth,
              height: desiredHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: VideoPlayerWidget(videoUrl: videoPath),
              ),
            ),
          ),
        if (data['errors'] != null)
          Text(
            'Errors: ${data['errors']}',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isVideoLoaded = true;
        });
      }).catchError((error) {
        print("Error initializing video player: $error"); // Add error handling
        setState(() {
          _isVideoLoaded = false; // Ensure loading is stopped on error
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isVideoLoaded
          ? GestureDetector(
              onTap: () {
                // Toggle play/pause on tap
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    if (!_controller.value.isPlaying)
                      Icon(
                        Icons.play_arrow,
                        size: 50.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                  ],
                ),
              ),
            )
          : _controller.value.hasError
              ? const Text(
                  "Error loading video",
                  style: TextStyle(color: Colors.red),
                )
              : const CircularProgressIndicator(),
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
    if (data == null || title == "Multimedia Info") {
      return SizedBox(); // Skip if no data OR title is "Multimedia Info"
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
