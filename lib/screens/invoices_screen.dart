import 'dart:convert';

import 'package:driver_reports_app/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InvoicesScreen extends StatefulWidget {
  final String token;
  final String role;

  const InvoicesScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  bool get isAdmin => widget.role == 'Admin';
  double cashlessVatAmount = 0;
  double invoicesAmount = 0;
  double balance = 0;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  bool isLoading = false;

  List<InvoiceDto> invoiceDtosList = [];

  final List<int> months = List.generate(12, (index) => index + 1);

  final List<int> years =
      List.generate(5, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
   loadData();
  }
Future<void> loadData() async {
  await loadSummary();
  await loadInvoices();
}
Future<void> loadSummary() async {
  final uri = Uri.parse(
    '${ApiConstants.baseUrl}/summary/invoices-summary'
    '?year=$selectedYear&month=$selectedMonth',
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer ${widget.token}',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    final summary =
        InvoiceSummaryDto.fromJson(json);

    setState(() {
      cashlessVatAmount =
          summary.cashlessVatAmount;

      invoicesAmount =
          summary.invoicesAmount;

      balance =
          summary.balance;
    });
  }
}
  Future<void> loadInvoices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/invoices'
        '?year=$selectedYear&month=$selectedMonth',
      );

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
          invoiceDtosList = json.map((e) => InvoiceDto.fromJson(e)).toList();

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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: $e',
          ),
        ),
      );
    }
  }

  String formatDate(String date) {
    final parsed = DateTime.parse(date);

    return '${parsed.day.toString().padLeft(2, '0')}.'
        '${parsed.month.toString().padLeft(2, '0')}.'
        '${parsed.year}';
  }
Widget buildSummaryCards() {
  return Column(
    children: [
      buildCard(
        'Безнал с НДС',
        cashlessVatAmount,
      ),
      buildCard(
        'Сумма счетов',
        invoicesAmount,
      ),
      buildCard(
        'Баланс',
        balance,
      ),
    ],
  );
}
Widget buildCard(
  String title,
  double value,
) {
  return Card(
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
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
            buildFilters(),
            const SizedBox(height: 16),
            buildSummaryCards(),

const SizedBox(height: 16),
            Expanded(
              child: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
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
                child: Text(
                  year.toString(),
                ),
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
          onPressed: loadData,
          child: const Text(
            'Показать',
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (invoiceDtosList.isEmpty) {
      return const Center(
        child: Text(
          'Нет счетов за выбранный период',
        ),
      );
    }

    return ListView.builder(
      itemCount: invoiceDtosList.length,
      itemBuilder: (context, index) {
        final invoice = invoiceDtosList[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          child: ListTile(
            leading: const Icon(
              Icons.receipt_long,
            ),
            title: Text(
              '${invoice.amount.toStringAsFixed(2)}',
            ),
            subtitle: Text(
              invoice.comment,
            ),
            trailing: Text(
              formatDate(invoice.invoiceDate),
            ),
          ),
        );
      },
    );
  }
}

class InvoiceDto {
  final double amount;
  final String invoiceDate;
  final String comment;

  InvoiceDto({
    required this.amount,
    required this.invoiceDate,
    required this.comment,
  });

  factory InvoiceDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceDto(
      amount: (json['amount'] as num).toDouble(),
      invoiceDate: json['invoiceDate'] ?? '',
      comment: json['comment'] ?? '',
    );
  }
}

class InvoiceSummaryDto {
  final double cashlessVatAmount;
  final double invoicesAmount;
  final double balance;

  InvoiceSummaryDto({
    required this.cashlessVatAmount,
    required this.invoicesAmount,
    required this.balance,
  });

  factory InvoiceSummaryDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceSummaryDto(
      cashlessVatAmount:
          (json['cashlessVatAmount'] as num).toDouble(),
      invoicesAmount:
          (json['invoicesAmount'] as num).toDouble(),
      balance:
          (json['balance'] as num).toDouble(),
    );
  }
}
