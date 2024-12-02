import 'package:camera_app/commite/results.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _patients = fetchPatients();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<List<Patient>> fetchPatients() async {
    const String url = "http://192.168.47.228:7476/clinic/getData1";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load data");
    }
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
      appBar: AppBar(
        title: const Text("Patient Data"),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
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
      body: FutureBuilder<List<Patient>>(
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
                            horizontal: 10, vertical: 5),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.epidNumber,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.teal),
                                    const SizedBox(width: 5),
                                    Text(
                                      patient.firstName?.isEmpty == false
                                          ? "${patient.firstName} ${patient.lastName}"
                                          : "Name not available",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EpidDataPage(
                                          epidNumber: patient.epidNumber,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("View Details"),
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
