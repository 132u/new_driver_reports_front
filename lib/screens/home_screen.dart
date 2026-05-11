import 'dart:convert';

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
  static const String baseUrl =
      'http://10.0.2.2:5288/api';

  bool get isAdmin => widget.role == 'Admin';

  int selectedMonth = DateTime.now().month;

  int selectedYear = DateTime.now().year;

  DriverDailySummaryDto? summary;

  bool isLoading = false;

  final List<int> months =
      List.generate(12, (i) => i + 1);

  final List<int> years =
      List.generate(5, (i) => DateTime.now().year - i);

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
      Uri.parse('$baseUrl/users/drivers'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json =
          jsonDecode(response.body);

      final result = json
          .map((e) => UserDto.fromJson(e))
          .toList();

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
        '$baseUrl/driver-summaries/$selectedDriverId/details'
        '?year=$selectedYear&month=$selectedMonth',
      );
    } else {
      uri = Uri.parse(
        '$baseUrl/driver-summaries/my/details'
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
      final json = jsonDecode(response.body);

      setState(() {
        summary =
            DriverDailySummaryDto.fromJson(json);

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
      '/create-report',
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: logout,
        ),
        title: Text(
          isAdmin
              ? 'Панель администратора'
              : 'Отчеты водителя',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openCreateReport,
          ),
        ],
      ),
      body: Padding(
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
      crossAxisAlignment:
          WrapCrossAlignment.center,
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

    if (summary == null ||
        summary!.rows.isEmpty) {
      return const Center(
        child: Text('Нет данных'),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Дата')),
            DataColumn(label: Text('Клиент')),
            DataColumn(label: Text('Нал')),
            DataColumn(label: Text('Безнал НДС')),
            DataColumn(label: Text('Безнал')),
            DataColumn(label: Text('Топливо')),
            DataColumn(label: Text('Аванс')),
            DataColumn(label: Text('Сдал')),
            DataColumn(label: Text('База')),
            DataColumn(label: Text('У кого')),
          ],
          rows: summary!.rows.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    formatDate(item.date),
                  ),
                ),

                DataCell(
                  Text(item.clientName ?? ''),
                ),

                DataCell(
                  Text(
                    item.cash?.toString() ?? '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.nonCashWithVat
                            ?.toString() ??
                        '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.nonCashWithoutVat
                            ?.toString() ??
                        '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.fuel?.toString() ?? '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.advance?.toString() ??
                        '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.settlement
                            ?.toString() ??
                        '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.baseWork?.toString() ??
                        '0',
                  ),
                ),

                DataCell(
                  Text(
                    item.moneyHolder ?? '',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // =====================================================
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

class DriverDailySummaryDto {
  final int year;

  final int month;

  final String driverId;

  final List<DriverDailySummaryRowDto> rows;

  DriverDailySummaryDto({
    required this.year,
    required this.month,
    required this.driverId,
    required this.rows,
  });

  factory DriverDailySummaryDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DriverDailySummaryDto(
      year: json['year'],
      month: json['month'],
      driverId: json['driverId'],
      rows: (json['rows'] as List)
          .map(
            (e) =>
                DriverDailySummaryRowDto
                    .fromJson(e),
          )
          .toList(),
    );
  }
}

// =====================================================
// ROW DTO
// =====================================================

class DriverDailySummaryRowDto {
  final String date;

  final String? clientName;

  final double? cash;

  final double? nonCashWithVat;

  final double? nonCashWithoutVat;

  final double? fuel;

  final double? advance;

  final double? settlement;

  final double? baseWork;

  final String? moneyHolder;

  DriverDailySummaryRowDto({
    required this.date,
    this.clientName,
    this.cash,
    this.nonCashWithVat,
    this.nonCashWithoutVat,
    this.fuel,
    this.advance,
    this.settlement,
    this.baseWork,
    this.moneyHolder,
  });

  factory DriverDailySummaryRowDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DriverDailySummaryRowDto(
      date: json['date'],

      clientName: json['clientName'],

      cash:
          (json['cash'] as num?)?.toDouble(),

      nonCashWithVat:
          (json['nonCashWithVat'] as num?)
              ?.toDouble(),

      nonCashWithoutVat:
          (json['nonCashWithoutVat']
                  as num?)
              ?.toDouble(),

      fuel:
          (json['fuel'] as num?)?.toDouble(),

      advance:
          (json['advance'] as num?)
              ?.toDouble(),

      settlement:
          (json['settlement'] as num?)
              ?.toDouble(),

      baseWork:
          (json['baseWork'] as num?)
              ?.toDouble(),

      moneyHolder:
          json['moneyHolder']?.toString(),
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