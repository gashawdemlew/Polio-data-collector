import 'dart:convert';
import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YU extends StatelessWidget {
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
  @override
  _ClinicDataScreenState createState() => _ClinicDataScreenState();
}

class _ClinicDataScreenState extends State<ClinicDataScreen> {
  late Future<List<ClinicData>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchClinicData();
  }

  Future<List<ClinicData>> fetchClinicData() async {
    final response = await http.get(Uri.parse('${baseUrl}clinic/getData'));

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
      appBar: AppBar(title: Text('Session Data')),
      body: FutureBuilder<List<ClinicData>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(item.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${item.id}'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LaboratoryFinalClassificationForm(
                                  epid: item.id,
                                  type: item.name,
                                )),
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
      id: json['epid_number'],
      name: json['type'],
    );
  }
}

class ClinicDetailScreen extends StatelessWidget {
  final ClinicData clinicData;

  ClinicDetailScreen({required this.clinicData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stool  Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${clinicData.name}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('epid: ${clinicData.id}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
