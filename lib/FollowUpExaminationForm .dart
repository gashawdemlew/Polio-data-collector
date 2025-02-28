import 'dart:convert';

import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FollowUpExaminationForm extends StatefulWidget {
  final LanguageResources? resources1;
  final String epid_Number;

  const FollowUpExaminationForm({
    super.key,
    required this.resources1,
    required this.epid_Number,
  });

  @override
  _FollowUpExaminationFormState createState() =>
      _FollowUpExaminationFormState();
}

class _FollowUpExaminationFormState extends State<FollowUpExaminationForm> {
  DateTime? _dateFollowUpExamination;
  final TextEditingController _dateOfDeathController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a global key for the form

  // Unified Map for all languages, with keys
  // that are consistent (using a unique identifier)
  Map<String, bool> _residualParalysis = {
    'right_arm': false,
    'left_leg': false,
    'right_leg': false,
    'left_arm': false,
  };

  String _findingsAtFollowUp = '';

  Map<String, dynamic> userDetails = {};

  // Maps for labels based on Language
  final Map<String, Map<String, String>> _paralysisLabels = {
    'English': {
      'right_arm': 'Right arm',
      'left_leg': 'Left leg',
      'right_leg': 'Right leg',
      'left_arm': 'Left arm',
    },
    'Amharic': {
      'right_arm': "ቀኝ ክንድ",
      'left_leg': "ግራ እግር",
      'right_leg': "ቀኝ እግር",
      'left_arm': "ግራ ክንድ",
    },
    'AfanOromo': {
      'right_arm': 'Harka mirgaa',
      'left_leg': 'Miila bitaa',
      'right_leg': 'Miila mirgaa',
      'left_arm': 'Harka bitaa',
    },
  };
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
        'id': prefs.getInt('id') ?? 'N/A',
      };
    });
  }

  void initState() {
    super.initState();
    getLocalstorage();
    _loadUserDetails();
  }

  bool isSubmitting = false;

  Future<void> _submitForm() async {
    // if (_dateFollowUpExamination == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //         content: Text('Please select Date of Follow-up Examination')),
    //   );
    //   return;
    // }

    // if (_findingsAtFollowUp == 'Lost to follow-up' &&
    //     _dateOfDeathController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('If lost to follow up, please fill in Date of Death'),
    //     ),
    //   );
    //   return;
    // }

    final url = Uri.parse('${baseUrl}clinic/followup');

    final body = json.encode({
      "epid_number": widget.epid_Number,
      'date_follow_up_investigation':
          _dateFollowUpExamination?.toIso8601String(),
      'residual_paralysis':
          _residualParalysis.toString(), // Save from the single map
      "user_id": userDetails['id'],
    });
    print(body);

    setState(() {
      isSubmitting = true;
    });
    print(body);
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
              builder: (context) => EnvironmentMetrologyForm(
                  resources1: widget.resources1,
                  epid_number: widget.epid_Number),
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

  String lang = "";
  // String xx="";
  void getLocalstorage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    xx = pref.getString("selectedLanguage") ??
        ""; // Use getString for String values

    setState(() {
      lang = xx ?? "English"; // Provide a default value if xx is null
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
          title: lang == "Amharic"
              ? "መከታተል"
              : lang == "AfanOromo"
                  ? "Qorannoo hordoffii"
                  : "Follow Up"),
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: const Color.fromARGB(255, 233, 230, 230),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.resources1
                            ?.followUp()["DateofFollowupExamination"] ??
                        '',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dateFollowUpExamination ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateFollowUpExamination = picked;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      widget.resources1
                              ?.followUp()["DateofFollowupExamination"] ??
                          '',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${widget.resources1?.followUp()["selectedDate"] ?? ''}: ${_dateFollowUpExamination != null ? DateFormat('yyyy-MM-dd').format(_dateFollowUpExamination!) : widget.resources1 == "Amharic" ? 'አልተመረጠም' : widget.resources1 == "AfanOromo" ? 'Guyyaa filadhu: hin filatamne' : 'Not Selected'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    widget.resources1?.followUp()["ResidualParalysis"] ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _residualParalysis.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_paralysisLabels[lang]?[key] ?? key}:",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            CheckboxListTile(
                              title: Text(
                                lang == "Amharic"
                                    ? 'አዎ'
                                    : lang == "AfanOromo"
                                        ? "Eeyyee"
                                        : 'Yes',
                                style: GoogleFonts.poppins(),
                              ),
                              value: _residualParalysis[key],
                              onChanged: (value) {
                                if (value != null)
                                  setState(() {
                                    _residualParalysis[key] = value;
                                  });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 5.0),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  // const SizedBox(height: 20.0),
                  Text(
                    widget.resources1?.followUp()["FindingsatFollowup"] ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(
                          widget.resources1?.followUp()["Losttofollowup"] ?? '',
                          style: GoogleFonts.poppins(),
                        ),
                        value: _findingsAtFollowUp == 'Lost to follow-up',
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _findingsAtFollowUp = 'Lost to follow-up';
                            } else {
                              _findingsAtFollowUp =
                                  ''; // Optionally handle unchecking
                            }
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_findingsAtFollowUp == 'Lost to follow-up') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dateOfDeathController,
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
                                _dateOfDeathController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText:
                                widget.resources1?.followUp()["DateofDeath"] ??
                                    '',
                            hintText: lang == "Amharic"
                                ? "Select date of death"
                                : lang == "AfanOromo"
                                    ? "Guyyaa Du’aa filadhu"
                                    : 'Select date of death',
                            border: const OutlineInputBorder(),
                            labelStyle: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            print('Form submitted!');
                            print(
                                'Date of Follow-up Examination: $_dateFollowUpExamination');
                            _residualParalysis.forEach((key, value) {
                              print('$key Residual Paralysis: $value');
                            });
                            print(
                                'Findings at Follow-up: $_findingsAtFollowUp');
                            _submitForm();
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 3,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.resources1?.followUp()["submit"] ?? 'Submit',
                            style: GoogleFonts.poppins(fontSize: 17),
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
