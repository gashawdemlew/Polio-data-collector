import 'dart:convert';
import 'package:camera_app/color.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsPage extends StatefulWidget {
  final String epidNumber;

  const ResultsPage({Key? key, required this.epidNumber}) : super(key: key);
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late Future<Map<String, dynamic>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final encodedEpidNumber = Uri.encodeComponent(widget.epidNumber);

    final response = await http
        .get(Uri.parse('${baseUrl}ModelRoute/data/$encodedEpidNumber'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: 'AI-Model Prediction',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return _buildResultsView(context, data);
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, Map<String, dynamic> data) {
    final images = (data['images'] as List).cast<Map<String, dynamic>>();
    final methodologies =
        (data['methodologies'] as List).cast<Map<String, dynamic>>();

    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        // Images Section
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Aligns items vertically
          children: [
            Container(
              decoration: BoxDecoration(
                color: CustomColors.testColor1, // Background color of the box
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              padding: EdgeInsets.all(8), // Padding inside the box
              child: Text(
                "1.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
            SizedBox(width: 8), // Space between the box and the text
            Text(
              "Model Result Using Image",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ],
        ),
        Divider(
          color: CustomColors.testColor1,
          thickness: 1,
          endIndent: 30,
        ),
        SizedBox(height: 10),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildRecordContainer(context, images[index],
                  type: "image");
            }),
        SizedBox(height: 20),

        // Methodologies Section
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Aligns items vertically
          children: [
            Container(
              decoration: BoxDecoration(
                color: CustomColors.testColor1, // Background color of the box
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              padding: EdgeInsets.all(8), // Padding inside the box
              child: Text(
                "2.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
            SizedBox(width: 8), // Space between the box and the text
            Text(
              "Model Result using Clinical History",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ],
        ),
        Divider(
          color: CustomColors.testColor1,
          thickness: 1,
          endIndent: 30,
        ),
        SizedBox(height: 10),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: methodologies.length,
            itemBuilder: (context, index) {
              return _buildRecordContainer(context, methodologies[index],
                  type: "method");
            }),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
          child: Text(
            "Finish",
            style: TextStyle(
              fontSize: 18, // Adjust font size
              fontWeight: FontWeight.bold, // Make text bold
              color: Colors.white, // Text color
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.testColor1, // Button background color
            padding: EdgeInsets.symmetric(
                horizontal: 20, vertical: 12), // Button padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordContainer(
      BuildContext context, Map<String, dynamic> record,
      {String type = ""}) {
    final bool suspected = record['suspected'] == "suspected";
    final bool confidence_interval = record['message'] == "not-suspected";
    final String message = record['message'] ?? "N/A";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(
              255, 223, 217, 217), // Set the border color to grey
          width: 0.5, // Set the border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, "Epid Number", record['epid_number']),
            _buildInfoRow(
                context, "confidence interval", record['confidence_interval']),
            _buildInfoRow(context, "suspected", record['suspected']),
            _buildInfoRow(context, "Message", message,
                color: suspected
                    ? Colors.red
                    : confidence_interval
                        ? Colors.green
                        : Colors.black),
            _buildInfoRow(context, "Date", _formatDate(record['createdAt'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, dynamic value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text: "$label : ",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: GoogleFonts.poppins().fontFamily)),
        TextSpan(
            text: "$value",
            style: TextStyle(
                color: color ?? Colors.grey,
                fontFamily: GoogleFonts.poppins().fontFamily)),
      ])),
    );
  }

  String _formatDate(String dateString) {
    final parsedDate = DateTime.parse(dateString);
    return DateFormat('MMMM d, yyyy, hh:mm a').format(parsedDate);
  }
}
