import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/image.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/stole_speciement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataListPage extends StatefulWidget {
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
    await Future.delayed(Duration(seconds: 1));
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
      setState(() {
        data = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String getProgressText(String progressNo) {
    switch (progressNo) {
      case "1":
        return "Continue Clinical History";
      case "2":
        return "Continue Stool Specimen";
      case "3":
        return "Continue Follow Up";
      case "4":
        return "Environment Metrology Form";
      case "5":
        return "Media Screen";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Sessions '),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    String progressNo = data[index]['progressNo'];
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
                          builder: (context) => StoolSpecimensForm34(
                            epid_Number: data[index]['epid_number'],
                          ),
                        ),
                      );
                    } else if (progressNo == "3") {
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
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          data[index]['first_name'][0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        data[index]['first_name'],
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        getProgressText(data[index]['progressNo'] ?? ""),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String epidNumber;

  DetailPage({required this.epidNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: Center(
        child: Text('Epid Number: $epidNumber'),
      ),
    );
  }
}
