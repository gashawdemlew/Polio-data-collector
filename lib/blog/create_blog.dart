import 'package:camera_app/color.dart';
import 'package:camera_app/commite/list_petients.dart';
import 'package:camera_app/components/appbar.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String userType = '';
  String email = '';
  String _selectedLanguage = "English";
  String languge = "ccc";
  LanguageResources? resources;
  LanguageResources? resource12;

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
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'none';
    if (mounted) {
      setState(() {
        languge = storedLanguage;
        resources = LanguageResources(languge);
        resource12 = resources;
      });
    }
  }

  Future<void> createBlog() async {
    setState(() {
      isSubmitting = true;
    });

    final response = await http.post(
      Uri.parse('${baseUrl}user/posts'),
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
      appBar: CustomAppBar(
        title: languge == "Amharic"
            ? "አዲስ ብሎግ ይፍጠሩ"
            : languge == "AfanOromo"
                ? "Biloogii haaraa uumi"
                : "Create New Blog",
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
                  labelText: languge == "Amharic"
                      ? "ርዕስ"
                      : languge == "AfanOromo"
                          ? "Mata duree"
                          : "Blog Topic",
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
                  labelText: languge == "Amharic"
                      ? "ደራሲ"
                      : languge == "AfanOromo"
                          ? "Barreessaa"
                          : "Author",
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
                  labelText: languge == "Amharic"
                      ? "ደራሲ"
                      : languge == "AfanOromo"
                          ? "Qabiyyee"
                          : "Blog Content",
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
                    borderRadius: BorderRadius.circular(12),
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
                    : Text(
                        languge == "Amharic"
                            ? "መዝግብ"
                            : languge == "AfanOromo"
                                ? "Galchuu"
                                : "Post Blog",
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
