import 'dart:convert';

import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/stole_speciement.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClinicalHistoryForm extends StatefulWidget {
  final String epid_Number;

  // final LanguageResources? resources1;
  // final String latitude;
  // final String longitude;

  // final String epid_number;

  // final String name;
  // final String first_name;
  // final String last_name;

  // final String phoneNo;

  // final String gender;
  // final String dateofbirth;
  // final String region;
  // final String zone;

  // final String woreda;

  @override
  const ClinicalHistoryForm({
    super.key,
    // required this.latitude,
    // required this.phoneNo,
    // required this.longitude,
    // required this.name,
    // required this.gender,
    // required this.dateofbirth,
    // required this.zone,
    // required this.region,
    // required this.first_name,
    // required this.last_name,
    // required this.epid_number,
    required this.epid_Number,
  });

  @override
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
    final url = Uri.parse('${baseUrl}clinic/clinicalHistory');

    //      fever_at_onset,
    // flaccid_sudden_paralysis,
    // paralysis_progressed,
    // asymmetric,
    // site_of_paralysis,
    // total_opv_doses,
    // admitted_to_hospital,
    // date_of_admission,
    // medical_record_no,
    // facility_name,

    final body = json.encode({
      "epid_number": widget.epid_Number,
      'fever_at_onset': _feverAtOnset,
      'flaccid_sudden_paralysis': _flaccidParalysis,
      'paralysis_progressed': _paralysisProgressed,
      'asymmetric': _asymmetric,
      'site_of_paralysis': _siteOfParalysis,
      "total_opv_doses": _totalOPVDoses,
      "admitted_to_hospital": _admittedToHospital,
      "date_of_admission": _dateOfAdmission.toString(),
      "user_id": userDetails['id'],
      "medical_record_no": _medicalRecordNo,
      "facility_name": _facilityName,
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
              builder: (context) => FollowUpExaminationForm(
                  resources1: resources, epid_Number: widget.epid_Number),
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
          languge == "Amharic" ? "ከሊኒካል  ታሪክ ቅጽ" : "Clinical History form",
          style: GoogleFonts.splineSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        // color: Theme.of(context).backgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  resources?.clinicalHistory()["dateAfterOnset"] ?? "",
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
                  child: Text(resources?.clinicalHistory()["selectDate"] ?? ""),
                ),
                Text(
                    "${resources?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_daysAfterOnset ?? resources?.stoolSpecimen()["notSelected"] ?? ""}"),
                Text(
                  resources?.clinicalHistory()["feverAtOnset"] ?? "",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          resources?.clinicalHistory()["yes"] ?? "",
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
                        title: Text(resources?.clinicalHistory()["no"] ?? ""),
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
                const SizedBox(height: 16.0),
                Text(
                  resources?.clinicalHistory()["flaccidAndSuddenParalysis"] ??
                      "",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          resources?.clinicalHistory()["yes"] ?? "",
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
                          resources?.clinicalHistory()["no"] ?? "",
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
                const SizedBox(height: 16.0),
                Text(
                  resources?.clinicalHistory()["paralysisProgressed"] ?? "",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          resources?.clinicalHistory()["yes"] ?? "",
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
                          resources?.clinicalHistory()["no"] ?? "",
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
                const SizedBox(height: 16.0),
                Text(
                  resources?.clinicalHistory()["asymmetric"] ?? "",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(resources?.clinicalHistory()["yes"] ?? ""),
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
                        title: Text(resources?.clinicalHistory()["no"] ?? ""),
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
                const SizedBox(height: 16.0),
                Text(
                  resources?.clinicalHistory()["siteOfParalysis"] ?? "",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title:
                          Text(resources?.clinicalHistory()["leftArm"] ?? ""),
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
                      title:
                          Text(resources?.clinicalHistory()["rightArm"] ?? ""),
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
                      title:
                          Text(resources?.clinicalHistory()["leftLeg"] ?? ""),
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
                      title:
                          Text(resources?.clinicalHistory()["rightLeg"] ?? ""),
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
                const SizedBox(height: 16.0),
                Text(
                  resources?.clinicalHistory()["totalOpvDoses"] ?? "",
                  style: const TextStyle(
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
                      ' ${resources?.clinicalHistory()["EntertotalOPVdose"] ?? ""}',
                      ' ${resources?.clinicalHistory()["EntertotalOPVdose"] ?? ""} '),
                ),
                const SizedBox(height: 16.0),
                Text(
                  resources?.clinicalHistory()["admittedToHospital"] ?? "",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(resources?.clinicalHistory()["yes"] ?? ""),
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
                        title: Text(resources?.clinicalHistory()["no"] ?? ""),
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
                  const SizedBox(height: 16.0),
                  Text(
                    resources?.clinicalHistory()["DateofAdmission"] ?? "",
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
                      resources?.stoolSpecimen()["selectDate"] ?? "",
                    ),
                  ),
                  Text(
                    '${resources?.stoolSpecimen()["selectedDate"] ?? ""}: ${_dateOfAdmission ?? "Not selected"}',
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _medicalRecordNo = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText:
                          resources?.clinicalHistory()["MedicalRecordNo"] ?? "",
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _facilityName = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText:
                          resources?.clinicalHistory()["FacilityName"] ?? "",
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
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
                const SizedBox(height: 56.0),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => StoolSpecimensForm34(
                    // resources1: widget.resources1,
                    // latitude: widget.latitude.toString(),
                    // longitude: widget.longitude.toString(),
                    // epid_number: widget.epid_number,
                    // name: widget.name,
                    // gender: widget.gender,
                    // dateofbirth: widget.dateofbirth,
                    // region: widget.region,
                    // zone: widget.zone.toString(),
                    // woreda: widget.woreda,
                    // feverAtOnset: _feverAtOnset,
                    // flaccidParalysis: _flaccidParalysis,
                    // paralysisProgressed: _paralysisProgressed,
                    // asymmetric: _asymmetric,
                    // siteOfParalysis: _siteOfParalysis,
                    // totalOPVDoses: _totalOPVDoses,
                    // admittedToHospital: _admittedToHospital,
                    // dateOfAdmission: _dateOfAdmission.toString(),
                    // medicalRecordNo: _medicalRecordNo,
                    // facilityName: _facilityName,
                    // dateStool1: _dateStool1.toString(),
                    // dateStool2: _dateStool2.toString(),
                    // daysAfterOnset: _daysAfterOnset.toString(),
                    // phoneNo: widget.phoneNo,
                    // first_name: widget.first_name,
                    // last_name: widget.last_name

                    // )));
                  },
                  // child: Text(resources?.patientDemographic()["next"] ?? ''),
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
                    isSubmitting ? 'Saving...' : 'Submit',
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
