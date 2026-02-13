import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/model/class_attendance.dart';

class AttendanceService {
  static const String _attendanceGridEndpoint = '/student-attendance-grid';
  static const String _summaryEndpoint = '/getattendanceSummary';

  static Future<ClassAttendance> getAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.studentApiBaseUrl}$_attendanceGridEndpoint/$studentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        jsonDecode(response.body);
        if (decoded is List) {
          return ClassAttendance.fromJson({'data': decoded});
        }
        return ClassAttendance.fromJson(decoded);
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> getAttendanceSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.studentApiBaseUrl}$_summaryEndpoint/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Map<String, dynamic>.from(decoded['data']);
        }
        return {};
      } else {
        throw Exception(
          'Failed to load attendance summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching attendance summary: $e');
    }
  }

  static Future<List<int>> downloadAttendanceReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.studentApiBaseUrl}/student-attendance-download/$studentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading report: $e');
    }
  }
}
