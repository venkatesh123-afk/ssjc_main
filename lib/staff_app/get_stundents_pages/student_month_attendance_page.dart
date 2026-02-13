import 'package:flutter/material.dart';

class StudentMonthAttendancePage extends StatelessWidget {
  final String monthName;
  final int year;

  const StudentMonthAttendancePage({
    super.key,
    required this.monthName,
    required this.year,
    required String studentName,
    required String admNo,
  });

  // ================= MONTH MAP =================
  static const Map<String, String> monthMap = {
    "January": "01",
    "February": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12",
  };

  // ================= DAYS IN MONTH =================
  int getDaysInMonth(String monthName, int year) {
    final monthNumber = int.parse(monthMap[monthName]!);

    if (monthNumber == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }

    if ([4, 6, 9, 11].contains(monthNumber)) {
      return 30;
    }

    return 31;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Student Attendance ($year)"),
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF0b132b) : Colors.white,

      // ✅ HORIZONTAL SCROLL FIX
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 520, // 👈 prevents cut on phones
            child: _attendanceTable(isDark),
          ),
        ),
      ),
    );
  }

  // ================= TABLE =================
  Widget _attendanceTable(bool isDark) {
    final borderColor =
        isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black;
    final headerColor = isDark ? const Color(0xFF1b2f5b) : Colors.grey.shade200;
    final cellColor = isDark ? const Color(0xFF2e2a63) : Colors.white;

    final totalDays = getDaysInMonth(monthName, year);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // ================= HEADER =================
          Row(
            children: [
              _fixedCell("S No", 60, headerColor, textColor, borderColor,
                  isHeader: true),
              _fixedCell("Adm No", 90, headerColor, textColor, borderColor,
                  isHeader: true),
              _fixedCell("Name", 120, headerColor, textColor, borderColor,
                  isHeader: true),
              Expanded(
                child: _cell(
                  "$monthName $year",
                  headerColor,
                  textColor,
                  borderColor,
                  isHeader: true,
                ),
              ),
            ],
          ),

          // ================= BODY (VERTICAL SCROLL) =================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(totalDays, (index) {
                  final dayNo = index + 1;

                  return Row(
                    children: [
                      _fixedCell(
                          "$dayNo", 60, cellColor, textColor, borderColor),
                      _fixedCell("", 90, cellColor, textColor, borderColor),
                      _fixedCell("", 120, cellColor, textColor, borderColor),
                      Expanded(
                        child: _cell(
                          "N/A",
                          cellColor,
                          textColor,
                          borderColor,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FIXED CELL =================
  Widget _fixedCell(
    String text,
    double width,
    Color bgColor,
    Color textColor,
    Color borderColor, {
    bool isHeader = false,
  }) {
    return Container(
      width: width,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  // ================= FLEX CELL =================
  Widget _cell(
    String text,
    Color bgColor,
    Color textColor,
    Color borderColor, {
    bool isHeader = false,
  }) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
