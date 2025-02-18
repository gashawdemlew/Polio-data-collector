import 'package:camera_app/color.dart';
import 'package:camera_app/commite/results.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PatientDataPage extends StatefulWidget {
  @override
  _PatientDataPageState createState() => _PatientDataPageState();
}

class _PatientDataPageState extends State<PatientDataPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Patient>> _patients;
  late TabController _tabController;
  String selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _patients = fetchPatients();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<List<Patient>> fetchPatients() async {
    String url = "${baseUrl}clinic/getData1";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load data");
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

  List<Patient> filterPatients(List<Patient> patients) {
    if (selectedFilter == 'All') {
      return patients;
    }
    return patients
        .where((patient) => patient.result == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CustomColors.testColor1, Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          child: AppBar(
            title: Text(
              xx == "Amharic"
                  ? 'የታካሚ ውሂብ'
                  : xx == "AfanOromo"
                      ? 'Ragaa Dhukkubsataa'
                      : 'Patient Data',
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
            backgroundColor: Colors.transparent, // Make the AppBar transparent
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white, // Set active tab text color
              unselectedLabelColor:
                  Colors.white54, // Set inactive tab text color
              onTap: (index) {
                setState(() {
                  if (index == 0) {
                    selectedFilter = 'All';
                  } else if (index == 1) {
                    selectedFilter = 'pending';
                  } else if (index == 2) {
                    selectedFilter = 'Positive';
                  } else if (index == 3) {
                    selectedFilter = 'Negative';
                  }
                });
              },
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Positive"),
                Tab(text: "Negative"),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(251, 232, 229, 229),
        child: FutureBuilder<List<Patient>>(
          future: _patients,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data available"));
            } else {
              List<Patient> filteredPatients = filterPatients(snapshot.data!);
              return filteredPatients.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        Patient patient = filteredPatients[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Epid Number
                                  Text(
                                    patient.epidNumber,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Name Row
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.teal,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          patient.firstName?.isEmpty == false
                                              ? "${patient.firstName} ${patient.lastName}"
                                              : "Name not available",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Additional Field (e.g., Patient Age)

                                  Row(
                                    children: [
                                      // Space between icon and text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Align text to the start
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.map,
                                                    color: Colors
                                                        .blue), // Icon for Woreda
                                                const SizedBox(width: 8),
                                                Text(
                                                  patient.woreda ??
                                                      "Woreda not available", // Use null-aware operator
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        16, // Uniform font size
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors
                                                        .black87, // Uniform color
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                                height:
                                                    4), // Space between text lines
                                            Row(
                                              children: [
                                                const Icon(Icons.place,
                                                    color: Colors
                                                        .green), // Icon for Zone
                                                const SizedBox(width: 8),
                                                Text(
                                                  patient.zone ??
                                                      "Zone not available", // Use null-aware operator
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        16, // Uniform font size
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors
                                                        .black87, // Uniform color
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                                height:
                                                    4), // Space between text lines
                                            Row(
                                              children: [
                                                const Icon(Icons.public,
                                                    color: Colors
                                                        .red), // Icon for Region
                                                const SizedBox(width: 8),
                                                Text(
                                                  patient.region ??
                                                      "Region not available", // Use null-aware operator
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        16, // Uniform font size
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors
                                                        .black87, // Uniform color
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Action Button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Tooltip(
                                      message: "View Details",
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EpidDataPage(
                                                epidNumber: patient.epidNumber,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: CustomColors.testColor1,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons
                                                .arrow_forward, // Choose an appropriate icon
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text("No patients found for the selected filter."),
                    );
            }
          },
        ),
      ),
    );
  }
}

class Patient {
  final int patientId;
  final String epidNumber;
  final String? gender;
  final String? firstName;
  final String? lastName;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? result;

  Patient(
      {required this.patientId,
      required this.epidNumber,
      this.gender,
      this.firstName,
      this.lastName,
      this.region,
      this.zone,
      this.woreda,
      this.result});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['petient_id'],
      epidNumber: json['epid_number'],
      gender: json['gender'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      region: json['region'],
      zone: json['zone'],
      woreda: json['woreda'],
      result: json['result'],
    );
  }
}
