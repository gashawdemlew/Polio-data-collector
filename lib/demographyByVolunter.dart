import 'package:camera_app/color.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:camera_app/volunter/vole_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DemographicForm extends StatefulWidget {
  @override
  _DemographicFormState createState() => _DemographicFormState();
}

class _DemographicFormState extends State<DemographicForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController first_name = TextEditingController();
  final TextEditingController last_name = TextEditingController();
  // String? _selectedGender;

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

  String _selectedLanguage = "English";

  List<String> healthOfficers = []; // List to store fetched health officers

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

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Please capture a quality and unblurred image. If the image is blurred, you will be requested again.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
            TextButton(
              child: Text('OK'),
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(
        Uri.parse('http://${baseUrl}clinic/post'),
        body: {
          'epid_number': epidNumber,
          'first_name': firstName,
          'last_name': lastName,
          "region": _selectedRegion,
          "zone": _selectedZone,
          "woreda": _selectedWoreda,
          'lat': lat,
          'long': long,
          'selected_health_officer': selectedHealthOfficer,
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit data')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Demographic Form',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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
                  decoration: ThemeHelper().textInputDecoration("First Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                  controller: first_name,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: ThemeHelper().textInputDecoration("Last Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                  controller: last_name,
                ),
                SizedBox(
                  height: 16,
                ),

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
                // const SizedBox(height: 16.0),
                SizedBox(
                  height: 16,
                ),
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
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper()
                      .textInputDecoration("Selected Health Officer"),
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
                SizedBox(height: 16),
                // Text('Coordinates: Lat ($lat), Long ($long)'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _submitForm();
                    //   },
                    //   child: Text('Submit'),
                    // ),
                    Container(
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
                        child: Text('Submit'),
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
