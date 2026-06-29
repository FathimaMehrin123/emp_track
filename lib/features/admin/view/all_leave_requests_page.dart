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
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: viewModel.leaves.length,
                    itemBuilder: (context, index) {
                      final leave = viewModel.leaves[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              "${leave["employee_name"] ?? ""} - ${leave["leave_type"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Duration: ${leave["start_date"]} to ${leave["end_date"]}\n"
                                "Status: ${leave["status"]}\n"
                                "Reason: ${leave["reason"]}",
                                style: const TextStyle(height: 1.4),
                              ),
                            ),
                            isThreeLine: true,
                            trailing: leave["status"] == "Pending"
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                        tooltip: "Approve",
                                        onPressed: () async {
                                          final commentController =
                                              TextEditingController();

                                          final comment = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Approve Leave"),
                                                content: SizedBox(
                                                  width: 400,
                                                  child: TextField(
                                                    controller: commentController,
                                                    decoration: const InputDecoration(
                                                      labelText: "Admin Comment",
                                                      hintText: "Enter your comment",
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    maxLines: 3,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        context,
                                                        commentController.text,
                                                      );
                                                    },
                                                    child: const Text("Approve"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (comment != null) {
                                            viewModel.updateLeaveStatus(
                                              leaveId: leave["id"],
                                              status: "Approved",
                                              adminComment: comment,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                        tooltip: "Reject",
                                        onPressed: () async {
                                          final commentController =
                                              TextEditingController();

                                          final comment = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Reject Leave"),
                                                content: SizedBox(
                                                  width: 400,
                                                  child: TextField(
                                                    controller: commentController,
                                                    decoration: const InputDecoration(
                                                      labelText: "Admin Comment",
                                                      hintText:
                                                          "Enter reason for rejection",
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    maxLines: 3,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        context,
                                                        commentController.text,
                                                      );
                                                    },
                                                    child: const Text("Reject"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (comment != null) {
                                            viewModel.updateLeaveStatus(
                                              leaveId: leave["id"],
                                              status: "Rejected",
                                              adminComment: comment,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: leave["status"] == "Approved"
                                          ? Colors.green.shade50
                                          : leave["status"] == "Rejected"
                                              ? Colors.red.shade50
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: leave["status"] == "Approved"
                                            ? Colors.green.shade300
                                            : leave["status"] == "Rejected"
                                                ? Colors.red.shade300
                                                : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      leave["status"],
                                      style: TextStyle(
                                        color: leave["status"] == "Approved"
                                            ? Colors.green.shade800
                                            : leave["status"] == "Rejected"
                                                ? Colors.red.shade800
                                                : Colors.grey.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
