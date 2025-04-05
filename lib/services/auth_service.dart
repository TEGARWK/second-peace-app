import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // emulator Android

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json'},
      body: {'name': name, 'email': email, 'password': password},
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
        jsonDecode(res.body)['message'] ?? 'Login/Register failed',
      );
    }
  }
}
