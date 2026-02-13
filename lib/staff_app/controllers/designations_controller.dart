import 'package:get/get.dart';
import 'package:student_app/staff_app/model/DepartmentModel.dart';
import '../api/api_service.dart';

import '../model/designation_model.dart';

class StaffController extends GetxController {
  // ================= LOADING & ERROR =================
  final isLoading = false.obs;
  final errorMessage = "".obs;

  // ================= RAW DATA =================
  final departmentList = <DepartmentModel>[].obs;
  final designationList = <DesignationModel>[].obs;

  // ================= FILTER STATE =================
  final selectedDepartment = "".obs;

  // ================= FILTERED RESULT =================
  List<DesignationModel> get filteredDesignations {
    if (selectedDepartment.value.isEmpty) {
      return designationList;
    }

    return designationList
        .where(
          (d) =>
              d.department.toLowerCase() ==
              selectedDepartment.value.toLowerCase(),
        )
        .toList();
  }

  // ================= FETCH BOTH APIs =================
  Future<void> fetchStaffData() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final results = await Future.wait([
        ApiService.getDepartmentsList(),
        ApiService.getDesignationsList(),
      ]);

      // 🔹 Departments
      departmentList.value = results[0]
          .map((e) => DepartmentModel.fromJson(e))
          .toList();

      // 🔹 Designations
      designationList.value = results[1]
          .map((e) => DesignationModel.fromJson(e))
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SET DEPARTMENT =================
  void setDepartment(String department) {
    selectedDepartment.value = department;
  }

  // ================= CLEAR FILTER =================
  void clearDepartmentFilter() {
    selectedDepartment.value = "";
  }
}
