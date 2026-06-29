import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AttendanceApiService {
  Future<Map<String, dynamic>> checkIn({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.checkIn),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {"error": body["detail"] ?? body["error"] ?? "Check in failed"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }

  Future<dynamic> getAttendanceHistory({
    required String token,
    int page = 1,
    int? month,
    int? year,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.attendanceHistory).replace(
        // Build the request URL with query parameters.
        // These values (page, month, year) are sent by the frontend in the URL
        // and FastAPI automatically receives them as the query parameters
        // defined in the backend route (page, month, year).
        queryParameters: {
          "page": page.toString(),
          if (month != null) "month": month.toString(),
          if (year != null) "year": year.toString(),
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

      return {"error": body["detail"] ?? body["error"] ?? "Failed to fetch attendance history"};
    } catch (e) {
      return {"error": "Unable to connect to the server."};
    }
  }
}