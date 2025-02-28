import 'dart:convert';

import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/camera_test.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/qrcode_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DateStooleRecieved extends StatefulWidget {
  final String epid_Number;

  const DateStooleRecieved({
    super.key,
    required this.epid_Number,
  });
  @override
  _StoolSpecimensFormState createState() => _StoolSpecimensFormState();
}

class _StoolSpecimensFormState extends State<DateStooleRecieved> {
  DateTime? _stool1DateCollected;
  DateTime? _stool2DateCollected;
  DateTime? _stool1DaysAfterOnset;
  DateTime? _stool2DaysAfterOnset;
  DateTime? _stool1DateSentToLab;
  DateTime? _stool2DateSentToLab;
  DateTime? _stool1DateReceivedByLab;
  DateTime? _stool2DateReceivedByLab;
  final _formKey = GlobalKey<FormState>();

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
    _loadUserDetails();
    _loadLanguage45();
    currentDate = DateTime.now();
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
      String firstName = prefs.getString('first_name') ?? 'N/A';
      String lastName = prefs.getString('last_name') ?? 'N/A';

      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'userType': prefs.getString('userType') ?? 'N/A',
        'firstName': '$firstName $lastName', // Concatenate first and last names
        'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
        'zone': prefs.getString('zone') ?? 'N/A',
        'woreda': prefs.getString('woreda') ?? 'N/A',
        'id': prefs.getInt('id') ?? 'N/A',
      };
    });
  }

  bool isSubmitting = false;
  String? first_name;
  String? last_name;
  String? region;

  String? zone;
  String? woreda;
  String? hofficer_name;
  String? hofficer_phonno;
  Future<void> _submitForm() async {
    if (_stool1DateSentToLab == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date Stool 1 Sent to Lab')),
      );
      return;
    }
    if (_stool2DateSentToLab == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date Stool 2 Sent to Lab')),
      );
      return;
    }

    final url = Uri.parse('${baseUrl}clinic/StoolSpeciement');

    final body = json.encode({
      "epid_number": widget.epid_Number,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Form submitted successfully!');

        final responseData = json.decode(response.body);
        final patientRecord = responseData['patientRecord'];

        setState(() {
          first_name = patientRecord['first_name'];
          last_name = patientRecord['last_name'];
          region = patientRecord['region'];
          zone = patientRecord['zone'];
          woreda = patientRecord['woreda'];
          hofficer_name = userDetails['firstName'];
          hofficer_phonno = userDetails['phoneNo'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );

        _showConfirmationDialog(context, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TakePictureScreen(
                epid_number: widget.epid_Number,
              ),
            ),
          );
        });

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TakePictureScreen(
        //       epid_number: widget.epid_Number,
        //     ),
        //   ),
        // );
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

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            languge == "Amharic"
                ? "ማረጋገጫ"
                : languge == "AfanOromo"
                    ? "mirkaneeffannaa"
                    : "Confirmation",
          ),
          content: Text(languge == "Amharic"
              ? 'እባክዎን ጥራት ያለው እና ያልደበዘዘ ምስል ይቅረጹ። ምስሉ ከተደበዘዘ እንደገና ይጠየቃሉ።'
              : languge == "AfanOromo"
                  ? 'Maaloo suuraa qulqullina qabu fi odeeffannoo gahaa haala dhukkubsataa agarsiisu kaasaa'
                  : 'Please capture a quality and unblurred Image. If the Image is blurred, you will be requested again..'),
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
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(height: 16.0),
                    Text(
                      resources?.stoolSpecimen()["DateSenttoLab"] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      resources?.stoolSpecimen()["stool1"] ?? '',
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _stool1DateSentToLab ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _stool1DateSentToLab = picked;
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
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    Text(
                      '${resources?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_stool1DateSentToLab != null ? _stool1DateSentToLab!.toString().split(' ')[0] : resources?.stoolSpecimen()["notSelected"] ?? ""}',
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      resources?.stoolSpecimen()["stool2"] ?? "",
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _stool2DateSentToLab ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _stool2DateSentToLab = picked;
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
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    Text(
                      languge == "Amharic"
                          ? "ቀን ምረጥ "
                          : languge == "AfanOromo"
                              ? "Guyyaa filadhu"
                              : 'Selected Date (Stool 2)',

                      // ${_stool2DateSentToLab != null ? _stool2DateSentToLab!.toString().split(' ')[0] : resources?.stoolSpecimen()["notSelected"] ?? ""}',
                      style: GoogleFonts.poppins(),
                    ),
                    Text(_stool2DateSentToLab.toString()),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
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
                      child: isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors
                                      .white, // Change color to match your theme
                                  strokeWidth: 3.0, // Adjust thickness
                                ),
                                const SizedBox(
                                    width:
                                        10), // Space between indicator and text
                                Text(
                                  languge == "Amharic"
                                      ? 'እየጫነ ነው...'
                                      : 'Loading...',
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            )
                          : Text(
                              languge == "Amharic"
                                  ? 'ቀጣይ'
                                  : languge == "AfanOromo"
                                      ? 'Ergi'
                                      : 'Next',
                              style: GoogleFonts.poppins(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
