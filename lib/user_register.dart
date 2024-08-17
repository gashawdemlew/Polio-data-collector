import 'dart:convert';

import 'package:camera_app/color.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/services/api_service.dart';
import 'package:camera_app/user_list.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart';

class RegisterScreen extends StatefulWidget {
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
  double latitude = 0.0;
  double longitude = 0.0;
  String? selectedRole;
  String? _selectedGender;

  final List<String> roles = [
    'Admin',
    'Health Officer',
    'Volunteers',
    'Laboratorist'
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
  Map<String, Map<String, List<String>>> locationData = {
    'Amhara': {
      'NorthGonder': ['Debark', 'Dabat'],
      'East Gojam': [
        'Bahirdar',
        'Debremarkos',
        'Enarj Enawga',
        'Mota',
        'Dejen'
      ],
      'SouthWollo': ['Dessie', 'Kombolcha', 'Bati', 'Debre Tabor'],
      'NorthShewa': ['DebreBerhan', 'Ankober', 'Wuchale', 'Ginchi'],
    },
    'Oromia': {
      'West Arsi Zone': [
        'Shashemene',
        'Arsi Negele',
        'Kofele',
        'Asella',
        'Robe'
      ],
      'EastShewa': ['Adama', 'Bishoftu', 'Mojo', 'Zeway', 'Dera'],
      'Jimma Zone': ['Jimma', 'Agaro', 'Limu Kosa', 'Sekoru', 'Gumii'],
      'Bale Zone': ['Robe', 'Ginnir', 'Goba', 'Delo Mena', 'Sinana'],
      'West Wollega': ['Nekemte', 'Gimbi', 'Dambi Dolo', 'Dembi Dolo', 'Gutin'],
    },
    'Tigray': {
      'NorthTigray': ['Shire', 'Axum', 'Adwa', 'Adi Remets', 'Zalambessa'],
      'CentralTigray': ['Mekelle', 'Adigrat', 'Quiha', 'Wukro', 'Hawzien'],
      'WesternTigray': [
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
    'Benishangul': {
      'Assosa Zone': ['Assosa', 'Bambasi', 'Kurmuk', 'Menge', 'Chagni'],
      'Metekel Zone': ['Pawe', 'Guba', 'Galgalla', 'Bure', 'Shehedi'],
      'Kamashi Zone': ['Asosa', 'Guba Koricha', 'Dibate', 'Beyeda', 'Mandura'],
    },
    'South': {
      'Sidama Zone': [
        'Hawassa',
        'Yirgalem',
        'Wendo Genet',
        'Dilla',
        'Aleta Wendo'
      ],
      'Wolaita': ['Sodo', 'Boditi', 'Areka', 'Wolaita Sodo', 'Sawla'],
      'Gurage': ['Butajira', 'Welkite', 'Silti', 'Endegagn', 'Cheha'],
    },
    'Gambela': {
      'Agnewak': ['Gambela', 'Itang', 'Abobo', 'Gog', 'Jor'],
      'Nuer Zone': ['Matar', 'Jikawo', 'Akobo', 'Lare', 'Wanthowa'],
      'Mezhenger Zone': ['Gilo', 'Abobo', 'Gambella', 'Dimma', 'Gog woreda'],
    },
    'Harari': {
      'HarariRegion': [
        'Harar',
        'Dire Dawa',
        'Asebe Teferi',
        'Jijiga',
        'Tuliguled'
      ],
      'DireDawa': ['Dire Dawa', 'Dhagaxbuur', 'Deder', 'Gursum', 'Lebu'],
    },
  };
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
            SnackBar(content: Text('Failed to fetch health officers')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CustomColors.testColor1,
          title: Text(
            'Register',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: firstNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration('First Name', 'First Name')),
                SizedBox(height: 16),
                TextField(
                    controller: lastNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration('Last Name', 'Last Name')),
                SizedBox(height: 16),

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

                SizedBox(height: 16),

                TextField(
                    controller: phoneNoController,
                    decoration: ThemeHelper()
                        .textInputDecoration('Phone Number', 'Phone Number')),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration:
                      ThemeHelper().textInputDecoration("Select Region"),
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
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper().textInputDecoration("Select zone"),
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
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      ThemeHelper().textInputDecoration("Select Woreda"),
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

                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper()
                      .textInputDecoration('User Role', 'User Role'),
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
                ),
                SizedBox(
                  height: 16,
                ),
                if (selectedRole == 'Volunteers')
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: ThemeHelper()
                        .textInputDecoration("Selected Health Officer  Woreda"),
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

                SizedBox(height: 16),
                TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: ThemeHelper()
                        .textInputDecoration('Password', 'Password')),
                SizedBox(height: 20),
                Container(
                  width: 370,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please select a user role')));
                        return;
                      }

                      try {
                        final response = await ApiService.createUser(
                          firstName: firstNameController.text,
                          gender: _selectedGender.toString(),
                          lastName: lastNameController.text,
                          phoneNo: phoneNoController.text,
                          region: _selectedRegion.toString(),
                          zone: _selectedZone.toString(),
                          woreda: _selectedWoreda.toString(),
                          lat: latitude.toString(),
                          long: long.toString(),
                          userRole: selectedRole!,
                          emergency_phonno: selectedHealthOfficer ?? "",
                          password: passwordController.text,
                        );
                        print('User created: ${response['message']}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => userList()));
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                    child: Text('Register'),
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
        ));
  }
}
