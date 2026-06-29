import 'package:emp_track/features/authentication/view/login_page.dart';
import 'package:emp_track/features/authentication/viewmodels/auth_viewmodel.dart';
import 'package:emp_track/features/employee/view/attendance_page.dart';
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
      appBar: AppBar(
        title: const Text("Employee Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
          ? Center(child: Text(viewModel.errorMessage!))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Overview",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AttendancePage(),
                                    ),
                                  );

                                  if (mounted) {
                                    await context
                                        .read<EmployeeDashboardViewModel>()
                                        .fetchDashboardStats();
                                  }
                                },
                                child: const Text("Attendance"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LeaveRequestPage(),
                                    ),
                                  );
                                  if (mounted) {
                                    await context
                                        .read<EmployeeDashboardViewModel>()
                                        .fetchDashboardStats();
                                  }
                                },
                                child: const Text("Leave"),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
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
              ),
            ),
    );
  }
}
