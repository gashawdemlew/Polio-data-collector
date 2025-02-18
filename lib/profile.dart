import 'package:camera_app/color.dart';
import 'package:camera_app/mainPage.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// class UserProfile extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             ' Profile page',
//             style: TextStyle(color: Colors.white),
//           ),
//           leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           backgroundColor: CustomColors.testColor1,
//           elevation: 0,
//         ),
//         body: ProfilePage(),
//       ),
//     );
//   }
// }

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<UserProfile> {
  String firstName = '';
  int id = 0;

  String phoneNo = '';
  String zone = '';
  String woreda = '';
  String lastname = '';
  String region = '';
  String password = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String languge = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      id = prefs.getInt('id') ?? 0;
      phoneNo = prefs.getString('phoneNo') ?? '';
      zone = prefs.getString('zone') ?? '';
      woreda = prefs.getString('woreda') ?? '';
      lastname = prefs.getString('last_name') ?? '';
      region = prefs.getString('region') ?? '';
      password = prefs.getString('password') ?? '';
      languge = prefs.getString('selectedLanguage') ?? '';

      // print(languge);
      _firstNameController.text = firstName;
      _phoneNoController.text = phoneNo;
      _zoneController.text = zone;
      _woredaController.text = woreda;
      _lastNameController.text = lastname;
      _regionController.text = region;
      _passwordController.text = password;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final url = '${baseUrl}user/$id';
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'first_name': _firstNameController.text,
          'phoneNo': _phoneNoController.text,
          'zone': _zoneController.text,
          'woreda': _woredaController.text,
          'lastname': _lastNameController.text,
          'region': _regionController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', _firstNameController.text);
        await prefs.setString('phoneNo', _phoneNoController.text);
        await prefs.setString('zone', _zoneController.text);
        await prefs.setString('woreda', _woredaController.text);
        await prefs.setString('lastname', _lastNameController.text);
        await prefs.setString('region', _regionController.text);
        await prefs.setString('password', _passwordController.text);

        setState(() {
          firstName = _firstNameController.text;
          phoneNo = _phoneNoController.text;
          zone = _zoneController.text;
          woreda = _woredaController.text;
          lastname = _lastNameController.text;
          region = _regionController.text;
          password = _passwordController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PolioDashboard(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            languge == "Amharic"
                ? "የፕሮፋይል ገጽ"
                : languge == "AfanOromo"
                    ? "Fuula Piroofaayilii"
                    : "Profile Page",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.testColor1, Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: 26),
              onPressed: () {
                // Implement notification functionality
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.people_alt, size: 26),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ),
                );
              },
              color: Colors.white,
            ),
            SizedBox(width: 10), // Add spacing for better alignment
          ],
        ),
      ),

      // appBar: AppBar(
      //   title: Text(
      //     languge == "Amharic" ? "የፕሮፋይል ገጽ" : "Profile Page",
      //     style:
      //         const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   backgroundColor: CustomColors.testColor1,
      //   elevation: 10,
      //   shadowColor: Colors.black54,
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFEFCF9), Color(0xFFFEFCF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    // Add functionality to update profile picture
                  },
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage('https://via.placeholder.com/150'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit,
                              color: CustomColors.testColor1, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  languge == "Amharic" ? 'አስተካክል' : 'Edit Your Profile',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildTextField(
                          controller: _firstNameController,
                          label: languge == "Amharic" ? "ስም" : "First Name",
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _lastNameController,
                          label: languge == "Amharic" ? "የአባት ስም" : "Last Name",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _phoneNoController,
                          label:
                              languge == "Amharic" ? "ስልክ ቁጥር" : "Phone Number",
                          icon: Icons.phone,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _zoneController,
                          label: languge == "Amharic" ? "ዞን" : "Zone",
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _woredaController,
                          label: languge == "Amharic" ? "ወረዳ" : "Woreda",
                          icon: Icons.map,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _regionController,
                          label: languge == "Amharic" ? "ክልል" : "Region",
                          icon: Icons.map_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _passwordController,
                          label: languge == "Amharic" ? "ፓስወርድ" : "Password",
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 80),
                            foregroundColor: Colors.white,
                            backgroundColor: CustomColors.testColor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 10,
                          ),
                          child: Text(
                            languge == "Amharic"
                                ? 'አስተካክል'
                                : languge == "AfanOromo"
                                    ? 'Piroofaayilii Haaromsi'
                                    : 'Update Profile',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: CustomColors.testColor1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
}
