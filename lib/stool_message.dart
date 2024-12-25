import 'dart:convert';
import 'package:camera_app/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Adjust import paths as necessary
import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';

class YU extends StatelessWidget {
  const YU({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ClinicDataScreen(),
    );
  }
}

class ClinicDataScreen extends StatefulWidget {
  const ClinicDataScreen({super.key});

  @override
  _ClinicDataScreenState createState() => _ClinicDataScreenState();
}

class _ClinicDataScreenState extends State<ClinicDataScreen> {
  late Future<List<ClinicData>> futureData;
  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    // Initialize futureData with a placeholder Future
    futureData = _loadUserDetails();
  }

  String languge = "";
  Future<List<ClinicData>> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userDetails = {
      'email': prefs.getString('email') ?? 'N/A',
      'userType': prefs.getString('userType') ?? 'N/A',
      'firstName': prefs.getString('first_name') ?? 'N/A',
      'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
      'zone': prefs.getString('zone') ?? 'N/A',
      'woreda': prefs.getString('woreda') ?? 'N/A',
      'id': prefs.getInt('id') ?? -1, // Use -1 or other default value for int
      'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
    };
    setState(() {
      languge = userDetails['selectedLanguage'];
    });
    // Fetch clinic data with the user ID
    return fetchClinicData(userDetails['id']);
  }

  Future<List<ClinicData>> fetchClinicData(int id) async {
    final response = await http.get(Uri.parse('${baseUrl}clinic/getData/$id'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ClinicData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          languge == "Amharic" ? 'ያላለቀ ሊስቶች' : 'Incomplete List',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PolioDashboard()),
            );
          },
        ),
      ),
      body: FutureBuilder<List<ClinicData>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(item.id,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Name: ${item.name}'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LaboratoryFinalClassificationForm(
                            epid: item.id,
                            type: item.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ClinicData {
  final String id;
  final String name;

  ClinicData({required this.id, required this.name});

  factory ClinicData.fromJson(Map<String, dynamic> json) {
    return ClinicData(
      id: json['epid_number'], // Ensure this key matches your API response
      name: json['type'],
    );
  }
}

class ClinicDetailScreen extends StatelessWidget {
  final ClinicData clinicData;

  const ClinicDetailScreen({super.key, required this.clinicData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stool Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${clinicData.name}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Epid: ${clinicData.id}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
