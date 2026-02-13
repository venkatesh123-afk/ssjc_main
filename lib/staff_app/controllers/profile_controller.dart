// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import '../api/api_collection.dart';
// import '../model/profile_model.dart';

// class ProfileController extends GetxController {
//   final box = GetStorage();

//   var isLoading = true.obs;
//   var profile = Rxn<ProfileModel>();

//   @override
//   void onInit() {
//     fetchProfile();
//     super.onInit();
//   }

//   Future<void> fetchProfile() async {
//     try {
//       isLoading(true);

//       final token = box.read("token"); // saved after login

//       final response = await http.get(
//         Uri.parse(ApiCollection.baseUrlSsjc + ApiCollection.myProfile),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Accept": "application/json",
//         },
//       );

//       if (response.statusCode == 200) {
//         profile.value = ProfileModel.fromJson(jsonDecode(response.body));
//       } else {
//         Get.snackbar("Error", "Profile load failed");
//       }
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }
// }
import 'package:get/get.dart';
import '../api/api_collection.dart';
import '../api/api_service.dart';
import '../model/profile_model.dart';
import '../utils/get_storage.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final profile = Rxn<ProfileModel>();
  int? _currentUserId; // Track current user ID

  @override
  void onInit() {
    super.onInit();
    // Get current user ID from storage
    _currentUserId = AppStorage.getUserId();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      // 🔍 CHECK IF USER CHANGED (MULTI-USER SUPPORT)
      final storedUserId = AppStorage.getUserId();
      if (_currentUserId != null && storedUserId != _currentUserId) {
        // User changed - clear old profile data
        profile.value = null;
        _currentUserId = storedUserId;
      } else if (_currentUserId == null && storedUserId != null) {
        // First time loading or user ID was set
        _currentUserId = storedUserId;
      }

      final response = await ApiService.getRequest(ApiCollection.myProfile);

      // API returns profile data directly (no success wrapper)
      // Check if response has success field for backward compatibility
      if (response.containsKey('success')) {
        final success =
            response['success'] == true || response['success'] == "true";
        if (!success) {
          Get.snackbar("Error", "Profile fetch failed");
          return;
        }
        // If success field exists, data might be in 'data' field or response itself
        final profileData = response['data'] ?? response;
        profile.value = ProfileModel.fromJson(profileData);
      } else {
        // No success field - response is the profile data directly
        profile.value = ProfileModel.fromJson(response);
      }

      // 🔥 UPDATE SESSION WITH PROFILE DETAILS
      if (profile.value != null && _currentUserId != null) {
        final p = profile.value!;
        final token = AppStorage.getToken();
        if (token != null) {
          AppStorage.saveUserSession({
            'user_login': p.userLogin.isNotEmpty
                ? p.userLogin
                : _currentUserId.toString(),
            'userid': _currentUserId,
            'name': p.name,
            'avatar': p.avatar,
            'email': p.email,
            'mobile': p.mobile,
          }, token);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Profile fetch failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔄 REFRESH PROFILE (CALL THIS WHEN USER CHANGES)
  void refreshProfile() {
    _currentUserId = AppStorage.getUserId();
    profile.value = null;
    fetchProfile();
  }

  @override
  void onClose() {
    profile.value = null; // 🔥 clear user data
    super.onClose();
  }
}
