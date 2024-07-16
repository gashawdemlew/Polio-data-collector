import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        fontFamily: 'Roboto', // Use a more visually appealing font
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
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get(Uri.parse('http://localhost:7476/clinic/getMessage676'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Message Display'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a header image or logo
          Container(
            height: 150,
            color: Colors.blue,
            child: Center(
              child: Text(
                'Clinic Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(), // Show a loading spinner
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to another page when the ListTile is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnotherPage(
                            firstName: message['first_name'] ?? 'N/A',
                            lastName: message['last_name'] ?? 'N/A',
                            epid: message['epid_number'] ?? 'N/A',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      decoration: BoxDecoration(
                        color: message['status'] == 'unseen'
                            ? Colors.green[300]
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 16.0),
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

  AnotherPage({
    required this.firstName,
    required this.lastName,
    required this.epid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category  Page'),
        centerTitle: true,
      ),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'First Name: $firstName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Last Name: $lastName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'EPID: $epid',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
