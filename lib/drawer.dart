import 'dart:async';
import 'package:camera_app/camera/cameraHome.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/demographyByVolunter.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/login.dart';
import 'package:camera_app/patient_demographic.dart';
import 'package:camera_app/profile.dart';
import 'package:camera_app/qr_scanner.dart';
import 'package:camera_app/sessionPage.dart';
import 'package:camera_app/sms.dart';
import 'package:camera_app/stool_message.dart';
import 'package:camera_app/user_list.dart';
import 'package:camera_app/viewMessage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Drawer45 extends StatefulWidget {
  final LanguageResources? resources1;
  final String email;
  final String userType;
  final String languge;

  Drawer45({
    required this.userType,
    required this.email,
    required this.languge,
    required this.resources1,
  });

  @override
  _Drawer45State createState() => _Drawer45State();
}

class _Drawer45State extends State<Drawer45> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _removeUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
  }

  Future<void> _loadLanguage45() async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
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

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }

  Future<void> _checkConnectivityAndNavigate(BuildContext context) async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.toString() != [ConnectivityResult.none].toString()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DemographicForm(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SMS(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: CustomColors.testColor1,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  if (widget.userType == "Health Officer")
                    Text(
                      widget.languge == "Amharic"
                          ? "የጤና መኮንን"
                          : 'Health Officer ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  Text(
                    widget.userType,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.userType == "Laboratorist")
              ListTile(
                leading: Icon(Icons.home, color: Colors.blue),
                title: Text(
                  widget.languge == "Amharic"
                      ? "incomplete investigation"
                      : 'incomplete investigation ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => YU(),
                    ),
                  );
                },
              ),
            if (widget.userType == "Laboratorist")
              ListTile(
                leading: Icon(Icons.home, color: Colors.blue),
                title: Text(
                  widget.languge == "Amharic" ? "Read QrCode" : 'Read QrCode ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QRViewExample(),
                    ),
                  );
                },
              ),
            if (widget.userType == "Admin")
              ListTile(
                leading: Icon(Icons.people, color: Colors.blue),
                title: Text(
                  widget.languge == "Amharic"
                      ? "የተጠቃሚ ምዝገባ"
                      : 'User Registration ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => userList(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.blue),
              title: Text(
                widget.resources1?.drawer()["profile"] ?? '',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ),
                );
              },
            ),
            if (widget.userType == "Health Officer")
              ListTile(
                leading: Icon(Icons.arrow_right, color: Colors.blue),
                title: Text(
                  "create  New petient",
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Patientdemographic(),
                    ),
                  );
                },
              ),
            if (widget.userType == "Volunteers")
              ListTile(
                leading: Icon(Icons.video_call, color: Colors.blue),
                title: Text(
                  'Register Suspected Patient ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () => _checkConnectivityAndNavigate(context),
              ),
            if (widget.userType == "Health Officer")
              ListTile(
                leading: Icon(Icons.arrow_right, color: Colors.blue),
                title: Text(
                  'Incomplete Petient Records',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DataListPage(),
                    ),
                  );
                },
              ),
            Divider(color: Colors.blue),
            // ListTile(
            //   leading: Icon(Icons.settings, color: Colors.blue),
            //   title: Text(
            //     widget.resources1?.drawer()["setting"] ?? '',
            //     style: TextStyle(color: Colors.blue),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                widget.resources1?.drawer()["logout"] ?? '',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _removeUserInfo();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
