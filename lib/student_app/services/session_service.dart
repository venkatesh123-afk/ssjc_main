import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class SessionService {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    StudentProfileService.resetProfileData();
  }
}
