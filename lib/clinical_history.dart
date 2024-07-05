import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/stole_speciement.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicalHistoryForm extends StatefulWidget {
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

  @override
  const ClinicalHistoryForm(
      {required this.resources1,
      required this.latitude,
      required this.longitude,
      required this.name,
      required this.gender,
      required this.dateofbirth,
      required this.zone,
      required this.region,
      required this.epid_number,
      required this.woreda});

  _ClinicalHistoryFormState createState() => _ClinicalHistoryFormState();
}

class _ClinicalHistoryFormState extends State<ClinicalHistoryForm> {
  String _feverAtOnset = '';
  String _flaccidParalysis = '';
  String _paralysisProgressed = '';
  String _asymmetric = '';
  String _siteOfParalysis = '';
  int _totalOPVDoses = 0;
  String _admittedToHospital = '';
  DateTime? _dateOfAdmission;
  String _medicalRecordNo = '';
  String _facilityName = '';
  DateTime? _dateStool1;
  DateTime? _dateStool2;
  DateTime? _daysAfterOnset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.resources1?.clinicalHistory()["clinicalhistoryform"] ?? "",
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
                Text(
                  widget.resources1?.clinicalHistory()["dateAfterOnset"] ?? "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _daysAfterOnset ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _daysAfterOnset = picked;
                      });
                    }
                  },
                  child: Text(
                      widget.resources1?.clinicalHistory()["selectDate"] ?? ""),
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
                Text(
                    "${widget.resources1?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_daysAfterOnset ?? "${widget.resources1?.stoolSpecimen()["notSelected"] ?? ""}"}"),
                Text(
                  widget.resources1?.clinicalHistory()["feverAtOnset"] ?? "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          widget.resources1?.clinicalHistory()["yes"] ?? "",
                        ),
                        value: 'Yes',
                        groupValue: _feverAtOnset,
                        onChanged: (value) {
                          setState(() {
                            _feverAtOnset = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                            widget.resources1?.clinicalHistory()["no"] ?? ""),
                        value: 'No',
                        groupValue: _feverAtOnset,
                        onChanged: (value) {
                          setState(() {
                            _feverAtOnset = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.resources1
                          ?.clinicalHistory()["flaccidAndSuddenParalysis"] ??
                      "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          widget.resources1?.clinicalHistory()["yes"] ?? "",
                        ),
                        value: 'Yes',
                        groupValue: _flaccidParalysis,
                        onChanged: (value) {
                          setState(() {
                            _flaccidParalysis = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          widget.resources1?.clinicalHistory()["no"] ?? "",
                        ),
                        value: 'No',
                        groupValue: _flaccidParalysis,
                        onChanged: (value) {
                          setState(() {
                            _flaccidParalysis = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.resources1?.clinicalHistory()["paralysisProgressed"] ??
                      "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          widget.resources1?.clinicalHistory()["yes"] ?? "",
                        ),
                        value: 'Yes',
                        groupValue: _paralysisProgressed,
                        onChanged: (value) {
                          setState(() {
                            _paralysisProgressed = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          widget.resources1?.clinicalHistory()["no"] ?? "",
                        ),
                        value: 'No',
                        groupValue: _paralysisProgressed,
                        onChanged: (value) {
                          setState(() {
                            _paralysisProgressed = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.resources1?.clinicalHistory()["asymmetric"] ?? "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                            widget.resources1?.clinicalHistory()["yes"] ?? ""),
                        value: 'Yes',
                        groupValue: _asymmetric,
                        onChanged: (value) {
                          setState(() {
                            _asymmetric = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                            widget.resources1?.clinicalHistory()["no"] ?? ""),
                        value: 'No',
                        groupValue: _asymmetric,
                        onChanged: (value) {
                          setState(() {
                            _asymmetric = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.resources1?.clinicalHistory()["siteOfParalysis"] ?? "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text(
                          widget.resources1?.clinicalHistory()["leftArm"] ??
                              ""),
                      value: _siteOfParalysis.contains('Left arm'),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _siteOfParalysis += 'Left arm, ';
                          } else {
                            _siteOfParalysis =
                                _siteOfParalysis.replaceAll('Left arm, ', '');
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text(
                          widget.resources1?.clinicalHistory()["rightArm"] ??
                              ""),
                      value: _siteOfParalysis.contains('Right arm'),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _siteOfParalysis += 'Right arm, ';
                          } else {
                            _siteOfParalysis =
                                _siteOfParalysis.replaceAll('Right arm, ', '');
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text(
                          widget.resources1?.clinicalHistory()["leftLeg"] ??
                              ""),
                      value: _siteOfParalysis.contains('Left leg'),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _siteOfParalysis += 'Left leg, ';
                          } else {
                            _siteOfParalysis =
                                _siteOfParalysis.replaceAll('Left leg, ', '');
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text(
                          widget.resources1?.clinicalHistory()["rightLeg"] ??
                              ""),
                      value: _siteOfParalysis.contains('Right leg'),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _siteOfParalysis += 'Right leg, ';
                          } else {
                            _siteOfParalysis =
                                _siteOfParalysis.replaceAll('Right leg, ', '');
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.resources1?.clinicalHistory()["totalOpvDoses"] ?? "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _totalOPVDoses = int.tryParse(value) ?? 0;
                    });
                  },
                  decoration: ThemeHelper().textInputDecoration(
                      ' ${widget.resources1?.clinicalHistory()["EntertotalOPVdose"] ?? ""}',
                      ' ${widget.resources1?.clinicalHistory()["EntertotalOPVdose"] ?? ""} '),
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.resources1?.clinicalHistory()["admittedToHospital"] ??
                      "",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                            widget.resources1?.clinicalHistory()["yes"] ?? ""),
                        value: 'Yes',
                        groupValue: _admittedToHospital,
                        onChanged: (value) {
                          setState(() {
                            _admittedToHospital = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                            widget.resources1?.clinicalHistory()["no"] ?? ""),
                        value: 'No',
                        groupValue: _admittedToHospital,
                        onChanged: (value) {
                          setState(() {
                            _admittedToHospital = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_admittedToHospital == 'Yes') ...[
                  SizedBox(height: 16.0),
                  Text(
                    widget.resources1?.clinicalHistory()["DateofAdmission"] ??
                        "",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dateOfAdmission ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateOfAdmission = picked;
                        });
                      }
                    },
                    child: Text(
                      widget.resources1?.stoolSpecimen()["selectDate"] ?? "",
                    ),
                  ),
                  Text(
                    '${widget.resources1?.stoolSpecimen()["selectedDate"] ?? ""}: ${_dateOfAdmission ?? "Not selected"}',
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _medicalRecordNo = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: widget.resources1
                              ?.clinicalHistory()["MedicalRecordNo"] ??
                          "",
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _facilityName = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: widget.resources1
                              ?.clinicalHistory()["FacilityName"] ??
                          "",
                    ),
                  ),
                ],
                SizedBox(height: 16.0),
                // Text(
                //   'Date stool collected (Stool 1):',
                //   style: TextStyle(
                //     fontSize: 16.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 8.0),
                // ElevatedButton(
                //   onPressed: () async {
                //     final DateTime? picked = await showDatePicker(
                //       context: context,
                //       initialDate: _dateStool1 ?? DateTime.now(),
                //       firstDate: DateTime(1900),
                //       lastDate: DateTime.now(),
                //     );
                //     if (picked != null) {
                //       setState(() {
                //         _dateStool1 = picked;
                //       });
                //     }
                //   },
                //   child: Text('Select Date'),
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
                //   'Selected Date (Stool 1): ${_dateStool1 ?? "Not selected"}',
                // ),
                // SizedBox(height: 16.0),
                // Text(
                //   'Date stool collected (Stool 2):',
                //   style: TextStyle(
                //     fontSize: 16.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 8.0),
                // ElevatedButton(
                //   onPressed: () async {
                //     final DateTime? picked = await showDatePicker(
                //       context: context,
                //       initialDate: _dateStool2 ?? DateTime.now(),
                //       firstDate: DateTime(1900),
                //       lastDate: DateTime.now(),
                //     );
                //     if (picked != null) {
                //       setState(() {
                //         _dateStool2 = picked;
                //       });
                //     }
                //   },
                //   child: Text('Select Date'),
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
                //   'Selected Date (Stool 2): ${_dateStool2 ?? "Not selected"}',
                // ),
                // SizedBox(height: 16.0),
                // Text(
                //   'Days after onset (Stool 1):',
                //   style: TextStyle(
                //     fontSize: 16.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 8.0),
                // ElevatedButton(
                //   onPressed: () async {
                //     final DateTime? picked = await showDatePicker(
                //       context: context,
                //       initialDate: _daysAfterOnset ?? DateTime.now(),
                //       firstDate: DateTime(1900),
                //       lastDate: DateTime.now(),
                //     );
                //     if (picked != null) {
                //       setState(() {
                //         _daysAfterOnset = picked;
                //       });
                //     }
                //   },
                //   child: Text('Select Date'),
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
                //   'Selected Date (Stool 1): ${_daysAfterOnset ?? "Not selected"}',
                // ),
                SizedBox(height: 56.0),
                ElevatedButton(
                  onPressed: () {
                    // Submit form data
                    print('Form submitted!');
                    print('Fever at onset: $_feverAtOnset');
                    print('Flaccid and sudden paralysis: $_flaccidParalysis');
                    print(
                        'Paralysis progressed <= 3 days: $_paralysisProgressed');
                    print('Asymmetric: $_asymmetric');
                    print('Site of paralysis: $_siteOfParalysis');
                    print('Total OPV Doses: $_totalOPVDoses');
                    print('Admitted to hospital: $_admittedToHospital');
                    print('Date of Admission: $_dateOfAdmission');
                    print('Medical Record No: $_medicalRecordNo');
                    print('Facility Name: $_facilityName');
                    print('Date stool collected (Stool 1): $_dateStool1');
                    print('Date stool collected (Stool 2): $_dateStool2');
                    print('Days after onset (Stool 1): $_daysAfterOnset');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StoolSpecimensForm34(
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
                                  feverAtOnset: _feverAtOnset,
                                  flaccidParalysis: _flaccidParalysis,
                                  paralysisProgressed: _paralysisProgressed,
                                  asymmetric: _asymmetric,
                                  siteOfParalysis: _siteOfParalysis,
                                  totalOPVDoses: _totalOPVDoses,
                                  admittedToHospital: _admittedToHospital,
                                  dateOfAdmission: _dateOfAdmission.toString(),
                                  medicalRecordNo: _medicalRecordNo,
                                  facilityName: _facilityName,
                                  dateStool1: _dateStool1.toString(),
                                  dateStool2: _dateStool2.toString(),
                                  daysAfterOnset: _daysAfterOnset.toString(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
