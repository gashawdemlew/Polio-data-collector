import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'color.dart';
import 'languge/LanguageResources.dart';

class LaboratoryFinalClassificationForm extends StatefulWidget {
  final String epid;
  final String type;

  const LaboratoryFinalClassificationForm({
    super.key,
    required this.epid,
    required this.type,
  });
  @override
  _LaboratoryFinalClassificationFormState createState() =>
      _LaboratoryFinalClassificationFormState();
}

class _LaboratoryFinalClassificationFormState
    extends State<LaboratoryFinalClassificationForm> {
  String _selectedLanguage = "English";
  LanguageResources? resources;
  LanguageResources? resource12;
  String languge = "ccc";
  String _trueAFP = '';
  String _finalCellCultureResult = '';
  DateTime? _dateFinalCellCultureResults;
  String _finalCombinedITDResult = '';
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    setState(() {
      _selectedLanguage = languge;
      resources = LanguageResources(languge);
    });
  }

  String ff = '';
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
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
    });

    setState(() {
      ff = userDetails['selectedLanguage'];
    });
  }

  Future<void> _loadLanguage45() async {
    // Simulate language loading
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge); // or "English"
      resource12 = resources;
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      isSubmitting = true;
    });

    final url =
        Uri.parse('${baseUrl}clinic/post'); // Update with your server URL

    final body = json.encode({
      'epid_number': widget.epid,
      'true_afp': _trueAFP,
      'type': widget.type,
      'user_id': userDetails['user_id'],
      'completed': 'true',
      'final_cell_culture_result': _finalCellCultureResult,
      'date_cell_culture_result':
          _dateFinalCellCultureResults?.toIso8601String(),
      'final_combined_itd_result': _finalCombinedITDResult,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        print('Form submitted successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered')),
        );

        // Check the widget.type
        if (widget.type == "Stool 2") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PolioDashboard()),
          );
        }
      } else {
        print('Failed to submit form: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register')),
        );
      }
    } catch (error) {
      print('Error submitting form: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
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
          " ${widget.type} ",
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Container(
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
                  const Text(
                    'True AFP:  ',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: Text(ff == "Amharic" ? 'አዎ' : 'Yes'),
                          value: 'Yes',
                          groupValue: _trueAFP,
                          onChanged: (value) {
                            setState(() {
                              _trueAFP = value.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: Text(
                            ff == "Amharic" ? "አይ" : "No",
                          ),
                          value: 'No',
                          groupValue: _trueAFP,
                          onChanged: (value) {
                            setState(() {
                              _trueAFP = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    ff == "Amharic"
                        ? "የመጨረሻ  ውጤት:"
                        : "Final Cell Culture Result:",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        title: Text(
                          ff == "Amharic"
                              ? " ፖሊኦቪረስ ተጠርጣሪ"
                              : "Suspected Poliovirus",
                        ),
                        value: 'Suspected Poliovirus',
                        groupValue: _finalCellCultureResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCellCultureResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text(
                          ff == "Amharic" ? "አልተገኘም" : "Negative",
                        ),
                        value: 'Negative',
                        groupValue: _finalCellCultureResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCellCultureResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text(
                          ff == "Amharic" ? "ኤንፒንት" : "NPENT",
                        ),
                        value: 'NPENT',
                        groupValue: _finalCellCultureResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCellCultureResult = value.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    ff == "Amharic"
                        ? "የመጨረሻ ቀን ውጤቶች :"
                        : "Date Final Cell Culture Results:",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _dateFinalCellCultureResults ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateFinalCellCultureResults = picked;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 14,
                    ),
                    child: Text(
                      ff == "Amharic" ? "ቀን ይምረጡ" : "Select Date",
                    ),
                  ),
                  Text(
                    'Selected Date (Final Cell Culture Results): ${_dateFinalCellCultureResults != null ? _dateFinalCellCultureResults!.toString().split(' ')[0] : "Not selected"}',
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    ff == "Amharic"
                        ? "የመጨረሻ  አይቲዲ ውጤት:"
                        : "Final Combined ITD Result:",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        title: Text(
                          ff == "Amharic" ? "የተረጋገጠ" : "Confirmed",
                        ),
                        value: 'Confirmed',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text(
                          ff == "Amharic" ? "ተስማሚ" : "Compatible",
                        ),
                        value: 'Compatible',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text(
                          ff == "Amharic" ? "የተወው" : "Discarded",
                        ),
                        value: 'Discarded',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text(
                          ff == "Amharic" ? " ኤፍፒ አይደለም" : "Not an AFP",
                        ),
                        value: 'Not an AFP',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 14,
                    ),
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
