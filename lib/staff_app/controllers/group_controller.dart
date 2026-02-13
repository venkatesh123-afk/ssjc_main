import 'package:get/get.dart';
import 'package:student_app/staff_app/api/api_service.dart';
import '../api/api_collection.dart';
import '../model/group_model.dart';

class GroupController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<GroupModel> groups = <GroupModel>[].obs;

  // ✅ selected group
  final Rxn<GroupModel> selectedGroup = Rxn<GroupModel>();

  Future<void> loadGroups(int branchId) async {
    try {
      isLoading.value = true;
      groups.clear();
      selectedGroup.value = null; // ✅ reset selection

      final data = await ApiService.getRequest(
        ApiCollection.groupsByBranch(branchId),
      );

      final success = data['success'] == true || data['success'] == "true";

      if (success && data['indexdata'] != null) {
        groups.assignAll(
          (data['indexdata'] as List)
              .map((e) => GroupModel.fromJson(e))
              .toList(),
        );
      } else {
        groups.clear();
      }
    } catch (e) {
      print("GROUP API ERROR => $e");
      Get.snackbar("Error", "Failed to load groups");
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    groups.clear();
    selectedGroup.value = null; // ✅ important
  }
}
