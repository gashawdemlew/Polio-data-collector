import 'dart:io';
import 'dart:ui';
import 'package:camera_app/color.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/modelResults/model_detail.dart';
import 'package:camera_app/model_result/model_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class QRCodeScreen extends StatelessWidget {
  final String imagePath;
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
    required this.imagePath,
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
      if (byteData == null)
        throw Exception('Failed to get byte data from image');

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Save the image to a temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/qr_code.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Send the file path to native Android code
      final String response = await _channel.invokeMethod('saveImage', {
        'filePath': filePath, // Corrected: Now sending a file path
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            epidNumber: epid_number,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving QR Code: $e $print{kkk}')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: languge == "Amharic"
              ? 'የተፈጠረው QR  ምስል'
              : languge == "AfanOromo"
                  ? 'QR koodii Madde'
                  : 'Genereted QR Code '),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                backgroundColor: CustomColors.testColor1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                languge == "Amharic"
                    ? 'ጋለርይ ላይ አስቀምጥ'
                    : languge == "AfanOromo"
                        ? 'Suuraa kana Gaalarii keessa olka’i'
                        : 'Save Image Into Gallery',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
