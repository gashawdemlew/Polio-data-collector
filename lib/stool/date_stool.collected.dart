import 'dart:convert';

import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/stool/date_stoole_recieved.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DateStoolcollected extends StatefulWidget {
  // final LanguageResources? resources1;
  final String epid_Number;

  // final String first_name;
  // final String last_name;
  // final String region;

  // final String zone;
  // final String woreda;
  // final String hofficer_name;
  // final String hofficer_phonno;

  @override
  const DateStoolcollected({
    super.key,
    // required this.resources1,
    required this.epid_Number,
    // required this.first_name,
    // required this.last_name,
    // required this.zone,
    // required this.region,
    // required this.woreda,
    // required this.hofficer_name,
    // required this.hofficer_phonno,
  });
  @override
  _StoolSpecimensFormState createState() => _StoolSpecimensFormState();
}

class _StoolSpecimensFormState extends State<DateStoolcollected> {
  DateTime? _stool1DateCollected;
  DateTime? _stool2DateCollected;
  DateTime? _stool1DaysAfterOnset;
  DateTime? _stool2DaysAfterOnset;
  DateTime? _stool1DateSentToLab;
  DateTime? _stool2DateSentToLab;
  DateTime? _stool1DateReceivedByLab;
  DateTime? _stool2DateReceivedByLab;
  final String _caseOrContact = '';
  final String _specimenCondition = '';

  String languge = "ccc";
  LanguageResources? resources;
  String _selectedLanguage = "English";
  LanguageResources? resource12;

  late DateTime currentDate;
  late String formattedDate;
  @override
  void initState() {
    super.initState();
    // getCurrentLocation();
    _loadUserDetails();
    _loadLanguage45();
    currentDate = DateTime.now();
    // formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    _loadLanguage().then((_) {
      setState(() {
        _selectedLanguage = languge;
        resources = LanguageResources(languge);
      });
    });
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

  Future<void> _submitForm() async {
    final url = Uri.parse('${baseUrl}clinic/StoolSpeciement');

    final body = json.encode({
      "epid_number": widget.epid_Number,
      'date_stool_1_collected': _stool1DateCollected?.toIso8601String(),
      'date_stool_2_collected': _stool2DateCollected?.toIso8601String(),
      'date_stool_1_sent_lab': _stool1DateSentToLab?.toIso8601String(),
      'date_stool_2_sent_lab': _stool2DateSentToLab?.toIso8601String(),
      'site_of_paralysis': _caseOrContact,
      "user_id": userDetails['id'],
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
        print('Form submitted successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DateStooleRecieved(
              epid_Number: widget.epid_Number,
              // first_name: widget.first_name,
              // last_name: widget.last_name,
              // zone: widget.zone,
              // region: widget.region,
              // woreda: widget.woreda,
              // hofficer_name: widget.hofficer_name,
              // hofficer_phonno: widget.hofficer_phonno,
            ),
          ),
        );
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
      appBar: AppBar(
        title: Text(
          resources?.stoolSpecimen()["appbar"] ?? '',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        // color: Theme.of(context).backgroundColor,
        child: SingleChildScrollView(
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    resources?.stoolSpecimen()["dateStoolCollected"] ?? '',
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    resources?.stoolSpecimen()["stool1"] ?? '',
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _stool1DateCollected ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _stool1DateCollected = picked;
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
                      resources?.stoolSpecimen()["selectDate"] ?? '',
                    ),
                  ),
                  Text(
                    '${resources?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_stool1DateCollected != null ? _stool1DateCollected!.toString().split(' ')[0] : resources?.stoolSpecimen()["notSelected"] ?? ""}',
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    resources?.stoolSpecimen()["stool2"] ?? '',
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _stool2DateCollected ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _stool2DateCollected = picked;
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
                      resources?.stoolSpecimen()["selectDate"] ?? '',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${resources?.stoolSpecimen()["selectedDateStool2"] ?? ""}: ${_stool2DaysAfterOnset != null ? _stool2DaysAfterOnset!.toString().split(' ')[0] : resources?.stoolSpecimen()["notSelected"] ?? ""}',
                  ),
                  const SizedBox(height: 16.0),
                  // Text(
                  //   resources?.stoolSpecimen()["DateSenttoLab"] ?? '',
                  //   style: TextStyle(
                  //     fontSize: 26.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 8.0),
                  // Text(
                  //   resources?.stoolSpecimen()["stool1"] ?? '',
                  // ),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool1DateSentToLab ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool1DateSentToLab = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(resources?.stoolSpecimen()["selectDate"] ?? ''),
                  //   style: ElevatedButton.styleFrom(
                  //     foregroundColor: Colors.white,
                  //     backgroundColor:
                  //         CustomColors.testColor1, // Change the text color
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(
                  //           8.0), // Adjust the border radius
                  //     ),
                  //     elevation: 14, // Add elevation
                  //   ),
                  // ),
                  // Text(
                  //   '${resources?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_stool1DateSentToLab != null ? _stool1DateSentToLab!.toString().split(' ')[0] : "${resources?.stoolSpecimen()["notSelected"] ?? ""}"}',
                  // ),
                  // SizedBox(height: 16.0),
                  // Text(resources?.stoolSpecimen()["stool2"] ?? ""),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool2DateSentToLab ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool2DateSentToLab = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(resources?.stoolSpecimen()["selectDate"] ?? ''),
                  //   style: ElevatedButton.styleFrom(
                  //     foregroundColor: Colors.white,
                  //     backgroundColor:
                  //         CustomColors.testColor1, // Change the text color
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(
                  //           8.0), // Adjust the border radius
                  //     ),
                  //     elevation: 14, // Add elevation
                  //   ),
                  // ),
                  // Text(
                  //   'Selected Date (Stool 2): ${_stool2DateSentToLab != null ? _stool2DateSentToLab!.toString().split(' ')[0] : "Not selected"}',
                  // ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Submit form data
                      print('Form submitted!');
                      print(
                          'Date stool collected (Stool 1): $_stool1DateCollected');
                      print(
                          'Date stool collected (Stool 2): $_stool2DateCollected');
                      print(
                          'Days after onset (Stool 1): $_stool1DaysAfterOnset');
                      print(
                          'Days after onset (Stool 2): $_stool2DaysAfterOnset');
                      print(
                          'Date Sent to Lab (Stool 1): $_stool1DateSentToLab');
                      print(
                          'Date Sent to Lab (Stool 2): $_stool2DateSentToLab');
                      print(
                          'Date stool received by Lab (Stool 1): $_stool1DateReceivedByLab');
                      print(
                          'Date stool received by Lab (Stool 2): $_stool2DateReceivedByLab');
                      print('Case or Contact: $_caseOrContact');
                      print(
                          'Specimen condition on receipt: $_specimenCondition');
                      _submitForm();
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
                    // child: Text(resources?.patientDemographic()["next"] ?? ''),
                    child: Text(
                      isSubmitting ? 'Saving...' : 'Submit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
