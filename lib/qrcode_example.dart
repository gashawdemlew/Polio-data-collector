import 'dart:ui';

import 'package:camera_app/color.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/model_result/model_result.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QRCodeScreen extends StatelessWidget {
  final String first_name;
  final String languge;
  final String last_name;
  final String region;

  final String epid_number;

  final String zone;
  final String woreda;
  final String hofficer_name;
  final String hofficer_phonno;
  late final String qrData;

  QRCodeScreen({
    Key? key,
    required this.first_name,
    required this.languge,
    required this.last_name,
    required this.zone,
    required this.region,
    required this.woreda,
    required this.hofficer_name,
    required this.hofficer_phonno,
    required this.epid_number,
  }) : super(key: key) {
    qrData = 'epid_number: $epid_number, '
        'first_name: $first_name, '
        'last_name: $last_name, '
        'zone: $zone, '
        'region: $region, '
        'woreda: $woreda, '
        'hofficer_name: $hofficer_name, '
        'hofficer_phonno: $hofficer_phonno, ';
  }
  static const MethodChannel _channel = MethodChannel('gallery_saver');
  Future<void> _downloadQRCode(BuildContext context) async {
    try {
      // Get the external directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('External storage directory not found');
      }

      // Define file path with a unique name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/qr_code_$timestamp.png';

      // Generate the QR code as an image
      final qrCode = QrPainter(
        data: qrData,
        options: const QrOptions(
          shapes: QrShapes(
            darkPixel: QrPixelShapeRoundCorners(cornerFraction: .5),
            frame: QrFrameShapeRoundCorners(cornerFraction: .25),
            ball: QrBallShapeRoundCorners(cornerFraction: .25),
          ),
          colors: QrColors(
            dark: QrColorLinearGradient(
              colors: [
                Color.fromARGB(255, 255, 0, 0),
                Color.fromARGB(255, 0, 0, 255)
              ],
              orientation: GradientOrientation.leftDiagonal,
            ),
          ),
        ),
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 350, 350));
      qrCode.paint(canvas, const Size(350, 350));

      final picture = recorder.endRecording();
      final img = await picture.toImage(350, 350);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      // Notify the user of success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code saved at $filePath')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MidelResult(
            epidNumber: epid_number,
          ),
        ),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving QR Code: $e'),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.testColor1,
        title: Text(
            languge == "Amharic" ? 'የተፈጠረው QR  ምስል' : 'Genereted QR Code '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Column(
            //   children: [
            //     Row(children: [
            //       Text(epid_number),
            //     ]),
            //     Row(children: [
            //       Text(first_name),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(region),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(last_name),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(zone),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(woreda),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(hofficer_name),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(hofficer_name),
            //     ]),
            //   ],
            // ),
            CustomPaint(
              painter: QrPainter(
                data: qrData,
                options: const QrOptions(
                  shapes: QrShapes(
                    darkPixel: QrPixelShapeRoundCorners(cornerFraction: .5),
                    frame: QrFrameShapeRoundCorners(cornerFraction: .25),
                    ball: QrBallShapeRoundCorners(cornerFraction: .25),
                  ),
                  colors: QrColors(
                    dark: QrColorLinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 0, 0),
                        Color.fromARGB(255, 0, 0, 255)
                      ],
                      orientation: GradientOrientation.leftDiagonal,
                    ),
                  ),
                ),
              ),
              size: const Size(350, 350),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _downloadQRCode(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: CustomColors.testColor1, // Text color
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 5, // Shadow elevation
              ),
              child: Text(
                languge == "Amharic"
                    ? 'ጋለርይ ላይ አስቀምጥ'
                    : 'Save Image Into Gallery',
                style: const TextStyle(
                  fontSize: 18, // Text size
                  fontWeight: FontWeight.bold, // Text weight
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
