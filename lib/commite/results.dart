import 'package:flutter/material.dart';
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

    print(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
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
            return EpidDataDisplay(data: data);
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

  const EpidDataDisplay({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final results = data['results'] as Map<String, dynamic>?;

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
        if (data['errors'] != null)
          Text(
            'Errors: ${data['errors']}',
            style: TextStyle(color: Colors.red),
          ),
      ],
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
