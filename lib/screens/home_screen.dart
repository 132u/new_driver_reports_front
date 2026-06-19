import '../core/constants/api_constants.dart';
import 'dart:convert';
import 'package:driver_reports_app/screens/report_details_screen.dart';

import 'create_financial_operation_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String token;

  /// Driver или Admin
  final String role;

  const HomeScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void onMenuSelected(String value) {
    switch (value) {
      case 'report':
        Navigator.pushNamed(
          context,
          '/create-report',
        );
        break;

      case 'advance':
        openFinancialOperation('Advance');
        break;

      case 'settlement':
        openFinancialOperation('Settlement');
        break;

      case 'baseWork':
        openFinancialOperation(
          'BaseWorkPayment',
        );
        break;

      case 'fuel':
        openFinancialOperation(
          'FuelExpense',
        );
        break;

      case 'invoice':
        Navigator.pushNamed(
          context,
          '/create-invoice',
        );
        break;
    }
  }

  void openFinancialOperation(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateFinancialOperationScreen(
          token: widget.token,
          role: widget.role,
          type: type,
        ),
      ),
    );
  }

  bool get isAdmin => widget.role == 'Admin';

  int selectedMonth = DateTime.now().month;

  int selectedYear = DateTime.now().year;

  List<ReportDto> reports = [];

  bool isLoading = false;

  final List<int> months = List.generate(12, (i) => i + 1);

  final List<int> years = List.generate(5, (i) => DateTime.now().year - i);

  // =====================================================
  // ADMIN
  // =====================================================

  List<UserDto> drivers = [];

  String? selectedDriverId;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    if (isAdmin) {
      await loadDrivers();
    }

    await loadSummary();
  }

  // =====================================================
  // LOAD DRIVERS
  // =====================================================

  Future<void> loadDrivers() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/drivers'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);

      final result = json.map((e) => UserDto.fromJson(e)).toList();

      setState(() {
        drivers = result;

        if (drivers.isNotEmpty) {
          selectedDriverId = drivers.first.id;
        }
      });
    }
  }

  // =====================================================
  // LOAD SUMMARY
  // =====================================================

  Future<void> loadSummary() async {
    setState(() {
      isLoading = true;
    });

    Uri uri;

    if (isAdmin) {
      uri = Uri.parse(
        '${ApiConstants.baseUrl}/reports/driver/$selectedDriverId'
        '?year=$selectedYear&month=$selectedMonth',
      );
    } else {
      uri = Uri.parse(
        '${ApiConstants.baseUrl}/reports/my'
        '?year=$selectedYear&month=$selectedMonth',
      );
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);

      setState(() {
        reports = json
            .map(
              (e) => ReportDto.fromJson(e),
            )
            .toList();

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: ${response.statusCode}',
          ),
        ),
      );
    }
  }
  // =====================================================
  // ACTIONS
  // =====================================================

  void logout() {
    Navigator.pushReplacementNamed(
      context,
      '/login',
    );
  }

  void openCreateReport() {
    Navigator.pushNamed(
      context,
      '/createReport',
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: buildTable(),
          ),
        ],
      ),
    );
  }
  // =====================================================
  // FILTERS
  // =====================================================

  Widget buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // =================================================
        // ADMIN DRIVER SELECT
        // =================================================

        if (isAdmin)
          SizedBox(
            width: 220,
            child: DropdownButton<String>(
              value: selectedDriverId,
              isExpanded: true,
              hint: const Text('Водитель'),
              items: drivers.map((driver) {
                return DropdownMenuItem(
                  value: driver.id,
                  child: Text(driver.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDriverId = value;
                });
              },
            ),
          ),

        // =================================================
        // MONTH
        // =================================================

        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedMonth = value;
              });
            },
          ),
        ),

        // =================================================
        // YEAR
        // =================================================

        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedYear,
            isExpanded: true,
            items: years.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedYear = value;
              });
            },
          ),
        ),

        // =================================================
        // BUTTON
        // =================================================

        ElevatedButton(
          onPressed: loadSummary,
          child: const Text('Показать'),
        ),
      ],
    );
  }

  // =====================================================
  // TABLE
  // =====================================================
  Widget buildTable() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (reports.isEmpty) {
      return const Center(
        child: Text('Нет отчетов'),
      );
    }

    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final item = reports[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportDetailsScreen(
                  reportId: item.id,
                  token: widget.token,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDate(
                      item.reportDate,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.clientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildInfoBlock(
                          'Наличные',
                          item.paymentType == 0 ? item.price : 0,
                        ),
                      ),
                      Expanded(
                        child: buildInfoBlock(
                          'Безнал НДС',
                          item.paymentType == 1 ? item.price : 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        item.moneyHolder == 0 ? 'У водителя' : 'У фирмы',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
// =====================================================
// INFO BLOCK
// =====================================================

  Widget buildInfoBlock(
    String title,
    double? value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          (value ?? 0).toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
// HELPERS
  // =====================================================

  String formatDate(String date) {
    final parsed = DateTime.parse(date);

    return '${parsed.day}.${parsed.month}.${parsed.year}';
  }
}

// =====================================================
// DTO
// =====================================================

// =====================================================
// ROW DTO
// =====================================================
class ReportDto {
  final String id;

  final String reportDate;

  final String clientName;

  final double price;

  final int paymentType;

  final int moneyHolder;

  ReportDto({
    required this.id,
    required this.reportDate,
    required this.clientName,
    required this.price,
    required this.paymentType,
    required this.moneyHolder,
  });

  factory ReportDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportDto(
      id: json['id'],
      reportDate: json['reportDate'],
      clientName: json['clientName'] ?? '',
      price: (json['price'] as num).toDouble(),
      paymentType: json['paymentType'] ?? 0,
      moneyHolder: json['moneyHolder'] ?? 0,
    );
  }
}
// =====================================================
// USER DTO
// =====================================================

class UserDto {
  final String id;

  final String name;

  UserDto({
    required this.id,
    required this.name,
  });

  factory UserDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserDto(
      id: json['id'],
      name: json['name'],
    );
  }
}
