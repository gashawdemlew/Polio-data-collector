import 'package:camera_app/color.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateBlogScreen extends StatefulWidget {
  @override
  _CreateBlogScreenState createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final authorController = TextEditingController();

  bool isSubmitting = false;

  Map<String, dynamic> userDetails = {};

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'lastName': prefs.getString('last_name') ?? 'N/A',
      };
      authorController.text =
          '${userDetails['firstName']} ${userDetails['lastName']}';
    });
  }

  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> createBlog() async {
    setState(() {
      isSubmitting = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.8.228:7476/user/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': titleController.text,
        'content': contentController.text,
        'author': authorController.text,
      }),
    );

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 200) {
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create blog'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Blog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CustomColors.testColor1,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Handle info button action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Author cannot be empty' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Content cannot be empty' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.testColor1, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          createBlog();
                        }
                      },
                child: isSubmitting
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('Submit',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
