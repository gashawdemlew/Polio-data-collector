import 'package:camera_app/color.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/services/api_service.dart';
import 'package:camera_app/user_list.dart';
import 'package:camera_app/util/common/theme_helper.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedRole;

  final List<String> roles = [
    'Admin',
    'Health Officer',
    'Volunteers',
    'Laboratorist'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CustomColors.testColor1,
          title: Text(
            'Register',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: firstNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration('First Name', 'First Name')),
                SizedBox(height: 16),
                TextField(
                    controller: lastNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration('Last Name', 'Last Name')),
                SizedBox(height: 16),
                TextField(
                    controller: phoneNoController,
                    decoration: ThemeHelper()
                        .textInputDecoration('Phone Number', 'Phone Number')),
                SizedBox(height: 16),
                TextField(
                    controller: zoneController,
                    decoration:
                        ThemeHelper().textInputDecoration('Zone', 'Zone')),
                SizedBox(height: 16),
                TextField(
                    controller: woredaController,
                    decoration:
                        ThemeHelper().textInputDecoration('Woreda', 'Woreda')),
                SizedBox(height: 16),
                TextField(
                    controller: latController,
                    decoration: ThemeHelper()
                        .textInputDecoration('Latitude', 'Latitude')),
                SizedBox(height: 16),
                TextField(
                    controller: longController,
                    decoration: ThemeHelper()
                        .textInputDecoration('Longitude', 'Longitude')),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: ThemeHelper()
                      .textInputDecoration('User Role', 'User Role'),
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue;
                    });
                  },
                  items: roles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: ThemeHelper()
                        .textInputDecoration('Password', 'Password')),
                SizedBox(height: 20),
                Container(
                  width: 370,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please select a user role')));
                        return;
                      }

                      try {
                        final response = await ApiService.createUser(
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          phoneNo: phoneNoController.text,
                          zone: zoneController.text,
                          woreda: woredaController.text,
                          lat: latController.text,
                          long: longController.text,
                          userRole: selectedRole!,
                          password: passwordController.text,
                        );
                        print('User created: ${response['message']}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => userList()));
                      } catch (e) {
                        print('Error: $e');
                      }
                    },
                    child: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          CustomColors.testColor1, // Change the text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust the border radius
                      ),
                      elevation: 14, // Add elevation
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: phoneNoController,
                decoration: ThemeHelper()
                    .textInputDecoration('Phone Number', 'Phone Number')),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                    ThemeHelper().textInputDecoration('Password', 'Password')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await ApiService.loginUser(
                    phoneNo: phoneNoController.text,
                    password: passwordController.text,
                  );
                  print(
                      'Login successful: ${response['message']}   ${response['token']}');

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PolioDashboard()));
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
