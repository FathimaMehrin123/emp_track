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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Request Leave",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: leaveType,
                      decoration: const InputDecoration(
                        labelText: "Leave Type",
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            onPressed: pickStartDate,
                            label: Text(
                              startDate == null
                                  ? "Start Date"
                                  : startDate.toString().split(" ")[0],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            onPressed: pickEndDate,
                            label: Text(
                              endDate == null
                                  ? "End Date"
                                  : endDate.toString().split(" ")[0],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: "Reason",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (startDate == null || endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select start and end dates")),
                            );
                            return;
                          }

                          final message = await vm.requestLeave(
                            leaveType: leaveType,
                            startDate: startDate!,
                            endDate: endDate!,
                            reason: reasonController.text,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Submit"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}