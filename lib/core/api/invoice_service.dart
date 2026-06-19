import 'dart:convert';

import 'package:driver_reports_app/core/api/api_client.dart';
import 'package:driver_reports_app/core/models/invoice.dart';
import 'package:driver_reports_app/core/models/invoice_summary.dart';

class InvoiceService {
    final ApiClient _client = ApiClient();

    Future<List<Invoice>> getInvoices() async {
    final response = await _client.get('/invoices');

    return (response.body as List)
        .map((e) => Invoice.fromJson(e))
        .toList();
  }

  Future<InvoiceSummary> getSummary() async {
    final response = await _client.get('/invoices/summary');
    final data = jsonDecode(response.body);
    return data;
  }

  Future<void> createInvoice({
    required double amount,
    required DateTime invoiceDate,
    String? comment,
  }) async {
    await _client.post(
      '/invoices',
      body: jsonEncode({
        'amount': amount,
        'invoiceDate': invoiceDate.toIso8601String(),
        'comment': comment,
      }),
    );
  }
}