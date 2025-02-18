import 'dart:async';
import 'dart:convert';

import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/drawer.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/mo/constan.dart';
import 'package:camera_app/services/locationData.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:location/location.dart' as location;

// import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import SharedPreferences from 'my_shared_preferences_package'

import '../../util/color/color.dart';
import '../../util/common/theme_helper.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Patientdemographic extends StatefulWidget {
  const Patientdemographic({super.key});

  // const Patientdemographic({});

  @override
  _PatientdemographicState createState() => _PatientdemographicState();
}

class _PatientdemographicState extends State<Patientdemographic> {
  String? selectedFilePath;
  String? selectedFileName;
  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedWoreda;
  String? _selectedGender;
  LanguageResources? resource12;
  LanguageResources? resource;

  String _selectedLanguage = "English";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController EPID_Number = TextEditingController();
  final TextEditingController names = TextEditingController();
  final TextEditingController first_name = TextEditingController();

  final TextEditingController last_name = TextEditingController();
  final TextEditingController phoneNo = TextEditingController();

  // final TextEditingController names = TextEditingController();

  final TextEditingController Date_of_birth = TextEditingController();

  final TextEditingController Province = TextEditingController();
  final TextEditingController District = TextEditingController();
  final _dateController = TextEditingController();

  final String _empId = '';
  final String _oId = '';
  String languge = "ccc";
  LanguageResources? resources;

  late DateTime currentDate;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _loadUserDetails();
    _loadLanguage45();
    currentDate = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    _loadLanguage().then((_) {
      setState(() {
        _selectedLanguage = languge;
        resources = LanguageResources(languge);
      });
    });
  }

  final TextEditingController _epidNumberController = TextEditingController();

  final currentDate56 = DateFormat('yyyy-MM-dd').format(DateTime.now());

  double latitude = 0.0;
  double longitude = 0.0;
  bool _locationFetched = false; // Flag to track if location is fetched

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
        _locationFetched = true; // Set the flag to true after fetching
        print(latitude);
      });

      print('Latitude: $latitude, Longitude: $longitude');

      // getAddressFromLatLng();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'none';
    if (mounted) {
      setState(() {
        languge = storedLanguage;
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

  bool isSubmitting = false;
  String epid_Number = "";
  Future<void> _submitForm() async {
    final url = Uri.parse('${baseUrl}clinic/prtientdemographi');

    final body = json.encode({
      'latitude': latitude,
      'longitude': longitude,
      'first_name': first_name.text,
      'last_name': last_name.text,
      'phoneNo': phoneNo.text,
      "gender": _selectedGender,
      "dateofbirth": Date_of_birth.text,
      "user_id": userDetails['id'],
      "region": _selectedRegion,
      "zone": _selectedZone,
      "woreda": _selectedWoreda
    });

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final responseBody =
            json.decode(response.body); // Decode the response body

        setState(() {
          epid_Number = responseBody['epid_number'];
        });
        print(epid_Number);
        print('Form submitted successfully!  ${responseBody}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ClinicalHistoryForm(epid_Number: epid_Number),
            ));
      } else {
        print('Failed to submit form: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit form: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error submitting form: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $error')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Drawer45(),
      backgroundColor: Color.fromARGB(251, 232, 229, 229),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            resources?.patientDemographic()["Patientdemographic"] ?? '',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.testColor1, Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(4),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true, // make it read-only
                controller: TextEditingController(text: latitude.toString()),
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["latitude"] ?? '',
                    resources?.patientDemographic()["latitude"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Longitude is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                readOnly: true, // make it read-only
                controller: TextEditingController(text: longitude.toString()),
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["longitude"] ?? '',
                    resources?.patientDemographic()["longitude"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Longitude is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: first_name,
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["First name"] ?? '',
                    resources?.patientDemographic()["First name"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Patients Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: last_name,
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["Last name"] ?? '',
                    resources?.patientDemographic()["Last name"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Patients Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: phoneNo,
                decoration: ThemeHelper().textInputDecoration(
                    resources?.patientDemographic()["Phone number"] ?? '',
                    resources?.patientDemographic()["Phone number"] ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length != 10 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                hint: Text(
                  languge == "Amharic"
                      ? "ጾታ ምረጥ"
                      : languge == "AfanOromo"
                          ? "Saala filadhu"
                          : "Select Gender",
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
                    resources?.patientDemographic()["gender"] ?? '',
                    resources?.patientDemographic()["gender"] ?? ''),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: Date_of_birth,
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      Date_of_birth.text = pickedDate
                          .toString()
                          .split(' ')[0]; // Only the date part
                    });
                  }
                },
                decoration: ThemeHelper().textInputDecoration(
                    '${resources?.patientDemographic()["dateOfBirth"] ?? ''} ',
                    '${resources?.patientDemographic()["dateOfBirth"] ?? ''} '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date of birth';
                  }

                  // Date validation logic (example: ensure date is not in the future)
                  try {
                    DateTime selectedDate = DateTime.parse(value);
                    if (selectedDate.isAfter(DateTime.now())) {
                      return 'Date of birth cannot be in the future';
                    }
                  } catch (e) {
                    return 'Invalid date format'; // Handle cases where parsing fails
                  }

                  return null; // Return null if the date is valid
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                hint: Text(
                  languge == "Amharic"
                      ? "ክልል ምረጥ"
                      : languge == "AfanOromo"
                          ? "Naannoo Filadhu"
                          : "Select Region",
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
                    _selectedZone = null; // Reset the zone dropdown
                    _selectedWoreda = null; // Reset the woreda dropdown
                  });
                },
                decoration: ThemeHelper().textInputDecoration(
                  languge == "Amharic" ? "ክልል ምረጥ" : "Select Region",
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a region';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (_selectedRegion != null)
                DropdownButtonFormField<String>(
                  hint: Text(
                    languge == "Amharic"
                        ? "ዞን ምረጥ"
                        : languge == "AfanOromo"
                            ? "Zoonii filadhu"
                            : "Select Zone",
                  ),
                  value: _selectedZone,
                  dropdownColor: Colors.white,
                  items:
                      locationData[_selectedRegion!]!.keys.map((String zone) {
                    return DropdownMenuItem<String>(
                      value: zone,
                      child: Text(zone),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedZone = newValue;
                      _selectedWoreda = null; // Reset the woreda dropdown
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      resources?.patientDemographic()["Select Zone "] ?? '',
                      resources?.patientDemographic()["Select Zone"] ?? ''),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a zone';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              if (_selectedZone != null)
                DropdownButtonFormField<String>(
                  hint: Text(
                    languge == "Amharic"
                        ? "ወረዳ ምረጥ"
                        : languge == "AfanOromo"
                            ? "Woreeda filadhu"
                            : "Select Woreda",
                  ),
                  dropdownColor: Colors.white,
                  value: _selectedWoreda,
                  items: locationData[_selectedRegion!]![_selectedZone!]!
                      .map((String woreda) {
                    return DropdownMenuItem<String>(
                      value: woreda,
                      child: Text(woreda),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedWoreda = newValue;
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      resources?.patientDemographic()["Select Woreda "] ?? '',
                      resources?.patientDemographic()["Select Woreda"] ?? ''),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a woreda';
                    }
                    return null;
                  },
                ),
              // const SizedBox(height: 16.0),
              // const SizedBox(height: 16.0),
              SizedBox(
                width: 370,
                child: ElevatedButton(
                  onPressed: _locationFetched
                      ? () {
                          // Trigger form validation
                          if (_formKey.currentState!.validate()) {
                            _submitForm();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill out all required fields')),
                            );
                          }
                        }
                      : null, // Disable the button when location isn't fetched
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _locationFetched
                        ? CustomColors.testColor1
                        : Colors.grey, // Change the text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8.0), // Adjust the border radius
                    ),
                    elevation: 14, // Add elevation
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(
                          isSubmitting
                              ? (languge == "Amharic"
                                  ? 'ቀጣይ...'
                                  : languge == "AfanOromo"
                                      ? 'OlKaa’uu.'
                                      : 'Saving...')
                              : (languge == "Amharic" ? 'ቀጣይ' : 'Next'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
