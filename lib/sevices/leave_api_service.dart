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

      return jsonDecode(response.body);
    } catch (e) {
      print(e);
      rethrow;

      ///If an exception occurs, the catch block only prints the error and then reaches the end of the function without returning anything.That's why Dart reports something like:The body might complete normally, causing 'null' to be returned...rethrow tells Dart the function won't continue after the exception.
    }
  }

  Future<List<dynamic>> getLeaveHistory({required String token}) async {
    final response = await http.get(
      Uri.parse(ApiConstants.leaveHistory),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }
}
