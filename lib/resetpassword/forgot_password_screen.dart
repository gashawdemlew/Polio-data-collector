import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/resetpassword/api_service.dart';
import 'package:camera_app/resetpassword/message.dart';
import 'package:camera_app/resetpassword/reset_password_screen.dart';
import 'package:camera_app/util/color/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  void sendResetCode() async {
    setState(() => isLoading = true);
    bool success = await apiService.forgotPassword(phoneController.text);
    setState(() => isLoading = false);

    if (success) {
      MessageService.showInfo(context, 'Reset code sent to your phone');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordScreen(phoneNo: phoneController.text),
        ),
      );
    } else {
      MessageService.showError(context,
          'Failed to send reset code. Please check the phone number.'); // Added more specific error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: "Forgot Password",
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phonelink_lock,
                size: 80,
                color: CustomColors.testColor1,
              ),
              SizedBox(height: 24),
              Text(
                "Forgot Your Password?",
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.testColor1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Enter your registered phone number and we'll send you a reset code.",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Enter your phone number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.testColor1,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  textStyle: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : sendResetCode,
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text("Send Reset Code",
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
