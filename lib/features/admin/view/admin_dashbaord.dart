import 'package:emp_track/features/admin/viemodels/dashboard_viewmodel.dart';
import 'package:emp_track/features/admin/view/all_leave_requests_page.dart';
import 'package:emp_track/features/admin/view/employee_list_page.dart';
import 'package:emp_track/features/admin/widgtes/dashboard_card.dart';
import 'package:emp_track/features/authentication/view/login_page.dart';
import 'package:emp_track/features/authentication/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  final String token;

  const AdminDashboardPage({super.key, required this.token});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<AdminDashboardViewModel>(
        context,
        listen: false,
      ).fetchDashboardData(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminDashboardViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  DashboardCard(
                    title: "Total Employees",
                    value: viewModel.totalEmployees.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeListPage(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: "Present Today",
                    value: viewModel.presentToday.toString(),
                  ),
                  DashboardCard(
                    title: "Late Today",
                    value: viewModel.lateToday.toString(),
                  ),
                  DashboardCard(
                    title: "Pending Leaves",
                    value: viewModel.pendingLeaves.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllLeaveRequestsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
