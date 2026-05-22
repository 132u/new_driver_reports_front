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
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {
  int selectedIndex = 0;

  // =====================================================
  // CREATE MENU
  // =====================================================

  void openCreateMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              // ================= REPORT =================

              ListTile(
                leading: const Icon(
                  Icons.description,
                ),
                title: const Text(
                  'Создать отчет',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/createReport',
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

              if (widget.role == 'Admin')
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

              if (widget.role == 'Admin')
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

              if (widget.role == 'Admin')
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
        builder: (_) =>
            CreateFinancialOperationScreen(
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
    ];

    return Scaffold(
      body: pages[selectedIndex],

      // ================= FAB =================

      floatingActionButton:
          FloatingActionButton(
        onPressed: openCreateMenu,
        child: const Icon(Icons.add),
      ),

      // ================= BOTTOM NAV =================

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
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
            label: 'Операции',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.table_chart,
            ),
            label: 'Итоги',
          ),
        ],
      ),
    );
  }
}