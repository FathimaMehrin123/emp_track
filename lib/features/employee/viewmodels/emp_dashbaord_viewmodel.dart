
import 'package:emp_track/sevices/employee_dashboard_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EmployeeDashboardViewModel extends ChangeNotifier {
  final DashboardApiService _dashboardApiService = DashboardApiService();


  bool isLoading = false;
  String? errorMessage;

  int workingDays = 0;
  int presentDays = 0;
  int lateDays = 0;
  int absentDays = 0;
  int pendingLeaves = 0;
  int approvedLeaves = 0;

  Future<void> fetchDashboardStats() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      errorMessage = "Token not found";
      isLoading = false;
      notifyListeners();
      return;
    }

    final result = await _dashboardApiService.getDashboardStats(token: token);

    if (result.containsKey("error")) {
      errorMessage = result["error"];
    } else {
      workingDays = result["workingDays"] ?? 0;
      presentDays = result["presentDays"] ?? 0;
      lateDays = result["lateDays"] ?? 0;
      absentDays = result["absentDays"] ?? 0;
      pendingLeaves = result["pendingLeaves"] ?? 0;
      approvedLeaves = result["approvedLeaves"] ?? 0;
    }

    isLoading = false;
    notifyListeners();
  }


}