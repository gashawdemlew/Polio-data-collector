import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:7476/user'; // Replace with your API URL

  static Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String phoneNo,
    required String zone,
  required String woreda,
    required String lat,
    required String long,
    required String userRole,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/create');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'phoneNo': phoneNo,
        'zone': zone,
        'woreda': woreda,
        'lat': lat,
        'long': long,
        'user_role': userRole,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String phoneNo,
    required String password,
  }) async {
    final url = Uri.parse('http://localhost:7476/user/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phoneNo': phoneNo,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}
