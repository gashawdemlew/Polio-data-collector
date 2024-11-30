import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  File? _profilePic;

  Future<void> _pickProfilePic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _profilePic = File(result.files.single.path!);
      });
    }
  }

  Future<void> _register() async {
    if (_profilePic == null) {
      // Handle error - profile picture not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _userTypeController.text.isEmpty) {
      // Handle error - required fields not filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final uri = Uri.parse('http://153.92.208.33:7070/api/auth/register');
    var request = http.MultipartRequest('POST', uri)
      ..fields['firstName'] = _firstNameController.text
      ..fields['lastName'] = _lastNameController.text
      ..fields['middleName'] = _middleNameController.text
      ..fields['email'] = _emailController.text
      ..fields['password'] = _passwordController.text
      ..fields['phone'] = _phoneController.text
      ..fields['userType'] = _userTypeController.text
      ..files.add(
          await http.MultipartFile.fromPath('profilePic', _profilePic!.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var responseBody = json.decode(responseData);
        // Handle successful registration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        // Navigate to another page or perform other actions
      } else {
        // Handle error
        var responseData = await response.stream.bytesToString();
        var responseBody = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Registration failed: ${responseBody['message']}')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Middle Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _userTypeController,
                decoration: const InputDecoration(labelText: 'User Type'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickProfilePic,
                child: const Text('Select Profile Picture'),
              ),
              const SizedBox(height: 16.0),
              _profilePic == null
                  ? const Text('No image selected.')
                  : Image.file(_profilePic!, height: 100, width: 100),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
