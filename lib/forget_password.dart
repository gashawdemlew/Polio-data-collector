import 'package:camera_app/login.dart';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color.dart';
import 'polioDashboard.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({super.key});

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  static const platform = MethodChannel('com.example.sms_sender/sms');

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  String? _selectedLanguage;
  String _smsStatus = '';
  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userDetails = {
          'email': prefs.getString('email') ?? 'N/A',
          'userType': prefs.getString('userType') ?? 'N/A',
          'firstName': prefs.getString('first_name') ?? 'N/A',
          'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
          'zone': prefs.getString('zone') ?? 'N/A',
          'woreda': prefs.getString('woreda') ?? 'N/A',
          'id': prefs.getInt('id')?.toString() ?? 'N/A',
          'selectedLanguage': prefs.getString('selectedLanguage') ?? 'English',
        };
        _selectedLanguage = userDetails['selectedLanguage'];
        _phoneNumberController.text = userDetails['phoneNo'] ?? '';
      });
    } catch (e) {
      debugPrint('Error loading user details: $e');
      _showSnackbar('Failed to load user details.');
    }
  }

  Future<void> _sendSms() async {
    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.isEmpty) {
      _showSnackbar('Phone Number are required.');
      return;
    }

    try {
      final password = await _fetchPassword(phoneNumber);

      if (password.isEmpty) {
        _showSnackbar('Failed to retrieve password.');
        return;
      }

      final message = 'Your password: $password';

      final String result = await platform.invokeMethod('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });

      setState(() {
        _smsStatus = 'SMS sent successfully: $result';
      });
      _showSnackbar('SMS sent successfully.');
      await _updateStatus(phoneNumber, 'pending');
    } on PlatformException catch (e) {
      debugPrint('Error sending SMS: ${e.message}');
      _showSnackbar('Failed to send SMS: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showSnackbar('An unexpected error occurred.');
    }
  }

  Future<String> _fetchPassword(String phoneNo) async {
    String apiUrl = '${baseUrl}user/getUserByPhoNno';
    print(apiUrl);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNo': phoneNo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['password'] ?? '';
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      debugPrint('Error fetching password: $e');
      return '';
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateStatus(String phoneNo, String status) async {
    String apiUrl = '${baseUrl}user/updateUserPhoNo';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNo': phoneNo, 'status': status}),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Status updated to $status.');
      } else {
        debugPrint('Failed to update status: ${response.body}');
        _showSnackbar('Failed to update status.');
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      _showSnackbar('Error updating status.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == "Amharic" ? "SMS ይላኩ" : "Forget Password",
          style: GoogleFonts.splineSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: _selectedLanguage == "Amharic"
                            ? "ስልክ ቁጥር"
                            : "Phone Number",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendSms,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: CustomColors.testColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 14,
                      ),
                      child: Text(
                        _selectedLanguage == "Amharic"
                            ? "SMS ይላኩ"
                            : "Forget Password",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _smsStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _smsStatus.contains('successfully')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
