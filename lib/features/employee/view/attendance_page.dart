import 'package:emp_track/features/employee/viewmodels/attendance_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int? selectedMonth;
  int? selectedYear;

  String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString).toLocal();

    return "${DateFormat("d MMMM yyyy").format(dateTime)}, "
        "${DateFormat("h:mm:ss a").format(dateTime)} IST";
  }

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
      appBar: AppBar(title: const Text("Attendance")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Attendance Log",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    Row(
                      children: [
                        DropdownButton<int?>(
                          value: selectedMonth,
                          hint: const Text("All"),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value;
                            });

                            context
                                .read<AttendanceViewModel>()
                                .fetchAttendanceHistory(
                                  page: 1,
                                  month: selectedMonth,
                                  year: selectedYear,
                                );
                          },
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("All"),
                            ),
                            ...List.generate(
                              12,
                              (index) => DropdownMenuItem<int?>(
                                value: index + 1,
                                child: Text("${index + 1}"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        DropdownButton<int?>(
                          value: selectedYear,
                          hint: const Text("All"),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value;
                            });

                            context
                                .read<AttendanceViewModel>()
                                .fetchAttendanceHistory(
                                  page: 1,
                                  month: selectedMonth,
                                  year: selectedYear,
                                );
                          },
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("All"),
                            ),
                            ...List.generate(5, (index) {
                              final year = DateTime.now().year - index;
                              return DropdownMenuItem<int?>(
                                value: year,
                                child: Text("$year"),
                              );
                            }),
                          ],
                        ),

                        const SizedBox(width: 20),

                        ElevatedButton(
                          onPressed: () async {
                            final message = await viewModel.checkIn();

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          },
                          child: const Text("Check In"),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 25),
                if (viewModel.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (viewModel.errorMessage != null)
                  Expanded(child: Center(child: Text(viewModel.errorMessage!)))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.attendanceHistory.length,
                      itemBuilder: (context, index) {
                        final attendance = viewModel.attendanceHistory[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              "Date: ${attendance["date"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Check In: ${formatDateTime(attendance["check_in_time"])}",
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: attendance["status"] == "Present"
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: attendance["status"] == "Present"
                                      ? Colors.green.shade300
                                      : Colors.orange.shade300,
                                ),
                              ),
                              child: Text(
                                attendance["status"],
                                style: TextStyle(
                                  color: attendance["status"] == "Present"
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: viewModel.currentPage > 1
                          ? () {
                              viewModel.fetchAttendanceHistory(
                                page: viewModel.currentPage - 1,
                                month: selectedMonth,
                                year: selectedYear,
                              );
                            }
                          : null,
                      child: const Text("Previous"),
                    ),

                    const SizedBox(width: 20),

                    Text(
                      "Page ${viewModel.currentPage}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: viewModel.attendanceHistory.length == 10
                          ? () {
                              viewModel.fetchAttendanceHistory(
                                page: viewModel.currentPage + 1,
                                month: selectedMonth,
                                year: selectedYear,
                              );
                            }
                          : null,
                      child: const Text("Next"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
