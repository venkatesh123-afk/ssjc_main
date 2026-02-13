import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/class_attendance_controller.dart';
import '../model/branch_model.dart';
import '../model/group_model.dart';
import '../model/course_model.dart';
import '../model/batch_model.dart';
import '../model/shift_model.dart';

class ClassAttendancePage extends StatefulWidget {
  const ClassAttendancePage({super.key});

  @override
  State<ClassAttendancePage> createState() => _ClassAttendancePageState();
}

class _ClassAttendancePageState extends State<ClassAttendancePage> {
  final ClassAttendanceController controller =
      Get.put(ClassAttendanceController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Class Attendance"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ✅ BACKGROUND GRADIENT
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B132B),
                    Color(0xFF1C2541),
                    Color(0xFF3A506B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5F7FA),
                    Color(0xFFE4E8F0),
                  ],
                ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Use GetBuilder to rebuild when update() is called or just use Obx carefully
                // Since we have optional controllers, Obx might throw if we don't access value
                // A safer way is to check inside Obx or use GetBuilder

                // Branch Selection
                Builder(builder: (context) {
                  final branchCtrl = controller.branchCtrl;
                  if (branchCtrl == null) {
                    return _selectionCard(
                      isDark: isDark,
                      icon: Icons.account_tree_rounded,
                      iconColor: Colors.grey,
                      title: "Branch (Loading...)",
                      value: null,
                      onTap: () {},
                    );
                  }
                  return Obx(() => _selectionCard(
                        isDark: isDark,
                        icon: Icons.account_tree_rounded,
                        iconColor: Colors.cyan,
                        title: "Select Branch",
                        value: branchCtrl.selectedBranch.value?.branchName,
                        onTap: () {
                          _showSelectionSheet<BranchModel>(
                            context: context,
                            title: "Select Branch",
                            items: branchCtrl.branches,
                            getName: (item) => item.branchName,
                            onSelected: (item) {
                              branchCtrl.selectedBranch.value = item;
                              // Reset dependent controllers
                              controller.groupCtrl?.selectedGroup.value = null;
                              controller.courseCtrl?.selectedCourse.value =
                                  null;
                              controller.batchCtrl?.selectedBatch.value = null;
                              // Load next level
                              controller.groupCtrl?.loadGroups(item.id);
                              controller.shiftCtrl?.loadShifts(item.id);
                            },
                            isDark: isDark,
                          );
                        },
                      ));
                }),

                // Group Selection
                Builder(builder: (context) {
                  final groupCtrl = controller.groupCtrl;
                  if (groupCtrl == null) {
                    return _selectionCard(
                      isDark: isDark,
                      icon: Icons.groups_rounded,
                      iconColor: Colors.grey,
                      title: "Group (Loading...)",
                      value: null,
                      onTap: () {},
                    );
                  }
                  return Obx(() => _selectionCard(
                        isDark: isDark,
                        icon: Icons.groups_rounded,
                        iconColor: Colors.purple,
                        title: "Select Group",
                        value: groupCtrl.selectedGroup.value?.name,
                        onTap: () {
                          if (groupCtrl.groups.isEmpty) {
                            Get.snackbar(
                                "Info", "Please select a branch first");
                            return;
                          }
                          _showSelectionSheet<GroupModel>(
                            context: context,
                            title: "Select Group",
                            items: groupCtrl.groups,
                            getName: (item) => item.name,
                            onSelected: (item) {
                              groupCtrl.selectedGroup.value = item;
                              // Reset dependent controllers
                              controller.courseCtrl?.selectedCourse.value =
                                  null;
                              controller.batchCtrl?.selectedBatch.value = null;
                              // Load next level
                              controller.courseCtrl?.loadCourses(item.id);
                            },
                            isDark: isDark,
                          );
                        },
                      ));
                }),

                // Course Selection
                Builder(builder: (context) {
                  final courseCtrl = controller.courseCtrl;
                  if (courseCtrl == null) {
                    return _selectionCard(
                      isDark: isDark,
                      icon: Icons.menu_book_rounded,
                      iconColor: Colors.grey,
                      title: "Course (Loading...)",
                      value: null,
                      onTap: () {},
                    );
                  }
                  return Obx(() => _selectionCard(
                        isDark: isDark,
                        icon: Icons.menu_book_rounded,
                        iconColor: Colors.blue,
                        title: "Select Course",
                        value: courseCtrl.selectedCourse.value?.courseName,
                        onTap: () {
                          if (courseCtrl.courses.isEmpty) {
                            Get.snackbar("Info", "Please select a group first");
                            return;
                          }
                          _showSelectionSheet<CourseModel>(
                            context: context,
                            title: "Select Course",
                            items: courseCtrl.courses,
                            getName: (item) => item.courseName,
                            onSelected: (item) {
                              courseCtrl.selectedCourse.value = item;
                              // Reset dependent controllers
                              controller.batchCtrl?.selectedBatch.value = null;
                              // Load next level
                              controller.batchCtrl?.loadBatches(item.id);
                            },
                            isDark: isDark,
                          );
                        },
                      ));
                }),

                // Batch Selection
                Builder(builder: (context) {
                  final batchCtrl = controller.batchCtrl;
                  if (batchCtrl == null) {
                    return _selectionCard(
                      isDark: isDark,
                      icon: Icons.class_rounded,
                      iconColor: Colors.grey,
                      title: "Batch (Loading...)",
                      value: null,
                      onTap: () {},
                    );
                  }
                  return Obx(() => _selectionCard(
                        isDark: isDark,
                        icon: Icons.class_rounded,
                        iconColor: Colors.pink,
                        title: "Select Batch",
                        value: batchCtrl.selectedBatch.value?.batchName,
                        onTap: () {
                          if (batchCtrl.batches.isEmpty) {
                            Get.snackbar(
                                "Info", "Please select a course first");
                            return;
                          }
                          _showSelectionSheet<BatchModel>(
                            context: context,
                            title: "Select Batch",
                            items: batchCtrl.batches,
                            getName: (item) => item.batchName,
                            onSelected: (item) {
                              batchCtrl.selectedBatch.value = item;
                            },
                            isDark: isDark,
                          );
                        },
                      ));
                }),

                // Shift Selection
                Builder(builder: (context) {
                  final shiftCtrl = controller.shiftCtrl;
                  if (shiftCtrl == null) {
                    return _selectionCard(
                      isDark: isDark,
                      icon: Icons.schedule_rounded,
                      iconColor: Colors.grey,
                      title: "Shift (Loading...)",
                      value: null,
                      onTap: () {},
                    );
                  }
                  return Obx(() => _selectionCard(
                        isDark: isDark,
                        icon: Icons.schedule_rounded,
                        iconColor: Colors.orange,
                        title: "Select Shift",
                        value: shiftCtrl.selectedShift.value?.shiftName,
                        onTap: () {
                          if (shiftCtrl.shifts.isEmpty) {
                            Get.snackbar(
                                "Info", "Please select a branch first");
                            return;
                          }
                          _showSelectionSheet<ShiftModel>(
                            context: context,
                            title: "Select Shift",
                            items: shiftCtrl.shifts,
                            getName: (item) => item.shiftName,
                            onSelected: (item) {
                              shiftCtrl.selectedShift.value = item;
                            },
                            isDark: isDark,
                          );
                        },
                      ));
                }),

                const SizedBox(height: 30),

                // ✅ BUTTON (works in both themes)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(() => ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.loadClassAttendance(),
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.search, size: 22),
                        label: Text(
                          controller.isLoading.value
                              ? "Loading..."
                              : "Get Students",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1FFFE0),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                      )),
                ),

                const SizedBox(height: 30),

                // ✅ ATTENDANCE DATA DISPLAY
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return _errorCard(isDark, controller.errorMessage.value);
                  }

                  if (controller.attendanceList.isEmpty) {
                    return _emptyStateCard(isDark);
                  }

                  return _attendanceTable(isDark);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SELECTION CARD =================

  // ================= SELECTION CARD =================

  Widget _selectionCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        // ✅ CARD COLOR BASED ON THEME
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color:
                isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),

        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.cyanAccent : Colors.grey.shade600,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // ================= ERROR CARD =================
  Widget _errorCard(bool isDark, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
        border: Border.all(
          color: isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE CARD =================
  Widget _emptyStateCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color:
                isDark ? Colors.white.withOpacity(0.3) : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "No Attendance Data",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select filters and click 'Get Students' to view attendance",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ATTENDANCE TABLE =================
  Widget _attendanceTable(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Attendance Records",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FFFE0).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${controller.attendanceList.length} Students",
                    style: const TextStyle(
                      color: Color(0xFF1FFFE0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Adm No',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  ...List.generate(31, (index) {
                    return DataColumn(
                      label: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }),
                  DataColumn(
                    label: Text(
                      'Present',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Absent',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
                rows: controller.attendanceList.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            student.fullName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          student.admno,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      ...List.generate(31, (index) {
                        final status = student.getAttendanceForDay(index + 1);
                        return DataCell(
                          _attendanceStatusWidget(status, isDark),
                        );
                      }),
                      DataCell(
                        Text(
                          '${student.totalPresent}',
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${student.totalAbsent}',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${student.attendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: student.attendancePercentage >= 75
                                ? Colors.green.shade400
                                : Colors.orange.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ATTENDANCE STATUS WIDGET =================
  Widget _attendanceStatusWidget(String status, bool isDark) {
    Color color;
    String text;

    switch (status) {
      case 'P':
        color = Colors.green.shade400;
        text = 'P';
        break;
      case 'A':
        color = Colors.red.shade400;
        text = 'A';
        break;
      case '-':
        color = isDark ? Colors.white30 : Colors.grey.shade400;
        text = '-';
        break;
      default:
        color = isDark ? Colors.white30 : Colors.grey.shade400;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= SELECTION SHEET =================
  void _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) getName,
    required Function(T) onSelected,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Allow full height control
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6, // Max height 60%
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Divider(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  height: 1),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          "No items found",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              getName(item),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300,
                            ),
                            onTap: () {
                              onSelected(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
