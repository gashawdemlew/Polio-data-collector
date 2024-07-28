import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(SMS());

class SMS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SmsSender(),
    );
  }
}

class SmsSender extends StatefulWidget {
  @override
  _SmsSenderState createState() => _SmsSenderState();
}

class _SmsSenderState extends State<SmsSender> {
  static const platform = MethodChannel('com.example.sms_sender/sms');

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();

  String _smsStatus = '';

  Future<void> _sendSms() async {
    String fullName = _fullNameController.text;
    String region = _regionController.text;
    String zone = _zoneController.text;
    String woreda = _woredaController.text;
    String phoneNumber = _phoneNumberController.text;

    String message = 'fullname: $fullName\n'
        'region: $region\n'
        'zone: $zone\n'
        'woreda: $woreda\n'
        'phone: $phoneNumber';

    try {
      final String result =
          await platform.invokeMethod('sendSms', <String, String>{
        'phoneNumber': phoneNumber,
        'message': message,
      });
      setState(() {
        _smsStatus = 'SMS sent successfully: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _smsStatus = "Failed to send SMS: '${e.message}'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send SMS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: 'Region',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _zoneController,
                      decoration: InputDecoration(
                        labelText: 'Zone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _woredaController,
                      decoration: InputDecoration(
                        labelText: 'Woreda',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendSms,
                      child: Text('Send SMS'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _smsStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _smsStatus.contains('successfully')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
