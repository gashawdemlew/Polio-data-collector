import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/image.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/stole_speciement.dart';
import 'package:camera_app/stool/date_stool.collected.dart';
import 'package:camera_app/stool/date_stoole_recieved.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataListPage extends StatefulWidget {
  const DataListPage({super.key});

  @override
  _DataListPageState createState() => _DataListPageState();
}

class _DataListPageState extends State<DataListPage> {
  List<dynamic> data = [];
  bool isLoading = true;
  Map<String, dynamic> userDetails = {};
  String languge = "ccc";
  LanguageResources? resources;
  String _selectedLanguage = "English";
  LanguageResources? resource12;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadLanguage45();
    _loadLanguage().then((_) {
      setState(() {
        _selectedLanguage = languge;
        resources = LanguageResources(languge);
      });
    });
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'none';
    if (mounted) {
      setState(() {
        languge = storedLanguage;
      });
    }
  }

  Future<void> _loadLanguage45() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge);
      resource12 = resources;
    });
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

    fetchData(userDetails['id']);
  }

  Future<void> fetchData(int userId) async {
    String url = '${baseUrl}clinic/getDataByUserId/$userId';
    print("Fetching data from: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        data = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _deleteDataById(int id) async {
    String url = '${baseUrl}clinic/deleteDataById/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        data.removeWhere((item) => item['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DataListPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete record')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(int patientId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              const SizedBox(width: 10),
              const Text(
                'Delete Confirmation',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this record? This action cannot be undone.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteDataById(patientId); // Delete the record
              },
            ),
          ],
        );
      },
    );
  }

  String getProgressText(String progressNo) {
    switch (progressNo) {
      case "1":
        return "Continue Clinical History";
      case "2":
        return "Continue Follow Up";
      case "3":
        return "Continue Follow Up";
      case "4":
        return "Environment Metrology Form";
      case "5":
        return "Media Screen";

      case "12":
        return "Continue Stool Collected Date";
      case "13":
        return "Continue Stool Recived Date";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(251, 232, 229, 229),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            languge == "Amharic"
                ? 'ያላለቁ የታካሚ መዝገቦች'
                : languge == "AfanOromo"
                    ? "Gosoota galtee"
                    : 'Incomplete registrations',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
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
                bottom: Radius.circular(4),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    String progressNo = data[index]['progressNo'];
                    // Navigation logic (unchanged)
                    if (progressNo == "1") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicalHistoryForm(
                            epid_Number: data[index]['epid_number'],
                          ),
                        ),
                      );
                    } else if (progressNo == "2") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowUpExaminationForm(
                            epid_Number: data[index]['epid_number'],
                            resources1: resource12,
                          ),
                        ),
                      );
                    } else if (progressNo == "4") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnvironmentMetrologyForm(
                            epid_number: data[index]['epid_number'],
                            resources1: resource12,
                          ),
                        ),
                      );
                    } else if (progressNo == "5") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakePictureScreen(
                            epid_number: data[index]['epid_number'],
                          ),
                        ),
                      );
                    } else if (progressNo == "12") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DateStoolcollected(
                            epid_Number: data[index]['epid_number'],
                          ),
                        ),
                      );
                    } else if (progressNo == "13") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DateStooleRecieved(
                            epid_Number: data[index]['epid_number'],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 228, 222, 222),
                          width: 1.0), // Grey border
                      color: Colors.white, // Card background color
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data[index]['first_name']} ${data[index]['last_name']}',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Divider(),
                              const SizedBox(height: 12.0),
                              _buildInfoRow(Icons.phone,
                                  'Phone: ${data[index]['phoneNo'] ?? 'N/A'}'),
                              _buildInfoRow(Icons.location_on,
                                  'Region: ${data[index]['region'] ?? 'N/A'}'),
                              _buildInfoRow(Icons.map,
                                  'Zone: ${data[index]['zone'] ?? 'N/A'}'),
                              _buildInfoRow(Icons.location_city,
                                  'Woreda: ${data[index]['woreda'] ?? 'N/A'}'),
                              _buildInfoRow(Icons.person,
                                  'Gender: ${data[index]['gender'] ?? 'N/A'}'),
                              ElevatedButton(
                                onPressed: () {
                                  // Add your desired functionality here
                                  String progressNo =
                                      data[index]['progressNo'] ?? "";

                                  // Navigation logic
                                  if (progressNo == "1") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ClinicalHistoryForm(
                                          epid_Number: data[index]
                                              ['epid_number'],
                                        ),
                                      ),
                                    );
                                  } else if (progressNo == "2") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FollowUpExaminationForm(
                                          epid_Number: data[index]
                                              ['epid_number'],
                                          resources1: resource12,
                                        ),
                                      ),
                                    );
                                  } else if (progressNo == "4") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EnvironmentMetrologyForm(
                                          epid_number: data[index]
                                              ['epid_number'],
                                          resources1: resource12,
                                        ),
                                      ),
                                    );
                                  } else if (progressNo == "5") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TakePictureScreen(
                                          epid_number: data[index]
                                              ['epid_number'],
                                        ),
                                      ),
                                    );
                                  } else if (progressNo == "12") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DateStoolcollected(
                                          epid_Number: data[index]
                                              ['epid_number'],
                                        ),
                                      ),
                                    );
                                  } else if (progressNo == "13") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DateStooleRecieved(
                                          epid_Number: data[index]
                                              ['epid_number'],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors
                                      .testColor1, // Button background color
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Rounded corners
                                  ),
                                ),
                                child: Text(
                                  getProgressText(
                                      data[index]['progressNo'] ?? ""),
                                  style: const TextStyle(
                                    color: Colors.white, // Text color
                                    fontSize: 16, // Font size
                                    fontWeight: FontWeight.bold, // Font weight
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add trailing icon for delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                data[index]['petient_id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54, // Label color
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
