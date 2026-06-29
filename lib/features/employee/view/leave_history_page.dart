import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/leave_viewmodel.dart';

class LeaveHistoryPage extends StatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  State<LeaveHistoryPage> createState() =>
      _LeaveHistoryPageState();
}

class _LeaveHistoryPageState
    extends State<LeaveHistoryPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<LeaveViewModel>()
          .fetchLeaveHistory();
    });
  }

  @override
  Widget build(BuildContext context) {

    final vm = context.watch<LeaveViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave History"),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ListView.builder(
                    itemCount: vm.leaveHistory.length,
                    itemBuilder: (context, index) {
                      final leave = vm.leaveHistory[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              leave["leave_type"],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Duration: ${leave["start_date"]} to ${leave["end_date"]}\n"
                                "Comment: ${leave["admin_comment"] ?? "-"}",
                                style: const TextStyle(height: 1.4),
                              ),
                            ),
                            trailing: Container(
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
                                  fontSize: 12,
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