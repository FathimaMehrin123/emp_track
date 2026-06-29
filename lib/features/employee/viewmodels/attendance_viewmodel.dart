import 'package:emp_track/sevices/attendance_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceApiService _attendanceApiService = AttendanceApiService();

  bool isLoading = false;
  String? errorMessage;
  List<dynamic> attendanceHistory = [];
  int currentPage = 1;
  int? selectedMonth;
  int? selectedYear;

  Future<String> checkIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      return "Token not found";
    }

    final result = await _attendanceApiService.checkIn(token: token);

    await fetchAttendanceHistory();

    return result["message"] ?? result["error"] ?? "Something went wrong";
  }

  Future<void> fetchAttendanceHistory({
  int? page,
  int? month,
  int? year,
}) async {
  isLoading = true;
  errorMessage = null;

  if (page != null) currentPage = page;
  if (month != null || month == null) selectedMonth = month;
  if (year != null || year == null) selectedYear = year;

  notifyListeners();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
    errorMessage = "Token not found";
    isLoading = false;
    notifyListeners();
    return;
  }

  final result = await _attendanceApiService.getAttendanceHistory(
    token: token,
    page: currentPage,
    month: selectedMonth,
    year: selectedYear,
  );

  if (result is Map && result.containsKey("error")) {
    errorMessage = result["error"];
    attendanceHistory = [];
  } else {
    attendanceHistory = result;
  }

  isLoading = false;
  notifyListeners();
}
}
