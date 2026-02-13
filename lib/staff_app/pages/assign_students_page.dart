import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/batch_controller.dart';
import '../controllers/hostel_controller.dart';
import '../controllers/assignment_controller.dart';
import '../model/branch_model.dart';
import '../model/group_model.dart';
import '../model/course_model.dart';
import '../model/batch_model.dart';

class AssignStudentsPage extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final bool isEdit;

  const AssignStudentsPage({
    super.key,
    required this.students,
    this.isEdit = false,
  });

  @override
  State<AssignStudentsPage> createState() => _AssignStudentsPageState();
}

class _AssignStudentsPageState extends State<AssignStudentsPage> {
  final ThemeController themeCtrl = Get.find<ThemeController>();

  // Get existing controllers or put them if not present
  final BranchController branchCtrl = Get.put(BranchController());
  final GroupController groupCtrl = Get.put(GroupController());
  final CourseController courseCtrl = Get.put(CourseController());
  final BatchController batchCtrl = Get.put(BatchController());
  final HostelController hostelCtrl = Get.put(HostelController());
  final AssignmentController assignmentCtrl = Get.put(AssignmentController());

  @override
  void initState() {
    super.initState();
    // Load initial data
    branchCtrl.loadBranches();
    hostelCtrl.loadHostelsByBranch(
      0,
    ); // Load all hostels initially or based on branch

    if (widget.isEdit && widget.students.isNotEmpty) {
      // In edit mode, we use the passed students
      assignmentCtrl.studentsList.assignAll(widget.students);

      final first = widget.students.first;
      final bName = (first['branch']?.toString() ?? '').trim();

      // Define a helper to fetch hostelry once branches are ready
      void fetchHostelsForStudent() {
        final b = branchCtrl.branches.firstWhereOrNull(
          (x) => x.branchName.trim() == bName,
        );

        if (b != null) {
          hostelCtrl.loadHostelsByBranch(b.id).then((_) {
            final hName = first['hostel']?.toString() ?? '';
            final h = hostelCtrl.hostels.firstWhereOrNull(
              (x) => x.buildingName == hName,
            );
            if (h != null) {
              hostelCtrl.loadFloorsAndRooms(h.id);
            }
          });
        }
      }

      if (branchCtrl.branches.isEmpty) {
        branchCtrl.loadBranches().then((_) => fetchHostelsForStudent());
      } else {
        fetchHostelsForStudent();
      }

      // Pre-populate assignments from existing data
      for (var s in widget.students) {
        final sid = int.tryParse(s['sid']?.toString() ?? '0') ?? 0;
        assignmentCtrl.updateTempAssignment(sid, 'hostel', s['hostel']);
        assignmentCtrl.updateTempAssignment(sid, 'floor', s['floor']);
        assignmentCtrl.updateTempAssignment(sid, 'room', s['room']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)]
              : const [Color(0xFFF5F6FA), Color(0xFFE8ECF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.isEdit ? 'Edit Hostel Member' : 'Add Hostel Members',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (!widget.isEdit) ...[
                // ================= FILTERS =================
                _buildFilters(isDark),
                const SizedBox(height: 16),

                // ================= GET STUDENTS BUTTON =================
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: assignmentCtrl.isLoading.value
                          ? null
                          : () => assignmentCtrl.fetchStudents(),
                      icon: assignmentCtrl.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.groups),
                      label: const Text('Get Students'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ================= STUDENT TABLE =================
              Expanded(
                child: Obx(() {
                  if (assignmentCtrl.isLoading.value &&
                      assignmentCtrl.studentsList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (assignmentCtrl.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(assignmentCtrl.errorMessage.value),
                    );
                  }

                  if (assignmentCtrl.studentsList.isEmpty) {
                    return const Center(
                      child: Text("Select filters and click 'Get Students'"),
                    );
                  }

                  // 🔥 If editing a single student, show form instead of table
                  if (widget.isEdit &&
                      assignmentCtrl.studentsList.length == 1) {
                    return _buildEditForm(isDark);
                  }

                  return _buildStudentTable(isDark);
                }),
              ),

              const SizedBox(height: 20),

              // ================= SAVE BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: assignmentCtrl.isLoading.value
                        ? null
                        : () => assignmentCtrl.saveAssignments(
                            isEdit: widget.isEdit,
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: assignmentCtrl.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            widget.isEdit ? 'Update Member' : 'Save Members',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Column(
      children: [
        // Branch
        Obx(
          () => _selectionCard(
            isDark: isDark,
            title: "Select Branch",
            value: branchCtrl.selectedBranch.value?.branchName,
            onTap: () => _showSelectionSheet<BranchModel>(
              title: "Select Branch",
              items: branchCtrl.branches,
              getName: (item) => item.branchName,
              onSelected: (item) {
                branchCtrl.selectedBranch.value = item;
                groupCtrl.clear();
                courseCtrl.clear();
                batchCtrl.clear();
                groupCtrl.loadGroups(item.id);
                hostelCtrl.loadHostelsByBranch(item.id);
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Group
        Obx(
          () => _selectionCard(
            isDark: isDark,
            title: "Select Group",
            value: groupCtrl.selectedGroup.value?.name,
            onTap: () {
              if (groupCtrl.groups.isEmpty) {
                Get.snackbar("Info", "Select Branch first");
                return;
              }
              _showSelectionSheet<GroupModel>(
                title: "Select Group",
                items: groupCtrl.groups,
                getName: (item) => item.name,
                onSelected: (item) {
                  groupCtrl.selectedGroup.value = item;
                  courseCtrl.clear();
                  batchCtrl.clear();
                  courseCtrl.loadCourses(item.id);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Course
        Obx(
          () => _selectionCard(
            isDark: isDark,
            title: "Select Course",
            value: courseCtrl.selectedCourse.value?.courseName,
            onTap: () {
              if (courseCtrl.courses.isEmpty) {
                Get.snackbar("Info", "Select Group first");
                return;
              }
              _showSelectionSheet<CourseModel>(
                title: "Select Course",
                items: courseCtrl.courses,
                getName: (item) => item.courseName,
                onSelected: (item) {
                  courseCtrl.selectedCourse.value = item;
                  batchCtrl.clear();
                  batchCtrl.loadBatches(item.id);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Batch
        Obx(
          () => _selectionCard(
            isDark: isDark,
            title: "Select Batch",
            value: batchCtrl.selectedBatch.value?.batchName,
            onTap: () {
              if (batchCtrl.batches.isEmpty) {
                Get.snackbar(
                  "Info",
                  "No batches available for this course. Please ensure you've selected a course or try another one.",
                );
                return;
              }
              _showSelectionSheet<BatchModel>(
                title: "Select Batch",
                items: batchCtrl.batches,
                getName: (item) => item.batchName,
                onSelected: (item) => batchCtrl.selectedBatch.value = item,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _selectionCard({
    required bool isDark,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? title,
                style: TextStyle(
                  color: value != null
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.cyanAccent : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(bool isDark) {
    final s = assignmentCtrl.studentsList.first;
    final sid = int.tryParse(s['sid']?.toString() ?? '0') ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _infoCard(
            isDark: isDark,
            title: "Student Details",
            content: [
              _infoRow("Name", s['full_name'] ?? s['student_name'] ?? '—'),
              _infoRow("Adm No", s['admno']?.toString() ?? '—'),
              _infoRow("Branch", s['branch']?.toString() ?? '—'),
            ],
          ),
          const SizedBox(height: 20),
          _infoCard(
            isDark: isDark,
            title: "Hostel Assignment",
            content: [
              const Text(
                "Change Location",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final assignment = assignmentCtrl.tempAssignments[sid] ?? {};
                return Column(
                  children: [
                    _labeledDropdown(
                      label: "Hostel",
                      child: _buildHostelDropdown(
                        sid,
                        assignment['hostel'],
                        isDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _labeledDropdown(
                      label: "Floor",
                      child: _buildFloorDropdown(
                        sid,
                        assignment['floor'],
                        isDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _labeledDropdown(
                      label: "Room",
                      child: _buildRoomDropdown(
                        sid,
                        assignment['room'],
                        isDark,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required bool isDark,
    required String title,
    required List<Widget> content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...content,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _labeledDropdown({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(child: child),
        ),
      ],
    );
  }

  Widget _buildStudentTable(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            isDark ? Colors.white10 : Colors.grey.shade100,
          ),
          columns: const [
            DataColumn(label: Text('S.No')),
            DataColumn(label: Text('Admno')),
            DataColumn(label: Text('Student Name')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Hostel')),
            DataColumn(label: Text('Floor')),
            DataColumn(label: Text('Room')),
          ],
          rows: List.generate(assignmentCtrl.studentsList.length, (index) {
            final s = assignmentCtrl.studentsList[index];
            final sid = int.tryParse(s['sid']?.toString() ?? '0') ?? 0;
            final assignment = assignmentCtrl.tempAssignments[sid] ?? {};

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(s['admno']?.toString() ?? '')),
                DataCell(
                  Text(
                    s['full_name']?.toString() ??
                        s['student_name']?.toString() ??
                        '',
                  ),
                ),
                DataCell(
                  Text(
                    s['pmobile']?.toString() ?? s['mobile']?.toString() ?? '',
                  ),
                ),
                DataCell(Text(s['address']?.toString() ?? '')),
                DataCell(
                  _buildHostelDropdown(sid, assignment['hostel'], isDark),
                ),
                DataCell(_buildFloorDropdown(sid, assignment['floor'], isDark)),
                DataCell(_buildRoomDropdown(sid, assignment['room'], isDark)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHostelDropdown(int sid, String? currentValue, bool isDark) {
    return Obx(
      () => DropdownButton<String>(
        isExpanded: true,
        value: (hostelCtrl.hostels.any((h) => h.buildingName == currentValue))
            ? currentValue
            : null,
        hint: const Text("Select Hostel"),
        items: hostelCtrl.hostels
            .map(
              (h) => DropdownMenuItem(
                value: h.buildingName,
                child: Text(h.buildingName),
              ),
            )
            .toList(),
        onChanged: (v) {
          assignmentCtrl.updateTempAssignment(sid, 'hostel', v);
          // Reset floor/room when hostel changes
          assignmentCtrl.updateTempAssignment(sid, 'floor', null);
          assignmentCtrl.updateTempAssignment(sid, 'room', null);

          // 🔥 Load real floors and rooms for selected hostel
          final h = hostelCtrl.hostels.firstWhereOrNull(
            (x) => x.buildingName == v,
          );
          if (h != null) {
            hostelCtrl.loadFloorsAndRooms(h.id);
          }
        },
      ),
    );
  }

  Widget _buildFloorDropdown(int sid, String? currentValue, bool isDark) {
    return Obx(() {
      final items = hostelCtrl.floors.isNotEmpty
          ? hostelCtrl.floors.toList()
          : [
              'GROUND FLOOR',
              '1ST FLOOR',
              '2ND FLOOR',
              '3RD FLOOR',
              '4TH FLOOR',
            ];

      return DropdownButton<String>(
        isExpanded: true,
        value: (items.contains(currentValue)) ? currentValue : null,
        hint: const Text("Select Floor"),
        items: items
            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
            .toList(),
        onChanged: (v) => assignmentCtrl.updateTempAssignment(sid, 'floor', v),
      );
    });
  }

  Widget _buildRoomDropdown(int sid, String? currentValue, bool isDark) {
    return Obx(() {
      final items = hostelCtrl.rooms.isNotEmpty
          ? hostelCtrl.rooms.toList()
          : List.generate(20, (i) => (101 + i).toString());

      return DropdownButton<String>(
        isExpanded: true,
        value: (items.contains(currentValue)) ? currentValue : null,
        hint: const Text("Select Room"),
        items: items
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: (v) => assignmentCtrl.updateTempAssignment(sid, 'room', v),
      );
    });
  }

  void _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T) getName,
    required Function(T) onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(getName(item)),
                    onTap: () {
                      onSelected(item);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
