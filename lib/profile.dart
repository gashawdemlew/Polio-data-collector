import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Profile Page')),
        body: ProfilePage(),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  int id = 0;

  String phoneNo = '';
  String zone = '';
  String woreda = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      id = prefs.getInt('id') ?? 0;

      phoneNo = prefs.getString('phoneNo') ?? '';
      zone = prefs.getString('zone') ?? '';
      woreda = prefs.getString('woreda') ?? '';
      _firstNameController.text = firstName;
      _phoneNoController.text = phoneNo;
      _zoneController.text = zone;
      _woredaController.text = woreda;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final url = 'http://localhost:7476/user/update/$id';
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'first_name': _firstNameController.text,
          'phoneNo': _phoneNoController.text,
          'zone': _zoneController.text,
          'woreda': _woredaController.text,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', _firstNameController.text);
        await prefs.setString('phoneNo', _phoneNoController.text);
        await prefs.setString('zone', _zoneController.text);
        await prefs.setString('woreda', _woredaController.text);

        setState(() {
          firstName = _firstNameController.text;
          phoneNo = _phoneNoController.text;
          zone = _zoneController.text;
          woreda = _woredaController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
              ),
              SizedBox(height: 20),
              Text(
                'Edit Your Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneNoController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _zoneController,
                      decoration: InputDecoration(
                        labelText: 'Zone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your zone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _woredaController,
                      decoration: InputDecoration(
                        labelText: 'Woreda',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your woreda';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.person, size: 40),
                  title: Text('First Name'),
                  subtitle: Text(firstName),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.phone, size: 40),
                  title: Text('Phone Number'),
                  subtitle: Text(phoneNo),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.map, size: 40),
                  title: Text('Zone'),
                  subtitle: Text(zone),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.location_on, size: 40),
                  title: Text('Woreda'),
                  subtitle: Text(woreda),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
