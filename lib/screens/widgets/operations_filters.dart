import 'package:flutter/material.dart';

class OperationsFilters extends StatelessWidget {
  final bool isAdmin;

  final String? selectedDriverId;
  final List<dynamic> drivers;

  final int selectedMonth;
  final int selectedYear;

  final List<int> months;
  final List<int> years;

  final ValueChanged<String?> onDriverChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  final VoidCallback onApply;

  const OperationsFilters({
    super.key,
    required this.isAdmin,
    required this.selectedDriverId,
    required this.drivers,
    required this.selectedMonth,
    required this.selectedYear,
    required this.months,
    required this.years,
    required this.onDriverChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onApply,
  });

  static const List<String> monthNames = [
    'Январь','Февраль','Март','Апрель','Май','Июнь',
    'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [

        // DRIVER
        if (isAdmin)
          SizedBox(
            width: 220,
            child: DropdownButton<String>(
              value: selectedDriverId,
              isExpanded: true,
              hint: const Text('Водитель'),
              items: drivers.map<DropdownMenuItem<String>>((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: onDriverChanged,
            ),
          ),

        // MONTH
        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: List.generate(12, (index) {
              final monthNumber = index + 1;

              return DropdownMenuItem(
                value: monthNumber,
                child: Text(monthNames[index]),
              );
            }),
            onChanged: (v) {
              if (v != null) onMonthChanged(v);
            },
          ),
        ),

        // YEAR
        SizedBox(
          width: 120,
          child: DropdownButton<int>(
            value: selectedYear,
            isExpanded: true,
            items: years.map((y) {
              return DropdownMenuItem(
                value: y,
                child: Text(y.toString()),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onYearChanged(v);
            },
          ),
        ),

        // BUTTON
        ElevatedButton(
          onPressed: onApply,
          child: const Text('Показать'),
        ),
      ],
    );
  }
}