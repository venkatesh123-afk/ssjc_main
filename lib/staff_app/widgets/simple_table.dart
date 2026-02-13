import 'package:flutter/material.dart';

class SimpleTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;

  const SimpleTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          columns: columns
              .map(
                (c) => DataColumn(
                  label: Text(
                    c,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: rows
              .map(
                (r) => DataRow(cells: r.map((v) => DataCell(Text(v))).toList()),
              )
              .toList(),
        ),
      ),
    );
  }
}
