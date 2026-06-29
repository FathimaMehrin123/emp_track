import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class LeaveApiService {
  Future<Map<String, dynamic>> requestLeave({
    required String token,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.leaveRequest),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "leave_type": leaveType,
          "start_date": startDate.toIso8601String().split('T').first,
          "end_date": endDate.toIso8601String().split('T').first,
          "reason": reason,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Leave request failed"};
    } catch (e) {
      print(e);
      return {"error": "Unable to connect to the server."};
    }
  }

  Future<dynamic> getLeaveHistory({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.leaveHistory),
        headers: {"Authorization": "Bearer $token"},
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Failed to fetch leave history"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }
}
