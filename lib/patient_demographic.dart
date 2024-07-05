import 'dart:async';
import 'dart:convert';

import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/drawer.dart';
import 'package:camera_app/languge/LanguageResources.dart';
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

final dio = Dio();

class Patientdemographic extends StatefulWidget {
  final LanguageResources? resources1;

  const Patientdemographic({required this.resources1});

  @override
  _PatientdemographicState createState() => _PatientdemographicState();
}

class _PatientdemographicState extends State<Patientdemographic> {
  String? selectedFilePath;
  String? selectedFileName;
  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedWoreda;
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
  final TextEditingController Gender = TextEditingController();
  final TextEditingController Date_of_birth = TextEditingController();

  final TextEditingController Province = TextEditingController();
  final TextEditingController District = TextEditingController();

  String _empId = '';
  String _oId = '';

  late DateTime currentDate;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
    getCurrentLocation();
    fetchLastEpidNumber();
    print(_lastEpidNumber);
    currentDate = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
  }

  TextEditingController _epidNumberController = TextEditingController();
  String _lastEpidNumber = 'Loading...';
  Future<void> fetchLastEpidNumber() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:7476/last-epid-number'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        String lastEpidNumber = jsonData['lastEpidNumber'];

        // Extract the numeric part of the epid_number
        final numericPart =
            int.parse(lastEpidNumber.replaceAll(RegExp(r'[^0-9]'), ''));

        // Increment the numeric part
        final nextEpidNumber = numericPart + 1;

        // Format the next epid_number back to the desired format
        final formattedNextEpidNumber =
            'E-${nextEpidNumber.toString().padLeft(3, '0')}';

        setState(() {
          _lastEpidNumber = formattedNextEpidNumber;
          _epidNumberController.text = _lastEpidNumber;
        });
      } else {
        throw Exception('Failed to fetch last epid_number');
      }
    } catch (error) {
      print('Error fetching last epid_number: $error');
    }
  }

  Future<void> _loadSavedValues() async {
    setState(() {});
  }

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
      });

      print('Latitude: $latitude, Longitude: $longitude');

      // getAddressFromLatLng();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _submitForm45() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRegion == null ||
          _selectedZone == null ||
          _selectedWoreda == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select region, zone, and woreda')),
        );
        return;
      }

      // Get current date
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Format the complete epid_number
      final completeEpidNumber =
          '$_selectedRegion-$_selectedZone-$_selectedWoreda-$currentDate-${_epidNumberController.text}';

      // You can now use completeEpidNumber for further processing or submission
      print('Complete EPID Number: $completeEpidNumber');

      // Example code to show the complete epid number (replace this with your actual form submission logic)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete EPID Number: $completeEpidNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Drawer45(),
      appBar: AppBar(
        title: Text(
          widget.resources1?.patientDemographic()["Patientdemographic"] ?? '',
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
                    '${widget.resources1?.patientDemographic()["latitude"] ?? ''}',
                    '${widget.resources1?.patientDemographic()["latitude"] ?? ''}'),
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
                    '${widget.resources1?.patientDemographic()["longitude"] ?? ''}',
                    '${widget.resources1?.patientDemographic()["longitude"] ?? ''}'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Longitude is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _epidNumberController,
                decoration: ThemeHelper().textInputDecoration(
                    '${widget.resources1?.patientDemographic()["epidNumber"] ?? ''} ',
                    '${widget.resources1?.patientDemographic()["epidNumber"] ?? ''}'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an EPID_Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: names,
                decoration: ThemeHelper().textInputDecoration(
                    '${widget.resources1?.patientDemographic()["name"] ?? ''}',
                    '${widget.resources1?.patientDemographic()["name"] ?? ''}'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Patients Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: Gender,
                decoration: ThemeHelper().textInputDecoration(
                    '${widget.resources1?.patientDemographic()["gender"] ?? ''}',
                    '${widget.resources1?.patientDemographic()["gender"] ?? ''} '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Enter Gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: Date_of_birth,
                decoration: ThemeHelper().textInputDecoration(
                    '${widget.resources1?.patientDemographic()["dateOfBirth"] ?? ''} ',
                    '${widget.resources1?.patientDemographic()["dateOfBirth"] ?? ''} '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Enter Date of birth ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: Province,
                // decoration: InputDecoration(labelText: 'Tendername Name'),
                decoration: ThemeHelper().textInputDecoration(
                    '${widget.resources1?.patientDemographic()["province"] ?? ''}',
                    '${widget.resources1?.patientDemographic()["province"] ?? ''}'),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Enter your Province';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButton<String>(
                hint: Text('Select Region'),
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
              ),
              if (_selectedRegion != null)
                DropdownButton<String>(
                  hint: Text('Select Zone'),
                  value: _selectedZone,
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
                ),
              if (_selectedZone != null)
                DropdownButton<String>(
                  hint: Text('Select Woreda'),
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
                ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              Container(
                width: 370,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm45();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClinicalHistoryForm(
                                  resources1: widget.resources1,
                                  latitude: latitude.toString(),
                                  longitude: longitude.toString(),
                                  epid_number: EPID_Number.text,
                                  name: names.text,
                                  gender: Gender.text,
                                  dateofbirth: Date_of_birth.text,
                                  region: _selectedRegion.toString(),
                                  zone: _selectedZone.toString(),
                                  woreda: _selectedZone.toString(),
                                )));
                  },
                  child: Text(
                      widget.resources1?.patientDemographic()["next"] ?? ''),
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
