import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hostel_controller.dart';
import '../controllers/branch_controller.dart';

class HostelAttendanceMarkPage extends StatefulWidget {
  const HostelAttendanceMarkPage({super.key});

  @override
  State<HostelAttendanceMarkPage> createState() =>
      _HostelAttendanceMarkPageState();
}

class _HostelAttendanceMarkPageState extends State<HostelAttendanceMarkPage> {
  final HostelController hostelCtrl = Get.put(HostelController());
  final Map<String, dynamic> args = Get.arguments;

  // State for attendance marking
  final Map<int, String> _statuses = {}; // sid -> status (P/A)

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // Note: Adjust params based on what's available in args
    // We need shift and date. For now, using defaults.
    await hostelCtrl.loadRoomStudents(
      shift: '1', // Default shift
      date: DateTime.now().toIso8601String().split('T')[0],
      roomId: args['room_id'].toString(),
    );

    // Initialize statuses to Present by default
    for (final s in hostelCtrl.roomStudents) {
      _statuses[s['sid']] = 'P';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roomName = args['room_name'] ?? 'Room';

    return Scaffold(
      backgroundColor: const Color(0xFF16213e),
      appBar: AppBar(
        title: Text("Mark Attendance - $roomName"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (hostelCtrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (hostelCtrl.roomStudents.isEmpty) {
                  return const Center(
                    child: Text(
                      "No students found in this room",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: hostelCtrl.roomStudents.length,
                  itemBuilder: (context, index) {
                    final student = hostelCtrl.roomStudents[index];
                    final sid = student['sid'];
                    final currentStatus = _statuses[sid] ?? 'P';

                    return ListTile(
                      title: Text(
                        student['student_name'] ?? 'Unknown',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Adm No: ${student['admno']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _statusButton(
                            'P',
                            Colors.green,
                            currentStatus == 'P',
                            () {
                              setState(() => _statuses[sid] = 'P');
                            },
                          ),
                          const SizedBox(width: 8),
                          _statusButton(
                            'A',
                            Colors.red,
                            currentStatus == 'A',
                            () {
                              setState(() => _statuses[sid] = 'A');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Submit Attendance"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(
    String label,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final sids = _statuses.keys.toList();
    final statuses = sids.map((id) => _statuses[id]!).toList();

    // Again, shift and branch need to be handled correctly
    // Getting branchId from selected branch if available
    final branchId =
        Get.put(BranchController()).selectedBranch.value?.id.toString() ?? '1';

    final success = await hostelCtrl.submitAttendance(
      branchId: branchId,
      hostel: args['room_id']
          .toString(), // The API might expect hostel name or ID?
      floor: args['floor_name'],
      room: args['room_name'],
      shift: '1',
      sidList: sids,
      statusList: statuses,
    );

    if (success) {
      Get.back();
      Get.snackbar("Success", "Attendance saved successfully");
    }
  }
}
