import 'dart:convert';

import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LabForm extends StatefulWidget {
  final String epid;
  final String type;
  final String languge;

  const LabForm({
    super.key,
    required this.epid,
    required this.type,
    required this.languge,
  });

  @override
  _StoolSpecimensFormState createState() => _StoolSpecimensFormState();
}

class _StoolSpecimensFormState extends State<LabForm> {
  DateTime? _stool1DateReceivedByLab;
  String _specimenCondition = '';
  bool _isSubmitting = false;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    // getCurrentLocation();
    _loadUserDetails();
  }

  Map<String, dynamic> userDetails = {};
  String languge = '';

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

    setState(() {});
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    if (_stool1DateReceivedByLab == null || _specimenCondition.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields.';
        _isSubmitting = false;
      });
      return;
    }

    final formData = {
      'epid_number': widget.epid,
      'stool_recieved_date': "2024-08-03T14:30:00Z",
      'speciement_condition': _specimenCondition.toString(),
      'type': widget.type,
      'completed': 'false',
      'user_id': userDetails['id'],
    };

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}clinic/registerStool'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully registered  ${widget.type}'),
            duration: const Duration(seconds: 30),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LaboratoryFinalClassificationForm(
              epid: widget.epid,
              type: widget.type,
            ),
          ),
        );
      } else {
        // Handle different error responses
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Bad Request: ${response.body}';
            break;
          case 401:
            errorMessage = 'Unauthorized: Please check your credentials.';
            break;
          case 403:
            errorMessage = 'Forbidden: You do not have permission.';
            break;
          case 404:
            errorMessage = 'Not Found: The endpoint does not exist.';
            break;
          case 500:
            errorMessage = 'Server Error: Please try again later.';
            break;
          default:
            errorMessage = 'Error submitting form: ${response.statusCode}';
        }
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      // Network error or other exception
      if (e is http.ClientException) {
        setState(() {
          _errorMessage = 'Network Error: ${e.message}';
        });
      } else if (e is FormatException) {
        setState(() {
          _errorMessage = 'Format Error: ${e.message}';
        });
      } else {
        setState(() {
          _errorMessage = 'Error submitting form: $e';
        });
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.languge == "Amharic"
              ? 'የሰገራ ውጤት'
              : widget.languge == "AfanOromo"
                  ? '        bu’aa sagaraa'
                  : ' Stool Result  ',
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
                  const SizedBox(height: 16.0),
                  Text(
                    widget.languge == "Amharic"
                        ? 'የ ሰገራ ናሙና የተሰበሰበበት  ቀን'
                        : 'Date'
                            'Date stool received by Lab: $languge',
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
                        initialDate: _stool1DateReceivedByLab ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _stool1DateReceivedByLab = picked;
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
                    child: Text("Select Date"),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _stool1DateReceivedByLab != null
                        ? 'Selected Date: ${_stool1DateReceivedByLab!.toLocal().toString().split(' ')[0]}'
                        : 'No date selected',
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.languge == "Amharic"
                        ? 'የናሙና ሁኔታ'
                        : 'Specimen Condition'
                            "Specimen Condition",
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title:
                              Text(widget.languge == "Amharic" ? 'ጥሩ' : 'Good'),
                          value: 'Good',
                          groupValue: _specimenCondition,
                          onChanged: (value) {
                            setState(() {
                              _specimenCondition = value.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title:
                              Text(widget.languge == "Amharic" ? 'መጥፎ' : 'Bad'),
                          value: 'Bad',
                          groupValue: _specimenCondition,
                          onChanged: (value) {
                            setState(() {
                              _specimenCondition = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.testColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 14,
                    ),
                    child: _isSubmitting
                        ? Text(
                            widget.languge == "Amharic" ? 'መዝግብ..' : 'Submit')
                        : Text("Submit"),
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
