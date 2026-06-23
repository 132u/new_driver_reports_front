import '../core/constants/api_constants.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;
  final String role;
  final String token;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.token,
    required this.role,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  ReportDetailsDto? report;
  bool get isAdmin => widget.role == 'Admin';
  bool isLoading = false;
  Future<void> deleteReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удаление'),
        content: const Text(
          'Удалить отчет?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Да'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.baseUrl}/reports/${report!.id}',
      ),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка удаления: ${response.statusCode}',
          ),
        ),
      );
    }
  }

  Future<void> openEditReport() async {
    print(report!.id);
  }

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
        '${ApiConstants.baseUrl}/reports/details/${widget.reportId}',
      ),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(jsonEncode(json));
      print('IMAGE PATHS: ${json['imagePaths']}');
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
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Детали отчета',
        ),
        actions: [
          if (isAdmin && report != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                openEditReport();
              },
            ),
          if (isAdmin && report != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteReport();
              },
            ),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            //report!.moneyHolder,
            report!.moneyHolder == 0 ? 'У водителя' : 'У фирмы',
          ),

          const SizedBox(height: 16),

          // ================= COMMENT =================

          if (report!.comment != null && report!.comment!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Комментарий',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Фотографии',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report!.photos.length,
                    itemBuilder: (context, index) {
                      final photo = report!.photos[index];
                      print("photo print = $photo");

                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return Dialog(
                                    backgroundColor: Colors.black,
                                    insetPadding: const EdgeInsets.all(8),
                                    child: Stack(
                                      children: [
                                        InteractiveViewer(
                                          child: Image.network(
                                            '${ApiConstants.serverUrl}$photo',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.network(
                              '${ApiConstants.serverUrl}$photo',
                              width: 220,
                              fit: BoxFit.cover,
                            ),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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

  final int moneyHolder;

  final String? comment;

  final List<String> photos;
// driverId
// paymentType
// price
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
      clientName: json['clientName'] ?? '',
      cash: json['paymentType'] == 0 ? (json['price'] as num?)?.toDouble() : 0,
      nonCashWithVat:
          json['paymentType'] == 1 ? (json['price'] as num?)?.toDouble() : 0,
      moneyHolder: json['moneyHolder'] ?? 0,
      comment: json['description'] ?? '',
      photos: List<String>.from(
        json['imagePaths'] ?? [],
      ),
    );
  }
}
