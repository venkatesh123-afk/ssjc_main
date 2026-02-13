import 'package:get/get.dart';
import '../api/api_collection.dart';
import '../api/api_service.dart';

class MonthlyAttendanceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList attendanceList = [].obs;

  Future<void> loadAttendance({
    required int branchId,
    required int groupId,
    required int courseId,
    required int batchId,
    required String month,
    required int shiftId,
  }) async {
    try {
      isLoading.value = true;
      attendanceList.clear();

      final res = await ApiService.getRequest(
        ApiCollection.monthlyAttendance(
          branchId: branchId,
          groupId: groupId,
          courseId: courseId,
          batchId: batchId,
          month: month,
          shiftId: shiftId,
        ),
      );

      if (res['success'] == "true" && res['indexdata'] != null) {
        attendanceList.assignAll(res['indexdata']);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load attendance");
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    attendanceList.clear();
  }
}
