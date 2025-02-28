import 'package:camera_app/color.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/services/locationData.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:camera_app/volunter/new_camera.dart';
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
            languge2 == "Amharic"
                ? "ማረጋገጫ"
                : languge2 == "AfanOromo"
                    ? "mirkaneeffannaa"
                    : "Confirmation",
          ),
          content: Text(languge2 == "Amharic"
              ? 'እባክዎን ጥራት ያለው እና ያልደበዘዘ ምስል ይቅረጹ። ምሰሉም ከተደበዘዘ እንደገና ይጠየቃሉ።'
              : languge2 == "AfanOromo"
                  ? 'Maaloo suuraa qulqullina qabu fi odeeffannoo gahaa haala dhukkubsataa agarsiisu kaasaa '
                  : 'Please capture a quality and unblurred Image. If the image is blurred, you will be requested again.'),
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
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: xx == "Amharic"
            ? "ዴሞግራፊክ ቅጽ ሙላ"
            : xx == "AfanOromo"
                ? " Guca Diimogiraafii"
                : "Demographic Form",
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
                    xx == "Amharic"
                        ? "ስም"
                        : xx == "AfanOromo"
                            ? "Maqaa"
                            : "First name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return xx == "Amharic"
                          ? 'እባክዎ መጀመሪያ ስም ይግቡ'
                          : xx == "AfanOromo"
                              ? 'Maqaa jalqabaa galchi'
                              : 'Please enter first name';
                    }
                    if (value.length < 3) {
                      return xx == "Amharic"
                          ? "ስሙ ቢያንስ 3 ፊደል መሆን አለበት"
                          : xx == "AfanOromo"
                              ? "Maqaan xiqqaateen qubee 3 qabaachuu qaba"
                              : "Name must be at least 3 characters";
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
                    xx == "Amharic"
                        ? "የአባት ስም"
                        : xx == "AfanOromo"
                            ? "Maqaa Abbaa"
                            : "Last Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return xx == "Amharic"
                          ? 'እባክዎ የአባት ስም ይግቡ'
                          : xx == "AfanOromo"
                              ? 'Maqaa Abbaa galchi'
                              : 'Please enter last name';
                    }

                    if (value.length < 3) {
                      return xx == "Amharic"
                          ? "ስሙ ቢያንስ 3 ፊደል መሆን አለበት"
                          : xx == "AfanOromo"
                              ? "Maqaan xiqqaateen qubee 3 qabaachuu qaba"
                              : "Name must be at least 3 characters";
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
                    xx == "Amharic"
                        ? "ጾታ ምረጥ"
                        : xx == "AfanOromo"
                            ? "Saala filadhu"
                            : "Select Gender",
                  ),
                  value: _selectedGender,
                  dropdownColor: Colors.white,
                  items: ['Male', 'Female', 'Other'].map((String gender) {
                    String translatedGender;
                    if (xx == "Amharic") {
                      switch (gender) {
                        case 'Male':
                          translatedGender = 'ወንድ';
                          break;
                        case 'Female':
                          translatedGender = 'ሴት';
                          break;
                        case 'Other':
                          translatedGender = 'ሌላ';
                          break;
                        default:
                          translatedGender =
                              gender; // Fallback, should not happen
                      }
                    } else if (xx == "AfanOromo") {
                      switch (gender) {
                        case 'Male':
                          translatedGender = 'Dhiira';
                          break;
                        case 'Female':
                          translatedGender = 'Dubara';
                          break;
                        case 'Other':
                          translatedGender = 'Kan biraa';
                          break;
                        default:
                          translatedGender =
                              gender; // Fallback, should not happen
                      }
                    } else {
                      translatedGender = gender;
                    }

                    return DropdownMenuItem<String>(
                      value:
                          gender, // Keep the original 'Male', 'Female', 'Other' as the value
                      child: Text(
                          translatedGender), // Display the translated label
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender =
                          newValue; // _selectedGender will hold 'Male', 'Female', or 'Other'
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic"
                        ? "ጾታ ምረጥ"
                        : xx == "AfanOromo"
                            ? "Saala"
                            : "Gender",
                    xx == "Amharic"
                        ? "ጾታዎን ይምረጡ"
                        : xx == "AfanOromo"
                            ? "Maaloo saala keessan filadhaa"
                            : "Select Gender",
                  ),
                  validator: (value) {
                    if (value == null) {
                      return xx == "Amharic"
                          ? 'እባክዎ ጾታዎን ይምረጡ'
                          : xx == "AfanOromo"
                              ? "Maaloo saala keessan filadhaa"
                              : 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: phoneNo,
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic"
                        ? "ስልክ ቁጥር"
                        : xx == "AfanOromo"
                            ? "Lakkoofsa bilbilaa"
                            : "Phone No",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return xx == "Amharic"
                          ? 'እባክዎ ስልክ ቁጥር ይግቡ'
                          : xx == "AfanOromo"
                              ? 'Lakkoofsa bilbilaa galchi'
                              : 'Please enter a Phone No';
                    }
                    if (value.length != 10 ||
                        !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return xx == "Amharic"
                          ? 'እባክዎን ትክክለኛ የ10 አሃዝ ስልክ ቁጥር ያስገቡ'
                          : xx == "AfanOromo"
                              ? "Maaloo lakkoofsa bilbilaa qubee 10 ta'e sirrii ta'e galchi"
                              : 'Please enter a valid 10-digit phone number';
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
                    xx == "Amharic"
                        ? "ክልል ምረጥ"
                        : xx == "AfanOromo"
                            ? "Naannoo"
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
                      _selectedZone = null;
                      _selectedWoreda = null;
                      fetchHealthOfficers();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return xx == "Amharic"
                          ? 'እባክዎ ክልል ይምረጡ'
                          : xx == "AfanOromo"
                              ? "Maaloo naannoo filadhu"
                              : 'Please select a region';
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
                    xx == "Amharic"
                        ? "ዞን ምረጥ"
                        : xx == "AfanOromo"
                            ? "Godina"
                            : "Select Zone",
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
                      return xx == "Amharic"
                          ? 'እባክዎ ዞን ይምረጡ'
                          : xx == "AfanOromo"
                              ? "Maaloo Godina Filadhu"
                              : 'Please select a zone';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  decoration: ThemeHelper().textInputDecoration(
                    xx == "Amharic"
                        ? "ወረዳ ምረጥ"
                        : xx == "AfanOromo"
                            ? "Aanaa"
                            : "Select Woreda",
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
                      return xx == "Amharic"
                          ? 'እባክዎ ወረዳ ይምረጡ'
                          : xx == "AfanOromo"
                              ? "Maaloo Aanaa filadhu"
                              : 'Please select a woreda';
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
                    xx == "Amharic"
                        ? "ባለሙያ ስም ምረጥ"
                        : xx == "AfanOromo"
                            ? "Ogeessa fayyaa filadhu"
                            : "Selected Health Officer",
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
                  // validator: (value) {
                  //   if (value == null) {
                  //     return xx == "Amharic"
                  //         ? 'እባክዎ የጤና ባለሙያ ይምረጡ'
                  //         : xx == "AfanOromo"
                  //             ? "Maaloo ogeessa fayyaa filadhu"
                  //             : 'Please select a health officer';
                  //   }
                  //   return null;
                  // },
                ),
                const SizedBox(height: 16),
                // Text('Coordinates: Lat ($lat), Long ($long)'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          // print(_selectedGender.toString());

                          if (_formKey.currentState!.validate()) {
                            _showConfirmationDialog(context, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TakePictureScreenColounter(
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
                        child: Text(
                          xx == "Amharic"
                              ? "መዝግብ"
                              : xx == "AfanOromo"
                                  ? "Ergi"
                                  : "Submit",
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
