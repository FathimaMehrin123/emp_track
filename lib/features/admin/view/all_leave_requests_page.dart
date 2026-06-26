import 'package:emp_track/features/admin/viemodels/all_leave_requests_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllLeaveRequestsPage extends StatefulWidget {
  const AllLeaveRequestsPage({super.key});

  @override
  State<AllLeaveRequestsPage> createState() => _LeaveRequestsPageState();
}

class _LeaveRequestsPageState extends State<AllLeaveRequestsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AllLeaveRequestsViewmodel>().fetchLeaveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AllLeaveRequestsViewmodel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Leave Requests")),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: viewModel.leaves.length,
              itemBuilder: (context, index) {
                final leave = viewModel.leaves[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("${leave["employee_name"] ?? ""} - ${leave["leave_type"]}"),
                    subtitle: Text(
                      "${leave["start_date"]} to ${leave["end_date"]}\n"
                      "Status: ${leave["status"]}\n"
                      "Reason: ${leave["reason"]}",
                    ),
                    isThreeLine: true,
                    trailing: leave["status"] == "Pending"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  viewModel.updateLeaveStatus(
                                    leaveId: leave["id"],
                                    status: "Approved",
                                    adminComment: "Approved",
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  viewModel.updateLeaveStatus(
                                    leaveId: leave["id"],
                                    status: "Rejected",
                                    adminComment: "Rejected",
                                  );
                                },
                              ),
                            ],
                          )
                        : Text(leave["status"]),
                  ),
                );
              },
            ),
    );
  }
}