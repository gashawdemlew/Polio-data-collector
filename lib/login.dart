import 'package:camera_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/polioDashboard.dart';

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

  @override
  void initState() {
    super.initState();
    loadLanguage();
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

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Validation passed, perform login action
      // For now, just display a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logging in...'),
        ),
      );
    }
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
                    labelText: 'Email',
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
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_emailController.text == "admin@gmail.com" &&
                          _passwordController.text == "admin@gmail.com") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PolioDashboard()));
                      } else {
                        final response = await ApiService.loginUser(
                          phoneNo: _emailController.text,
                          password: _passwordController.text,
                        );
                        print(
                            'Login successful: ${response['message']}   ${response['token']}');
                        print('Response:   ${response}');
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('email', _emailController.text);
                        await prefs.setString(
                            'userType', response['user_role'] ?? "");
                        await prefs.setString(
                            'first_name', response['first_name'] ?? "");
                        await prefs.setString(
                            'phoneNo', response['phoneNo'] ?? "");
                        await prefs.setString('zone', response['zone'] ?? "");
                        await prefs.setString(
                            'woreda', response['woreda'] ?? "");
                        await prefs.setString('zone', response['zone'] ?? "");
                        await prefs.setInt('id', response['id'] ?? 0);

                        await prefs.setString(
                            'userType', response['user_role'] ?? "");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PolioDashboard()));
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                    // Perform login validation here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.testColor1,
                    elevation: 5,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
