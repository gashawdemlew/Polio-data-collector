import 'dart:convert';
import 'package:camera_app/color.dart';
import 'package:camera_app/home_page.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart';

class EnvironmentMetrologyForm extends StatefulWidget {
  @override
  final LanguageResources? resources1;
  final String latitude;
  final String longitude;

  final String epid_number;

  final String name;

  final String gender;
  final String dateofbirth;
  final String region;
  final String zone;

  final String woreda;

  final String feverAtOnset;
  final String flaccidParalysis;
  final String paralysisProgressed;
  final String asymmetric;
  final String siteOfParalysis;
  final int totalOPVDoses;
  final String admittedToHospital;
  final String dateOfAdmission;
  final String medicalRecordNo;
  final String facilityName;
  final String dateStool1;
  final String dateStool2;
  final String daysAfterOnset;

  final String stool1DateCollected;
  final String stool2DateCollected;
  final String stool1DaysAfterOnset;
  final String stool2DaysAfterOnset;
  final String stool1DateSentToLab;
  final String stool2DateSentToLab;
  final String stool1DateReceivedByLab;
  final String stool2DateReceivedByLab;
  final String caseOrContact;
  final String specimenCondition;
  final String residualParalysis;

  @override
  EnvironmentMetrologyForm({
    required this.resources1,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.gender,
    required this.dateofbirth,
    required this.zone,
    required this.region,
    required this.epid_number,
    required this.woreda,
    required this.feverAtOnset,
    required this.flaccidParalysis,
    required this.paralysisProgressed,
    required this.asymmetric,
    required this.siteOfParalysis,
    required this.totalOPVDoses,
    required this.admittedToHospital,
    required this.dateOfAdmission,
    required this.medicalRecordNo,
    required this.facilityName,
    required this.dateStool1,
    required this.dateStool2,
    required this.daysAfterOnset,
    required this.stool1DateCollected,
    required this.stool2DateCollected,
    required this.stool1DaysAfterOnset,
    required this.stool1DateSentToLab,
    required this.stool2DateSentToLab,
    required this.stool1DateReceivedByLab,
    required this.stool2DateReceivedByLab,
    required this.caseOrContact,
    required this.specimenCondition,
    required this.stool2DaysAfterOnset,
    required this.residualParalysis,
  });
  _EnvironmentMetrologyFormState createState() =>
      _EnvironmentMetrologyFormState();
}

class _EnvironmentMetrologyFormState extends State<EnvironmentMetrologyForm> {
  double? _dailyAverageTemperature;
  double? _dailyRainfall;
  double? _dailyHumidity;
  double? _dailySoilMoisture;
  String address = '';
  String _latitude = 'Unknown';
  String _longitude = 'Unknown';

  double latitude = 0.0;
  double longitude = 0.0;

  TextEditingController tempController = TextEditingController();
  TextEditingController rainfallController = TextEditingController();
  TextEditingController humidityController = TextEditingController();
  TextEditingController soilMoistureController = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController snow = TextEditingController();

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = '${position.latitude}';
        _longitude = '${position.longitude}';
      });
    } catch (e) {
      print('Error getting location: $e');
    }
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

  void initState() {
    super.initState();

    // Get the current location and then fetch weather data
    getCurrentLocation().then((_) {
      fetchWeatherData();
    });
  }

  Future<void> getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark currentPlace = placemarks[0];
        setState(() {
          address =
              "${currentPlace.street}, ${currentPlace.locality}, ${currentPlace.postalCode}, ${currentPlace.country}";
        });
      } else {
        setState(() {
          address = 'Address not found';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchWeatherData() async {
    final apiKey = 'ab35dbe46a3a4c838547c896b36ce867';

    final response = await http.get(
      Uri.parse(
          'https://api.weatherbit.io/v2.0/current?lat=$latitude&lon=$longitude&key=$apiKey'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      // Check if 'data' field exists and is not empty
      if (data.containsKey('data') &&
          data['data'] is List &&
          data['data'].isNotEmpty) {
        // Access specific fields from the response JSON
        city.text = data['data'][0]['city_name'].toString();

        tempController.text = data['data'][0]['temp'].toString();
        rainfallController.text = data['data'][0]['precip'].toString();
        humidityController.text = data['data'][0]['rh'].toString();
        snow.text = data['data'][0]['snow'].toString();

        soilMoistureController.text =
            data['data'][0]['weather']['description'].toString();
      } else {
        print('No data available');
      }
    } else {
      print('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.resources1?.environmentalMethodology()["appbar"] ?? '',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        // color: Theme.of(context).backgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildArgumentDisplay(),
                TextFormField(
                  controller: city,
                  keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   setState(() {
                  //     _dailyHumidity = double.tryParse(value);
                  //   });
                  // },

                  decoration: ThemeHelper().textInputDecoration(
                      '${widget.resources1?.environmentalMethodology()["city"] ?? ''}',
                      ' ${widget.resources1?.patientDemographic()["city"] ?? ''} '),
                ),
                SizedBox(height: 8.0),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: tempController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _dailyAverageTemperature = double.tryParse(value);
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      '${widget.resources1?.environmentalMethodology()["tempreture"] ?? ''}',
                      ' ${widget.resources1?.patientDemographic()["tempreture"] ?? ''} '),
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: rainfallController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _dailyRainfall = double.tryParse(value);
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      '${widget.resources1?.environmentalMethodology()["rainfall"] ?? ''}',
                      ' ${widget.resources1?.patientDemographic()["rainfall"] ?? ''} '),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: humidityController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _dailyHumidity = double.tryParse(value);
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      '${widget.resources1?.environmentalMethodology()["humidity"] ?? ''}',
                      ' ${widget.resources1?.patientDemographic()["humidity"] ?? ''} '),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: snow,
                  // keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   setState(() {
                  //     _dailyHumidity = double.tryParse(value);
                  //   });
                  // },
                  decoration: ThemeHelper().textInputDecoration(
                      '${widget.resources1?.environmentalMethodology()["snow"] ?? ''}',
                      ' ${widget.resources1?.patientDemographic()["snow"] ?? ''} '),
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 8.0),
                TextFormField(
                  controller: soilMoistureController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _dailySoilMoisture = double.tryParse(value);
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      '${widget.resources1?.environmentalMethodology()["description"] ?? ''}',
                      ' ${widget.resources1?.patientDemographic()["description"] ?? ''} '),
                ),
                SizedBox(height: 16.0),
                Container(
                    width: 370,
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit form data
                        // print('Form submitted!');
                        // print(
                        //     'Daily Average Temperature: $_dailyAverageTemperature');
                        // print('Daily Rainfall: $_dailyRainfall');
                        // print('Daily Humidity: $_dailyHumidity');
                        // print('Daily Soil Moisture: $_dailySoilMoisture');

                        // Call API to fetch weather data
                        // fetchWeatherData();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraPage()));
                      },
                      child: Text('Next'),
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
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildArgumentDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latitude: ${widget.latitude}'),
        Text('Longitude: ${widget.longitude}'),
        Text('Epid Number: ${widget.epid_number}'),
        Text('Name: ${widget.name}'),
        Text('Gender: ${widget.gender}'),
        Text('Date of Birth: ${widget.dateofbirth}'),
        Text('Region: ${widget.region}'),
        Text('Zone: ${widget.zone}'),
        Text('Woreda: ${widget.woreda}'),
        Text('Fever At Onset: ${widget.feverAtOnset}'),
        Text('Flaccid Paralysis: ${widget.flaccidParalysis}'),
        Text('Paralysis Progressed: ${widget.paralysisProgressed}'),
        Text('Asymmetric: ${widget.asymmetric}'),
        Text('Site of Paralysis: ${widget.siteOfParalysis}'),
        Text('Total OPV Doses: ${widget.totalOPVDoses}'),
        Text('Admitted to Hospital: ${widget.admittedToHospital}'),
        Text('Date of Admission: ${widget.dateOfAdmission}'),
        Text('Medical Record No: ${widget.medicalRecordNo}'),
        Text('Facility Name: ${widget.facilityName}'),
        Text('Date Stool 1: ${widget.dateStool1}'),
        Text('Date Stool 2: ${widget.dateStool2}'),
        Text('Days After Onset: ${widget.daysAfterOnset}'),
        Text('Stool 1 Date Collected: ${widget.stool1DateCollected}'),
        Text('Stool 2 Date Collected: ${widget.stool2DateCollected}'),
        Text('Stool 1 Days After Onset: ${widget.stool1DaysAfterOnset}'),
        Text('Stool 2 Days After Onset: ${widget.stool2DaysAfterOnset}'),
        Text('Stool 1 Date Sent to Lab: ${widget.stool1DateSentToLab}'),
        Text('Stool 2 Date Sent to Lab: ${widget.stool2DateSentToLab}'),
        Text('Stool 1 Date Received by Lab: ${widget.stool1DateReceivedByLab}'),
        Text('Stool 2 Date Received by Lab: ${widget.stool2DateReceivedByLab}'),
        Text('Case or Contact: ${widget.caseOrContact}'),
        Text('Specimen Condition: ${widget.specimenCondition}'),
        Text('Residual Paralysis: ${widget.residualParalysis}'),
      ],
    );
  }
}
