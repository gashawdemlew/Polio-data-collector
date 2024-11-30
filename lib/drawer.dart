import 'dart:async';
import 'package:camera_app/blog/create_blog.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/commite/results.dart';
import 'package:camera_app/demographyByVolunter.dart';
import 'package:camera_app/ho_volunter.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Drawer45 extends StatefulWidget {
  final LanguageResources? resources1;
  final String email;
  final String userType;
  final String languge;

  const Drawer45({
    super.key,
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
    _loadUserDetails1();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Map<String, dynamic> userDetails1 = {};
  String languge2 = '';
  String fname = '';
  String lname = '';

  Future<void> _loadUserDetails1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userDetails1 = {
        'email': prefs.getString('email') ?? 'N/A',
        'userType': prefs.getString('userType') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'lastName': prefs.getString('last_name') ?? 'N/A',
        'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
        'zone': prefs.getString('zone') ?? 'N/A',
        'woreda': prefs.getString('woreda') ?? 'N/A',
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
      setState(() {
        languge2 = userDetails1['selectedLanguage'];
        fname = userDetails1['firstName'] ?? "";
        lname = userDetails1['lastName'] ?? "";
      });
      print(userDetails1);

      // Fetch data by phone number and assign the future to _futureVols
    });
  }

  Future<void> _removeUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
  }

  Future<void> _loadLanguage45() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
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
          child: Column(// Use Column to avoid wrapping ListView in Expanded
              children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomColors.testColor1, Colors.red],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20), // Rounded edges
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                          CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              // backgroundImage: widget.profileUrl != null
                              // ? NetworkImage(widget.profileUrl!)
                              // : null,
                              child: Icon(
                                Icons.person,
                                color: CustomColors.testColor1,
                                size: 50,
                              )),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "$fname $lname",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ])),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (widget.userType == "Health Officer")
                    _buildListTile(
                      context,
                      icon: Icons.home,
                      title: widget.languge == "Amharic"
                          ? 'የበጎ ፍቃደኛ መልዕክት'
                          : 'Volunteers Messages',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DemographiVolPage()),
                      ),
                    ),
                  if (widget.userType == "Laboratorist")
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.blue),
                      title: Text(
                        widget.languge == "Amharic"
                            ? "ያልተሟላ ምርመራ"
                            : 'incomplete investigation ',
                        style: const TextStyle(color: Colors.blue),
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
                      leading: const Icon(Icons.home, color: Colors.blue),
                      title: Text(
                        widget.languge == "Amharic"
                            ? "Qrcode አንብብ"
                            : 'Read QrCode ',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const QRViewExample(),
                          ),
                        );
                      },
                    ),
                  if (widget.userType == "Admin")
                    ListTile(
                      leading: const Icon(Icons.people, color: Colors.blue),
                      title: Text(
                        widget.languge == "Amharic"
                            ? "የተጠቃሚ ምዝገባ"
                            : 'User Registration ',
                        style: const TextStyle(color: Colors.blue),
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
                    leading:
                        const Icon(Icons.account_circle, color: Colors.blue),
                    title: Text(
                      widget.resources1?.drawer()["profile"] ?? '',
                      style: const TextStyle(color: Colors.blue),
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
                      leading:
                          const Icon(Icons.arrow_right, color: Colors.blue),
                      title: Text(
                        widget.languge == "Amharic"
                            ? 'አዲሰ ታካሚ መዝግብ'
                            : widget.languge == "AfanOromo"
                                ? "Ergaa"
                                : 'Create New Patient',
                        style: const TextStyle(
                            color: Color.fromRGBO(33, 150, 243, 1)),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Patientdemographic(),
                          ),
                        );
                      },
                    ),

                  ListTile(
                    leading: const Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      "Results",
                      style: const TextStyle(
                          color: Color.fromRGBO(33, 150, 243, 1)),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EpidDataPage(
                              epidNumber: "CE-KE-DU-11/29/2024-E-042"),
                        ),
                      );
                    },
                  ),
                  // if (widget.userType == "Health Officer")
                  ListTile(
                    leading: const Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      widget.languge == "Amharic"
                          ? 'አዲሰ ብሎግ መዝግብ'
                          : widget.languge == "AfanOromo"
                              ? "Create New Blog"
                              : 'Create New Blog',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateBlogScreen(),
                        ),
                      );
                    },
                  ),

                  if (widget.userType == "Volunteers")
                    ListTile(
                      leading: const Icon(Icons.video_call, color: Colors.blue),
                      title: Text(
                        widget.languge == "Amharic"
                            ? "የተጠረጠረ ታካሚ መዝግብ"
                            : "Register Suspected Patient",
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () => _checkConnectivityAndNavigate(context),
                    ),
                  if (widget.userType == "Health Officer")
                    ListTile(
                      leading:
                          const Icon(Icons.arrow_right, color: Colors.blue),
                      title: Text(
                        widget.languge == "Amharic"
                            ? 'ያላለቁ የታካሚ መዝገቦች'
                            : widget.languge == "AfanOromo"
                                ? "Gosoota galtee"
                                : 'Incomplete petient Records',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DataListPage(),
                          ),
                        );
                      },
                    ),
                  const Divider(color: Colors.blue),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      widget.resources1?.drawer()["logout"] ?? '',
                      style: const TextStyle(color: Colors.red),
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
            )
          ])),
    );
  }

  ListTile _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color iconColor = Colors.blue}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: CustomColors.testColor1,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: CustomColors.testColor1.withOpacity(0.1),
      tileColor: Colors.white,
    );
  }
}
