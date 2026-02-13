import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextStyle? hintStyle;
  final Color? textColor;
  final Color? iconColor;

  const SearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.hintStyle,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      onChanged: onChanged,
      style: TextStyle(
        color: textColor ?? (isDark ? Colors.white : Colors.black),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: iconColor ?? (isDark ? Colors.white70 : Colors.black54),
        ),
        hintText: hint,
        hintStyle: hintStyle ??
            TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
            ),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
