import 'package:get/get.dart';
import '../api/api_collection.dart';
import '../api/api_service.dart';
import 'branch_controller.dart';
import 'group_controller.dart';
import 'course_controller.dart';
import 'batch_controller.dart';
import 'hostel_controller.dart';

class AssignmentController extends GetxController {
  final BranchController branchCtrl = Get.find<BranchController>();
  final GroupController groupCtrl = Get.find<GroupController>();
  final CourseController courseCtrl = Get.find<CourseController>();
  final BatchController batchCtrl = Get.find<BatchController>();
  final HostelController hostelCtrl = Get.find<HostelController>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> studentsList =
      <Map<String, dynamic>>[].obs;
  final RxString errorMessage = ''.obs;

  // Track individual assignments in memory before saving
  final RxMap<int, Map<String, dynamic>> tempAssignments =
      <int, Map<String, dynamic>>{}.obs;

  Future<void> fetchStudents() async {
    final batchId = batchCtrl.selectedBatch.value?.id;
    if (batchId == null) {
      Get.snackbar("Error", "Please select a batch");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      studentsList.clear();
      tempAssignments.clear();

      // We use the monthly Attendance List as it returns students for the batch.
      final now = DateTime.now();
      final monthStr = now.month.toString().padLeft(2, '0');

      final res = await ApiService.getRequest(
        ApiCollection.monthlyAttendance(
          branchId: branchCtrl.selectedBranch.value?.id ?? 0,
          groupId: groupCtrl.selectedGroup.value?.id ?? 0,
          courseId: courseCtrl.selectedCourse.value?.id ?? 0,
          batchId: batchId,
          month: monthStr,
          shiftId: 1, // Default shift
        ),
      );

      if ((res['success'] == true || res['success'] == "true") &&
          res['indexdata'] != null) {
        final List data = res['indexdata'];
        studentsList.assignAll(
          data.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      } else {
        errorMessage.value = "No students found for this batch";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void updateTempAssignment(int sid, String key, dynamic value) {
    if (!tempAssignments.containsKey(sid)) {
      tempAssignments[sid] = {};
    }
    tempAssignments[sid]![key] = value;
    tempAssignments.refresh();
  }

  Future<void> saveAssignments({bool isEdit = false}) async {
    if (tempAssignments.isEmpty) {
      Get.snackbar("Info", "No assignments to save");
      return;
    }

    isLoading.value = true;
    try {
      int successCount = 0;
      for (final entry in tempAssignments.entries) {
        final sid = entry.key;
        final data = entry.value;

        if (data['hostel'] == null ||
            data['floor'] == null ||
            data['room'] == null) {
          continue; // Skip incomplete assignments
        }

        if (isEdit) {
          await ApiService.editHostelMember(
            sid: sid.toString(),
            branch: branchCtrl.selectedBranch.value?.branchName ?? '',
            hostel: data['hostel'],
            floor: data['floor'],
            room: data['room'],
            month: 'January', // Default or could be dynamic
          );
        } else {
          await ApiService.addHostelMember(
            sid: sid.toString(),
            branch: branchCtrl.selectedBranch.value?.branchName ?? '',
            hostel: data['hostel'],
            floor: data['floor'],
            room: data['room'],
            month: 'January', // Default or could be dynamic
          );
        }
        successCount++;
      }

      if (successCount > 0) {
        Get.snackbar(
          "Success",
          isEdit
              ? "$successCount members updated successfully"
              : "$successCount members assigned successfully",
        );
        if (!isEdit) fetchStudents(); // Refresh list only on new assignments
      } else {
        Get.snackbar(
          "Warning",
          "Please complete hostel/floor/room selection for at least one student",
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
