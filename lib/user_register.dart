import 'dart:convert';

import 'package:camera_app/color.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/services/api_service.dart';
import 'package:camera_app/services/locationData.dart';
import 'package:camera_app/user_list.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false; // Track loading state
  double latitude = 0.0;
  double longitude = 0.0;
  String? selectedRole;
  String? _selectedGender;
  String? _selectedGenderValue;
  final List<String> roles = [
    'Admin',
    'Health Officer',
    'Volunteers',
    'Laboratorist',
    'Desicion_maker_commite'
  ];

  String? epidNumber,
      firstName,
      lastName,
      region,
      zone,
      woreda,
      lat = '38976543.0', // Initialize with a default value
      long = '3866990.0', // Initialize with a default value
      selectedHealthOfficer;

  List<String> healthOfficers = []; // List to store fetched health officers
  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedWoreda;

  @override
  void initState() {
    super.initState();
    _loadUserDetails1();
  }

  Map<String, dynamic> userDetails = {};
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

  Future<void> getCurrentLocation() async {
    var locationPlugin = location.Location();

    try {
      location.PermissionStatus permission =
          await locationPlugin.hasPermission();
      if (permission == location.PermissionStatus.denied) {
        permission = await locationPlugin.requestPermission();
        if (permission != location.PermissionStatus.granted) {
          print('Location permission denied');
          return;
        }
      }

      location.LocationData locationData = await locationPlugin.getLocation();

      setState(() {
        latitude = locationData.latitude ?? 0.0;
        longitude = locationData.longitude ?? 0.0;
      });

      print('LatitudeXXXXX: $latitude, LongitudeXXXXX: $longitude');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> fetchHealthOfficers() async {
    if (_selectedRegion != null &&
        _selectedZone != null &&
        _selectedWoreda != null) {
      final response = await http.get(Uri.parse(
          '${baseUrl}clinic/demoByVolunter?woreda=$_selectedWoreda®ion=$_selectedRegion&zone=$_selectedZone'));

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

  void showError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: languge2 == "Amharic"
              ? "መዝግብ"
              : languge2 == "AfanOromo"
                  ? "Fayyadamaa Galmeessaa"
                  : "Register New User",
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: ThemeHelper().textInputDecoration(
                    languge2 == "Amharic"
                        ? "የመጀመሪያ ስም"
                        : languge2 == "AfanOromo"
                            ? "Maqaa"
                            : "First Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lastNameController,
                  decoration: ThemeHelper().textInputDecoration(
                    languge2 == "Amharic"
                        ? "ያባት ስም"
                        : languge2 == "AfanOromo"
                            ? "Maqaa Abbaa"
                            : "Last Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  hint: Text(
                    languge2 == "Amharic"
                        ? "ጾታ ይምረጡ"
                        : languge2 == "AfanOromo"
                            ? "Saala"
                            : "Select Gender",
                  ),
                  value: _selectedGender,
                  dropdownColor: Colors.white,
                  items: [
                    if (languge2 == "Amharic") ...[
                      'ወንድ',
                      'ሴት',
                      'ሌላ',
                    ] else if (languge2 == "AfanOromo") ...[
                      'Dhiira',
                      'Dubartii',
                      'Kan biroo',
                    ] else ...[
                      'Male',
                      'Female',
                      'Other'
                    ]
                  ].map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                      if (newValue == 'Male' ||
                          newValue == 'ወንድ' ||
                          newValue == 'Dhiira') {
                        _selectedGenderValue = 'male';
                      } else if (newValue == 'Female' ||
                          newValue == 'ሴት' ||
                          newValue == 'Dubartii') {
                        _selectedGenderValue = 'female';
                      } else if (newValue == 'Other' ||
                          newValue == 'ሌላ' ||
                          newValue == 'Kan biroo') {
                        _selectedGenderValue = 'other';
                      }
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                    languge2 == "Amharic" ? "ጾታ" : "Gender",
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneNoController,
                  keyboardType: TextInputType.phone,
                  decoration: ThemeHelper().textInputDecoration(
                    languge2 == "Amharic"
                        ? "ስልክ ቁጥር"
                        : languge2 == "AfanOromo"
                            ? "Lakkoofsa Bilbilaa"
                            : "Phone no",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final phoneRegex = RegExp(r'^[0-9]{10}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: ThemeHelper().textInputDecoration(
                      languge2 == "Amharic" ? "የይለፍ ቃል ይሙሉ" : "Enter Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Password";
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: ThemeHelper().textInputDecoration(
                      languge2 == "Amharic" ? "ክልል ይምረጡ" : "Select Region"),
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
                      languge2 == "Amharic" ? "ዞን ይምረጡ" : "Select Zone"),
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
                      languge2 == "Amharic" ? "ወረዳ ይምረጡ" : "Select Woreda"),
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

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper().textInputDecoration(
                      languge2 == "Amharic"
                          ? "የተጠቃሚ ሚና ይምረጡ"
                          : "Select User Role"),
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue;
                    });
                  },
                  items: roles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a user role';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                if (selectedRole == 'Volunteers')
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: ThemeHelper().textInputDecoration(
                        languge2 == "Amharic"
                            ? "የተመረጡ ጤና ባለሙያ"
                            : "Selected Health Officer"),
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
                // SizedBox(height: 16),
                // TextField(
                //     controller: latController,
                //     decoration: ThemeHelper()
                //         .textInputDecoration('Latitude', 'Latitude')),
                // SizedBox(height: 16),
                // TextField(
                //     controller: longController,
                //     decoration: ThemeHelper()
                //         .textInputDecoration('Longitude', 'Longitude')),

                const SizedBox(height: 16),

                const SizedBox(height: 20),
                SizedBox(
                  width: 370,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          final response = await ApiService.createUser(
                            firstName: firstNameController.text,
                            gender: _selectedGenderValue!,
                            lastName: lastNameController.text,
                            phoneNo: phoneNoController.text,
                            region: _selectedRegion.toString(),
                            zone: _selectedZone.toString(),
                            woreda: _selectedWoreda.toString(),
                            lat: latitude.toString(),
                            long: longitude.toString(),
                            userRole: selectedRole!,
                            emergency_phonno: selectedHealthOfficer ?? "",
                            password: passwordController.text,
                          );
                          print('User created: ${response['message']}');
                          showError(context, ' ${response['message']}');
                          // Success, navigate to user list
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => userList()));
                        } catch (e) {
                          showError(context, 'Error: $e');
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
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
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            languge2 == "Amharic" ? "መዝግብ" : "Register",
                          ),
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
