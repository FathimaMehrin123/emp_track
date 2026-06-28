import 'package:emp_track/sevices/leave_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LeaveViewModel extends ChangeNotifier {
  final LeaveApiService _leaveApiService = LeaveApiService();

  bool isLoading = false;
  String? errorMessage;

  List<dynamic> leaveHistory = [];

  Future<void> fetchLeaveHistory() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      errorMessage = "Token not found";
      isLoading = false;
      notifyListeners();
      return;
    }

    leaveHistory =
        await _leaveApiService.getLeaveHistory(token: token);

    isLoading = false;
    notifyListeners();
  }

  Future<String> requestLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      return "Token not found";
    }

    final response =
        await _leaveApiService.requestLeave(
      token: token,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
    

    await fetchLeaveHistory();

    return response["message"] ??
        response["error"] ??
        "Something went wrong";
  }
}