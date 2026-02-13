import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/student_app/config/api_config.dart';

class CalendarService {
  static const String _calendarEndpoint = '/calendar';

  static Future<List<dynamic>> getCalendarEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');
      final String? studentId = prefs.getString('student_id');

      if (token == null || studentId == null) {
        throw Exception('User or Student ID not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.studentApiBaseUrl}$_calendarEndpoint/$studentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return decoded['data'];
        }
        return [];
      } else {
        throw Exception(
          'Failed to load calendar events: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching calendar events: $e');
      throw Exception('Error fetching calendar events: $e');
    }
  }
}
