import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'create_financial_operation_screen.dart';

class FinancialOperationsScreen
    extends StatefulWidget {
  final String token;
  final String role;

  const FinancialOperationsScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<FinancialOperationsScreen>
      createState() =>
          _FinancialOperationsScreenState();
}

class _FinancialOperationsScreenState
    extends State<FinancialOperationsScreen> {
  // static const String baseUrl =
  //     'http://10.0.2.2:5288/api';
final String baseUrl = kIsWeb
    ? 'http://localhost:5288/api'
    : 'http://10.0.2.2:5288/api';
  bool get isAdmin =>
      widget.role == 'Admin';

  // =====================================================
  // FILTERS
  // =====================================================

  int selectedMonth = DateTime.now().month;

  int selectedYear = DateTime.now().year;

  final List<int> months =
      List.generate(12, (i) => i + 1);

  final List<int> years = List.generate(
    5,
    (i) => DateTime.now().year - i,
  );

  // =====================================================
  // ADMIN
  // =====================================================

  List<UserDto> drivers = [];

  String? selectedDriverId;

  // =====================================================
  // DATA
  // =====================================================

  List<FinancialOperationDto>
      operations = [];

  bool isLoading = false;

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

    await loadOperations();
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

      final result = json
          .map((e) => UserDto.fromJson(e))
          .toList();

      setState(() {
        drivers = result;

        if (drivers.isNotEmpty) {
          selectedDriverId =
              drivers.first.id;
        }
      });
    }
  }

  // =====================================================
  // LOAD OPERATIONS
  // =====================================================

  Future<void> loadOperations() async {
    setState(() {
      isLoading = true;
    });

    Uri uri;
 if (isAdmin) {
      uri = Uri.parse(
        '$baseUrl/financial-operations/$selectedDriverId/details'
        '?year=$selectedYear&month=$selectedMonth',
      );
    } else {
      uri = Uri.parse(
        '$baseUrl/financial-operations/my/details'
        '?year=$selectedYear&month=$selectedMonth',
      );
    }
    // if (isAdmin) {
    //   uri = Uri.parse(
    //     '$baseUrl/financialOperations/driver'
    //     '/$selectedDriverId'
    //     '?year=$selectedYear'
    //     '&month=$selectedMonth',
    //   );
    // } else {
    //   uri = Uri.parse(
    //     '$baseUrl/financialOperations/my'
    //     '?year=$selectedYear'
    //     '&month=$selectedMonth',
    //   );
    // }

    final response = await http.get(
      uri,
      headers: {
        'Authorization':
            'Bearer ${widget.token}',
      },
    );
print("PRINT TEST "+response.body);
    if (!mounted) return;

    if (response.statusCode == 200) {
      final List<dynamic> json =
          jsonDecode(response.body);

      setState(() {
        operations = json
            .map(
              (e) =>
                  FinancialOperationDto
                      .fromJson(e),
            )
            .toList();

        isLoading = false;
      });
    } else if (response.statusCode ==
        204) {
      setState(() {
        operations = [];
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
  // OPEN CREATE
  // =====================================================

  void openCreate(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateFinancialOperationScreen(
          token: widget.token,
          role: widget.role,
          type: type,
        ),
      ),
    ).then((_) {
      loadOperations();
    });
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
          child: buildList(),
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
      children: [
        // =============================================
        // DRIVER
        // =============================================

        if (isAdmin)
          SizedBox(
            width: 220,
            child:
                DropdownButton<String>(
              value: selectedDriverId,
              isExpanded: true,
              hint: const Text(
                'Водитель',
              ),
              items: drivers.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(d.name),
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

        // =============================================
        // MONTH
        // =============================================

        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: months.map((m) {
              return DropdownMenuItem(
                value: m,
                child:
                    Text(m.toString()),
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

        // =============================================
        // YEAR
        // =============================================

        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedYear,
            isExpanded: true,
            items: years.map((y) {
              return DropdownMenuItem(
                value: y,
                child:
                    Text(y.toString()),
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

        // =============================================
        // BUTTON
        // =============================================

        ElevatedButton(
          onPressed: loadOperations,
          child:
              const Text('Показать'),
        ),
      ],
    );
  }

  // =====================================================
  // LIST
  // =====================================================

  Widget buildList() {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (operations.isEmpty) {
      return const Center(
        child: Text('Нет данных'),
      );
    }

    return ListView.builder(
      itemCount: operations.length,
      itemBuilder: (context, index) {
        final item =
            operations[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        item.typeName,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        formatDate(
                          item.date,
                        ),
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  item.amount
                      .toStringAsFixed(
                    2,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  String formatDate(String date) {
    final parsed =
        DateTime.parse(date);

    return '${parsed.day}.${parsed.month}.${parsed.year}';
  }
}

// =====================================================
// DTO
// =====================================================

class FinancialOperationDto {
 // final String id;

  final String date;

  final double amount;

  final int type;

  FinancialOperationDto({
  
    required this.date,
    required this.amount,
    required this.type,
  });

  String get typeName {
    switch (type) {
      case 0:
        return 'Аванс';

      case 1:
        return 'Сдача денег';

      case 2:
        return 'Работа на базе';

      case 3:
        return 'Топливо';

      default:
        return 'Неизвестно';
    }
  }

  factory FinancialOperationDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialOperationDto(
          date: json['date'],

      amount:
          (json['amount'] as num)
              .toDouble(),

      type: json['type'],
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