import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AdminApiService {
  /// Get admin dashboard statistics.
  Future<Map<String, dynamic>> getDashboardStats({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminDashboard),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  /// Get all employees or search employees by name/email.
  Future<List<dynamic>> getEmployees({
    required String token,
    String? search,
  }) async {
    // Build the request URL with the optional search query parameter.
    // If search is provided, the backend receives it as:
    // GET /admin/employees?search=value

    final uri = Uri.parse(ApiConstants.employeeList).replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) "search": search,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  /// Approve or reject a leave request.
  Future<Map<String, dynamic>> updateLeaveStatus({
    required String token,
    required String leaveId,
    required String status,
    String? adminComment,
  }) async {
    final response = await http.put(
      Uri.parse("${ApiConstants.leaveApproval}/$leaveId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "status": status,
        "admin_comment": adminComment,
      }),
    );

    return jsonDecode(response.body);
  }

Future<List<dynamic>> getAllLeaveRequests({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse("${ApiConstants.baseUrl}/admin/leaves"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(response.body);
}


}


