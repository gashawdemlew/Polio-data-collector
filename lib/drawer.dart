import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/camera/cameraHome.dart';
import 'package:camera_app/camera/videoHome.dart';
import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/controler/FileListPage.dart';
import 'package:camera_app/customform.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/lab_catagories.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/login.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/patient_demographic.dart';
import 'package:camera_app/register_login.dart';
import 'package:camera_app/stole_speciement.dart';
import 'package:camera_app/user_list.dart';
import 'package:camera_app/viewMessage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Drawer45 extends StatelessWidget {
  final LanguageResources? resources1;
  final String email;
  final String userType;
  final String languge;

  Drawer45(
      {required this.userType,
      required this.email,
      required this.languge,
      required this.resources1});
  _removeUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('userType');
    await prefs.remove('email');
  }

  Future<void> _loadLanguage45() async {
    await Future.delayed(Duration(seconds: 1));
  }

  // 'Admin',
  // 'Health Officer',
  // 'Volunteers',
  // 'Laboratorist'
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
                  if (userType == "Health Officer")
                    Text(
                      languge == "Amharic" ? "የጤና መኮንን" : 'Health Officer ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  if (userType == "Volunteers")
                    Text(
                      languge == "Amharic" ? "በጎ ፈቃደኞች" : 'Voluntaries ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  if (userType == "Laboratorist")
                    ListTile(
                      leading: Icon(Icons.ad_units_rounded, color: Colors.blue),
                      title: Text(
                        languge == "Amharic" ? "መነሻ" : 'EPHI labratory ',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                LaboratoryFinalClassificationForm(),
                          ),
                        ); // Add your navigation logic here
                      },
                    ),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (userType == "Laboratorist")
              ListTile(
                leading: Icon(Icons.home, color: Colors.blue),
                title: Text(
                  languge == "Amharic" ? "ላብራቶሪ" : 'Labratory ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewMessage(),
                    ),
                  ); // Add your navigation logic here
                },
              ),
            if (userType == "Admin")
              ListTile(
                leading: Icon(Icons.people, color: Colors.blue),
                title: Text(
                  languge == "Amharic" ? "የተጠቃሚ ምዝገባ" : 'User Registration ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => userList(),
                    ),
                  ); // Add your navigation logic here
                },
              ),
            if (userType == "Health Officer")
              ListTile(
                leading: Icon(Icons.arrow_right, color: Colors.blue),
                title: Text(
                  languge == "Amharic" ? "መልእክት" : 'Message ',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => JHJ(),
                    ),
                  ); // Add your navigation logic here
                },
              ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.blue),
              title: Text(
                resources1?.drawer()["profile"] ?? '',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add your navigation logic here
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.category, color: Colors.blue),
              title: Text(
                resources1?.drawer()["categories"] ?? '',
                style: TextStyle(color: const Color.fromARGB(255, 36, 40, 43)),
              ),
              children: <Widget>[
                if (userType == "Health Officer" || userType == "Volunteers")
                  ListTile(
                    leading: Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      resources1?.drawer()["patientDemographic"] ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Patientdemographic(
                            resources1: resources1,
                          ),
                        ),
                      ); // Add your navigation logic here
                    },
                  ),
                if (userType == "Health Officer" || userType == "Volunteers")
                  ListTile(
                    leading: Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      resources1?.drawer()["clinicalHistory"] ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {},
                  ),
                if (userType == "Health Officer")
                  ListTile(
                    leading: Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      resources1?.drawer()["stoolSpecimen"] ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => StoolSpecimensForm34(
                      //       resources1: resources1,
                      //     ),
                      //   ),
                      // ); // Add your navigation logic here
                    },
                  ),
                if (userType == "Health Officer" || userType == "Volunteers")
                  ListTile(
                    leading: Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      resources1?.drawer()["followUp"] ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => FollowUpExaminationForm(
                      //       resources1: resources1,
                      //     ),
                      //   ),
                      // ); // Add your navigation logic here
                    },
                  ),
                if (userType == "Laboratorist")
                  ListTile(
                    leading: Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      resources1?.drawer()["LaboratoryInformation"] ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => labCatagory(),
                        ),
                      ); // Add your navigation logic here
                    },
                  ),
                if (userType == "Health Officer" || userType == "Volunteers")
                  ListTile(
                    leading: Icon(Icons.arrow_right, color: Colors.blue),
                    title: Text(
                      resources1?.drawer()["environmentalMethodology"] ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EnvironmentMetrologyForm(
                      //       resources1: resources1,
                      //     ),
                      //   ),
                      // ); // Add your navigation logic here
                    },
                  ),
              ],
            ),
            Divider(color: Colors.blue),
            if (email == "Health Officer" || email == "Volunteers")
              ListTile(
                leading: Icon(Icons.camera, color: Colors.blue),
                title: Text(
                  resources1?.drawer()["camera"] ?? '',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => cameraHome(),
                    ),
                  ); // Add your navigation logic here
                },
              ),
            if (userType == "Health Officer" || userType == "Volunteers")
              ListTile(
                leading: Icon(Icons.video_call, color: Colors.blue),
                title: Text(
                  resources1?.drawer()["video"] ?? '',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => videoHome(),
                    ),
                  ); // Add your navigation logic here
                },
              ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue),
              title: Text(
                resources1?.drawer()["setting"] ?? '',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add your navigation logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_right, color: Colors.blue),
              title: Text(
                "Custom Form",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CustomForm(),
                  ),
                ); // Add your navigation logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                resources1?.drawer()["logout"] ?? '',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _removeUserInfo();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                ); // Add your navigation logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}
