import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  AuthGuard({required this.child});

  Future<bool> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final userType = prefs.getString('userType');
    return email != null && userType != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthentication(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == true) {
          return child;
        } else {
          Future.microtask(() {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return SizedBox.shrink();
        }
      },
    );
  }
}
