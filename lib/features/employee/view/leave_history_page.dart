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
          : ListView.builder(
              itemCount: vm.leaveHistory.length,
              itemBuilder: (context, index) {

                final leave =
                    vm.leaveHistory[index];

                return Card(
                  child: ListTile(
                    title:
                        Text(leave["leave_type"]),
                    subtitle: Text(
                      "${leave["start_date"]} - ${leave["end_date"]}\n"
                      "Status : ${leave["status"]}\n"
                      "Comment : ${leave["admin_comment"] ?? "-"}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}