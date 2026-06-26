import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class LeaveApiService {
  Future<Map<String, dynamic>> requestLeave({
    required String token,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.leaveRequest),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getLeaveHistory({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConstants.leaveHistory),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
}