import 'package:camera_app/mo/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DemographicForm extends StatefulWidget {
  @override
  _DemographicFormState createState() => _DemographicFormState();
}

class _DemographicFormState extends State<DemographicForm> {
  final _formKey = GlobalKey<FormState>();
  String? epidNumber,
      firstName,
      lastName,
      region,
      zone,
      woreda,
      lat,
      long,
      selectedHealthOfficer;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(
        Uri.parse('http://${baseUrl}clinic/post'),
        body: {
          'epid_number': epidNumber,
          'first_name': firstName,
          'last_name': lastName,
          'region': region,
          'zone': zone,
          'woreda': woreda,
          'lat': lat,
          'long': long,
          'selected_health_officcer': selectedHealthOfficer,
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit data')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demographic Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'EPID Number'),
                onSaved: (value) => epidNumber = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter EPID Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                onSaved: (value) => firstName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter First Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                onSaved: (value) => lastName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Last Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Region'),
                onSaved: (value) => region = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Zone'),
                onSaved: (value) => zone = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Woreda'),
                onSaved: (value) => woreda = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Latitude'),
                onSaved: (value) => lat = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Longitude'),
                onSaved: (value) => long = value,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Selected Health Officer'),
                onSaved: (value) => selectedHealthOfficer = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
