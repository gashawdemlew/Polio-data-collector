import 'package:camera_app/commite/list_petients.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EpidDataPage extends StatefulWidget {
  final String epidNumber;

  const EpidDataPage({Key? key, required this.epidNumber}) : super(key: key);

  @override
  State<EpidDataPage> createState() => _EpidDataPageState();
}

class _EpidDataPageState extends State<EpidDataPage> {
  late Future<Map<String, dynamic>> _dataFuture;
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedResult = 'Positive';

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchEpidData(widget.epidNumber);
  }

  Future<Map<String, dynamic>> fetchEpidData(String epidNumber) async {
    final encodedEpidNumber = Uri.encodeComponent(epidNumber);
    final url = Uri.parse(
        'http://192.168.47.228:7476/clinic/getDataByEpidNumber/$encodedEpidNumber');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> getSharedPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve values, using an empty string if they are null
    String last_name = prefs.getString('last_name') ?? '';
    String first_name = prefs.getString('first_name') ?? '';

    return {
      'phone_no': prefs.getString('phoneNo') ?? '',
      'full_name': "$first_name $last_name"
          .trim(), // Trim to avoid leading/trailing spaces
      'user_id':
          (prefs.getInt('id')?.toString() ?? ''), // Convert int to String
    };
  }

  void _showEditModal(
      BuildContext context, Map<String, String> sharedPrefsData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit EPID Data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Phone No: ${sharedPrefsData['phone_no']}'),
                  Text('Full Name: ${sharedPrefsData['full_name']}'),
                  Text('User ID: ${sharedPrefsData['user_id']}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedResult,
                    items: ['Positive', 'Negative']
                        .map((result) => DropdownMenuItem(
                              value: result,
                              child: Text(result),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedResult = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Result',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle form submission
                      _submitForm(sharedPrefsData);
                      Navigator.pop(context);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm(Map<String, String> sharedPrefsData) async {
    final encodedEpidNumber = Uri.encodeComponent(widget.epidNumber);

    final data = {
      ...sharedPrefsData,
      'result': _selectedResult,
      'description': _descriptionController.text,
    };

    // Send data to your API endpoint
    final url = Uri.parse(
        'http://192.168.47.228:7476/clinic/updateCommiteResult/$encodedEpidNumber');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data updated successfully!')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PatientDataPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EPID Data'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final sharedPrefsData = snapshot.data!;

            return EpidDataDisplay(
              data: data,
              onEdit: () async {
                final sharedPrefsData = await getSharedPreferencesData();
                _showEditModal(context, sharedPrefsData);
              },
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}

class EpidDataDisplay extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;

  const EpidDataDisplay({Key? key, required this.data, required this.onEdit})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final results = data['results'] as Map<String, dynamic>?;
    final multimediaInfo = results?['Multimedia Info'] as Map<String, dynamic>?;

    // Safely extracting imagePath and videoPath
    final imagePath = multimediaInfo?['iamge_path'] ?? "";
    final videoPath = multimediaInfo?['viedeo_path'] ?? "";

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'EPID Number: ${data['epid_number']}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        results != null
            ? Column(
                children: results.entries.map((entry) {
                  return SectionCard(
                    title: entry.key,
                    data: entry.value,
                  );
                }).toList(),
              )
            : const Text('No results available'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onEdit,
          child: const Text('Edit Data'),
        ),
        // Displaying multimedia content
        // if (imagePath.isNotEmpty)
        // Image.network(
        //   "data:image/jpeg;base64,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",
        //   height: 200,
        //   fit: BoxFit.cover,
        // ),
        if (videoPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: const VideoPlayerWidget(
                  videoUrl: "https://www.youtube.com/shorts/YeDHkg7E188"),
            ),
          ),
        if (data['errors'] != null)
          Text(
            'Errors: ${data['errors']}',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}

// Placeholder widget for video player (you need to implement this)
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video Player Placeholder\nURL: $videoUrl',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final dynamic data;

  const SectionCard({Key? key, required this.title, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return SizedBox(); // Skip if no data
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            ..._buildDetails(data),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetails(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.entries.map((entry) {
        final key = entry.key;
        final value = entry.value ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  key.replaceAll('_', ' '),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  value.toString(),
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      }).toList();
    } else {
      return [Text(data.toString())];
    }
  }
}
