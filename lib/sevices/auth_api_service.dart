import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthApiService {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = "employee",
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? "Registration failed"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try{
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": email, "password": password},
    );

     final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body;
    }

    return {
      "error": body["detail"] ?? "Login failed"
    };
  } catch (e) {
    return {
      "error": "Unable to connect to the server."
    };
  }
  }
}
