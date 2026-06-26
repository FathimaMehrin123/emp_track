import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class DashboardApiService {
  Future<Map<String, dynamic>> getDashboardStats({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConstants.empdashboardStats),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
}