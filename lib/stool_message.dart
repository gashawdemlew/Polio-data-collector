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
  String languge = "";

  @override
  void initState() {
    super.initState();
    futureData = _loadUserDetails();
  }

  Future<List<ClinicData>> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userDetails = {
      'email': prefs.getString('email') ?? 'N/A',
      'userType': prefs.getString('userType') ?? 'N/A',
      'firstName': prefs.getString('first_name') ?? 'N/A',
      'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
      'zone': prefs.getString('zone') ?? 'N/A',
      'woreda': prefs.getString('woreda') ?? 'N/A',
      'id': prefs.getInt('id') ?? -1,
      'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
    };
    setState(() {
      languge = userDetails['selectedLanguage'];
    });
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
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
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
      body: Container(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<ClinicData>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error loading data.',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  languge == "Amharic"
                      ? 'ምንም ያልተጠናቀቀ መረጃ የለም'
                      : 'No incomplete data available',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              );
            } else {
              final data = snapshot.data!;
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: CustomColors.testColor1,
                        foregroundColor: Colors.white,
                        child: Text(
                          '${index + 1}',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(
                        item.id,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 17),
                      ),
                      subtitle: Text(
                        'Name: ${item.name}',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.teal),
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
      id: json['epid_number'],
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
