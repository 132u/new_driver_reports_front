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
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        if (isAdmin)
          SizedBox(
            width: 180,
            child: DropdownButton<String>(
              value: selectedDriverId,
              isExpanded: true,
              hint: const Text('Водитель'),
              items: drivers.map<DropdownMenuItem<String>>((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(
                    d.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onDriverChanged,
            ),
          ),

        const SizedBox(width: 8),

        SizedBox(
          width: 110,
          child: DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(monthNames[index]),
              );
            }),
            onChanged: (v) {
              if (v != null) onMonthChanged(v);
            },
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 90,
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

        const SizedBox(width: 8),

        ElevatedButton(
          onPressed: onApply,
          child: const Text('Показать'),
        ),
      ],
    ),
  );
}
}