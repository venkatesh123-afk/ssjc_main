import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.login}");
      print("Attempting login to: $url");
      print("Payload: ${jsonEncode({'mobile': mobile, 'password': password})}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        },
        body: jsonEncode({'mobile': mobile, 'password': password}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map && body['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          if (body['data'] != null && body['data'] is Map) {
            if (body['data']['token'] != null) {
              await prefs.setString("access_token", body['data']['token']);
            }
            if (body['data']['sid'] != null) {
              await prefs.setString(
                "student_id",
                body['data']['sid'].toString(),
              );
            }
          }
          // Fetch and set profile data globally after successful login
          // ignore: unawaited_futures
          StudentProfileService.fetchAndSetProfileData();
          return {'success': true, 'message': 'Login Successful'};
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Invalid credentials',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Login Exception: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
