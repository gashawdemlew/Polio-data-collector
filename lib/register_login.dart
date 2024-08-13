import 'package:camera_app/color.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/services/api_service.dart';
import 'package:camera_app/user_list.dart';
import 'package:camera_app/util/common/theme_helper.dart';
// import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatelessWidget {
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneNoController,
              decoration: ThemeHelper()
                  .textInputDecoration('Phone Number', 'Phone Number'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
                  ThemeHelper().textInputDecoration('Password', 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String phoneNo = phoneNoController.text;
                String password = passwordController.text;
                await _handleLogin(context, phoneNo, password);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(
      BuildContext context, String phoneNo, String password) async {
    // ConnectivityResult connectivityResult =
    //     await (Connectivity().checkConnectivity());

    // if (connectivityResult == ConnectivityResult.none) {
    //   // No internet connection, try login with shared preferences
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String storedPhoneNo = prefs.getString('phoneNo') ?? '';
    //   String storedPassword = prefs.getString('password') ?? '';

    //   if (phoneNo == storedPhoneNo && password == storedPassword) {
    //     // Successful login with stored credentials
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => PolioDashboard()),
    //     );
    //   } else {
    //     // Credentials do not match
    //     _showErrorDialog(context, 'Invalid credentials from local storage.');
    //   }
    // } else {
    // Internet connection available, try login with API
    try {
      final response =
          await ApiService.loginUser(phoneNo: phoneNo, password: password);
      print('Login successful: ${response['message']}   ${response['token']}');

      // Save credentials to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('phoneNo', phoneNo);
      prefs.setString('password', password);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PolioDashboard()),
      );
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'Login failed: $e');
      // }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
