import 'package:get/get.dart';
import 'package:student_app/staff_app/api/api_service.dart';
import 'package:student_app/staff_app/model/DepartmentModel.dart';
import 'package:student_app/staff_app/model/staff_model.dart';

class StaffController extends GetxController {
  // ================= STATE =================
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ================= DATA =================
  final staffList = <StaffModel>[].obs;
  final departmentList = <DepartmentModel>[].obs;

  // ================= FILTER =================
  final selectedDepartment = 'ALL'.obs;

  // ================= DROPDOWN VALUES =================
  List<String> get uniqueDepartments => const [
    'ALL',
    'FINANCE',
    'ACADAMIC',
    'NON ACADAMIC',
  ];

  // ================= NORMALIZE DEPARTMENT =================
  String normalizeDepartment(String value) {
    final name = value.toUpperCase().trim();

    if (name.contains('NON')) {
      return 'NON ACADAMIC';
    } else if (name.contains('FINANCE') || name.contains('ACCOUNT')) {
      return 'FINANCE';
    } else if (name.contains('ACAD')) {
      return 'ACADAMIC';
    }
    return '';
  }

  // ================= FILTERED STAFF =================
  List<StaffModel> get filteredDesignations {
    // 🔹 ALL → return everything
    if (selectedDepartment.value == 'ALL') {
      return staffList;
    }

    return staffList
        .where(
          (s) => normalizeDepartment(s.department) == selectedDepartment.value,
        )
        .toList();
  }

  // ================= FETCH DATA =================
  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        ApiService.getDepartmentsList(),
        ApiService.getDesignationsList(),
      ]);

      departmentList.value = results[0]
          .map((e) => DepartmentModel.fromJson(e))
          .toList();

      staffList.value = results[1].map((e) => StaffModel.fromJson(e)).toList();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SET / CLEAR =================
  void setDepartment(String value) {
    selectedDepartment.value = value;
  }

  void clearDepartment() {
    selectedDepartment.value = 'ALL';
  }

  Future<bool> assignIncharge({
    required int branchId,
    required int hostelId,
    required int staffId,
    required int floorId,
    required String rooms,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await ApiService.assignIncharge(
        branchId: branchId,
        hostelId: hostelId,
        staffId: staffId,
        floorId: floorId,
        rooms: rooms,
      );

      Get.snackbar("Success", "Incharge assigned successfully");
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
