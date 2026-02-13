import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';

class HostelAttendanceService {
  static const String _hostelAttendanceEndpoint =
      '/student-hostel-attendance-grid';

  static Future<HostelAttendance> getHostelAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.studentApiBaseUrl}$_hostelAttendanceEndpoint/$studentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return HostelAttendance.fromJson(decoded);
      } else {
        throw Exception(
          'Failed to load hostel attendance: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching hostel attendance: $e');
    }
  }

  static Future<List<int>> downloadHostelAttendanceReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.studentApiBaseUrl}/student-hostel-attendance-download/$studentId',
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
