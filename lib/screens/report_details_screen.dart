import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;

  final String token;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.token,
  });

  @override
  State<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState
    extends State<ReportDetailsScreen> {
  static const String baseUrl =
      'http://10.0.2.2:5288/api';

  ReportDetailsDto? report;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadReport();
  }

  // =====================================================
  // LOAD REPORT
  // =====================================================

  Future<void> loadReport() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
        '$baseUrl/reports/${widget.reportId}',
      ),
      headers: {
        'Authorization':
            'Bearer ${widget.token}',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      setState(() {
        report = ReportDetailsDto.fromJson(
          json,
        );

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
        title: const Text(
          'Детали отчета',
        ),
      ),

      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (report == null) {
      return const Center(
        child: Text('Нет данных'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ================= CLIENT =================

          Text(
            report!.clientName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            formatDate(report!.date),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          // ================= MONEY =================

          Row(
            children: [
              Expanded(
                child: buildMoneyCard(
                  'Наличные',
                  report!.cash,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: buildMoneyCard(
                  'Безнал НДС',
                  report!.nonCashWithVat,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= MONEY HOLDER =================

          buildInfoRow(
            Icons.account_circle,
            'У кого деньги',
            report!.moneyHolder,
          ),

          const SizedBox(height: 16),

          // ================= COMMENT =================

          if (report!.comment != null &&
              report!.comment!.isNotEmpty)
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Комментарий',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Text(
                    report!.comment!,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),

          // ================= PHOTOS =================

          if (report!.photos.isNotEmpty)
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Фотографии',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 220,

                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal,

                    itemCount:
                        report!.photos.length,

                    itemBuilder:
                        (context, index) {
                      final photo =
                          report!.photos[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          right: 12,
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          child: Image.network(
                            photo,
                            width: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  Widget buildMoneyCard(
    String title,
    double? amount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            (amount ?? 0).toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String formatDate(String date) {
    final parsed = DateTime.parse(date);

    return '${parsed.day}.${parsed.month}.${parsed.year}';
  }
}

// =====================================================
// DTO
// =====================================================

class ReportDetailsDto {
  final String id;

  final String date;

  final String clientName;

  final double? cash;

  final double? nonCashWithVat;

  final String moneyHolder;

  final String? comment;

  final List<String> photos;

  ReportDetailsDto({
    required this.id,
    required this.date,
    required this.clientName,
    required this.cash,
    required this.nonCashWithVat,
    required this.moneyHolder,
    this.comment,
    required this.photos,
  });

factory ReportDetailsDto.fromJson(
  Map<String, dynamic> json,
) {
  return ReportDetailsDto(
    id: json['id'],

    date: json['reportDate'],

    clientName:
        json['clientName'] ?? '',

    cash: json['paymentType'] == 0
        ? (json['price'] as num?)?.toDouble()
        : 0,

    nonCashWithVat:
        json['paymentType'] == 1
            ? (json['price'] as num?)?.toDouble()
            : 0,

    moneyHolder:
        json['moneyHolder']
            ?.toString() ??
        '',

    comment:
        json['description'] ?? '',

    photos: List<String>.from(
      json['imagePaths'] ?? [],
    ),
  );
}

}