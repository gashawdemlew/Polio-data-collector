import 'package:camera_app/ReviewPage.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PushMessage extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String first_name;
  final String last_name;
  final String phoneNo;
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
  final String residualParalysis;
  final String tempreture;
  final String rainfall;
  final String humidity;
  final String snow;
  final String epid_number;

  PushMessage({
    // required this.resources,
    required this.latitude,
    required this.longitude,
    required this.first_name,
    required this.last_name,
    required this.phoneNo,
    required this.gender,
    required this.dateofbirth,
    required this.region,
    required this.zone,
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
    required this.stool2DaysAfterOnset,
    required this.stool1DateSentToLab,
    required this.stool2DateSentToLab,
    required this.stool1DateReceivedByLab,
    required this.stool2DateReceivedByLab,
    required this.caseOrContact,
    required this.specimenCondition,
    required this.residualParalysis,
    required this.tempreture,
    required this.rainfall,
    required this.humidity,
    required this.snow,
    required this.epid_number,
  });
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<PushMessage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _woredaController = TextEditingController();
  final _zoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _healthOfficerNameController = TextEditingController();
  final _healthOfficerPhoneController = TextEditingController();

  @override
  void dispose() {
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Push Message Form',
          style: GoogleFonts.splineSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: CustomColors.testColor1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: ThemeHelper().textInputDecoration('First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: ThemeHelper().textInputDecoration('Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _woredaController,
                decoration: ThemeHelper().textInputDecoration('Woreda'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the woreda';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _zoneController,
                decoration: ThemeHelper().textInputDecoration('Zone'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the zone';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _regionController,
                decoration: ThemeHelper().textInputDecoration('Region'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the region';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _healthOfficerNameController,
                decoration:
                    ThemeHelper().textInputDecoration('Health Officer Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the health officer name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _healthOfficerPhoneController,
                decoration: ThemeHelper()
                    .textInputDecoration('Health Officer Phone Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the health officer phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewPage(
                            // formData: formData,
                            // resources: widget.resources1,
                            rainfall: widget.rainfall,
                            snow: widget.snow,
                            humidity: widget.humidity,
                            tempreture: widget.tempreture,
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                            // name: widget.name,
                            gender: widget.gender,
                            dateofbirth: widget.dateofbirth,
                            epid_number: widget.epid_number,
                            first_name: widget.first_name,
                            last_name: widget.last_name,
                            zone: widget.zone,
                            region: widget.region,
                            woreda: widget.woreda,
                            feverAtOnset: widget.feverAtOnset,
                            flaccidParalysis: widget.flaccidParalysis,
                            paralysisProgressed: widget.paralysisProgressed,
                            asymmetric: widget.asymmetric,
                            siteOfParalysis: widget.siteOfParalysis,
                            totalOPVDoses: widget.totalOPVDoses,
                            admittedToHospital: widget.admittedToHospital,
                            dateOfAdmission: widget.dateOfAdmission,
                            medicalRecordNo: widget.medicalRecordNo,
                            facilityName: widget.facilityName,
                            dateStool1: widget.dateStool1,
                            dateStool2: widget.dateStool2,
                            daysAfterOnset: widget.daysAfterOnset,
                            stool1DateCollected: widget.stool1DateCollected,
                            stool2DateCollected: widget.stool2DateCollected,
                            stool1DaysAfterOnset: widget.stool1DaysAfterOnset,
                            stool1DateSentToLab: widget.stool1DateSentToLab,
                            stool2DateSentToLab: widget.stool2DateSentToLab,
                            stool1DateReceivedByLab:
                                widget.stool1DateReceivedByLab,
                            stool2DateReceivedByLab:
                                widget.stool2DateReceivedByLab,
                            caseOrContact: widget.caseOrContact,
                            specimenCondition: widget.specimenCondition,
                            stool2DaysAfterOnset: widget.stool2DaysAfterOnset,
                            residualParalysis: widget.residualParalysis,
                            phoneNo: widget.phoneNo,
                            hofficer_name: _healthOfficerNameController.text,
                            hofficer_phonno:
                                _healthOfficerPhoneController.text),
                      ),
                    );
                  }
                },
                child: Text(
                  'Submit',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      CustomColors.testColor1, // Change the text color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Adjust the border radius
                  ),
                  elevation: 14, // Add elevation
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
