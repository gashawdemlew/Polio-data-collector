import 'dart:convert';
import 'dart:io';
import 'package:camera_app/color.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/qrcode_example.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPage extends StatefulWidget {
  final String latitude;
  final String videoPath;
  final String imagePath;
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
    required this.latitude,
    required this.imagePath,
    required this.videoPath,
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

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool isSaving = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? first_name;
  String? phoneNo;

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? first_name = prefs.getString('first_name');
    String? phoneNo = prefs.getString('phoneNo');
    if (first_name != null) {
      _emailController.text = first_name;
    }
    if (phoneNo != null) {
      _passwordController.text = phoneNo;
    }
  }

  Future<void> postClinicalData(BuildContext context) async {
    setState(() {
      isSaving = true; // Start saving
    });

    final url = '${baseUrl}clinic/create';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Content-Type'] = 'multipart/form-data';

    // Adding JSON fields
    request.fields.addAll({
      "epid_number": widget.epid_number,
      "latitude": widget.latitude,
      "longitude": widget.longitude,
      "first_name": widget.first_name,
      "phonNo": widget.phoneNo,
      "last_name": widget.last_name,
      "gender": widget.gender,
      "dateofbirth": widget.dateofbirth.toString(),
      "region": widget.region,
      "zone": widget.zone,
      "woreda": widget.woreda,
      "fever_at_onset": widget.feverAtOnset,
      "flaccid_sudden_paralysis": widget.flaccidParalysis,
      "paralysis_progressed": widget.paralysisProgressed,
      "asymmetric": widget.asymmetric,
      "site_of_paralysis": widget.siteOfParalysis,
      "total_opv_doses": widget.totalOPVDoses.toString(),
      "admitted_to_hospital": widget.admittedToHospital,
      "date_of_admission": widget.dateOfAdmission,
      "medical_record_no": widget.medicalRecordNo,
      "facility_name": widget.facilityName,
      "date_stool_1_collected": widget.stool1DateCollected,
      "date_stool_2_collected": widget.stool2DateCollected,
      "date_after_onset": widget.daysAfterOnset,
      "date_stool_1_sent_lab": widget.stool1DateSentToLab,
      "date_stool_2_sent_lab": widget.stool2DateSentToLab,
      "case_contact": widget.caseOrContact,
      "stool1DaysAfterOnset": widget.stool1DaysAfterOnset,
      "stool2DaysAfterOnset": widget.stool2DaysAfterOnset,
      "stool1DateReceivedByLab": widget.stool1DateReceivedByLab,
      "stool2DateReceivedByLab": widget.stool2DateReceivedByLab,
      "specimenCondition": widget.specimenCondition,
      "residual_paralysis": widget.residualParalysis,
      "tempreture": widget.tempreture,
      "rainfall": DateTime.now().toString(),
      "humidity": widget.humidity,
      "snow": widget.snow,
      "hofficer_name": _emailController.text,
      'hofficer_phonno': _passwordController.text,
    });

    // Adding image file
    if (widget.imagePath.isNotEmpty) {
      var imageFile = File(widget.imagePath);
      var imageMimeType = lookupMimeType(widget.imagePath) ?? 'image/jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(imageMimeType),
      ));
    }

    // Adding video file
    if (widget.videoPath.isNotEmpty) {
      var videoFile = File(widget.videoPath);
      var videoMimeType = lookupMimeType(widget.videoPath) ?? 'video/mp4';

      request.files.add(await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
        contentType: MediaType.parse(videoMimeType),
      ));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data submitted successfully')),
      );

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => QRCodeScreen(
      //       first_name: widget.first_name,
      //       last_name: widget.last_name,
      //       woreda: widget.woreda,
      //       zone: widget.zone,
      //       region: widget.region,
      //       hofficer_name: widget.hofficer_name,
      //       hofficer_phonno: widget.hofficer_phonno,
      //     ),
      //   ),
      // );

      print('Data posted successfully');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post data: ${response.statusCode}')),
      );

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => QRCodeScreen(
      //       first_name: widget.first_name,
      //       last_name: widget.last_name,
      //       woreda: widget.woreda,
      //       zone: widget.zone,
      //       region: widget.region,
      //       hofficer_name: widget.hofficer_name,
      //       hofficer_phonno: widget.hofficer_phonno,
      //     ),
      //   ),
      // );

      print('Failed to post data: ${response.statusCode}');
    }

    setState(() {
      isSaving = false; // Stop saving
    });
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
              if (isSaving)
                CircularProgressIndicator() // Show progress indicator
              else ...[
                Text('Review your data'),
                SizedBox(height: 20),
                ListTile(
                    title: Text('Epidemic Number'),
                    subtitle: Text(widget.epid_number)),
                ListTile(title: Text('Gender'), subtitle: Text(widget.gender)),
                ListTile(
                    title: Text('Date of Birth'),
                    subtitle: Text(widget.dateofbirth)),
                ListTile(title: Text('Zone'), subtitle: Text(widget.zone)),
                ListTile(title: Text('Region'), subtitle: Text(widget.region)),
                ListTile(title: Text('Woreda'), subtitle: Text(widget.woreda)),
                ListTile(
                    title: Text('Fever At Onset'),
                    subtitle: Text(widget.feverAtOnset)),
                ListTile(
                    title: Text('Flaccid Paralysis'),
                    subtitle: Text(widget.flaccidParalysis)),
                ListTile(
                    title: Text('Paralysis Progressed'),
                    subtitle: Text(widget.paralysisProgressed)),
                ListTile(
                    title: Text('Asymmetric'),
                    subtitle: Text(widget.asymmetric)),
                ListTile(
                    title: Text('Site of Paralysis'),
                    subtitle: Text(widget.siteOfParalysis)),
                ListTile(
                    title: Text('Total OPV Doses'),
                    subtitle: Text(widget.totalOPVDoses.toString())),
                ListTile(
                    title: Text('Admitted to Hospital'),
                    subtitle: Text(widget.admittedToHospital)),
                ListTile(
                    title: Text('Date of Admission'),
                    subtitle: Text(widget.dateOfAdmission)),
                ListTile(
                    title: Text('Medical Record No'),
                    subtitle: Text(widget.medicalRecordNo)),
                ListTile(
                    title: Text('Facility Name'),
                    subtitle: Text(widget.facilityName)),
                ListTile(
                    title: Text('Date Stool 1'),
                    subtitle: Text(widget.dateStool1)),
                ListTile(
                    title: Text('Date Stool 2'),
                    subtitle: Text(widget.dateStool2)),
                ListTile(
                    title: Text('Days After Onset'),
                    subtitle: Text(widget.daysAfterOnset)),
                ListTile(
                    title: Text('Stool 1 Date Collected'),
                    subtitle: Text(widget.stool1DateCollected)),
                ListTile(
                    title: Text('Stool 2 Date Collected'),
                    subtitle: Text(widget.stool2DateCollected)),
                ListTile(
                    title: Text('Stool 1 Days After Onset'),
                    subtitle: Text(widget.stool1DaysAfterOnset)),
                ListTile(
                    title: Text('Stool 1 Date Sent to Lab'),
                    subtitle: Text(widget.stool1DateSentToLab)),
                ListTile(
                    title: Text('Stool 2 Date Sent to Lab'),
                    subtitle: Text(widget.stool2DateSentToLab)),
                ListTile(
                    title: Text('Stool 1 Date Received by Lab'),
                    subtitle: Text(widget.stool1DateReceivedByLab)),
                ListTile(
                    title: Text('Stool 2 Date Received by Lab'),
                    subtitle: Text(widget.stool2DateReceivedByLab)),
                ListTile(
                    title: Text('Case or Contact'),
                    subtitle: Text(widget.caseOrContact)),
                ListTile(
                    title: Text('Specimen Condition'),
                    subtitle: Text(widget.specimenCondition)),
                ListTile(
                    title: Text('Stool 2 Days After Onset'),
                    subtitle: Text(widget.stool2DaysAfterOnset)),
                ListTile(
                    title: Text('Residual Paralysis'),
                    subtitle: Text(widget.residualParalysis)),
                ListTile(
                    title: Text('First Name'),
                    subtitle: Text(widget.first_name)),
                ListTile(
                    title: Text('Last Name'), subtitle: Text(widget.last_name)),
                ListTile(
                    title: Text('Phone No'), subtitle: Text(widget.phoneNo)),
                ElevatedButton(
                  onPressed: () async {
                    await postClinicalData(context);

                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => QRCodeScreen(
                    //               first_name: widget.first_name,
                    //               last_name: widget.last_name,
                    //               woreda: widget.woreda,
                    //               zone: widget.zone,
                    //               region: widget.region,
                    //               hofficer_name: widget.hofficer_name,
                    //               hofficer_phonno: widget.hofficer_phonno,
                    //             )));
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
            ],
          ),
        ),
      ),
    );
  }
}
