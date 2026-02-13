import 'package:get/get.dart';
import '../api/api_service.dart';

class ExamCategoryController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;

      // ✅ CORRECT METHOD NAME
      final response = await ApiService.getRequest('/categorylist');

      if (response['success'] == "true") {
        categories.assignAll(
          List<Map<String, dynamic>>.from(response['indexdata']),
        );
      } else {
        categories.clear();
      }
    } catch (e) {
      print("Category API Error: $e");
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
