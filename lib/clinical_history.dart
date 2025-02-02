import 'dart:convert';
import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClinicalHistoryForm extends StatefulWidget {
  final String epid_Number;

  const ClinicalHistoryForm({
    super.key,
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
  String _selectedLanguage = "English";
  LanguageResources? resources;
  final _formKey = GlobalKey<FormState>(); // Key for the form

  late DateTime currentDate;
  late String formattedDate;

  bool _isLanguageLoaded = false; // Flag to check if language is loaded

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _initLanguage();
    currentDate = DateTime.now();
  }

  Future<void> _initLanguage() async {
    resources = LanguageResources("English");
    _loadLanguage().then((value) {
      if (mounted) {
        setState(() {
          _isLanguageLoaded = true;
        });
      }
    });
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    if (storedLanguage != _selectedLanguage) {
      if (mounted) {
        setState(() {
          _selectedLanguage = storedLanguage;
          resources = LanguageResources(_selectedLanguage);
        });
      }
    }
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_admittedToHospital == 'Yes' &&
        (_dateOfAdmission == null ||
            _medicalRecordNo.isEmpty ||
            _facilityName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'If admitted, please fill in Date of Admission, Medical Record No., and Facility Name'),
        ),
      );
      return;
    }
    if (_daysAfterOnset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select Date after onset'),
        ),
      );
      return;
    }
    if (_feverAtOnset.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select Fever at onset'),
        ),
      );
      return;
    }
    if (_flaccidParalysis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select Flaccid Paralysis'),
        ),
      );
      return;
    }
    if (_paralysisProgressed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select Paralysis Progressed'),
        ),
      );
      return;
    }
    if (_asymmetric.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select Asymmetric'),
        ),
      );
      return;
    }

    // if (_siteOfParalysis.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please Select Site of Paralysis'),
    //     ),
    //   );
    //   return;
    // }
    if (_totalOPVDoses == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Enter total opv doses'),
        ),
      );
      return;
    }

    if (_admittedToHospital.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select admitted to hospital'),
        ),
      );
      return;
    }
    final url = Uri.parse('${baseUrl}clinic/clinicalHistory');

    final body = json.encode({
      "epid_number": widget.epid_Number,
      "date_after_onset": _daysAfterOnset?.toIso8601String(),
      'fever_at_onset': _feverAtOnset,
      'flaccid_sudden_paralysis': _flaccidParalysis,
      'paralysis_progressed': _paralysisProgressed,
      'asymmetric': _asymmetric,
      'site_of_paralysis': _siteOfParalysis,
      "total_opv_doses": _totalOPVDoses,
      "admitted_to_hospital": _admittedToHospital,
      "date_of_admission": _dateOfAdmission?.toIso8601String(),
      "user_id": userDetails['id'],
      "medical_record_no": _medicalRecordNo,
      "facility_name": _facilityName,
    });
    print(body);

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
      appBar: CustomAppBar(
        title: resources?.clinicalHistory()["clinicalHistory"] ??
            "Clinical History",
      ),
      body: _isLanguageLoaded
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDateAfterOnset(),
                        const SizedBox(height: 16),
                        _buildFeverAtOnset(),
                        const SizedBox(height: 16.0),
                        _buildFlaccidParalysis(),
                        const SizedBox(height: 16.0),
                        _buildParalysisProgressed(),
                        const SizedBox(height: 16.0),
                        _buildAsymmetric(),
                        const SizedBox(height: 16.0),
                        _buildSiteOfParalysis(),
                        const SizedBox(height: 16.0),
                        _buildTotalOpvDoses(),
                        const SizedBox(height: 16.0),
                        _buildAdmittedToHospital(),
                        const SizedBox(height: 16.0),
                        _buildSubmitButton(),
                        const SizedBox(height: 56.0),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDateAfterOnset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["dateAfterOnset"] ?? "",
          style: GoogleFonts.poppins(
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
            backgroundColor: CustomColors.testColor1, // Change the text color
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8.0), // Adjust the border radius
            ),
            elevation: 14, // Add elevation
          ),
          child: Text(
            resources?.clinicalHistory()["selectDate"] ?? "",
            style: GoogleFonts.poppins(),
          ),
        ),
        Text(
          "${resources?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_daysAfterOnset != null ? "${_daysAfterOnset?.toLocal().year}-${_daysAfterOnset?.toLocal().month}-${_daysAfterOnset?.toLocal().day}" : resources?.stoolSpecimen()["notSelected"] ?? ""}",
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }

  Widget _buildFeverAtOnset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["feverAtOnset"] ?? "",
          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(),
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
                  resources?.clinicalHistory()["no"] ?? "",
                  style: GoogleFonts.poppins(),
                ),
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
      ],
    );
  }

  Widget _buildFlaccidParalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["flaccidAndSuddenParalysis"] ?? "",
          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(),
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
                  style: GoogleFonts.poppins(),
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
      ],
    );
  }

  Widget _buildParalysisProgressed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["paralysisProgressed"] ?? "",
          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(),
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
                  style: GoogleFonts.poppins(),
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
      ],
    );
  }

  Widget _buildAsymmetric() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["asymmetric"] ?? "",
          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(),
                ),
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
                  resources?.clinicalHistory()["no"] ?? "",
                  style: GoogleFonts.poppins(),
                ),
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
      ],
    );
  }

  Widget _buildSiteOfParalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resources?.clinicalHistory()["siteOfParalysis"] ?? "",
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text(
                resources?.clinicalHistory()["leftArm"] ?? "",
                style: GoogleFonts.poppins(),
              ),
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
                resources?.clinicalHistory()["rightArm"] ?? "",
                style: GoogleFonts.poppins(),
              ),
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
                resources?.clinicalHistory()["leftLeg"] ?? "",
                style: GoogleFonts.poppins(),
              ),
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
                resources?.clinicalHistory()["rightLeg"] ?? "",
                style: GoogleFonts.poppins(),
              ),
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
      ],
    );
  }

  Widget _buildTotalOpvDoses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["totalOpvDoses"] ?? "",
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${resources?.clinicalHistory()["totalOpvDoses"] ?? ""} is required';
            }
            final intValue = int.tryParse(value);
            if (intValue == null || intValue <= 0) {
              return '${resources?.clinicalHistory()["totalOpvDoses"] ?? ""} must be a positive number';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _totalOPVDoses = int.tryParse(value) ?? 0;
            });
          },
          decoration: ThemeHelper().textInputDecoration(
            ' ${resources?.clinicalHistory()["EntertotalOPVdose"] ?? ""}',
            ' ${resources?.clinicalHistory()["EntertotalOPVdose"] ?? ""} ',
          ),
        ),
      ],
    );
  }

  Widget _buildAdmittedToHospital() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resources?.clinicalHistory()["admittedToHospital"] ?? "",
          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(),
                ),
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
                  resources?.clinicalHistory()["no"] ?? "",
                  style: GoogleFonts.poppins(),
                ),
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
            style: GoogleFonts.poppins(
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
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: CustomColors.testColor1, // Change the text color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Adjust the border radius
              ),
              elevation: 14, // Add elevation
            ),
            child: Text(
              resources?.stoolSpecimen()["selectDate"] ?? "",
              style: GoogleFonts.poppins(),
            ),
          ),
          Text(
            '${resources?.stoolSpecimen()["selectedDate"] ?? ""}: ${_dateOfAdmission != null ? "${_dateOfAdmission?.toLocal().year}-${_dateOfAdmission?.toLocal().month}-${_dateOfAdmission?.toLocal().day}" : "Not selected"}',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${resources?.clinicalHistory()["MedicalRecordNo"] ?? ""}  is required';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _medicalRecordNo = value;
              });
            },
            decoration: ThemeHelper().textInputDecoration(
              ' ${resources?.clinicalHistory()["MedicalRecordNo"] ?? ""}',
              ' ${resources?.clinicalHistory()["MedicalRecordNo"] ?? ""} ',
            ),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${resources?.clinicalHistory()["FacilityName"] ?? ""} is required';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _facilityName = value;
              });
            },
            decoration: ThemeHelper().textInputDecoration(
              ' ${resources?.clinicalHistory()["FacilityName"] ?? ""}',
              ' ${resources?.clinicalHistory()["FacilityName"] ?? ""} ',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        _submitForm();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: CustomColors.testColor1, // Change the text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Adjust the border radius
        ),
        elevation: 14, // Add elevation
      ),
      child: Text(
        isSubmitting
            ? resources?.clinicalHistory()["saving"] ?? "Saving.."
            : resources?.clinicalHistory()["submit"] ?? 'Submit',
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
