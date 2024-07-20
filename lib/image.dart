import 'dart:io';
import 'package:camera_app/color.dart';
import 'package:camera_app/video.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class TakePictureScreen extends StatefulWidget {
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

  TakePictureScreen({
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

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? cameras;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(
        cameras!.first,
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = join(directory.path, '${DateTime.now()}.png');
      await image.saveTo(imagePath);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DisplayPictureScreen(
              imagePath: imagePath,
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
              stool1DateReceivedByLab: widget.stool1DateReceivedByLab,
              stool2DateReceivedByLab: widget.stool2DateReceivedByLab,
              caseOrContact: widget.caseOrContact,
              specimenCondition: widget.specimenCondition,
              stool2DaysAfterOnset: widget.stool2DaysAfterOnset,
              residualParalysis: widget.residualParalysis,
              phoneNo: widget.phoneNo,
              hofficer_name: widget.hofficer_name,
              hofficer_phonno: widget.hofficer_phonno),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Picture'),
        backgroundColor: Colors.deepPurple,
      ),
      body: cameras == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FloatingActionButton(
                            onPressed: _takePicture,
                            backgroundColor: Colors.deepPurple,
                            child: ScaleTransition(
                              scale: _animation,
                              child: Icon(Icons.camera_alt),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
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

  DisplayPictureScreen({
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
    required this.imagePath,
  });
  Future<void> _uploadImage(File image) async {
    final uri = Uri.parse('http://192.168.1.111:7476/clinic/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['epid_number'] = '12345'
      ..files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();

    if (response.statusCode == 201) {
      print('Image uploaded successfully');
    } else {
      print('Image upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Picture'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(imagePath)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // await _uploadImage(File(imagePath));
                // Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TakeMediaScreen(
                        imagePath: imagePath,
                        rainfall: rainfall,
                        snow: snow,
                        humidity: humidity,
                        tempreture: tempreture,
                        latitude: latitude,
                        longitude: longitude,
                        // name: widget.name,
                        gender: gender,
                        dateofbirth: dateofbirth,
                        epid_number: epid_number,
                        first_name: first_name,
                        last_name: last_name,
                        zone: zone,
                        region: region,
                        woreda: woreda,
                        feverAtOnset: feverAtOnset,
                        flaccidParalysis: flaccidParalysis,
                        paralysisProgressed: paralysisProgressed,
                        asymmetric: asymmetric,
                        siteOfParalysis: siteOfParalysis,
                        totalOPVDoses: totalOPVDoses,
                        admittedToHospital: admittedToHospital,
                        dateOfAdmission: dateOfAdmission,
                        medicalRecordNo: medicalRecordNo,
                        facilityName: facilityName,
                        dateStool1: dateStool1,
                        dateStool2: dateStool2,
                        daysAfterOnset: daysAfterOnset,
                        stool1DateCollected: stool1DateCollected,
                        stool2DateCollected: stool2DateCollected,
                        stool1DaysAfterOnset: stool1DaysAfterOnset,
                        stool1DateSentToLab: stool1DateSentToLab,
                        stool2DateSentToLab: stool2DateSentToLab,
                        stool1DateReceivedByLab: stool1DateReceivedByLab,
                        stool2DateReceivedByLab: stool2DateReceivedByLab,
                        caseOrContact: caseOrContact,
                        specimenCondition: specimenCondition,
                        stool2DaysAfterOnset: stool2DaysAfterOnset,
                        residualParalysis: residualParalysis,
                        phoneNo: phoneNo,
                        hofficer_name: hofficer_name,
                        hofficer_phonno: hofficer_phonno),
                  ),
                );
              },
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
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

// class DisplayVideoScreen extends StatelessWidget {
//   final String latitude;
//   final String longitude;
//   final String first_name;
//   final String last_name;
//   final String phoneNo;
//   final String gender;
//   final String dateofbirth;
//   final String region;
//   final String zone;
//   final String woreda;
//   final String feverAtOnset;
//   final String flaccidParalysis;
//   final String paralysisProgressed;
//   final String asymmetric;
//   final String siteOfParalysis;
//   final int totalOPVDoses;
//   final String admittedToHospital;
//   final String dateOfAdmission;
//   final String medicalRecordNo;
//   final String facilityName;
//   final String dateStool1;
//   final String dateStool2;
//   final String daysAfterOnset;
//   final String stool1DateCollected;
//   final String stool2DateCollected;
//   final String stool1DaysAfterOnset;
//   final String stool2DaysAfterOnset;
//   final String stool1DateSentToLab;
//   final String stool2DateSentToLab;
//   final String stool1DateReceivedByLab;
//   final String stool2DateReceivedByLab;
//   final String caseOrContact;
//   final String specimenCondition;
//   final String residualParalysis;
//   final String tempreture;
//   final String rainfall;
//   final String humidity;
//   final String snow;
//   final String epid_number;
//   final String hofficer_name;

//   final String hofficer_phonno;

//   DisplayVideoScreen({
//     // required this.resources,
//     required this.latitude,
//     required this.longitude,
//     required this.first_name,
//     required this.last_name,
//     required this.phoneNo,
//     required this.gender,
//     required this.dateofbirth,
//     required this.region,
//     required this.zone,
//     required this.woreda,
//     required this.feverAtOnset,
//     required this.flaccidParalysis,
//     required this.paralysisProgressed,
//     required this.asymmetric,
//     required this.siteOfParalysis,
//     required this.totalOPVDoses,
//     required this.admittedToHospital,
//     required this.dateOfAdmission,
//     required this.medicalRecordNo,
//     required this.facilityName,
//     required this.dateStool1,
//     required this.dateStool2,
//     required this.daysAfterOnset,
//     required this.stool1DateCollected,
//     required this.stool2DateCollected,
//     required this.stool1DaysAfterOnset,
//     required this.stool2DaysAfterOnset,
//     required this.stool1DateSentToLab,
//     required this.stool2DateSentToLab,
//     required this.stool1DateReceivedByLab,
//     required this.stool2DateReceivedByLab,
//     required this.caseOrContact,
//     required this.specimenCondition,
//     required this.residualParalysis,
//     required this.tempreture,
//     required this.rainfall,
//     required this.humidity,
//     required this.snow,
//     required this.epid_number,
//     required this.hofficer_name,
//     required this.hofficer_phonno,
//   });


//   Future<void> _uploadVideo(File video) async {
//     final uri = Uri.parse('http://192.168.1.100:7476/clinic/upload');
//     final request = http.MultipartRequest('POST', uri)
//       ..fields['epid_number'] = '12345'
//       ..files.add(await http.MultipartFile.fromPath('video', video.path));
//     final response = await request.send();

//     if (response.statusCode == 201) {
//       print('Video uploaded successfully');
//     } else {
//       print('Video upload failed');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Preview Video'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: Text('Video saved at: ${widget}'),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: () async {
//                 await _uploadVideo(File(videoPath));
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//               ),
//               child: Text('Send to API'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
