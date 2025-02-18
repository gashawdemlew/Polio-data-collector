import 'package:camera_app/color.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/register_login.dart';
import 'package:camera_app/user_register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Added a default font for consistent look
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> _usersFuture;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  String _selectedLanguage = "English";
  String languge = "ccc";
  LanguageResources? resources;
  LanguageResources? resource12;

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

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _usersFuture = fetchUsers();
    _loadUserDetails1();
    _usersFuture.then((users) {
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    });
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('${baseUrl}user/getAllUser'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return (user['first_name']
                    ?.toLowerCase()
                    ?.contains(query.toLowerCase()) ??
                false) ||
            (user['last_name']?.toLowerCase()?.contains(query.toLowerCase()) ??
                false) ||
            (user['phoneNo']
                    ?.toLowerCase()
                    ?.contains(query.toLowerCase()) ??
                false) ||
            (user['user_role']?.toLowerCase()?.contains(query.toLowerCase()) ??
                false) ||
            (user['zone']?.toLowerCase()?.contains(query.toLowerCase()) ??
                false) ||
            (user['woreda']?.toLowerCase()?.contains(query.toLowerCase()) ??
                false);
      }).toList();
    });
  }

  Map<String, dynamic> userDetails = {};
  String languge2 = '';

  Future<void> _loadUserDetails1() async {
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
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
      setState(() {
        languge2 = userDetails['selectedLanguage'];
      });
      print(userDetails);
    });
  }

  //  Add this function to handle user deletion
  Future<void> _deleteUser(int userId) async {
    final url =
        Uri.parse('${baseUrl}user/$userId'); // Replace with your API endpoint
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // User deleted successfully
      print('User deleted successfully');
      // Refresh the user list.  Very important!
      setState(() {
        _usersFuture = fetchUsers(); //Re-fetch users
        _usersFuture.then((users) {
          _allUsers = users; // Update _allUsers after refresh
          _filteredUsers =
              users; //  Reset filtered users, or apply filter again.
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(languge == "Amharic"
                ? "ተጠቃሚው በተሳካ ሁኔታ ተሰርዟል"
                : languge == "AfanOromo"
                    ? "Fayyadamaan sun milkaa'inaan haaqameera"
                    : 'User deleted successfully')),
      );
    } else {
      // Handle error
      print('Failed to delete user. Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(languge == "Amharic"
                ? "ተጠቃሚውን መሰረዝ አልተሳካም"
                : languge == "AfanOromo"
                    ? "Fayyadamaa sana haquun hin danda'amne"
                    : 'Failed to delete user')),
      );
    }
  }

  // Add delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(int userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languge == "Amharic"
              ? 'ማስጠንቀቂያ!'
              : languge == "AfanOromo"
                  ? 'Akeekkachiisa!'
                  : 'Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(languge == "Amharic"
                    ? 'ይህን ተጠቃሚ መሰረዝዎን እርግጠኛ ነዎት?'
                    : languge == "AfanOromo"
                        ? 'Fayyadamaa kana haquuf mirkanaa\'aa dha?'
                        : 'Are you sure you want to delete this user?'),
                Text(languge == "Amharic"
                    ? 'ይህ እርምጃ መቀልበስ አይቻልም.'
                    : languge == "AfanOromo"
                        ? 'Tarkaanfiin kun duubatti deebi\'uu hin danda\'u.'
                        : 'This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(languge == "Amharic"
                  ? 'ይቅር'
                  : languge == "AfanOromo"
                      ? 'Dhiifama'
                      : 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text(languge == "Amharic"
                  ? 'ሰርዝ'
                  : languge == "AfanOromo"
                      ? 'Haqi'
                      : 'Delete'),
              onPressed: () {
                _deleteUser(userId); // Call the delete function
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(251, 232, 229, 229),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            languge == "Amharic"
                ? "የተጠቃሚ ዝርዝር"
                : languge == "AfanOromo"
                    ? "Tarreeffama fayyadamtootaa"
                    : 'User List',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PolioDashboard()));
            },
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.testColor1, const Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(4),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: languge == "Amharic"
                    ? "ተጠቃሚዎችን ይፈልጉ"
                    : languge == "AfanOromo"
                        ? "Fayyadamtoota Barbaadi"
                        : "Search Users",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(
                          255, 236, 234, 233)), // Set the border color to red
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 234, 230,
                          230)), // Set the enabled border color to red
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 239, 237,
                          237)), // Set the focused border color to red
                ),
              ),
              onChanged: (value) {
                _filterUsers(value);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                    languge == "Amharic"
                        ? "ተጠቃሚ የለም"
                        : languge == "AfanOromo"
                            ? "fayyadamaan hin argamne"
                            : 'No User Found',
                  ));
                } else {
                  return ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = _filteredUsers[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['first_name']} ${user['last_name']}',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${user['phoneNo']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${user['user_role']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 18, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${user['zone']}, ${user['woreda']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    user['user_id'].toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              // Add delete button here
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red, // Background color
                                  foregroundColor: Colors.white, // Text color
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8), // Padding
                                  textStyle:
                                      TextStyle(fontSize: 16), // Text style
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                  ),
                                ),
                                onPressed: () {
                                  // Call the delete confirmation dialog
                                  _showDeleteConfirmationDialog(
                                      user['user_id']);
                                },
                                child: Text(languge == "Amharic"
                                    ? "ሰርዝ"
                                    : languge == "AfanOromo"
                                        ? "haqaa"
                                        : 'Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RegisterScreen()));
        },
        backgroundColor: CustomColors.testColor1,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
