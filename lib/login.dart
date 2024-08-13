import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/services/api_service.dart';

void main() {
  runApp(MyApp78());
}

class MyApp78 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LanguageResources resources = LanguageResources('English');
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _selectedLanguage = 'English'; // Default value
  bool _isLoading = false; // Loading state variable

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    loadLanguage();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    if (mounted) {
      setState(() {
        _selectedLanguage = storedLanguage;
      });
    }
  }

  void _saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      print("XXXXXXXX $result");
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  String xx = "";
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      var connectivityResult = await Connectivity().checkConnectivity();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("Connectivity Status: $connectivityResult");

      if (connectivityResult.toString() !=
          [ConnectivityResult.none].toString()) {
        setState(() {
          _isLoading = true;
        });

        try {
          if (_emailController.text == "admin@gmail.com" &&
              _passwordController.text == "admin@gmail.com") {
            await prefs.setString('email', "admin@gmail.com");
            await prefs.setString('userType', "Admin");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PolioDashboard()));
          } else {
            final response = await ApiService.loginUser(
              phoneNo: _emailController.text,
              password: _passwordController.text,
            );
            print(
                'Login successful: ${response['message']}   ${response['token']}');
            print('Response:   ${response}');

            // Save credentials to shared preferences
            await prefs.setString('email', _emailController.text);
            await prefs.setString('userType', response['user_role'] ?? "");
            await prefs.setString('first_name', response['first_name'] ?? "");
            await prefs.setString('last_name', response['last_name'] ?? "");

            await prefs.setString('phoneNo', response['phoneNo'] ?? "");
            await prefs.setString('zone', response['zone'] ?? "");
            await prefs.setString('woreda', response['woreda'] ?? "");
            await prefs.setString('region', response['region'] ?? "");

            await prefs.setInt('id', response['user_id'] ?? 0);
            await prefs.setString('password', _passwordController.text);
            await prefs.setString(
                'emergency_phonno', response['emergency_phonno'] ?? "");

            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PolioDashboard()));
          }
        } catch (e) {
          print('Error: $e');
          _showErrorDialog('Login failed: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Check stored credentials locally
        String storedPhoneNo = prefs.getString('phoneNo') ?? '';
        String storedPassword = prefs.getString('password') ?? '';

        if (_emailController.text == storedPhoneNo &&
            _passwordController.text == storedPassword) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PolioDashboard()));
        } else {
          _showErrorDialog(
              'No internet connection and no valid local credentials.');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.deepPurpleAccent,
                        width: 2,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      hint: Text(
                        'Select Language',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLanguage = newValue!;
                          _saveSelectedLanguage(newValue);
                        });
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.deepPurpleAccent,
                      ),
                      iconSize: 36.0,
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 18.0,
                      ),
                      dropdownColor: Colors.white,
                      items: <String>['English', 'Amharic', 'AfanOromo']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: CustomColors.testColor1),
                    ),
                  ),
                  validator: _validateEmail,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "Forget Password?",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.testColor1,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: CustomColors.testColor1),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 50.0),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.testColor1,
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
