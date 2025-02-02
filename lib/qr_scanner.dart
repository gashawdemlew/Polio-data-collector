import 'dart:developer';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/util/color/color.dart';
import 'package:camera_app/viewMessage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(home: Qrreader()));

class Qrreader extends StatelessWidget {
  const Qrreader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('Open QR Scanner'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  String? scannedData;
  Map<String, dynamic> userDetails = {};
  String language = '';
  bool isNavigating = false;
  late MobileScannerController _mobileScannerController;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _mobileScannerController = MobileScannerController();
  }

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
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'English',
      };
      language = userDetails['selectedLanguage'];
    });
  }

  @override
  void dispose() {
    // Dispose of the MobileScannerController to free up resources.
    _mobileScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.testColor1,
        title: Text(
          language == "Amharic" ? 'QR ምስሉን አንሳ' : 'Scan QR Code',
          style: TextStyle(
            fontSize: 22, // Increased font size for better visibility
            fontWeight: FontWeight.bold, // Bold for emphasis
            color: Colors.white, // White text for contrast
          ),
        ),
        centerTitle: true, // Center the title
        elevation: 4.0, // Added elevation for depth
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: _mobileScannerController,
              onDetect: (BarcodeCapture capture) async {
                if (!isNavigating) {
                  final barcode = capture.barcodes.firstWhere(
                    (barcode) => barcode.rawValue != null,
                  );
                  if (barcode != null) {
                    setState(() {
                      scannedData = barcode.rawValue;
                      isNavigating = true;
                    });
                    // Stop the camera before navigating
                    await _mobileScannerController.stop();
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => DetailPage(
                        data: scannedData!,
                        language: language,
                      ),
                    ))
                        .then((_) {
                      // Restart the camera after returning
                      _mobileScannerController.start();
                      setState(() {
                        isNavigating = false;
                      });
                    });
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedData != null
                  ? Text(
                      '${language == "Amharic" ? 'የተነበበ' : 'Scanned'}: $scannedData',
                      style: TextStyle(
                        fontSize: 24, // Larger font size for better readability
                        fontWeight: FontWeight.bold, // Bold text for emphasis
                        color: Colors.blueAccent, // Attractive color
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                          ),
                        ], // Shadow for depth
                      ),
                    )
                  : Text(
                      language == "Amharic"
                          ? 'እባኮትን ኮድ ይስነቡ'
                          : 'Please scan a code',
                      style: TextStyle(
                        fontSize: 20, // Slightly smaller than the scanned text
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700], // Softer color for the prompt
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String data;
  final String language;

  const DetailPage({Key? key, required this.data, required this.language})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parsedData = _parseData(data);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
          title: language == "Amharic"
              ? 'ዝርዝር መረጃ'
              : language == "AfaOromo"
                  ? 'ዝርዝር መረጃ'
                  : 'Detailed Information'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                    language == "Amharic"
                        ? 'የግል መረጃ'
                        : language == "AfaOromo"
                            ? 'Odeeffannoo Dhuunfaa'
                            : 'Personal Information',
                    context),
                _buildDetailRow('Epid Number', parsedData['epid_number']),
                _buildDetailRow('First Name', parsedData['first_name']),
                _buildDetailRow('Last Name', parsedData['last_name']),
                const SizedBox(height: 16),
                _buildSectionTitle(
                    language == "Amharic"
                        ? 'የአካባቢ መረጃ'
                        : language == "AfaOromo"
                            ? 'Odeeffannoo Naannoo'
                            : 'Location Information',
                    context),
                _buildDetailRow('Region', parsedData['region']),
                _buildDetailRow('Zone', parsedData['zone']),
                _buildDetailRow('Woreda', parsedData['woreda']),
                const SizedBox(height: 16),
                _buildSectionTitle(
                    language == "Amharic"
                        ? 'የጤና ሰራተኛ መረጃ'
                        : language == "AfaOromo"
                            ? 'Odeeffannoo Hojjetaa Fayyaa'
                            : 'Health Officer Information',
                    context),
                _buildDetailRow('Phone', parsedData['hofficer_phonno']),
                _buildDetailRow('Officer Name', parsedData['hofficer_name']),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AnotherPage(
                            languge: language,
                            epid: parsedData['epid_number'] ?? 'N/A',
                            firstName: parsedData['first_name'] ?? 'N/A',
                            lastName: parsedData['last_name'] ?? 'N/A',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CustomColors.testColor1, // Set background color
                      foregroundColor: Colors.white, // Set text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      elevation: 3, // Set a slight elevation
                      shape: RoundedRectangleBorder(
                        // Add rounded corners
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      language == "Amharic"
                          ? 'ወደ ላብ መረጃ ቅጽ ይሂዱ'
                          : language == "AfaOromo"
                              ? 'gara Formii Odeeffannoo Lab Deemi'
                              : 'Go to Lab Information Form',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white), // Set text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            textStyle: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _parseData(String data) {
    final Map<String, String> result = {};
    try {
      final entries = data.split(',');
      for (var entry in entries) {
        final keyValue = entry.split(':');
        if (keyValue.length == 2) {
          result[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
    } catch (e) {
      log('Error parsing data: $e');
    }
    return result;
  }
}
