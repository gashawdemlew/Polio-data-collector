import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmPasswordPage extends StatefulWidget {
  final int userId;

  ConfirmPasswordPage({required this.userId});

  @override
  _ConfirmPasswordPageState createState() => _ConfirmPasswordPageState();
}

class _ConfirmPasswordPageState extends State<ConfirmPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showSnackbar('Both fields are required.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = '${baseUrl}user/${widget.userId}';

      // const apiUrl = 'http://192.168.8.228:7476/user/updateUser';
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          "status": "Active,",
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Password updated successfully.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PolioDashboard()),
        );
      } else {
        final data = jsonDecode(response.body);
        _showSnackbar(data['message'] ?? 'Failed to update password.');
      }
    } catch (e) {
      debugPrint('Error updating password: $e');
      _showSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updatePassword,
                    child: Text('Update Password'),
                  ),
          ],
        ),
      ),
    );
  }
}
