import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SummaryScreen extends StatefulWidget {
  final String token;
  final String role;

  const SummaryScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<SummaryScreen> createState() =>
      _SummaryScreenState();
}

class _SummaryScreenState
    extends State<SummaryScreen> {
  final String baseUrl = kIsWeb
      ? 'http://localhost:5288/api'
      : 'http://10.0.2.2:5288/api';

  bool get isAdmin =>
      widget.role == 'Admin';

  bool isLoading = false;

  DriverMonthlySummaryDto? summary;

  // =====================================================
  // FILTERS
  // =====================================================

  int selectedMonth = DateTime.now().month;

  int selectedYear = DateTime.now().year;

  final List<int> months =
      List.generate(12, (i) => i + 1);

  final List<int> years =
      List.generate(
    5,
    (i) => DateTime.now().year - i,
  );

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
        'Authorization':
            'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json =
          jsonDecode(response.body);

      setState(() {
        drivers = json
            .map(
              (e) => UserDto.fromJson(e),
            )
            .toList();

        if (drivers.isNotEmpty) {
          selectedDriverId =
              drivers.first.id;
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
        '$baseUrl/summary/$selectedDriverId'
        '?year=$selectedYear&month=$selectedMonth',
      );
    } else {
      uri = Uri.parse(
        '$baseUrl/summary/my'
        '?year=$selectedYear&month=$selectedMonth',
      );
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization':
            'Bearer ${widget.token}',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final json =
          jsonDecode(response.body);

      setState(() {
        summary =
            DriverMonthlySummaryDto
                .fromJson(json);

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: ${response.statusCode}',
          ),
        ),
      );
    }
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Итоговые отчёты'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            buildFilters(),

            const SizedBox(height: 16),

            Expanded(
              child: buildBody(),
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
      children: [
        if (isAdmin)
          SizedBox(
            width: 220,
            child:
                DropdownButton<String>(
              value: selectedDriverId,
              isExpanded: true,
              hint:
                  const Text('Водитель'),
              items:
                  drivers.map((driver) {
                return DropdownMenuItem(
                  value: driver.id,
                  child:
                      Text(driver.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDriverId =
                      value;
                });
              },
            ),
          ),

        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(
                  month.toString(),
                ),
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

        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedYear,
            isExpanded: true,
            items: years.map((year) {
              return DropdownMenuItem(
                value: year,
                child:
                    Text(year.toString()),
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

        ElevatedButton(
          onPressed: loadSummary,
          child:
              const Text('Показать'),
        ),
      ],
    );
  }

  // =====================================================
  // BODY
  // =====================================================

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (summary == null) {
      return const Center(
        child: Text('Нет данных'),
      );
    }

    return ListView(
      children: [
        buildCard(
          'Наличные',
          summary!.cashEarned,
        ),

        buildCard(
          'Безнал с НДС',
          summary!.nonCashWithVat,
        ),

        buildCard(
          'Безнал без НДС',
          summary!.nonCashWithoutVat,
        ),

        buildCard(
          'Авансы',
          summary!.advanceTotal,
        ),

        buildCard(
          'Топливо',
          summary!.fuelTotal,
        ),

        buildCard(
          'Работа на базе',
          summary!.baseWorkTotal,
        ),

        buildCard(
          'Сдал денег',
          summary!.settlementsTotal,
        ),

        buildCard(
          'Общая сумма',
          summary!.totalEarned,
        ),

        buildCard(
          'Зарплата',
          summary!.salary,
        ),

        Card(
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Баланс',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  summary!
                              .remainingDebt >
                          0
                      ? 'Виктор должен водителю'
                      : 'Водитель должен Виктору',
                  style:
                      const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  summary!
                      .remainingDebt
                      .abs()
                      .toStringAsFixed(2),
                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // CARD
  // =====================================================

  Widget buildCard(
    String title,
    double value,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// DTO
// =====================================================

class DriverMonthlySummaryDto {
  final double cashEarned;

  final double nonCashWithVat;

  final double nonCashWithoutVat;

  final double advanceTotal;

  final double fuelTotal;

  final double baseWorkTotal;

  final double settlementsTotal;

  final double totalEarned;

  final double salary;

  final double remainingDebt;

  DriverMonthlySummaryDto({
    required this.cashEarned,
    required this.nonCashWithVat,
    required this.nonCashWithoutVat,
    required this.advanceTotal,
    required this.fuelTotal,
    required this.baseWorkTotal,
    required this.settlementsTotal,
    required this.totalEarned,
    required this.salary,
    required this.remainingDebt,
  });

  factory DriverMonthlySummaryDto
      .fromJson(
    Map<String, dynamic> json,
  ) {
    double parse(dynamic value) {
      return (value as num?)
              ?.toDouble() ??
          0;
    }

    return DriverMonthlySummaryDto(
      cashEarned:
          parse(json['cashEarned']),

      nonCashWithVat:
          parse(
              json['nonCashWithVat']),

      nonCashWithoutVat: parse(
        json['nonCashWithoutVat'],
      ),

      advanceTotal:
          parse(json['advanceTotal']),

      fuelTotal:
          parse(json['fuelTotal']),

      baseWorkTotal:
          parse(json['baseWorkTotal']),

      settlementsTotal: parse(
        json['settlementsTotal'],
      ),

      totalEarned:
          parse(json['totalEarned']),

      salary:
          parse(json['salary']),

      remainingDebt:
          parse(json['remainingDebt']),
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