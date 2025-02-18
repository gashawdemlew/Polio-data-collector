import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/login.dart';
import 'package:camera_app/resetpassword/message.dart';
import 'package:camera_app/util/color/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNo;
  ResetPasswordScreen({required this.phoneNo});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = false; // Initialize password visibility
    confirmPasswordVisible = false;
  }

  void resetPassword() async {
    if (passwordController.text != confirmPasswordController.text) {
      MessageService.showError(context, 'Passwords do not match.');
      return;
    }

    setState(() => isLoading = true);
    bool success = await apiService.resetPassword(
        widget.phoneNo, otpController.text, passwordController.text);
    setState(() => isLoading = false);

    if (success) {
      MessageService.showSuccess(context, 'Password reset successful!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      MessageService.showError(
          context, 'Failed to reset password. Please check your inputs.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: CustomAppBar(title: "Reset Password"),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Icon(
                Icons.lock_reset,
                size: 80,
                color: CustomColors.testColor1,
              ),
              SizedBox(height: 24),

              // Title
              Text(
                "Reset Your Password",
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.testColor1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Subtitle
              Text(
                "Enter the reset code sent to your phone and your new password.",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // OTP Field
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Reset Code",
                  hintText: "Enter the code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.security),
                ),
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  labelText: "New Password",
                  hintText: "Enter new password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  hintText: "Re-enter new password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        confirmPasswordVisible = !confirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Reset Password Button
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
                onPressed: isLoading ? null : resetPassword,
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text("Reset Password",
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
