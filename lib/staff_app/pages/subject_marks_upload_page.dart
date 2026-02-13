import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';

/// ---------------- BACKGROUND ----------------
class SSJCBackground extends StatelessWidget {
  final Widget child;
  const SSJCBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                  Color(0xFF533483),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
      child: child,
    );
  }
}

/// ---------------- PAGE ----------------
class SubjectMarksUploadPage extends StatefulWidget {
  const SubjectMarksUploadPage({super.key});

  @override
  State<SubjectMarksUploadPage> createState() => _SubjectMarksUploadPageState();
}

class _SubjectMarksUploadPageState extends State<SubjectMarksUploadPage> {
  static const Color neon = Color(0xFF00FFF5);

  // ---------------- CONTROLLERS ----------------
  final BranchController branchCtrl = Get.put(BranchController());
  final GroupController groupCtrl = Get.put(GroupController());
  final CourseController courseCtrl = Get.put(CourseController());

  // ---------------- SELECTED VALUES ----------------
  String? branch;
  String? group;
  String? course;
  String? batch;
  String? exam;
  String? subject;

  int? selectedBranchId;
  int? selectedGroupId;
  int? selectedCourseId;

  // ---------------- STATIC DATA ----------------
  final List<String> batches = ["2023–25", "2024–26", "2025–27"];
  final List<String> exams = [
    "Unit Test–1",
    "Unit Test–2",
    "Quarterly",
    "Half-Yearly",
    "Pre-Final",
    "Final Exam",
  ];
  final List<String> subjects = [
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English",
  ];

  @override
  void initState() {
    super.initState();

    branchCtrl.loadBranches();

    ever(branchCtrl.branches, (_) {
      if (branchCtrl.branches.isNotEmpty && branch == null) {
        final b = branchCtrl.branches.first;
        branch = b.branchName;
        selectedBranchId = b.id;

        groupCtrl.clear();
        courseCtrl.clear();
        groupCtrl.loadGroups(b.id);

        setState(() {});
      }
    });

    ever(groupCtrl.groups, (_) {
      if (groupCtrl.groups.isNotEmpty && group == null) {
        final g = groupCtrl.groups.first;
        group = g.name;
        selectedGroupId = g.id;

        courseCtrl.clear();
        courseCtrl.loadCourses(g.id);

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        title: Text(
          "Subject Marks Upload",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),

      body: SSJCBackground(
        child: Stack(
          children: [
            /// ---------------- SCROLL CONTENT ----------------
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 200),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        color: isDark
                            ? Colors.white24
                            : Theme.of(context).dividerColor,
                        width: 1.3,
                      ),
                    ),
                    child: Column(
                      children: [
                        /// -------- BRANCH --------
                        Obx(() => _buildField(
                              context: context,
                              label: "Select Branch",
                              icon: Icons.school,
                              iconColor: Colors.cyanAccent,
                              value: branch,
                              items: branchCtrl.branches
                                  .map((b) => b.branchName)
                                  .toList(),
                              onChanged: (v) {
                                final b = branchCtrl.branches
                                    .firstWhere((e) => e.branchName == v);

                                setState(() {
                                  branch = v;
                                  group = null;
                                  course = null;
                                });

                                groupCtrl.clear();
                                courseCtrl.clear();
                                groupCtrl.loadGroups(b.id);
                              },
                            )),

                        /// -------- GROUP --------
                        Obx(() => _buildField(
                              context: context,
                              label: groupCtrl.groups.isEmpty
                                  ? "Select Branch First"
                                  : "Select Group",
                              icon: Icons.group,
                              iconColor: Colors.purpleAccent,
                              value: group,
                              items:
                                  groupCtrl.groups.map((g) => g.name).toList(),
                              onChanged: groupCtrl.groups.isEmpty
                                  ? null
                                  : (v) {
                                      final g = groupCtrl.groups
                                          .firstWhere((e) => e.name == v);

                                      setState(() {
                                        group = v;
                                        course = null;
                                      });

                                      courseCtrl.clear();
                                      courseCtrl.loadCourses(g.id);
                                    },
                            )),

                        /// -------- COURSE --------
                        Obx(() => _buildField(
                              context: context,
                              label: courseCtrl.courses.isEmpty
                                  ? "Select Group First"
                                  : "Select Course",
                              icon: Icons.menu_book,
                              iconColor: Colors.blueAccent,
                              value: course,
                              items: courseCtrl.courses
                                  .map((c) => c.courseName)
                                  .toList(),
                              onChanged: courseCtrl.courses.isEmpty
                                  ? null
                                  : (v) {
                                      final c = courseCtrl.courses
                                          .firstWhere((e) => e.courseName == v);
                                      setState(() {
                                        course = v;
                                        selectedCourseId = c.id;
                                      });
                                    },
                            )),

                        _buildField(
                          context: context,
                          label: "Select Batch",
                          icon: Icons.date_range,
                          iconColor: Colors.orangeAccent,
                          value: batch,
                          items: batches,
                          onChanged: (v) => setState(() => batch = v),
                        ),

                        _buildField(
                          context: context,
                          label: "Select Exam",
                          icon: Icons.assignment,
                          iconColor: Colors.lightGreenAccent,
                          value: exam,
                          items: exams,
                          onChanged: (v) => setState(() => exam = v),
                        ),

                        _buildField(
                          context: context,
                          label: "Select Subject",
                          icon: Icons.book,
                          iconColor: Colors.pinkAccent,
                          value: subject,
                          items: subjects,
                          onChanged: (v) => setState(() => subject = v),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.groups, color: Colors.black),
                            label: const Text(
                              "Get Students",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: neon,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        Text(
                          "2025 © SSJC",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ---------------- BOTTOM BUTTONS ----------------
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text("Download Format"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon:
                            const Icon(Icons.cloud_upload, color: Colors.white),
                        label: const Text("Marks Bulk Upload"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  /// ---------------- DROPDOWN FIELD ----------------
  Widget _buildField({
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
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white24 : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                dropdownColor: isDark ? const Color(0xFF0f1d3a) : Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: neon),
                hint: Text(
                  label,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB5C7E8) : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
