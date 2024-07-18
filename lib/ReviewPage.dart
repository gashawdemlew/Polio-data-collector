import 'dart:convert';
import 'package:camera_app/color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewPage extends StatelessWidget {
  // final String resources;
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
  final String hofficer_name;

  final String hofficer_phonno;

  ReviewPage({
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
    required this.hofficer_name,
    required this.hofficer_phonno,
  });

  Future<void> postClinicalData() async {
    final url = 'http://localhost:7476/clinic/post';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "epid_number": epid_number,
        "latitude": latitude,
        "longitude": longitude,
        "first_name": first_name,
        "phonNo": phoneNo,
        "last_name": last_name,
        "gender": gender,
        "dateofbirth": dateofbirth,
        "region": region,
        "zone": zone,
        "woreda": woreda,
        "fever_at_onset": feverAtOnset,
        "flaccid_sudden_paralysis": flaccidParalysis,
        "paralysis_progressed": paralysisProgressed,
        "asymmetric": asymmetric,
        "site_of_paralysis": siteOfParalysis,
        "total_opv_doses": totalOPVDoses,
        "admitted_to_hospital": admittedToHospital,
        "date_of_admission": dateOfAdmission,
        "medical_record_no": medicalRecordNo,
        "facility_name": facilityName,
        "date_stool_1_collected": stool1DateCollected,
        "date_stool_2_collected": stool2DateCollected,
        "date_after_onset": daysAfterOnset,
        "date_stool_1_sent_lab": stool1DateSentToLab,
        "date_stool_2_sent_lab": stool2DateSentToLab,
        "case_contact": caseOrContact,
        "stool1DaysAfterOnset": stool1DaysAfterOnset,
        "stool2DaysAfterOnset": stool2DaysAfterOnset,
        "stool1DateReceivedByLab": stool1DateReceivedByLab,
        "stool2DateReceivedByLab": stool2DateReceivedByLab,
        "specimenCondition": specimenCondition,
        "residual_paralysis": residualParalysis,
        "tempreture": tempreture,
        "rainfall": rainfall,
        "humidity": humidity,
        "snow": snow,
        "hofficer_name": hofficer_name,
        'hofficer_phonno': hofficer_phonno
      }),
    );

    if (response.statusCode == 201) {
      print('Data posted successfully');
    } else {
      print('Failed to post data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Review Data')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Review your data'),
                SizedBox(height: 20),
                ListTile(
                    title: Text('Epidemic Number'),
                    subtitle: Text(epid_number)),
                ListTile(title: Text('Gender'), subtitle: Text(gender)),
                ListTile(
                    title: Text('Date of Birth'), subtitle: Text(dateofbirth)),
                ListTile(title: Text('Zone'), subtitle: Text(zone)),
                ListTile(title: Text('Region'), subtitle: Text(region)),
                ListTile(title: Text('Woreda'), subtitle: Text(woreda)),
                ListTile(
                    title: Text('Fever At Onset'),
                    subtitle: Text(feverAtOnset)),
                ListTile(
                    title: Text('Flaccid Paralysis'),
                    subtitle: Text(flaccidParalysis)),
                ListTile(
                    title: Text('Paralysis Progressed'),
                    subtitle: Text(paralysisProgressed)),
                ListTile(title: Text('Asymmetric'), subtitle: Text(asymmetric)),
                ListTile(
                    title: Text('Site of Paralysis'),
                    subtitle: Text(siteOfParalysis)),
                ListTile(
                    title: Text('Total OPV Doses'),
                    subtitle: Text(totalOPVDoses.toString())),
                ListTile(
                    title: Text('Admitted to Hospital'),
                    subtitle: Text(admittedToHospital)),
                ListTile(
                    title: Text('Date of Admission'),
                    subtitle: Text(dateOfAdmission)),
                ListTile(
                    title: Text('Medical Record No'),
                    subtitle: Text(medicalRecordNo)),
                ListTile(
                    title: Text('Facility Name'), subtitle: Text(facilityName)),
                ListTile(
                    title: Text('Date Stool 1'), subtitle: Text(dateStool1)),
                ListTile(
                    title: Text('Date Stool 2'), subtitle: Text(dateStool2)),
                ListTile(
                    title: Text('Days After Onset'),
                    subtitle: Text(daysAfterOnset)),
                ListTile(
                    title: Text('Stool 1 Date Collected'),
                    subtitle: Text(stool1DateCollected)),
                ListTile(
                    title: Text('Stool 2 Date Collected'),
                    subtitle: Text(stool2DateCollected)),
                ListTile(
                    title: Text('Stool 1 Days After Onset'),
                    subtitle: Text(stool1DaysAfterOnset)),
                ListTile(
                    title: Text('Stool 1 Date Sent to Lab'),
                    subtitle: Text(stool1DateSentToLab)),
                ListTile(
                    title: Text('Stool 2 Date Sent to Lab'),
                    subtitle: Text(stool2DateSentToLab)),
                ListTile(
                    title: Text('Stool 1 Date Received by Lab'),
                    subtitle: Text(stool1DateReceivedByLab)),
                ListTile(
                    title: Text('Stool 2 Date Received by Lab'),
                    subtitle: Text(stool2DateReceivedByLab)),
                ListTile(
                    title: Text('Case or Contact'),
                    subtitle: Text(caseOrContact)),
                ListTile(
                    title: Text('Specimen Condition'),
                    subtitle: Text(specimenCondition)),
                ListTile(
                    title: Text('Stool 2 Days After Onset'),
                    subtitle: Text(stool2DaysAfterOnset)),
                ListTile(
                    title: Text('Residual Paralysis'),
                    subtitle: Text(residualParalysis)),
                ListTile(title: Text('First Name'), subtitle: Text(first_name)),
                ListTile(title: Text('Last Name'), subtitle: Text(last_name)),
                ListTile(title: Text('Phone No'), subtitle: Text(phoneNo)),
                ElevatedButton(
                  onPressed: () {
                    postClinicalData();
                  },
                  child: Text('Submit'),
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
        ));
  }
}
