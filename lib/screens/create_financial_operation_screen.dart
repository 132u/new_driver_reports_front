import 'package:driver_reports_app/screens/financial_operations_screen.dart';

import '../core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateFinancialOperationScreen extends StatefulWidget {
  final String token;
  final String role;
  final String type;
  final FinancialOperationDto? operation;
  const CreateFinancialOperationScreen({
    super.key,
    required this.token,
    required this.role,
    required this.type,
    this.operation,
  });

  @override
  State<CreateFinancialOperationScreen> createState() =>
      _CreateFinancialOperationScreenState();
}

class _CreateFinancialOperationScreenState
    extends State<CreateFinancialOperationScreen> {
  bool get isEdit => widget.operation != null;
  final amountController = TextEditingController();

  final commentController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  bool isLoading = false;

  List<UserDto> drivers = [];

  String? selectedDriverId;
  int operationType = 0;
  bool get isAdmin => widget.role == 'Admin';
  @override
  void initState() {
    super.initState();

    if (widget.operation != null) {
      final op = widget.operation!;

      amountController.text = op.amount.toString();

      commentController.text = op.comment ?? '';

      selectedDate = DateTime.parse(op.date);

      selectedDriverId = op.userId;

      operationType = op.type;
    }

    if (isAdmin) {
      loadDrivers();
    }
  }

  // =========================
  // LOAD DRIVERS
  // =========================
  Future<void> loadDrivers() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/all'),
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

        setState(() {
          drivers = result;

          if (widget.operation != null) {
            selectedDriverId = widget.operation!.userId;
          } else if (drivers.isNotEmpty) {
            selectedDriverId = drivers.first.id;
          }
        });
      });
    }
  }

  // =========================
  // CREATE
  // =========================
  // Future<void> create() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   final response = await http.post(
  //     Uri.parse('${ApiConstants.baseUrl}/financial-operations'),
  //     headers: {
  //       'Authorization': 'Bearer ${widget.token}',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       "userId": isAdmin ? selectedDriverId : null,
  //       "date": selectedDate.toUtc().toIso8601String(),
  //       "amount": double.parse(
  //         amountController.text,
  //       ),
  //       "type": getOperationType(),
  //       "comment": commentController.text,
  //     }),
  //   );

  //   setState(() {
  //     isLoading = false;
  //   });

  //   if (!mounted) return;

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     Navigator.pop(context, true);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Ошибка: ${response.statusCode}',
  //         ),
  //       ),
  //     );
  //   }
  // }
  Future<void> create() async {
    setState(() {
      isLoading = true;
    });

    final body = jsonEncode({
      "userId": isAdmin ? selectedDriverId : null,
      "date": selectedDate.toString().split(' ')[0],
      "amount": double.parse(amountController.text),
      "type": getOperationType(),
      "comment": commentController.text,
    });
print("widget.type = ${widget.type}");
print("operationType = ${operationType}");
    final response = isEdit
        ? await http.put(
            Uri.parse(
              '${ApiConstants.baseUrl}/financial-operations/${widget.operation!.id}',
            ),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: body,
          )
        : await http.post(
            Uri.parse(
              '${ApiConstants.baseUrl}/financial-operations',
            ),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: body,
          );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      Navigator.pop(context, true);
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
      case 'Аванс':
        return 0;

      case 'Settlement':
      case 'Сдача денег':
        return 1;

      case 'BaseWorkPayment':
      case 'Работа на базе':
        return 2;

      case 'FuelExpense':
      case 'Топливо':
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
        title: Text(
          isEdit ? 'Редактирование операции' : 'Финансовая операция',
        ),
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
                    : Text(
                        isEdit ? 'Сохранить' : 'Создать',
                      ),
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
