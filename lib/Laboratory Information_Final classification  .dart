import 'package:camera_app/color.dart';
import 'package:camera_app/enviroment.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaboratoryFinalClassificationForm extends StatefulWidget {
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
  void init() {
    setState(() {
      _selectedLanguage = languge;
      resources = LanguageResources(languge);
    });
  }

  Future<void> _loadLanguage45() async {
    // Simulate language loading
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge); // or "English"
      resource12 = resources;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LaboratoryInformation/FinalClassificationForm",
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        // color: Theme.of(context),
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
                    'True AFP:',
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
                          title: Text('Yes'),
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
                          title: Text('No'),
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
                  SizedBox(height: 16.0),
                  Text(
                    'Final Cell Culture Result:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        title: Text('Suspected Poliovirus'),
                        value: 'Suspected Poliovirus',
                        groupValue: _finalCellCultureResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCellCultureResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Negative'),
                        value: 'Negative',
                        groupValue: _finalCellCultureResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCellCultureResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('NPENT'),
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
                  SizedBox(height: 16.0),
                  Text(
                    'Date Final Cell Culture Results:',
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
                    child: Text('Select Date'),
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
                    'Selected Date (Final Cell Culture Results): ${_dateFinalCellCultureResults != null ? _dateFinalCellCultureResults!.toString().split(' ')[0] : "Not selected"}',
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Final Combined ITD Result:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        title: Text('Confirmed'),
                        value: 'Confirmed',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Compatible'),
                        value: 'Compatible',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Discarded'),
                        value: 'Discarded',
                        groupValue: _finalCombinedITDResult,
                        onChanged: (value) {
                          setState(() {
                            _finalCombinedITDResult = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Not an AFP'),
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
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => EnvironmentMetrologyForm(
                      //               resources1: resource12,
                      //             )));
                      // Submit form data
                      print('Form submitted!');
                      print('True AFP: $_trueAFP');
                      print(
                          'Final Cell Culture Result: $_finalCellCultureResult');
                      print(
                          'Date Final Cell Culture Results: $_dateFinalCellCultureResults');
                      print(
                          'Final Combined ITD Result: $_finalCombinedITDResult');
                    },
                    child: Text('Next'),
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
      ),
    );
  }
}
