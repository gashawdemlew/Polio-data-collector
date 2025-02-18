import 'dart:convert';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const platform = MethodChannel('com.example.sms_sender/sms');

  Future<bool> forgotPassword(String phoneNo) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}user/forgot-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNo": phoneNo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);
        String? resetCode =
            data['resetToken']; // ✅ Extract reset code from backend

        if (resetCode != null) {
          _sendSms(resetCode, phoneNo); // ✅ Send actual reset code
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> _sendSms(String resetCode, String phoneNo) async {
    try {
      final String message = 'Your reset password code: $resetCode';

      final String result = await platform.invokeMethod('sendSms', {
        'phoneNumber': phoneNo, // FIXED: Added `.text`
        'message': message,
      });

      print('SMS sent successfully: $result');
    } on PlatformException catch (e) {
      debugPrint('Error sending SMS: ${e.message}');
      print('Failed to send SMS: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      print('An unexpected error occurred.');
    }
  }

  Future<bool> resetPassword(
      String phoneNo, String resetToken, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}user/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNo": phoneNo,
          "resetToken": resetToken,
          "newPassword": newPassword
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
