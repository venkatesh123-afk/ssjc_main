import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/search_field.dart';
import '../controllers/hostel_controller.dart';

class HostelAttendanceResultPage extends StatefulWidget {
  const HostelAttendanceResultPage({super.key});

  @override
  State<HostelAttendanceResultPage> createState() =>
      _HostelAttendanceResultPageState();
}

class _HostelAttendanceResultPageState
    extends State<HostelAttendanceResultPage> {
  String _query = "";
  final HostelController hostelCtrl = Get.put(HostelController());

  // COLORS
  static const Color neon = Color(0xFF00FFF5);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color darkBlue = Color(0xFF16213e);
  static const Color midBlue = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF16213e),

      // ✅ APP BAR
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.black.withOpacity(0.35)
            : Colors.white.withOpacity(0.95),
        elevation: 0,
        title: Text(
          "Hostel Attendance Status",
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

      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [darkNavy, darkBlue, midBlue, purpleDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isDark ? null : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 10),

            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.24)
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: SearchField(
                  hint: 'Search room / floor',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.black54 : Colors.black45,
                  ),
                  textColor: Colors.black,
                  iconColor: Colors.black87,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📋 LIST
            Expanded(
              child: Obx(() {
                if (hostelCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: neon),
                  );
                }

                if (hostelCtrl.roomsSummary.isEmpty) {
                  return const Center(
                    child: Text(
                      "No attendance records found.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final filtered = hostelCtrl.roomsSummary.where((row) {
                  final room = (row['room_name'] ?? '')
                      .toString()
                      .toLowerCase();
                  final floor = (row['floor_name'] ?? '')
                      .toString()
                      .toLowerCase();
                  return room.contains(_query.toLowerCase()) ||
                      floor.contains(_query.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching rooms found.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _attendanceCard(filtered[index], isDark),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _attendanceCard(Map<String, dynamic> row, bool isDark) {
    // Note: Adjust these keys based on actual API response structure
    final roomName = row['room_name'] ?? row['room'] ?? 'N/A';
    final floorName = row['floor_name'] ?? row['floor'] ?? 'N/A';
    final incharge = row['incharge'] ?? row['in_charge'] ?? '—';

    final total = int.tryParse(row['total_students']?.toString() ?? '0') ?? 0;
    final present = int.tryParse(row['present_count']?.toString() ?? '0') ?? 0;
    final absent = int.tryParse(row['absent_count']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: () {
        // Navigate to Marking Page
        Get.toNamed(
          '/hostelAttendanceMark',
          arguments: {
            'room_id': row['room_id'] ?? row['id'],
            'room_name': roomName,
            'floor_name': floorName,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? null : Theme.of(context).cardColor,
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    midBlue.withOpacity(0.55),
                    purpleDark.withOpacity(0.55),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? neon.withOpacity(0.35) : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: neon.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Room: $roomName",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: neon,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Details",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              "Floor: $floorName",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              "Incharge: $incharge",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _badge(Icons.people, "Total: $total", neon),
                _badge(
                  Icons.check_circle,
                  "Present: $present",
                  Colors.greenAccent,
                ),
                _badge(Icons.cancel, "Absent: $absent", Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= BADGE =================
  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
