import 'package:camera_app/color.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(SMS());

class SMS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SmsSender(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SmsSender extends StatefulWidget {
  @override
  _SmsSenderState createState() => _SmsSenderState();
}

class _SmsSenderState extends State<SmsSender> {
  static const platform = MethodChannel('com.example.sms_sender/sms');

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();
  final TextEditingController phonNo = TextEditingController();

  String? _selectedGender;

  String _smsStatus = '';
  String userType = '';
  String emergency_phonno = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserDetails();
  }

  Map<String, dynamic> userDetails = {};
  String xx = '';

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'userType': prefs.getString('userType') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
        'zone': prefs.getString('zone') ?? 'N/A',
        'woreda': prefs.getString('woreda') ?? 'N/A',
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
    });

    setState(() {
      xx = userDetails['selectedLanguage'];
    });
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType') ?? '';
      emergency_phonno = prefs.getString('emergency_phonno') ?? '';

      // Set emergency_phonno as the default value for _phoneNumberController
      _phoneNumberController.text = emergency_phonno;
    });
  }

  Future<void> _sendSms() async {
    String fullName = _fullNameController.text;
    String region = _regionController.text;
    String zone = _zoneController.text;
    String woreda = _woredaController.text;
    String phoneNumber = _phoneNumberController.text;
    String gender = _selectedGender.toString();
    String phon = phonNo.text;

    String message = 'fullname: $fullName\n'
        'region: $region\n'
        'gender: $gender\n'
        'zone: $zone\n'
        'woreda: $woreda\n'
        'phone: $phon';

    try {
      final String result =
          await platform.invokeMethod('sendSms', <String, String>{
        'phoneNumber': phoneNumber,
        'message': message,
      });
      setState(() {
        _smsStatus = 'SMS sent successfully: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _smsStatus = "Failed to send SMS: '${e.message}'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          xx == "Amharic" ? "SMS ይላኩ" : "Send SMS",
          style: GoogleFonts.splineSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add navigation logic here to go back to the previous screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PolioDashboard(),
              ),
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
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: xx == "Amharic" ? "ሙሉ ስም" : "Full Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: xx == "Amharic" ? "ክልል" : "Region",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _zoneController,
                      decoration: InputDecoration(
                        labelText: xx == "Amharic" ? "ዞን" : "Zone",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _woredaController,
                      decoration: InputDecoration(
                        labelText: xx == "Amharic" ? "ወረዳ" : "Woreda",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      hint: Text(
                        xx == "Amharic" ? "የጾታ ምረጥ" : "Select Gender",
                      ),
                      value: _selectedGender,
                      dropdownColor: Colors.white,
                      items: ['Male', 'Female'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: xx == "Amharic" ? "ጾታ" : "Gender",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: phonNo,
                      decoration: InputDecoration(
                        labelText:
                            xx == "Amharic" ? "የስልክ ቁጥር" : "Phone Number",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      readOnly: true,
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        filled: true, // Enable the filled property
                        fillColor: Colors.grey[300],
                        labelText: xx == "Amharic"
                            ? "የተቀባይ የስልክ ቁጥር"
                            : "Receiver Phone Number",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendSms,
                      child: Text(
                        xx == "Amharic" ? "SMS ይላኩ" : "Send SMS",
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            CustomColors.testColor1, // Change the text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the border radius
                        ),
                        elevation: 14, // Add elevation
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _smsStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _smsStatus.contains('successfully')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
