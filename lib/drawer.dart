import 'dart:async';
import 'package:camera_app/blog/create_blog.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/commite/list_petients.dart';
import 'package:camera_app/modelResults/complete_peitient.dart';
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
    _loadUserDetails1();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
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
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => DemographicForm()));
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => SMS()));
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
                gradient: LinearGradient(
                  colors: [CustomColors.testColor1, Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  Text(
                    " $fname $lname",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.userType,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.userType == "Health Officer")
              ListTile(
                leading: Icon(Icons.message_rounded, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? 'የበጎ ፍቃደኛ መልዕክት'
                      : widget.languge == "AfanOromo"
                          ? "Ergaa Tola ooltotaa"
                          : 'Volunteer message',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DemographiVolPage(),
                    ),
                  );
                },
              ),

            if (widget.userType == "Laboratorist")
              ListTile(
                leading: Icon(Icons.compare_outlined, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? "ያልተሟላ ምርመራ"
                      : widget.languge == "AfanOromo"
                          ? "qorannoo guutuu hin taane"
                          : 'incomplete investigation ',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => YU()));
                },
              ),
            if (widget.userType == "Laboratorist")
              ListTile(
                leading: Icon(Icons.qr_code, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? "QR code አንብብ"
                      : widget.languge == "AfanOromo"
                          ? "QR koodii dubbisi"
                          : 'Read QrCode ',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => QRViewExample()),
                  );
                },
              ),
            if (widget.userType == "Admin")
              ListTile(
                leading: const Icon(
                  Icons.kebab_dining_outlined,
                  color: Colors.black,
                ),
                title: Text(
                  widget.languge == "Amharic"
                      ? 'አዲሰ ብሎግ መዝግብ'
                      : widget.languge == "AfanOromo"
                          ? "Biloogii haaraa uumi"
                          : 'Create New Blog',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateBlogScreen()),
                  );
                },
              ),
            if (widget.userType == "Desicion_maker_commite")
              ListTile(
                leading: const Icon(
                  Icons.summarize_outlined,
                  color: Colors.black,
                ),
                title: Text(
                  widget.languge == "Amharic"
                      ? 'ውሳኔ ያድርጉ'
                      : widget.languge == "AfanOromo"
                          ? "Murtoo kennuu"
                          : 'make decision',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PatientDataPage()),
                  );
                },
              ),
            if (widget.userType == "Admin")
              ListTile(
                leading: Icon(Icons.people_outline, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? "የተጠቃሚ ምዝገባ"
                      : widget.languge == "AfanOromo"
                          ? "Galmee Fayyadamtootaa"
                          : 'User Registration ',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => UserList()));
                },
              ),
            ListTile(
              leading: Icon(Icons.people_alt_outlined, color: Colors.black),
              title: Text(
                widget.resources1?.drawer()["profile"] ?? '',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => UserProfile()));
              },
            ),
            if (widget.userType == "Health Officer")
              ListTile(
                leading: Icon(Icons.add_box, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? 'አዲሰ ታካሚ መዝግብ'
                      : widget.languge == "AfanOromo"
                          ? "Dhukkubsataa haaraa galmeessi"
                          : 'Create New Patient',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
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
                leading: Icon(Icons.dashboard_customize, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? "የተጠረጠረ ታካሚ መዝግብ"
                      : widget.languge == "AfanOromo"
                          ? "Dhukkubsataa shakkame galmeess"
                          : "Register Suspected Patient",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _checkConnectivityAndNavigate(context),
              ),
            if (widget.userType == "Health Officer")
              ListTile(
                leading: Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Colors.black,
                ),
                title: Text(
                  widget.languge == "Amharic"
                      ? 'ያለቀ የታካሚ መዝገቦች'
                      : widget.languge == "AfanOromo"
                          ? "Galmee dhukkubsataa guutuu hin taane"
                          : 'Complete patient Records',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => Complete()));
                },
              ),
            if (widget.userType == "Health Officer")
              ListTile(
                leading: Icon(Icons.incomplete_circle, color: Colors.black),
                title: Text(
                  widget.languge == "Amharic"
                      ? 'ያላለቁ የታካሚ መዝገቦች'
                      : widget.languge == "AfanOromo"
                          ? "Gosoota galtee"
                          : 'Incomplete patient Records',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DataListPage()),
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
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                _removeUserInfo();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
