import 'dart:convert';
import 'package:camera_app/color.dart';
import 'package:camera_app/lab_form.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Laboratory Information_Final classification  .dart';

void main() {
  runApp(ViewMessage());
}

class ViewMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Message Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: ClinicMessagePage(),
    );
  }
}

class ClinicMessagePage extends StatefulWidget {
  @override
  _ClinicMessagePageState createState() => _ClinicMessagePageState();
}

class _ClinicMessagePageState extends State<ClinicMessagePage> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();

    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get(Uri.parse('${baseUrl}clinic/getMessage676'));
    if (response.statusCode == 200) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages = [
          {'error': 'Error: ${response.statusCode}'}
        ];
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> userDetails = {};
  String languge = '';

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
      setState(() {
        languge = userDetails['selectedLanguage'];
      });
      print(userDetails);

      // Fetch data by phone number and assign the future to _futureVols
    });
  }

  Future<void> _updateMessageStatus(int push_id) async {
    try {
      final url = '${baseUrl}clinic/messages23/$push_id';
      print('Sending PUT request to: $url');

      final response = await http.put(
        Uri.parse(url),
        body: jsonEncode({}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Message status updated successfully');
      } else {
        print(
            'Error updating message status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating message status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.testColor1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // Add your back button logic here
            Navigator.pop(context);
          },
        ),
        title: Text(
          'User List',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Center(
              child: Text(
                'Clinic Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return GestureDetector(
                    onTap: () {
                      int push_id = int.parse(message['push_id'].toString());

// Call the function with the parsed integer
                      _updateMessageStatus(push_id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnotherPage(
                            languge: languge,
                            firstName: message['first_name'] ?? 'N/A',
                            lastName: message['last_name'] ?? 'N/A',
                            epid: message['epid_number'] ?? 'N/A',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              message['status'] == 'unseen'
                                  ? Icons.mark_email_unread
                                  : Icons.mark_email_read,
                              color: message['status'] == 'unseen'
                                  ? Colors.green
                                  : Colors.blue,
                              size: 40.0,
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${message['first_name'] ?? 'N/A'} ${message['last_name'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'EPID: ${message['epid_number'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String epid;
  final String languge;

  AnotherPage(
      {required this.firstName,
      required this.languge,
      required this.lastName,
      required this.epid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$firstName $lastName',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EPID: $epid',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LabForm(
                                  epid: epid,
                                  languge: languge,
                                  type: "Stool 1",
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 132, vertical: 20),
                      backgroundColor: CustomColors.testColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      languge == "Amharic" ? 'ሰገራ ምርምራ 1' : 'Stool 1',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LabForm(
                                  epid: epid,
                                  languge: languge,
                                  type: 'Stool 2',
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 132, vertical: 20),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      languge == "Amharic" ? 'ሰገራ ምርምራ 2' : 'Stool 2',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
