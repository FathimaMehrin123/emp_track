import 'package:emp_track/features/employee/view/attendance_page.dart';
import 'package:emp_track/features/employee/view/leave_history_page.dart';
import 'package:emp_track/features/employee/view/leave_request_page.dart';
import 'package:emp_track/features/employee/viewmodels/emp_dashbaord_viewmodel.dart';
import 'package:emp_track/features/employee/widgets/emp_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<EmployeeDashboardViewModel>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmployeeDashboardViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Employee Dashboard")),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
          ? Center(child: Text(viewModel.errorMessage!))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendancePage(),
                        ),
                      );
                    },
                    child: const Text("Attendance"),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaveRequestPage(),
                        ),
                      );
                    },
                    child: const Text("Apply Leave"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaveHistoryPage(),
                        ),
                      );
                    },
                    child: const Text("Leave History"),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        EmployeeDashboardCard(
                          title: "Working Days",
                          value: viewModel.workingDays.toString(),
                        ),
                        EmployeeDashboardCard(
                          title: "Present Days",
                          value: viewModel.presentDays.toString(),
                        ),
                        EmployeeDashboardCard(
                          title: "Late Days",
                          value: viewModel.lateDays.toString(),
                        ),
                        EmployeeDashboardCard(
                          title: "Absent Days",
                          value: viewModel.absentDays.toString(),
                        ),
                        EmployeeDashboardCard(
                          title: "Pending Leaves",
                          value: viewModel.pendingLeaves.toString(),
                        ),
                        EmployeeDashboardCard(
                          title: "Approved Leaves",
                          value: viewModel.approvedLeaves.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
