import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/controllers/monthly_attendance_controller.dart';
import 'package:student_app/staff_app/controllers/shift_controller.dart';
import 'package:student_app/staff_app/get_stundents_pages/student_month_attendance_page.dart';

import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/batch_controller.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  // ================= CONTROLLERS =================
  final BranchController branchCtrl = Get.put(BranchController());
  final GroupController groupCtrl = Get.put(GroupController());
  final CourseController courseCtrl = Get.put(CourseController());
  final BatchController batchCtrl = Get.put(BatchController());
  final ShiftController shiftCtrl = Get.put(ShiftController());
  final MonthlyAttendanceController attendanceCtrl = Get.put(
    MonthlyAttendanceController(),
  );

  // ================= SELECTED VALUES =================
  String? branch;
  String? group;
  String? course;
  String? batch;
  String? shift;
  String? month;
  String? selectedMonthName;

  final Map<String, String> monthMap = {
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

  static const Color neon = Color(0xFF00FFF5);

  @override
  void initState() {
    super.initState();

    branchCtrl.loadBranches();

    ever(branchCtrl.branches, (_) {
      if (branchCtrl.branches.isNotEmpty && branch == null) {
        final b = branchCtrl.branches.first;
        branch = b.branchName;
        groupCtrl.loadGroups(b.id);
        setState(() {});
      }
    });

    ever(groupCtrl.groups, (_) {
      if (groupCtrl.groups.isNotEmpty && group == null) {
        final g = groupCtrl.groups.first;
        group = g.name;
        courseCtrl.loadCourses(g.id);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0b132b) : Colors.white,
        elevation: 0,
        title: Text(
          "Student Attendance",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF0b132b),
                    Color(0xFF1c2541),
                    Color(0xFF3a0ca3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF5F6FA), Color(0xFFE8ECF4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0f172a) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.15))
                  : null,
            ),

            // ✅ SINGLE SCROLL
            child: ListView(
              children: [
                Text(
                  "Select filters to view student attendance records",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(
                  () => _filterBox(
                    context: context,
                    label: "Select Branch",
                    icon: Icons.school,
                    iconColor: Colors.cyanAccent,
                    value: branch,
                    items: branchCtrl.branches
                        .map((b) => b.branchName)
                        .toList(),
                    onChanged: (v) {
                      final b = branchCtrl.branches.firstWhere(
                        (e) => e.branchName == v,
                      );
                      setState(() {
                        branch = v;
                        group = course = batch = shift = month = null;
                        selectedMonthName = null;
                      });
                      groupCtrl.loadGroups(b.id);
                      shiftCtrl.loadShifts(b.id);
                    },
                  ),
                ),
                Obx(
                  () => _filterBox(
                    context: context,
                    label: "Select Group",
                    icon: Icons.groups,
                    iconColor: Colors.pinkAccent,
                    value: group,
                    items: groupCtrl.groups.map((g) => g.name).toList(),
                    onChanged: groupCtrl.groups.isEmpty
                        ? null
                        : (v) {
                            final g = groupCtrl.groups.firstWhere(
                              (e) => e.name == v,
                            );
                            setState(() {
                              group = v;
                              course = batch = null;
                            });
                            courseCtrl.loadCourses(g.id);
                          },
                  ),
                ),
                Obx(
                  () => _filterBox(
                    context: context,
                    label: "Select Course",
                    icon: Icons.menu_book,
                    iconColor: Colors.blueAccent,
                    value: course,
                    items: courseCtrl.courses.map((c) => c.courseName).toList(),
                    onChanged: courseCtrl.courses.isEmpty
                        ? null
                        : (v) {
                            final c = courseCtrl.courses.firstWhere(
                              (e) => e.courseName == v,
                            );
                            setState(() {
                              course = v;
                              batch = null;
                            });
                            batchCtrl.loadBatches(c.id);
                          },
                  ),
                ),
                Obx(
                  () => _filterBox(
                    context: context,
                    label: "Select Batch",
                    icon: Icons.group_work,
                    iconColor: Colors.orangeAccent,
                    value: batch,
                    items: batchCtrl.batches.map((b) => b.batchName).toList(),
                    onChanged: batchCtrl.batches.isEmpty
                        ? null
                        : (v) => setState(() => batch = v),
                  ),
                ),
                Obx(
                  () => _filterBox(
                    context: context,
                    label: "Select Shift",
                    icon: Icons.schedule,
                    iconColor: Colors.lightGreenAccent,
                    value: shift,
                    items: shiftCtrl.shifts.map((s) => s.shiftName).toList(),
                    onChanged: shiftCtrl.shifts.isEmpty
                        ? null
                        : (v) => setState(() => shift = v),
                  ),
                ),
                _filterBox(
                  context: context,
                  label: "Select Month",
                  icon: Icons.date_range,
                  iconColor: Colors.pinkAccent,
                  value: selectedMonthName,
                  items: monthMap.keys.toList(),
                  onChanged: (v) => setState(() {
                    selectedMonthName = v;
                    month = monthMap[v!];
                  }),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neon,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      if ([
                        branch,
                        group,
                        course,
                        batch,
                        shift,
                        month,
                      ].contains(null)) {
                        Get.snackbar("Error", "Please select all filters");
                        return;
                      }

                      await attendanceCtrl.loadAttendance(
                        branchId: branchCtrl.branches
                            .firstWhere((e) => e.branchName == branch!)
                            .id,
                        groupId: groupCtrl.groups
                            .firstWhere((e) => e.name == group!)
                            .id,
                        courseId: courseCtrl.courses
                            .firstWhere((e) => e.courseName == course!)
                            .id,
                        batchId: batchCtrl.batches
                            .firstWhere((e) => e.batchName == batch!)
                            .id,
                        shiftId: shiftCtrl.shifts
                            .firstWhere((e) => e.shiftName == shift!)
                            .id,
                        month: month!,
                      );

                      Get.to(
                        () => StudentMonthAttendancePage(
                          studentName: "Students",
                          monthName: selectedMonthName!,
                          year: DateTime.now().year,
                          admNo: '',
                        ),
                      );
                    },
                    child: const Text(
                      "Get Students",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "2025 © SSJC.",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterBox({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF0b132b),
                  Color(0xFF1c3faa),
                  Color(0xFF6a2dbf),
                ],
              )
            : null,
        color: isDark ? null : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.35)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF0b132b) : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? neon : Colors.black54,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
