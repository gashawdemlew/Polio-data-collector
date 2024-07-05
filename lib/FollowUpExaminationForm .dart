import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowUpExaminationForm extends StatefulWidget {
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

  @override
  FollowUpExaminationForm({
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
  });
  @override
  _FollowUpExaminationFormState createState() =>
      _FollowUpExaminationFormState();
}

class _FollowUpExaminationFormState extends State<FollowUpExaminationForm> {
  DateTime? _dateFollowUpExamination;
  Map<String, bool> _residualParalysis = {
    'Right arm': false,
    'Left leg': false,
    'Right leg': false,
    'Left arm ': false,
  };
  Map<String, bool> _residualParalysis1 = {
    "ግራ ክንድ": false,
    "ቀኝ ክንድ": false,
    "ግራ እግር": false,
    "ቀኝ እግር": false,
  };
  String _findingsAtFollowUp = '';

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
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.resources1
                            ?.followUp()["DateofFollowupExamination"] ??
                        '',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
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
                    child: Text(
                      widget.resources1
                              ?.followUp()["DateofFollowupExamination"] ??
                          '',
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 14,
                    ),
                  ),
                  Text(
                    ' ${widget.resources1?.followUp()["selectedDate"] ?? ''}: ${_dateFollowUpExamination != null ? _dateFollowUpExamination!.toString().split(' ')[0] : "Not selected"}',
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    widget.resources1?.followUp()["ResidualParalysis"] ?? '',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.resources1 == "Amharic"
                        ? _residualParalysis1.keys.map((key) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key + ":",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                CheckboxListTile(
                                  title: Text('Yes'),
                                  value: _residualParalysis1[key],
                                  onChanged: (value) {
                                    setState(() {
                                      _residualParalysis1[key] = value!;
                                    });
                                  },
                                ),
                                SizedBox(height: 8.0),
                              ],
                            );
                          }).toList()
                        : _residualParalysis.keys.map((key) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key + ":",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
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
                                SizedBox(height: 8.0),
                              ],
                            );
                          }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    widget.resources1?.followUp()["FindingsatFollowup"] ?? '',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        title: Text(
                          widget.resources1?.followUp()["ResidualParalysis"] ??
                              '',
                        ),
                        value: 'No residual paralysis',
                        groupValue: _findingsAtFollowUp,
                        onChanged: (value) {
                          setState(() {
                            _findingsAtFollowUp = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text(
                          widget.resources1?.followUp()["Losttofollowup"] ?? '',
                        ),
                        value: 'Lost to follow-up',
                        groupValue: _findingsAtFollowUp,
                        onChanged: (value) {
                          setState(() {
                            _findingsAtFollowUp = value.toString();
                          });
                        },
                      ),
                      if (_findingsAtFollowUp == 'Lost to follow-up') ...[
                        TextFormField(
                          keyboardType: TextInputType.datetime,
                          onChanged: (value) {
                            // Handle text input if needed
                          },
                          decoration: InputDecoration(
                            labelText:
                                widget.resources1?.followUp()["DateofDeath"] ??
                                    '',
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.0),
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

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnvironmentMetrologyForm(
                                  resources1: widget.resources1,
                                  latitude: widget.latitude.toString(),
                                  longitude: widget.longitude.toString(),
                                  epid_number: widget.epid_number,
                                  name: widget.name,
                                  gender: widget.gender,
                                  dateofbirth: widget.dateofbirth,
                                  region: widget.region,
                                  zone: widget.zone.toString(),
                                  woreda: widget.woreda,
                                  feverAtOnset: widget.feverAtOnset,
                                  flaccidParalysis: widget.flaccidParalysis,
                                  paralysisProgressed:
                                      widget.paralysisProgressed,
                                  asymmetric: widget.asymmetric,
                                  siteOfParalysis: widget.siteOfParalysis,
                                  totalOPVDoses: widget.totalOPVDoses,
                                  admittedToHospital: widget.admittedToHospital,
                                  dateOfAdmission:
                                      widget.dateOfAdmission.toString(),
                                  medicalRecordNo: widget.medicalRecordNo,
                                  facilityName: widget.facilityName,
                                  dateStool1: widget.dateStool1.toString(),
                                  dateStool2: widget.dateStool2.toString(),
                                  daysAfterOnset:
                                      widget.daysAfterOnset.toString(),
                                  stool1DateCollected:
                                      widget.stool1DateCollected.toString(),
                                  stool2DateCollected:
                                      widget.stool2DateCollected.toString(),
                                  stool1DaysAfterOnset:
                                      widget.stool1DaysAfterOnset.toString(),
                                  stool2DaysAfterOnset:
                                      widget.stool2DaysAfterOnset.toString(),
                                  stool1DateSentToLab:
                                      widget.stool1DateSentToLab.toString(),
                                  stool2DateSentToLab:
                                      widget.stool2DateSentToLab.toString(),
                                  stool1DateReceivedByLab:
                                      widget.stool1DateReceivedByLab.toString(),
                                  stool2DateReceivedByLab:
                                      widget.stool2DateReceivedByLab.toString(),
                                  caseOrContact: widget.caseOrContact,
                                  specimenCondition: widget.specimenCondition,
                                  residualParalysis:
                                      _residualParalysis.toString())));
                    },
                    child: Text(
                        widget.resources1?.patientDemographic()["next"] ?? ''),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 14,
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
