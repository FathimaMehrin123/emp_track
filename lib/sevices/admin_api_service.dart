import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AdminApiService {
  /// Get admin dashboard statistics.
  Future<Map<String, dynamic>> getDashboardStats({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.adminDashboard),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Failed to fetch admin stats"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }

  /// Get all employees or search employees by name/email.
  Future<dynamic> getEmployees({
    required String token,
    String? search,
  }) async {
    try {
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

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Failed to fetch employees"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }

  /// Approve or reject a leave request.
  Future<Map<String, dynamic>> updateLeaveStatus({
    required String token,
    required String leaveId,
    required String status,
    String? adminComment,
  }) async {
    try {
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

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Failed to update leave status"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }

  Future<dynamic> getAllLeaveRequests({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/admin/leaves"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Failed to fetch leave requests"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }
}


