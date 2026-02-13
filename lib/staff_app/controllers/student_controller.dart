import 'package:get/get.dart';
import '../model/student_model.dart';
import '../api/api_service.dart';

class StudentController extends GetxController {
  var isLoading = false.obs;
  var students = <StudentModel>[].obs;

  Future<void> searchStudent(String admNo) async {
    if (admNo.isEmpty) {
      Get.snackbar("Error", "Admission number is required");
      return;
    }

    try {
      isLoading(true);

      final data = await ApiService.searchStudentByAdmNo(admNo);

      students.value = data.map((e) => StudentModel.fromJson(e)).toList();
    } catch (e) {
      students.clear();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
