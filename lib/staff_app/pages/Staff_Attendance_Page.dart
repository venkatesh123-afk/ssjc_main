import 'package:flutter/material.dart';
import 'package:student_app/staff_app/widgets/search_field.dart';

class StaffAttendancePage extends StatefulWidget {
  const StaffAttendancePage({super.key});

  @override
  State<StaffAttendancePage> createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  // ================= COLORS =================
  static const Color dark1 = Color(0xFF1a1a2e);
  static const Color dark2 = Color(0xFF16213e);
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);
  static const Color neon = Color(0xFF00FFF5);

  String query = "";

  // SAMPLE DATA
  final List<Map<String, dynamic>> attendance = [
    {
      "id": "666980",
      "name": "A ANJANEYULU",
      "days": ["A", "A", "A", "A", "A", "A", "A"],
    },
    {
      "id": "667290",
      "name": "A ARUN KUMAR",
      "days": ["A", "A", "A", "A", "A", "A", "A"],
    },
    {
      "id": "666865",
      "name": "A BALARAM",
      "days": ["A", "A", "A", "A", "A", "A", "A"],
    },
    {
      "id": "666870",
      "name": "A G SANKAR REDDY",
      "days": ["A", "A", "A", "A", "A", "A", "A"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = attendance.where((s) {
      return s["name"]!.toLowerCase().contains(query.toLowerCase()) ||
          s["id"]!.contains(query);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Staff Attendance",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [dark1, dark2, dark3, purpleDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 95),

              // ================= SEARCH =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: SearchField(
                    hint: "Search by name / user ID",
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFFB5C7E8) : Colors.black54,
                    ),
                    textColor: isDark ? Colors.white : Colors.black,
                    iconColor: isDark ? neon : Colors.black54,
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================= TITLE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Staff Month Wise - November 2025",
                  style: TextStyle(
                    color: isDark ? neon : Theme.of(context).primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= LIST =================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final staff = filtered[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? LinearGradient(
                                colors: [
                                  dark3.withOpacity(0.55),
                                  purpleDark.withOpacity(0.55),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.08),
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.08),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? neon.withOpacity(0.35)
                              : Theme.of(context).dividerColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? neon.withOpacity(0.2)
                                : Colors.black12,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff["name"],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "User ID: ${staff["id"]}",
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFB5C7E8)
                                  : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // DAYS
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (int i = 0; i < staff["days"].length; i++)
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "${i + 1}",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          staff["days"][i],
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),

          // ================= BOTTOM BUTTONS =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Staff Biometric Logs",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Take Staff Attendance",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
