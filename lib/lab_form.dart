import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class LabForm extends StatefulWidget {
  @override
  @override
  _StoolSpecimensFormState createState() => _StoolSpecimensFormState();
}

class _StoolSpecimensFormState extends State<LabForm> {
  DateTime? _stool1DateCollected;
  DateTime? _stool2DateCollected;
  DateTime? _stool1DaysAfterOnset;
  DateTime? _stool2DaysAfterOnset;
  DateTime? _stool1DateSentToLab;
  DateTime? _stool2DateSentToLab;
  DateTime? _stool1DateReceivedByLab;
  DateTime? _stool2DateReceivedByLab;
  String _caseOrContact = '';
  String _specimenCondition = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forms',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        // color: Theme.of(context).backgroundColor,
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
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["dateStoolCollected"] ??
                  //       '',
                  //   style: TextStyle(
                  //     fontSize: 26.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 8.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["stool1"] ?? '',
                  // ),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool1DateCollected ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool1DateCollected = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //     widget.resources1?.stoolSpecimen()["selectDate"] ?? '',
                  //   ),
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
                  //   '${widget.resources1?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_stool1DateCollected != null ? _stool1DateCollected!.toString().split(' ')[0] : "${widget.resources1?.stoolSpecimen()["notSelected"] ?? ""}"}',
                  // ),
                  // SizedBox(height: 16.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["stool2"] ?? '',
                  // ),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool2DateCollected ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool2DateCollected = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //     widget.resources1?.stoolSpecimen()["selectDate"] ?? '',
                  //   ),
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
                  //   '${widget.resources1?.stoolSpecimen()["selectedDateStool2"] ?? ""}: ${_stool2DateCollected != null ? _stool2DateCollected!.toString().split(' ')[0] : "${widget.resources1?.stoolSpecimen()["notSelected"] ?? ""}"}',
                  // ),
                  SizedBox(height: 16.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["Daysafteronset"] ?? '',
                  //   style: TextStyle(
                  //     fontSize: 26.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 8.0),
                  // Text(widget.resources1?.stoolSpecimen()["stool1"] ?? ''),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool1DaysAfterOnset ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool1DaysAfterOnset = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //       widget.resources1?.stoolSpecimen()["selectDate"] ?? ''),
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
                  //   '${widget.resources1?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_stool1DaysAfterOnset != null ? _stool1DaysAfterOnset!.toString().split(' ')[0] : "Not selected"}',
                  // ),
                  // SizedBox(height: 16.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["stool2"] ?? '',
                  // ),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool2DaysAfterOnset ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool2DaysAfterOnset = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //     widget.resources1?.stoolSpecimen()["selectDate"] ?? '',
                  //   ),
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
                  //   '${widget.resources1?.stoolSpecimen()["selectedDateStool2"] ?? ""}: ${_stool2DaysAfterOnset != null ? _stool2DaysAfterOnset!.toString().split(' ')[0] : "${widget.resources1?.stoolSpecimen()["notSelected"] ?? ""}"}',
                  // ),
                  // SizedBox(height: 16.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["DateSenttoLab"] ?? '',
                  //   style: TextStyle(
                  //     fontSize: 26.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 8.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["stool1"] ?? '',
                  // ),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool1DateSentToLab ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool1DateSentToLab = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //       widget.resources1?.stoolSpecimen()["selectDate"] ?? ''),
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
                  //   '${widget.resources1?.stoolSpecimen()["selectedDateStool1"] ?? ""}: ${_stool1DateSentToLab != null ? _stool1DateSentToLab!.toString().split(' ')[0] : "${widget.resources1?.stoolSpecimen()["notSelected"] ?? ""}"}',
                  // ),
                  // SizedBox(height: 16.0),
                  // Text(widget.resources1?.stoolSpecimen()["stool2"] ?? ""),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool2DateSentToLab ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool2DateSentToLab = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text(
                  //       widget.resources1?.stoolSpecimen()["selectDate"] ?? ''),
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
                  //   'Selected Date (Stool 2): ${_stool2DateSentToLab != null ? _stool2DateSentToLab!.toString().split(' ')[0] : "Not selected"}',
                  // ),
                  // SizedBox(height: 16.0),
                  Text(
                    'Date stool received by Lab:',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text('Stool 1:'),
                  SizedBox(height: 8.0),
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
                    child: Text("selectDate"),
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
                    '"selectedDateStool1'
                    '}: ${_stool1DateReceivedByLab != null ? _stool1DateReceivedByLab!.toString().split(' ')[0] : "notSelected" ?? ''}"}',
                  ),
                  SizedBox(height: 16.0),
                  // Text("stool2"),
                  // SizedBox(height: 8.0),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: _stool2DateReceivedByLab ?? DateTime.now(),
                  //       firstDate: DateTime(1900),
                  //       lastDate: DateTime.now(),
                  //     );
                  //     if (picked != null) {
                  //       setState(() {
                  //         _stool2DateReceivedByLab = picked;
                  //       });
                  //     }
                  //   },
                  //   child: Text("selectDate"),
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
                  //   'selectedDateStool2  }: ${_stool2DateReceivedByLab != null ? _stool2DateReceivedByLab!.toString().split(' ')[0] : "notSelected"}',
                  // ),
                  // SizedBox(height: 36.0),
                  // Text(
                  //   widget.resources1?.stoolSpecimen()["CaseorContact"] ?? "",
                  //   style: TextStyle(
                  //     fontSize: 16.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 8.0),
                  // Column(
                  //   children: [
                  //     LayoutBuilder(
                  //       builder: (context, constraints) {
                  //         return Expanded(
                  //           child: RadioListTile(
                  //             title: Text(
                  //                 widget.resources1?.stoolSpecimen()["case"] ??
                  //                     ""),
                  //             value: 'Case',
                  //             groupValue: _caseOrContact,
                  //             onChanged: (value) {
                  //               Future.delayed(Duration.zero, () {
                  //                 setState(() {
                  //                   _caseOrContact = value.toString();
                  //                 });
                  //               });
                  //             },
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //     LayoutBuilder(
                  //       builder: (context, constraints) {
                  //         return Expanded(
                  //           child: RadioListTile(
                  //             title: Text(widget.resources1
                  //                     ?.stoolSpecimen()["contact"] ??
                  //                 ""),
                  //             value: 'Contact',
                  //             groupValue: _caseOrContact,
                  //             onChanged: (value) {
                  //               Future.delayed(Duration.zero, () {
                  //                 setState(() {
                  //                   _caseOrContact = value.toString();
                  //                 });
                  //               });
                  //             },
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //     LayoutBuilder(
                  //       builder: (context, constraints) {
                  //         return Expanded(
                  //           child: RadioListTile(
                  //             title: Text(widget.resources1
                  //                     ?.stoolSpecimen()["community"] ??
                  //                 ""),
                  //             value: 'Community',
                  //             groupValue: _caseOrContact,
                  //             onChanged: (value) {
                  //               Future.delayed(Duration.zero, () {
                  //                 setState(() {
                  //                   _caseOrContact = value.toString();
                  //                 });
                  //               });
                  //             },
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 16.0),
                  Text(
                    "Specimen condition",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: Text(
                            "good",
                          ),
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
                          title: Text(
                            "Bad",
                          ),
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
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Submit form data
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

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PolioDashboard()));
                    },
                    child: Text("Submit"),
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
