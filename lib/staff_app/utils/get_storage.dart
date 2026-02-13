import 'package:get_storage/get_storage.dart';

class AppStorage {
  static final GetStorage _box = GetStorage();

  // ---------------- TOKEN ----------------
  static void saveToken(String token) {
    _box.write('token', token);
  }

  static String? getToken() {
    final token = _box.read('token');
    if (token is String && token.trim().isNotEmpty) {
      return token;
    }
    return null;
  }

  // ---------------- USER ----------------
  static void saveUserId(int userId) {
    _box.write('userid', userId);
  }

  static int? getUserId() {
    return _box.read('userid');
  }

  // ---------------- LOGIN FLAG ----------------
  static void setLoggedIn(bool value) {
    _box.write('isLoggedIn', value);
  }

  static bool isLoggedIn() {
    return _box.read('isLoggedIn') ?? false;
  }

  // ---------------- MULTI-USER SESSIONS ----------------
  static void saveUserSession(Map<String, dynamic> userData, String token) {
    if (userData['user_login'] == null) return;

    List<dynamic> savedUsers = _box.read('saved_users') ?? [];

    // Remove existing entry for this user if it exists (to update it)
    savedUsers.removeWhere((u) => u['user_login'] == userData['user_login']);

    // Add new session data
    Map<String, dynamic> sessionData = {
      'user_login': userData['user_login'],
      'name': userData['name'] ?? 'User',
      'avatar': userData['avatar'] ?? '',
      'token': token,
      'userid': userData['userid'],
      'email': userData['email'] ?? '',
      'mobile': userData['mobile'] ?? '',
    };

    savedUsers.add(sessionData);
    _box.write('saved_users', savedUsers);
  }

  static List<Map<String, dynamic>> getSavedUsers() {
    List<dynamic> users = _box.read('saved_users') ?? [];
    return List<Map<String, dynamic>>.from(users);
  }

  static void removeUser(String userLogin) {
    List<dynamic> savedUsers = _box.read('saved_users') ?? [];
    savedUsers.removeWhere((u) => u['user_login'] == userLogin);
    _box.write('saved_users', savedUsers);
  }

  static Future<void> switchUser(Map<String, dynamic> userSession) async {
    await _box.write('token', userSession['token']);
    await _box.write('userid', userSession['userid']);
    await _box.write('isLoggedIn', true);
  }

  // ---------------- LOGOUT ----------------
  static void clear() {
    // Only clear current session keys, preserve saved_users
    _box.remove('token');
    _box.remove('userid');
    _box.remove('isLoggedIn');
  }

  static void clearAll() {
    _box.erase(); // Completely wipe everything
  }
}
