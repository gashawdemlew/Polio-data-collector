import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/services/locationData.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:camera_app/volunter/vole_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:location/location.dart' as location;

import 'package:shared_preferences/shared_preferences.dart';

class DemographicForm extends StatefulWidget {
  const DemographicForm({super.key});

  @override
  _DemographicFormState createState() => _DemographicFormState();
}

class _DemographicFormState extends State<DemographicForm> {
  final _formKey = GlobalKey<FormState>();
  LanguageResources? resource12;
  LanguageResources? resources;

  String languge = "ccc";
  String languge1 = "";

  final String _selectedLanguage = "English";

  LanguageResources? resource;
  final TextEditingController first_name = TextEditingController();
  final TextEditingController last_name = TextEditingController();
  // String? _selectedGender;
  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'none';
    if (mounted) {
      setState(() {
        languge = storedLanguage;
        languge1 = storedLanguage;
      });
    }
  }

  Future<void> _loadLanguage45() async {
    // Simulate language loading
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge); // or "English"
      resource12 = resources;
    });
  }

  String? epidNumber,
      firstName,
      lastName,
      region,
      zone,
      woreda,
      lat = '38976543.0', // Initialize with a default value
      long = '3866990.0', // Initialize with a default value
      selectedHealthOfficer;

  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedWoreda;
  String? _selectedGender;
  final TextEditingController phoneNo = TextEditingController();

  List<String> healthOfficers = []; // List to store fetched health officers

  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    // getCurrentLocation();
    _loadUserDetails1();
    _loadUserDetails();
  }

  String xx = "";
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

  Future<void> fetchHealthOfficers() async {
    if (_selectedRegion != null &&
        _selectedZone != null &&
        _selectedWoreda != null) {
      final response = await http.get(Uri.parse(
          '${baseUrl}clinic/demoByVolunter?woreda=$_selectedWoreda&region=$_selectedRegion&zone=$_selectedZone'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          healthOfficers = data
              .map((user) => user['phoneNo'] as String ?? "")
              .toSet()
              .toList(); // Ensure no duplicates
          if (!healthOfficers.contains(selectedHealthOfficer)) {
            selectedHealthOfficer =
                null; // Reset if selected value is not in the list
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch health officers')));
      }
    }
  }

  Map<String, dynamic> userDetails1 = {};
  String languge2 = '';

  Future<void> _loadUserDetails1() async {
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
      setState(() {
        languge2 = userDetails['selectedLanguage'];
      });
      print(userDetails);

      // Fetch data by phone number and assign the future to _futureVols
    });
  }

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            languge2 == "Amharic" ? "ማረጋገጫ" : "Confirmation",
          ),
          content: Text(languge2 == "Amharic"
              ? 'እባክዎን ጥራት ያለው እና ያልደበዘዘ ቪዲዮ ይቅረጹ። ቪዲዮው ከተደበዘዘ እንደገና ይጠየቃሉ።'
              : languge2 == "AfanOromo"
                  ? 'Odeeffannoon barbaachisu akka hin dhabamnetti suura qulqullina qabu kaasaa. '
                  : 'Please capture a quality and unblurred video. If the video is blurred, you will be requested again..'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
                onConfirm(); // Calls the callback to navigate to TakePictureScreen
              },
            ),
          ],
        );
      },
    );
  }

  double latitude = 0.0;
  double longitude = 0.0;
  Future<void> getCurrentLocation(dynamic location) async {
    var locationPlugin = location.Location();

    try {
      var permission = await locationPlugin.hasPermission();
      if (permission == location.PermissionStatus.denied) {
        permission = await locationPlugin.requestPermission();
        if (permission != location.PermissionStatus.granted) {
          print('Location permission denied');
          return;
        }
      }

      var locationData = await locationPlugin.getLocation();

      setState(() {
        latitude = locationData.latitude ?? 0.0;
        longitude = locationData.longitude ?? 0.0;
        print(latitude);
      });

      print('Latitude: $latitude, Longitude: $longitude');

      // getAddressFromLatLng();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          xx == "Amharic" ? "ዴሞግራፊክ ቅጽ ሙላ" : "Demographic Form",
          style: GoogleFonts.splineSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ስም" : "First name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return xx == "Amharic"
                          ? 'እባክዎ መጀመሪያ ስም ይግቡ'
                          : 'Please enter first name';
                    }
                    return null;
                  },
                  controller: first_name,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "የአባት ስም" : "Last Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return xx == "Amharic"
                          ? 'እባክዎ የአባት ስም ይግቡ'
                          : 'Please enter last name';
                    }
                    return null;
                  },
                  controller: last_name,
                ),
                const SizedBox(
                  height: 16,
                ),

                DropdownButtonFormField<String>(
                  hint: Text(
                    xx == "Amharic" ? "ጾታ ምረጥ" : "Select Gender",
                  ),
                  value: _selectedGender,
                  dropdownColor: Colors.white,
                  items: ['Male', 'Female', 'Other'].map((String gender) {
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
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ጾታ ምረጥ" : "Gender",
                    xx == "Amharic" ? "ጾታዎን ይምረጡ" : "Select Gender",
                  ),
                  validator: (value) {
                    if (value == null) {
                      return xx == "Amharic"
                          ? 'እባክዎ ጾታዎን ይምረጡ'
                          : 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: phoneNo,
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ስልክ ቁጥር" : "Phone No",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return xx == "Amharic"
                          ? 'እባክዎ ስልክ ቁጥር ይግቡ'
                          : 'Please enter a Phone No';
                    }
                    if (value.length != 10 ||
                        !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                // const SizedBox(height: 16.0),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ክልል ምረጥ" : "Select Region",
                  ),
                  dropdownColor: Colors.white,
                  value: _selectedRegion,
                  items: locationData.keys.map((String region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRegion = newValue;
                      _selectedZone = null;
                      _selectedWoreda = null;
                      fetchHealthOfficers();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a region';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ዞን ምረጥ" : "Select Zone",
                  ),
                  value: _selectedZone,
                  items: _selectedRegion != null
                      ? locationData[_selectedRegion!]!.keys.map((String zone) {
                          return DropdownMenuItem<String>(
                            value: zone,
                            child: Text(zone),
                          );
                        }).toList()
                      : [],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedZone = newValue;
                      _selectedWoreda = null;
                      fetchHealthOfficers();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a zone';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ወረዳ ምረጥ" : "Select Woreda",
                  ),
                  dropdownColor: Colors.white,
                  value: _selectedWoreda,
                  items: _selectedRegion != null && _selectedZone != null
                      ? locationData[_selectedRegion]![_selectedZone]!
                          .map((String woreda) {
                          return DropdownMenuItem<String>(
                            value: woreda,
                            child: Text(woreda),
                          );
                        }).toList()
                      : [],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedWoreda = newValue;
                      fetchHealthOfficers();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a woreda';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic" ? "ባለሙያ ስም ምረጥ" : "Selected Health Officer",
                  ),
                  value: selectedHealthOfficer,
                  items: healthOfficers.map((String officer) {
                    return DropdownMenuItem<String>(
                      value: officer,
                      child: Text(officer),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedHealthOfficer = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a health officer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Text('Coordinates: Lat ($lat), Long ($long)'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _submitForm();
                    //   },
                    //   child: Text('Submit'),
                    // ),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VolTakePictureScreen(
                                  // epidNumber: epidNumber ?? '',
                                  first_name: first_name.text,
                                  last_name: last_name.text,
                                  region: _selectedRegion ?? '',
                                  zone: _selectedZone ?? '',
                                  woreda: _selectedWoreda ?? '',
                                  gender: _selectedGender.toString(),
                                  phonNo: phoneNo.text,
                                  lat: lat.toString(),
                                  long: long.toString(),
                                  selected_health_officer:
                                      selectedHealthOfficer ?? '',
                                ),
                              ),
                            );
                          });
                        },
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
                        child: Text(
                          xx == "Amharic" ? "መዝግብ" : "Submit",
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
