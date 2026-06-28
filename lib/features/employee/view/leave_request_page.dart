import 'package:emp_track/features/employee/view/leave_history_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/leave_viewmodel.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() =>
      _LeaveRequestPageState();
}

class _LeaveRequestPageState
    extends State<LeaveRequestPage> {

  final reasonController = TextEditingController();

  String leaveType = "Sick";

  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        startDate = date;
      });
    }
  }

  Future<void> pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: startDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        endDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final vm = context.read<LeaveViewModel>();

    return Scaffold(
      appBar: AppBar(
        actions: [
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
        ],
        title: const Text("Apply Leave"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButton<String>(
              value: leaveType,
              isExpanded: true,
              items: const [

                DropdownMenuItem(
                  value: "Sick",
                  child: Text("Sick"),
                ),

                DropdownMenuItem(
                  value: "Casual",
                  child: Text("Casual"),
                ),

                DropdownMenuItem(
                  value: "Emergency",
                  child: Text("Emergency"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  leaveType = value!;
                });
              },
            ),

            ElevatedButton(
              onPressed: pickStartDate,
              child: Text(
                startDate == null
                    ? "Select Start Date"
                    : startDate.toString().split(" ")[0],
              ),
            ),

            ElevatedButton(
              onPressed: pickEndDate,
              child: Text(
                endDate == null
                    ? "Select End Date"
                    : endDate.toString().split(" ")[0],
              ),
            ),

            TextField(
              controller: reasonController,
              decoration:
                  const InputDecoration(labelText: "Reason"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                if (startDate == null ||
                    endDate == null) {
                  return;
                }

                final message =
                    await vm.requestLeave(
                  leaveType: leaveType,
                  startDate: startDate!,
                  endDate: endDate!,
                  reason: reasonController.text,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}