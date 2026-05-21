import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'financial_operations_screen.dart';
import 'summary_screen.dart';

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
            icon: Icon(Icons.description),
            label: 'Отчеты',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Операции',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Итоги',
          ),
        ],
      ),
    );
  }
}