import 'package:emp_track/features/employee/viewmodels/attendance_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AttendanceViewModel>().fetchAttendanceHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final message = await viewModel.checkIn();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Text("Check In"),
            ),
            const SizedBox(height: 16),

            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (viewModel.errorMessage != null)
              Center(child: Text(viewModel.errorMessage!))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final attendance = viewModel.attendanceHistory[index];

                    return Card(
                      child: ListTile(
                        title: Text("Date: ${attendance["date"]}"),
                        subtitle: Text(
                          "Check In: ${attendance["check_in_time"]}\n"
                          "Status: ${attendance["status"]}",
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}