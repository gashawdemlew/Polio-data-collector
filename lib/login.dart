import 'dart:async';

import 'package:camera_app/forget_pass/confirm_password.dart';
import 'package:camera_app/forget_password.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/user_list.dart';
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
  const MyApp78({super.key});

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
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LanguageResources resources = LanguageResources('English');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
      return _selectedLanguage == "Amharic"
          ? "እባክዎ የስልክ ቁጥርዎን ይጻፉ"
          : _selectedLanguage == "AfanOromo"
              ? "Lakkoofsa Bilbila keessanii galchaa"
              : "Please enter your Phone No";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _selectedLanguage == "Amharic"
          ? "እባክዎ የይለፍ ቁጥርዎን ይጻፉ"
          : _selectedLanguage == "AfanOromo"
              ? "Mee password kee barreessi"
              : "Please enter your password";
    }
    return null;
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      print("XXXXXXXX $result");
    } on PlatformException {
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
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
    }
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
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        try {
          if (_emailController.text == "admin@gmail.com" &&
              _passwordController.text == "admin@gmail.com") {
            await prefs.setString('email', "admin@gmail.com");
            await prefs.setString('userType', "Admin");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainPage()));
          } else {
            final response = await ApiService.loginUser(
              phoneNo: _emailController.text,
              password: _passwordController.text,
            );

            print(
                'Login successful: ${response['message']}   ${response['token']}');
            print('Response:   $response');

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

            // Check user status
            if (response['status'] == 'pending') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmPasswordPage(
                    userId: response['user_id'],
                  ),
                ),
              );
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PolioDashboard()));
            }
          }
        } catch (e) {
          print('Error: $e');
          _showErrorDialog('Login failed: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
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
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isObscured = true;

  void _onForgetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgetPassword()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          body: Column(
            children: [
              // Custom Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CustomColors.testColor1, Color(0xFF007AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/im/heder.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedLanguage == "Amharic"
                                ? "ሰላም!"
                                : _selectedLanguage == "AfanOromo"
                                    ? "Anaa dhufu!"
                                    : "welcome",
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.5, 1.5),
                                  color: Colors.black38,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              dropdownColor: Colors.white,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedLanguage = newValue!;
                                  _saveSelectedLanguage(newValue);
                                });
                              },
                              icon: const Icon(Icons.language,
                                  color: Colors.white),
                              items: <String>[
                                'English',
                                'Amharic',
                                'AfanOromo'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value == 'Amharic'
                                        ? 'አማርኛ'
                                        : value == 'AfanOromo'
                                            ? 'Afaan Oromoo'
                                            : value,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ]),
                    const SizedBox(height: 10.0),
                    Text(
                      _selectedLanguage == "Amharic"
                          ? "የፖሊዮ ዳታ ሰብሳቢ እና ዲያግኖሲስ መተግበሪያ!"
                          : "PolioAntenna App!!",
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Phone Input
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: _selectedLanguage == "Amharic"
                                ? "ስልክ ቁጥር"
                                : _selectedLanguage == "AfanOromo"
                                    ? "Lakkoofsa Bilbilaa"
                                    : "Phone No",
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(Icons.phone),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 20.0),
                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.black),
                          obscureText: _isObscured,
                          decoration: InputDecoration(
                            labelText: _selectedLanguage == "Amharic"
                                ? "ይለፍ ቃል"
                                : _selectedLanguage == "AfanOromo"
                                    ? "Jecha Iccitii [Jecha darbii]"
                                    : "Password",
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        // const SizedBox(height: 20.0),
                        // Forget Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _onForgetPassword(context),
                            child: Text(
                              _selectedLanguage == "Amharic"
                                  ? "የይለፍ ቃል ማስታወሻ"
                                  : _selectedLanguage == "AfanOromo"
                                      ? "Jecha Iccitii Dagatee? [Jecha darbii dagattee?]"
                                      : "Forgot Password?",
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _login, // Disable when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors
                                .testColor1, // set blue if not loading
                            elevation: 5,
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                ) // Show indicator when loading
                              : Text(
                                  _selectedLanguage == "Amharic"
                                      ? "ግባ"
                                      : _selectedLanguage == "AfanOromo"
                                          ? "seenuu"
                                          : "Login",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "@ 2024 RAPPS-PolioAntenna App. All rights reserved..",
                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ));
  }
}
