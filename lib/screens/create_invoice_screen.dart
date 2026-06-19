import '../core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateInvoiceScreen extends StatefulWidget {
  final String token;
  final String role;
  const CreateInvoiceScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<CreateInvoiceScreen> createState() =>
      CreateInvoiceScreenState();
}

class CreateInvoiceScreenState
    extends State<CreateInvoiceScreen> {

  final amountController = TextEditingController();
  
  final commentController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  bool isLoading = false;
List<InvoiceDto> invoices = [];
  bool get isAdmin => widget.role == 'Admin';

  @override
  void initState() {
    super.initState();

    if (isAdmin) {
      loadInvoices();
    }
  }

  // =========================
  // LOAD INVOICES
  // =========================
  Future<void> loadInvoices() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/invoices'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final result = json
          .map((e) => InvoiceDto.fromJson(e))
          //.where((x) => x.role == "1")
          .toList();
      setState(() {
        invoices = result;
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
      Uri.parse('${ApiConstants.baseUrl}/invoices'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "invoiceDate": selectedDate.toUtc().toIso8601String(),
        "amount": double.parse(
          amountController.text,
        ),
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
        title: const Text('Счета'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

class InvoiceDto {
  final String id;
  final String comment;
  final double amount;
  final String date;

  InvoiceDto({
    required this.id,
    required this.comment,
    required this.amount,
    required this.date,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDto(
      id: json['id'],
      comment: json['comment'],
      amount: json['amount'],
      date: json['date'],
    );
  }
  }
