import 'dart:ui';

import 'package:camera_app/polioDashboard.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QRCodeScreen extends StatelessWidget {
  final String first_name;
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
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/qr_code.png';

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
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 350, 350));
      qrCode.paint(canvas, Size(350, 350));

      final picture = recorder.endRecording();
      final img = await picture.toImage(350, 350);
      final byteData = await img.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File(filePath);
      await file.writeAsBytes(buffer);

      // Save to gallery
      await _channel.invokeMethod('saveImage', {'filePath': filePath});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code saved to gallery')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PolioDashboard(),
        ),
      );
    } catch (e) {
      print("DDDDDDDDDD  $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving QR Code: $e'),
          duration: const Duration(seconds: 40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(children: [
                  Text(epid_number),
                ]),
                Row(children: [
                  Text(first_name),
                  SizedBox(
                    width: 10,
                  ),
                  Text(region),
                  SizedBox(
                    width: 10,
                  ),
                  Text(last_name),
                  SizedBox(
                    width: 10,
                  ),
                  Text(zone),
                  SizedBox(
                    width: 10,
                  ),
                  Text(woreda),
                  SizedBox(
                    width: 10,
                  ),
                  Text(hofficer_name),
                  SizedBox(
                    width: 10,
                  ),
                  Text(hofficer_name),
                ]),
              ],
            ),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _downloadQRCode(context),
              child: const Text('Save QR Code to Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
