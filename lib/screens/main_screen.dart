import 'package:driver_reports_app/core/api/token_storage.dart';
import 'package:driver_reports_app/screens/create_invoice_screen.dart';
import 'package:driver_reports_app/screens/create_report_screen.dart';
import 'package:driver_reports_app/screens/invoices_screen.dart';
import 'package:driver_reports_app/screens/version_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'financial_operations_screen.dart';
import 'summary_screen.dart';
import 'create_financial_operation_screen.dart';

class MainScreen extends StatefulWidget {
  final String token;

  final String role;

  const MainScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  bool get isAdmin => widget.role == 'Admin';
  // =====================================================
  // CREATE MENU
  // =====================================================

  void openCreateMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= REPORT =================

              ListTile(
                leading: const Icon(
                  Icons.description,
                ),
                title: const Text(
                  'Отчет',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateReportScreen(
                        token: widget.token,
                        role: widget.role,
                      ),
                    ),
                  );
                },
              ),

              // ================= SETTLEMENT =================

              ListTile(
                leading: const Icon(
                  Icons.attach_money,
                ),
                title: const Text(
                  'Сдача денег',
                ),
                onTap: () {
                  Navigator.pop(context);

                  openFinancialOperation(
                    'Settlement',
                  );
                },
              ),

              // ================= ADMIN ONLY =================
              if (isAdmin)
                ListTile(
                  leading: const Icon(
                    Icons.payments,
                  ),
                  title: const Text(
                    'Аванс',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    openFinancialOperation(
                      'Advance',
                    );
                  },
                ),

              ListTile(
                leading: const Icon(
                  Icons.warehouse,
                ),
                title: const Text(
                  'Работа на базе',
                ),
                onTap: () {
                  Navigator.pop(context);

                  openFinancialOperation(
                    'BaseWorkPayment',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.local_gas_station,
                ),
                title: const Text(
                  'Топливо',
                ),
                onTap: () {
                  Navigator.pop(context);

                  openFinancialOperation(
                    'FuelExpense',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.description,
                ),
                title: const Text(
                  'Счет',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateInvoiceScreen(
                        token: widget.token,
                        role: widget.role,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // OPEN FIN OPERATION
  // =====================================================

  void openFinancialOperation(
    String type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateFinancialOperationScreen(
          token: widget.token,
          role: widget.role,
          type: type,
        ),
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    print('Role = ${widget.role}');
    print('IsAdmin = $isAdmin');

    final pages = [
      HomeScreen(
        token: widget.token,
        role: widget.role,
      ),
      FinancialOperationsScreen(
        token: widget.token,
        role: widget.role,
      ),
      SummaryScreen(
        token: widget.token,
        role: widget.role,
      ),
      if (isAdmin)
        InvoicesScreen(
          token: widget.token,
          role: widget.role,
        ),
    ];
    print('pages count = ${pages.length}');
    print('selectedIndex = $selectedIndex');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final tokenStorage = TokenStorage();

            await tokenStorage.clearToken();

            if (!mounted) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'О приложении',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VersionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[selectedIndex],

      // ================= FAB =================

      floatingActionButton: FloatingActionButton(
        onPressed: openCreateMenu,
        child: const Icon(Icons.add),
      ),

      // ================= BOTTOM NAV =================

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.description,
            ),
            label: 'Отчеты',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.payments,
            ),
            label: 'Финансы',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.table_chart,
            ),
            label: 'Итоги',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.table_chart,
              ),
              label: 'Счета',
            ),
        ],
      ),
    );
  }
}
