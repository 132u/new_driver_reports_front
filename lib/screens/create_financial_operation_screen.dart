import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateFinancialOperationScreen extends StatefulWidget {
  final String token;
  final String role;
  final String type;
  const CreateFinancialOperationScreen({
    super.key,
    required this.token,
    required this.role,
    required this.type,
  });

  @override
  State<CreateFinancialOperationScreen> createState() =>
      _CreateFinancialOperationScreenState();
}

class _CreateFinancialOperationScreenState
    extends State<CreateFinancialOperationScreen> {
  static const String baseUrl = 'http://10.0.2.2:5288/api';

  final amountController = TextEditingController();

  final commentController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  bool isLoading = false;

  List<UserDto> drivers = [];

  String? selectedDriverId;

  bool get isAdmin => widget.role == 'Admin';

  @override
  void initState() {
    super.initState();

    if (isAdmin) {
      loadDrivers();
    }
  }

  // =========================
  // LOAD DRIVERS
  // =========================
  Future<void> loadDrivers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/all'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final result = json
          .map((e) => UserDto.fromJson(e))
          .where((x) => x.role == "1")
          .toList();
      setState(() {
        drivers = result;

        if (drivers.isNotEmpty) {
          selectedDriverId = drivers.first.id;
        }
      });
    }
  }

  // =========================
  // CREATE
  // =========================
  Future<void> create() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/FinancialOperations'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userId": isAdmin ? selectedDriverId : null,
        "date": selectedDate.toUtc().toIso8601String(),
        "amount": double.parse(
          amountController.text,
        ),
        "type": getOperationType(),
        "comment": commentController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: ${response.statusCode}',
          ),
        ),
      );
    }
  }

  // =========================
  // ENUM MAP
  // =========================
  int getOperationType() {
    return typeFromString(widget.type);
  }

  int typeFromString(String type) {
    switch (type) {
      case 'Advance':
        return 0;
      case 'Settlement':
        return 1;
      case 'BaseWorkPayment':
        return 2;
      case 'FuelExpense':
        return 3;
      default:
        return 0;
    }
  }

  // =========================
  // DATE PICKER
  // =========================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовая операция'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= DRIVER SELECT =================

            if (isAdmin)
              DropdownButton<String>(
                isExpanded: true,
                value: selectedDriverId,
                items: drivers.map((d) {
                  return DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(d.userName),
                  );
                }).toList(),
                onChanged: drivers.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          selectedDriverId = value;
                        });
                      },
              ),

            if (isAdmin) const SizedBox(height: 16),

            // ================= AMOUNT =================

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Сумма',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= COMMENT =================
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= DATE =================
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Дата: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text('Выбрать'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : create,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Создать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// DTO
// =========================

class UserDto {
  final String id;
  final String userName;
  final String role;

  UserDto({
    required this.id,
    required this.userName,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      userName: json['name'],
      role: json['roles'].toString(),
    );
  }
}
