import 'package:get/get.dart';

import 'branch_controller.dart';
import 'group_controller.dart';
import 'course_controller.dart';
import 'batch_controller.dart';
import 'shift_controller.dart';
import '../api/api_collection.dart';
import '../api/api_service.dart';
import '../models/attendance_model.dart';

class ClassAttendanceController extends GetxController {
  // ================= DEPENDENT CONTROLLERS (LAZY & SAFE) =================
  BranchController? get branchCtrl {
    try {
      return Get.find<BranchController>();
    } catch (e) {
      return null;
    }
  }

  GroupController? get groupCtrl {
    try {
      return Get.find<GroupController>();
    } catch (e) {
      return null;
    }
  }

  CourseController? get courseCtrl {
    try {
      return Get.find<CourseController>();
    } catch (e) {
      return null;
    }
  }

  BatchController? get batchCtrl {
    try {
      return Get.find<BatchController>();
    } catch (e) {
      return null;
    }
  }

  ShiftController? get shiftCtrl {
    try {
      return Get.find<ShiftController>();
    } catch (e) {
      return null;
    }
  }

  // ================= MONTH =================
  final RxString selectedMonth = ''.obs; // format: YYYY-MM

  // ================= ATTENDANCE STATE =================
  final RxBool isLoading = false.obs;
  final RxList<StudentAttendance> attendanceList = <StudentAttendance>[].obs;
  final RxString errorMessage = ''.obs;

  // ================= VALIDATION =================
  bool get isReady {
    return branchCtrl?.selectedBranch.value != null &&
        groupCtrl?.selectedGroup.value != null &&
        courseCtrl?.selectedCourse.value != null &&
        batchCtrl?.selectedBatch.value != null &&
        shiftCtrl?.selectedShift.value != null &&
        selectedMonth.value.isNotEmpty;
  }

  // ================= LOAD ATTENDANCE =================
  Future<void> loadClassAttendance() async {
    if (!isReady) {
      Get.snackbar("Error", "Please select all fields");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      attendanceList.clear();

      final res = await ApiService.getRequest(
        ApiCollection.monthlyAttendance(
          branchId: branchCtrl?.selectedBranch.value?.id ?? 0,
          groupId: groupCtrl?.selectedGroup.value?.id ?? 0,
          courseId: courseCtrl?.selectedCourse.value?.id ?? 0,
          batchId: batchCtrl?.selectedBatch.value?.id ?? 0,
          shiftId: shiftCtrl?.selectedShift.value?.id ?? 0,
          month: selectedMonth.value,
        ),
      );

      final success = res['success'] == true || res['success'] == "true";

      if (success && res['indexdata'] != null) {
        final attendanceResponse = AttendanceResponse.fromJson(res);
        attendanceList.assignAll(attendanceResponse.indexdata);
      } else {
        errorMessage.value = "No attendance data found";
      }
    } catch (e) {
      errorMessage.value = "Failed to load attendance";
      Get.snackbar("Error", errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= CLEAR =================
  void clear() {
    attendanceList.clear();
    errorMessage.value = '';
  }
}
