import 'dart:convert';

import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowUpExaminationForm extends StatefulWidget {
  final LanguageResources? resources1;
  final String epid_Number;

  // final String latitude;
  // final String longitude;

  // final String epid_number;

  // final String name;

  // final String gender;
  // final String dateofbirth;
  // final String region;
  // final String zone;

  // final String woreda;

  // final String feverAtOnset;
  // final String flaccidParalysis;
  // final String paralysisProgressed;
  // final String asymmetric;
  // final String siteOfParalysis;
  // final int totalOPVDoses;
  // final String admittedToHospital;
  // final String dateOfAdmission;
  // final String medicalRecordNo;
  // final String facilityName;
  // final String dateStool1;
  // final String dateStool2;
  // final String daysAfterOnset;

  // final String stool1DateCollected;
  // final String stool2DateCollected;
  // final String stool1DaysAfterOnset;
  // final String stool2DaysAfterOnset;
  // final String stool1DateSentToLab;
  // final String stool2DateSentToLab;
  // final String stool1DateReceivedByLab;
  // final String stool2DateReceivedByLab;
  // final String caseOrContact;
  // final String specimenCondition;
  // final String phoneNo;

  // final String first_name;

  // final String last_name;

  @override
  const FollowUpExaminationForm({
    super.key,
    required this.resources1,
    required this.epid_Number,

    // required this.latitude,
    // required this.longitude,
    // required this.name,
    // required this.gender,
    // required this.dateofbirth,
    // required this.zone,
    // required this.region,
    // required this.epid_number,
    // required this.woreda,
    // required this.feverAtOnset,
    // required this.flaccidParalysis,
    // required this.paralysisProgressed,
    // required this.asymmetric,
    // required this.siteOfParalysis,
    // required this.totalOPVDoses,
    // required this.admittedToHospital,
    // required this.dateOfAdmission,
    // required this.medicalRecordNo,
    // required this.facilityName,
    // required this.dateStool1,
    // required this.dateStool2,
    // required this.daysAfterOnset,
    // required this.stool1DateCollected,
    // required this.stool2DateCollected,
    // required this.stool1DaysAfterOnset,
    // required this.stool1DateSentToLab,
    // required this.stool2DateSentToLab,
    // required this.stool1DateReceivedByLab,
    // required this.stool2DateReceivedByLab,
    // required this.caseOrContact,
    // required this.specimenCondition,
    // required this.stool2DaysAfterOnset,
    // required this.first_name,
    // required this.last_name,
    // required this.phoneNo,
  });
  @override
  _FollowUpExaminationFormState createState() =>
      _FollowUpExaminationFormState();
}

class _FollowUpExaminationFormState extends State<FollowUpExaminationForm> {
  DateTime? _dateFollowUpExamination;
  final TextEditingController _dateOfDeathController = TextEditingController();

  final Map<String, bool> _residualParalysis = {
    'Right arm': false,
    'Left leg': false,
    'Right leg': false,
    'Left arm ': false,
  };
  final Map<String, bool> _residualParalysis1 = {
    "ግራ ክንድ": false,
    "ቀኝ ክንድ": false,
    "ግራ እግር": false,
    "ቀኝ እግር": false,
  };
  String _findingsAtFollowUp = '';

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
  // epid_number,
  //   date_follow_up_investigation,
  //   residual_paralysis,
  //   user_id,
  Future<void> _submitForm() async {
    final url = Uri.parse('${baseUrl}clinic/followup');

    final body = json.encode({
      "epid_number": widget.epid_Number,
      'date_follow_up_investigation':
          _dateFollowUpExamination?.toIso8601String(),
      'residual_paralysis': _residualParalysis.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.resources1?.followUp()["appbar"] ?? '',
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
                  Text(
                    widget.resources1
                            ?.followUp()["DateofFollowupExamination"] ??
                        '',
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 14,
                    ),
                    child: Text(
                      widget.resources1
                              ?.followUp()["DateofFollowupExamination"] ??
                          '',
                    ),
                  ),
                  Text(
                    ' ${widget.resources1?.followUp()["selectedDate"] ?? ''}: ${_dateFollowUpExamination != null ? _dateFollowUpExamination!.toString().split(' ')[0] : "Not selected"}',
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.resources1?.followUp()["ResidualParalysis"] ?? '',
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.resources1 == "Amharic"
                        ? _residualParalysis1.keys.map((key) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$key:",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                CheckboxListTile(
                                  title: const Text('Yes'),
                                  value: _residualParalysis1[key],
                                  onChanged: (value) {
                                    setState(() {
                                      _residualParalysis1[key] = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            );
                          }).toList()
                        : _residualParalysis.keys.map((key) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$key:",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                CheckboxListTile(
                                  title: Text(
                                      widget.resources1?.followUp()["yes"] ??
                                          ''),
                                  value: _residualParalysis[key],
                                  onChanged: (value) {
                                    setState(() {
                                      _residualParalysis[key] = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.resources1?.followUp()["FindingsatFollowup"] ?? '',
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(
                          widget.resources1?.followUp()["Losttofollowup"] ?? '',
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
                      ),
                      if (_findingsAtFollowUp == 'Lost to follow-up') ...[
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
                                _dateOfDeathController.text = pickedDate
                                    .toString()
                                    .split(' ')[0]; // Only the date part
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText:
                                widget.resources1?.followUp()["DateofDeath"] ??
                                    '',
                            hintText: 'Select date of death',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Submit form data
                      print('Form submitted!');
                      print(
                          'Date of Follow-up Examination: $_dateFollowUpExamination');
                      _residualParalysis.forEach((key, value) {
                        print('$key Residual Paralysis: $value');
                      });
                      print('Findings at Follow-up: $_findingsAtFollowUp');
                      _submitForm();
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => EnvironmentMetrologyForm(
                      //             resources1: widget.resources1,
                      //             latitude: widget.latitude.toString(),
                      //             longitude: widget.longitude.toString(),
                      //             epid_number: widget.epid_number,
                      //             name: widget.name,
                      //             gender: widget.gender,
                      //             dateofbirth: widget.dateofbirth,
                      //             region: widget.region,
                      //             zone: widget.zone.toString(),
                      //             woreda: widget.woreda,
                      //             feverAtOnset: widget.feverAtOnset,
                      //             flaccidParalysis: widget.flaccidParalysis,
                      //             paralysisProgressed:
                      //                 widget.paralysisProgressed,
                      //             asymmetric: widget.asymmetric,
                      //             siteOfParalysis: widget.siteOfParalysis,
                      //             totalOPVDoses: widget.totalOPVDoses,
                      //             admittedToHospital: widget.admittedToHospital,
                      //             dateOfAdmission:
                      //                 widget.dateOfAdmission.toString(),
                      //             medicalRecordNo: widget.medicalRecordNo,
                      //             facilityName: widget.facilityName,
                      //             dateStool1: widget.dateStool1.toString(),
                      //             dateStool2: widget.dateStool2.toString(),
                      //             daysAfterOnset:
                      //                 widget.daysAfterOnset.toString(),
                      //             stool1DateCollected:
                      //                 widget.stool1DateCollected.toString(),
                      //             stool2DateCollected:
                      //                 widget.stool2DateCollected.toString(),
                      //             stool1DaysAfterOnset:
                      //                 widget.stool1DaysAfterOnset.toString(),
                      //             stool2DaysAfterOnset:
                      //                 widget.stool2DaysAfterOnset.toString(),
                      //             stool1DateSentToLab:
                      //                 widget.stool1DateSentToLab.toString(),
                      //             stool2DateSentToLab:
                      //                 widget.stool2DateSentToLab.toString(),
                      //             stool1DateReceivedByLab:
                      //                 widget.stool1DateReceivedByLab.toString(),
                      //             stool2DateReceivedByLab:
                      //                 widget.stool2DateReceivedByLab.toString(),
                      //             caseOrContact: widget.caseOrContact,
                      //             specimenCondition: widget.specimenCondition,
                      //             residualParalysis:
                      //                 _residualParalysis.toString(),
                      //             phoneNo: widget.phoneNo,
                      //             first_name: widget.first_name,
                      //             last_name: widget.last_name

                      //             )

                      //             )

                      // );
                    },
                    // child:
                    //  Text(
                    //     widget.resources1?.patientDemographic()["next"] ?? ''),
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
