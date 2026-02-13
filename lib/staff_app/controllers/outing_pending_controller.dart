import 'package:get/get.dart';
import 'package:student_app/staff_app/api/api_service.dart';
import '../model/model2.dart';

class OutingPendingController extends GetxController {
  final isLoading = false.obs;
  final students = <StudentModel>[].obs;
  final filteredStudents = <StudentModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOutings();
  }

  Future<void> fetchOutings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final responseList = await ApiService.getPendingOutingList();

      final allList = responseList
          .map((e) => StudentModel.fromJson(e))
          // 👇 keep this if page is ONLY pending
          //.where((s) => s.status.toLowerCase() == 'pending')
          .toList();

      students.assignAll(allList);
      filteredStudents.assignAll(allList);
    } catch (e) {
      students.clear();
      filteredStudents.clear();
      errorMessage.value = 'Failed to load outings';
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SEARCH =================
  void searchStudent(String value) {
    if (value.trim().isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      final query = value.toLowerCase();
      filteredStudents.assignAll(
        students.where(
          (s) =>
              s.name.toLowerCase().contains(query) || s.admNo.contains(query),
        ),
      );
    }
  }

  void fetchPendingOutings() {}
}
