import 'package:get/get.dart';
import '../api/api_collection.dart';
import '../api/api_service.dart';
import '../model/shift_model.dart';

class ShiftController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<ShiftModel> shifts = <ShiftModel>[].obs;
  final Rxn<ShiftModel> selectedShift = Rxn<ShiftModel>();

  Future<void> loadShifts(int branchId) async {
    try {
      isLoading.value = true;
      shifts.clear();

      final res = await ApiService.getRequest(
        ApiCollection.shiftsByBranch(branchId),
      );

      if (res['success'] == "true" && res['indexdata'] != null) {
        shifts.assignAll(
          (res['indexdata'] as List)
              .map((e) => ShiftModel.fromJson(e))
              .toList(),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load shifts");
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    shifts.clear();
  }
}
