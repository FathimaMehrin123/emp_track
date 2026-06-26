import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viemodels/employee_list_viewmodel.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EmployeeListViewModel>().fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmployeeListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search employee",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    viewModel.fetchEmployees(
                      search: searchController.text.trim(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.employees.length,
                  itemBuilder: (context, index) {
                    final employee = viewModel.employees[index];

                    return Card(
                      child: ListTile(
                        title: Text(employee["name"]),
                        subtitle: Text(employee["email"]),
                        trailing: Text(employee["role"]),
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