import 'package:emp_track/sevices/admin_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AllLeaveRequestsViewmodel extends ChangeNotifier {
  final AdminApiService _adminApiService = AdminApiService();

  bool isLoading = false;
  String? errorMessage;
  List<dynamic> leaves = [];

  Future<void> fetchLeaveRequests() async {
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

    final result = await _adminApiService.getAllLeaveRequests(token: token);

    if (result is Map && result.containsKey("error")) {
      errorMessage = result["error"];
      leaves = [];
    } else {
      leaves = result;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? adminComment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    await _adminApiService.updateLeaveStatus(
      token: token,
      leaveId: leaveId,
      status: status,
      adminComment: adminComment,
    );

    await fetchLeaveRequests();
  }
}