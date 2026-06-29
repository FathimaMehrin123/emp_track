import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class DashboardApiService {
  Future<Map<String, dynamic>> getDashboardStats({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.empdashboardStats),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      print(response.body);
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Failed to fetch dashboard stats"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }
}