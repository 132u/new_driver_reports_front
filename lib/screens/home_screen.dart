import 'package:flutter/material.dart';
import '../core/api/report_service.dart';
import 'report_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final reportService = ReportService();

  List reports = [];

  final String driverName = "Viktor";

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final data = await reportService.getReports();

    setState(() {
      reports = data;
    });
  }

  String moneyHolderToString(int value, String driverName) {
    switch (value) {
      case 1:
        return driverName; // 👈 ВОДИТЕЛЬ ИЗ РЕПОРТА
      case 2:
        return "Viktor";
      default:
        return "Unknown";
    }
  }

  void logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  String paymentTypeToString(int value) {
    switch (value) {
      case 0:
        return "Наличные";
      case 1:
        return "Безнал с НДС";
      case 2:
        return "Безнал без НДС";
      default:
        return "Unknown";
    }
  }

  String _formatDate(String? date) {
    if (date == null) return "";

    try {
      return date.split("T")[0]; // убираем время ISO
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // 🔝 TOP BAR
          Container(
            padding: const EdgeInsets.fromLTRB(12, 50, 12, 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Exit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    //Navigator.pushNamed(context, '/createReport');
                    final result =
                        await Navigator.pushNamed(context, '/createReport');
                    if (result == true) {
                      loadReports(); // 👈 обновляем список
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Create"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📌 TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "История отчетов",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 📄 LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await loadReports();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailsScreen(report: report),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // // ✏️ EDIT
                            // IconButton(
                            //   icon: const Icon(Icons.edit, color: Colors.blue),
                            //   onPressed: () {},
                            // ),

                            // const SizedBox(width: 8),

                            // 📄 CONTENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔝 TOP ROW
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _formatDate(report["reportDate"]),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Водитель ${report["driverName"] ?? ""}",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Заказчик ${report["clientName"] ?? ""}",
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // 🔻 DETAILS
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("💰 ${report["price"] ?? 0} ₽"),
                                        Text(
                                          "💳 ${paymentTypeToString(report["paymentType"])}",
                                        ),
                                        Text(
                                          "👤 Деньги у ${moneyHolderToString(
                                            report["moneyHolder"],
                                            report["driverName"],
                                          )}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
