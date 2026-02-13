import 'package:flutter/material.dart';

void showSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> items,
  required String labelKey,
  required Function(Map<String, dynamic>) onSelect,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => ListTile(
                title: Text(item[labelKey].toString()),
                onTap: () {
                  onSelect(item);
                  Navigator.pop(context);
                },
              )),
        ],
      );
    },
  );
}
