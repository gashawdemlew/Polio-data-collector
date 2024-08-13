import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
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
  String lastname = '';
  String region = '';
  String password = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      lastname = prefs.getString('last_name') ?? '';
      region = prefs.getString('region') ?? '';
      password = prefs.getString('password') ?? '';

      _firstNameController.text = firstName;
      _phoneNoController.text = phoneNo;
      _zoneController.text = zone;
      _woredaController.text = woreda;
      _lastNameController.text = lastname;
      _regionController.text = region;
      _passwordController.text = password;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final url = '${baseUrl}user/$id';
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
          'lastname': _lastNameController.text,
          'region': _regionController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', _firstNameController.text);
        await prefs.setString('phoneNo', _phoneNoController.text);
        await prefs.setString('zone', _zoneController.text);
        await prefs.setString('woreda', _woredaController.text);
        await prefs.setString('lastname', _lastNameController.text);
        await prefs.setString('region', _regionController.text);
        await prefs.setString('password', _passwordController.text);

        setState(() {
          firstName = _firstNameController.text;
          phoneNo = _phoneNoController.text;
          zone = _zoneController.text;
          woreda = _woredaController.text;
          lastname = _lastNameController.text;
          region = _regionController.text;
          password = _passwordController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PolioDashboard(),
          ),
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
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your last name';
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
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: 'Region',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your region';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
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
              _buildInfoCard('First Name', firstName, Icons.person),
              _buildInfoCard('Last Name', lastname, Icons.person),
              _buildInfoCard('Phone Number', phoneNo, Icons.phone),
              _buildInfoCard('Zone', zone, Icons.map),
              _buildInfoCard('Woreda', woreda, Icons.location_on),
              _buildInfoCard('Region', region, Icons.location_city),
              _buildInfoCard('Password', password, Icons.lock),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
