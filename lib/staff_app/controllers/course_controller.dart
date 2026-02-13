import 'package:get/get.dart';
import '../api/api_collection.dart';
import '../api/api_service.dart';
import '../model/course_model.dart';

class CourseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final Rxn<CourseModel> selectedCourse = Rxn<CourseModel>();

  Future<void> loadCourses(int groupId) async {
    try {
      isLoading.value = true;
      courses.clear();

      final res = await ApiService.getRequest(
        ApiCollection.coursesByGroup(groupId),
      );

      final success = res['success'] == true || res['success'] == "true";

      if (success && res['indexdata'] != null) {
        courses.assignAll(
          (res['indexdata'] as List)
              .map((e) => CourseModel.fromJson(e))
              // ✅ show only active courses (optional)
              .where((c) => c.status == 1)
              .toList(),
        );
      } else {
        courses.clear();
      }
    } catch (e) {
      print("COURSE API ERROR => $e");
      Get.snackbar("Error", "Failed to load courses");
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    courses.clear();
    selectedCourse.value = null; // ✅ Reset selection
  }
}
