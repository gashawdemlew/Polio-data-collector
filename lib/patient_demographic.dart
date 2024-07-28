import 'dart:async';
import 'dart:convert';

import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/drawer.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/mo/constan.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:location/location.dart' as location;

// import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
// import SharedPreferences from 'my_shared_preferences_package'

import '../../util/color/color.dart';
import '../../util/common/theme_helper.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

class Patientdemographic extends StatefulWidget {
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

  Map<String, Map<String, List<String>>> locationData = {
    'Amhara': {
      'North Gonder': ['Debark', 'Dabat'],
      'East Gojam': [
        'Bahirdar',
        'Debremarkos',
        'Enarj Enawga',
        'Mota',
        'Dejen'
      ],
      'South Wollo': ['Dessie', 'Kombolcha', 'Bati', 'Debre Tabor'],
      'North Shewa': ['Debre Berhan', 'Ankober', 'Wuchale', 'Ginchi'],
    },
    'Oromia': {
      'West Arsi Zone': [
        'Shashemene',
        'Arsi Negele',
        'Kofele',
        'Asella',
        'Robe'
      ],
      'East Shewa Zone': ['Adama', 'Bishoftu', 'Mojo', 'Zeway', 'Dera'],
      'Jimma Zone': ['Jimma', 'Agaro', 'Limu Kosa', 'Sekoru', 'Gumii'],
      'Bale Zone': ['Robe', 'Ginnir', 'Goba', 'Delo Mena', 'Sinana'],
      'West Wollega': ['Nekemte', 'Gimbi', 'Dambi Dolo', 'Dembi Dolo', 'Gutin'],
    },
    'Tigray': {
      'North Tigray': ['Shire', 'Axum', 'Adwa', 'Adi Remets', 'Zalambessa'],
      'Central Tigray': ['Mekelle', 'Adigrat', 'Quiha', 'Wukro', 'Hawzien'],
      'Western Tigray': [
        'Humera',
        'Sheraro',
        'Dansha',
        'Adi Gudem',
        'May Tsebri'
      ],
    },
    'Somali': {
      'Siti Zone': ['Shinile', 'Erer', 'Aysha', 'Jijiga', 'Kebri Beyah'],
      'Jarar Zone': ['Degehabur', 'Kebri Dehar', 'Gode', 'Fik', 'Galadi'],
      'Afder Zone': ['Dolo Odo', 'Kelafo', 'Mustahil', 'Filtu', 'Liben'],
    },
    'Afar': {
      'Zone 1': ['Dubti', 'Ereb Ber', 'Awash', 'Asaita', 'Chifra'],
      'Zone 5': ['Ewa', 'Yalo', 'Mille', 'Chifra', 'Afdera'],
      'Zone 4': ['Semera', 'Afrera', 'Dalol', 'Berahle', 'Hamedela'],
    },
    'Benishangul-Gumuz': {
      'Assosa Zone': ['Assosa', 'Bambasi', 'Kurmuk', 'Menge', 'Chagni'],
      'Metekel Zone': ['Pawe', 'Guba', 'Galgalla', 'Bure', 'Shehedi'],
      'Kamashi Zone': ['Asosa', 'Guba Koricha', 'Dibate', 'Beyeda', 'Mandura'],
    },
    'Southern Nations, Nationalities, and Peoples': {
      'Sidama Zone': [
        'Hawassa',
        'Yirgalem',
        'Wendo Genet',
        'Dilla',
        'Aleta Wendo'
      ],
      'Wolaita Zone': ['Sodo', 'Boditi', 'Areka', 'Wolaita Sodo', 'Sawla'],
      'Gurage Zone': ['Butajira', 'Welkite', 'Silti', 'Endegagn', 'Cheha'],
    },
    'Gambela': {
      'Agnewak Zone': ['Gambela', 'Itang', 'Abobo', 'Gog', 'Jor'],
      'Nuer Zone': ['Matar', 'Jikawo', 'Akobo', 'Lare', 'Wanthowa'],
      'Mezhenger Zone': ['Gilo', 'Abobo', 'Gambella', 'Dimma', 'Gog woreda'],
    },
    'Harari': {
      'Harari Region': [
        'Harar',
        'Dire Dawa',
        'Asebe Teferi',
        'Jijiga',
        'Tuliguled'
      ],
      'Dire Dawa Special Zone': [
        'Dire Dawa',
        'Dhagaxbuur',
        'Deder',
        'Gursum',
        'Lebu'
      ],
    },
  };
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

  String _empId = '';
  String _oId = '';
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

  TextEditingController _epidNumberController = TextEditingController();

  final currentDate56 = DateFormat('yyyy-MM-dd').format(DateTime.now());

  double latitude = 0.0;
  double longitude = 0.0;
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
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge); // or "English"
      resource12 = resources;
    });
  }

  Map<String, dynamic> userDetails = {};

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
      };
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
      "region": _selectedRegion,
      "user_id": userDetails['id'],
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
        print('Form submitted successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted successfully!')),
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
      appBar: AppBar(
        title: Text(
          resources?.patientDemographic()["Patientdemographic"] ?? '',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(45.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true, // make it read-only
                controller: TextEditingController(text: latitude.toString()),
                decoration: ThemeHelper().textInputDecoration(
                    '${resources?.patientDemographic()["latitude"] ?? ''}',
                    '${resources?.patientDemographic()["latitude"] ?? ''}'),
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
                    '${resources?.patientDemographic()["longitude"] ?? ''}',
                    '${resources?.patientDemographic()["longitude"] ?? ''}'),
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
                decoration: ThemeHelper().textInputDecoration('first Name'),
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
                decoration: ThemeHelper().textInputDecoration('Last Name'),
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
                decoration: ThemeHelper().textInputDecoration('Phone No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Phon No';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                hint: Text('Select Gender'),
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
                decoration: ThemeHelper()
                    .textInputDecoration('Gender', 'Select Gender'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
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
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                hint: Text('Select Region'),
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
                  'Region',
                  'Select Region',
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
                  hint: Text('Select Zone'),
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
                    'Zone',
                    'Select Zone',
                  ),
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
                  hint: Text('Select Woreda'),
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
                    'Woreda',
                    'Select Woreda',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a woreda';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              Container(
                width: 370,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => ClinicalHistoryForm(
                    //               epid_Number: epid_Number,
                    //               // resources1: widget.resources1,
                    //               // first_name: first_name.text,
                    //               // last_name: last_name.text,
                    //               // phoneNo: phoneNo.text,
                    //               // latitude: latitude.toString(),
                    //               // longitude: longitude.toString(),
                    //               // epid_number: EPID_Number.text,
                    //               // name: names.text,
                    //               // gender: _selectedGender ?? '',
                    //               // dateofbirth: Date_of_birth.text,
                    //               // region: _selectedRegion.toString(),
                    //               // zone: _selectedZone.toString(),
                    //               // woreda: _selectedZone.toString(),
                    //             )));
                  },
                  child: Text(
                    isSubmitting ? 'Saving...' : 'Submit',
                  ),
                  //  isSubmitting ? Text('Saving...') : Text('Submit'),

                  //
                  // Text(
                  //     widget.resources1?.patientDemographic()["next"] ?? ''),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
