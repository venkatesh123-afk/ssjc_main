import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../api/api_collection.dart';

class ApiService {
  ApiService._();

  static final GetStorage _box = GetStorage();

  // ================= HEADERS =================

  static Map<String, String> _authHeaders(String token) => {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    // 🔥 IMPORTANT: credentials in URL (NOT body)
    final Uri url = Uri.parse(
      ApiCollection.baseUrl +
          ApiCollection.login(username: username, password: password),
    );

    try {
      // clear old session (multi-user safe)
      _box.remove("token");
      _box.remove("user_id");

      final response = await http
          .post(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 20));

      // Handle non-200 status codes
      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      // Parse JSON response
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("LOGIN JSON PARSE ERROR: ${response.body}");
        throw Exception("Invalid server response format");
      }

      // 🔍 DEBUG: Log the full response
      debugPrint("LOGIN API RESPONSE: ${response.body}");
      debugPrint("LOGIN PARSED DATA: $data");

      // Check if login was successful
      final isSuccess =
          data["success"] == true ||
          data["success"] == "true" ||
          data["success"] == 1;

      debugPrint(
        "LOGIN SUCCESS CHECK: isSuccess=$isSuccess, hasToken=${data["access_token"] != null}",
      );

      if (isSuccess && data["access_token"] != null) {
        _box.write("token", data["access_token"]);
        _box.write("user_id", data["userid"]);
        return data;
      }

      // Extract error message from response
      final errorMessage =
          data["message"] ??
          data["error"] ??
          data["msg"] ??
          data["errors"]?.toString() ??
          "Invalid credentials";

      debugPrint("LOGIN ERROR MESSAGE: $errorMessage");
      throw Exception(errorMessage);
    } on http.ClientException {
      throw Exception("Network error: Please check your internet connection");
    } on FormatException {
      throw Exception("Invalid server response format");
    } catch (e) {
      // If it's already an Exception, rethrow it
      if (e is Exception) {
        rethrow;
      }
      // Otherwise wrap it
      throw Exception(e.toString());
    }
  }

  // ================= AUTH GET =================
  static Future<dynamic> getRequest(String endpoint) async {
    final String? token = _box.read<String>("token");

    if (token == null || token.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    final Uri url = Uri.parse(ApiCollection.baseUrl + endpoint);

    try {
      final response = await http
          .get(url, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 20));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return decoded;
      }

      if (response.statusCode == 401) {
        _box.remove("token");
        _box.remove("user_id");
        throw Exception("Unauthorized");
      }

      throw Exception("API Error ${response.statusCode}: ${response.body}");
    } catch (e) {
      rethrow;
    }
  }

  // ================= STUDENT SEARCH =================
  static Future<List<Map<String, dynamic>>> searchStudentByAdmNo(
    String admNo,
  ) async {
    final res = await getRequest(ApiCollection.studentByAdmNo(admNo));

    if ((res["success"] == true || res["success"] == "true") &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Student not found");
  }

  // ================= DEPARTMENTS =================
  static Future<List<Map<String, dynamic>>> getDepartmentsList() async {
    final res = await getRequest(ApiCollection.departmentsList);

    if ((res["success"] == true || res["success"] == "true") &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Failed to load departments");
  }

  // ================= HOSTELS BY BRANCH =================
  static Future<List<Map<String, dynamic>>> getHostelsByBranch(
    int branchId,
  ) async {
    final res = await getRequest(ApiCollection.getHostelsByBranch(branchId));

    debugPrint("HOSTELS API RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Failed to load hostels");
  }

  // ================= DESIGNATIONS =================
  static Future<List<Map<String, dynamic>>> getDesignationsList() async {
    final res = await getRequest(ApiCollection.designationsList);

    if ((res["success"] == true || res["success"] == "true") &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Failed to load designations");
  }

  // ================= ADD HOSTEL MEMBER =================
  static Future<void> addHostelMember({
    required String sid,
    required String branch,
    required String hostel,
    required String floor,
    required String room,
    required String month,
  }) async {
    final String? token = _box.read<String>("token");

    if (token == null || token.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    final Uri url = Uri.parse(
      ApiCollection.baseUrl + ApiCollection.addHostelMember,
    );

    final Map<String, dynamic> body = {
      "sid": sid,
      "branch": branch,
      "hostel": hostel,
      "floor": floor,
      "room": room,
      "month": month,
    };

    debugPrint("ADD HOSTEL MEMBER REQUEST: $body");

    final response = await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    debugPrint("ADD HOSTEL MEMBER RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    final isSuccess =
        decoded["success"] == true ||
        decoded["success"] == "true" ||
        decoded["success"] == 1;

    if (!isSuccess) {
      throw Exception(
        decoded["indexdata"] ??
            decoded["message"] ??
            "Failed to add hostel member",
      );
    }
  }

  // ================= EDIT HOSTEL MEMBER =================
  static Future<void> editHostelMember({
    required String sid,
    required String branch,
    required String hostel,
    required String floor,
    required String room,
    required String month,
  }) async {
    final String? token = _box.read<String>("token");

    if (token == null || token.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    final Uri url = Uri.parse(
      ApiCollection.baseUrl + ApiCollection.editHostelMember,
    );

    final Map<String, dynamic> body = {
      "sid": sid,
      "branch": branch,
      "hostel": hostel,
      "floor": floor,
      "room": room,
      "month": month,
    };

    debugPrint("EDIT HOSTEL MEMBER REQUEST: $body");

    final response = await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    debugPrint("EDIT HOSTEL MEMBER RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    final isSuccess =
        decoded["success"] == true ||
        decoded["success"] == "true" ||
        decoded["success"] == 1;

    if (!isSuccess) {
      throw Exception(
        decoded["indexdata"] ??
            decoded["message"] ??
            "Failed to update hostel member",
      );
    }
  }

  // ================= DELETE HOSTEL MEMBER =================
  static Future<void> deleteHostelMember({required String sid}) async {
    final String? token = _box.read<String>("token");

    if (token == null || token.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    final Uri url = Uri.parse(
      ApiCollection.baseUrl + ApiCollection.deleteHostelMember,
    );

    final Map<String, dynamic> body = {"sid": sid};

    debugPrint("DELETE HOSTEL MEMBER REQUEST: $body");

    final response = await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    debugPrint("DELETE HOSTEL MEMBER RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    final isSuccess =
        decoded["success"] == true ||
        decoded["success"] == "true" ||
        decoded["success"] == 1;

    if (!isSuccess) {
      throw Exception(
        decoded["indexdata"] ??
            decoded["message"] ??
            "Failed to delete hostel member",
      );
    }
  }

  // ================= HOSTEL MEMBERS LIST =================
  static Future<List<Map<String, dynamic>>> getHostelMembers({
    required String type, // hostel | floor | room | batch
    required String param, // id / room no / batch id
  }) async {
    final res = await getRequest(
      ApiCollection.hostelMembersList(type: type, param: param),
    );

    debugPrint("HOSTEL MEMBERS RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Failed to load hostel members");
  }

  // ================= VERIFY ATTENDANCE =================
  static Future<List<Map<String, dynamic>>> getVerifyAttendance({
    required int branchId,
    required int shiftId,
  }) async {
    final res = await getRequest(
      ApiCollection.getVerifyAttendance(branchId: branchId, shiftId: shiftId),
    );

    debugPrint("VERIFY ATTENDANCE RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    return []; // 👈 empty list is valid (same as Postman)
  }

  // ================= MONTHLY CLASS ATTENDANCE =================
  static Future<List<Map<String, dynamic>>> getMonthlyClassAttendance({
    required int branchId,
    required int groupId,
    required int courseId,
    required int batchId,
    required String month, // "01" to "12"
    required int shiftId,
  }) async {
    final res = await getRequest(
      ApiCollection.monthlyAttendance(
        branchId: branchId,
        groupId: groupId,
        courseId: courseId,
        batchId: batchId,
        month: month,
        shiftId: shiftId, // ✅ maps to `shift` query param
      ),
    );

    debugPrint("MONTHLY ATTENDANCE RESPONSE: $res");

    // ✅ Handle all backend success formats
    final bool isSuccess =
        res["success"] == true ||
        res["success"] == "true" ||
        res["success"] == 1;

    if (isSuccess && res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    return [];
  }

  // ================= OUTING LIST (RAW RESPONSE) =================
  static Future<Map<String, dynamic>> getOutingListRaw() async {
    final res = await getRequest(ApiCollection.outingList);

    if ((res["success"] == true || res["success"] == "true")) {
      return res;
    }

    throw Exception("Failed to load outing list");
  }

  // ================= PENDING OUTING =================
  static Future<List<Map<String, dynamic>>> getPendingOutingList() async {
    final res = await getRequest(ApiCollection.pendingOutingList);

    if ((res["success"] == true || res["success"] == "true") &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Failed to load pending outing list");
  }

  // ================= HOSTEL ATTENDANCE (NEW) =================

  /// 1️⃣ Get students for a room (to mark attendance)
  static Future<List<Map<String, dynamic>>> getRoomStudentsAttendance({
    required String shift,
    required String date,
    required String param, // room id
  }) async {
    final res = await getRequest(
      ApiCollection.getRoomStudentsAttendance(
        shift: shift,
        date: date,
        param: param,
      ),
    );

    debugPrint("ROOM STUDENTS ATTENDANCE RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    return [];
  }

  /// 2️⃣ Store hostel attendance
  static Future<void> storeHostelAttendance({
    required String branchId,
    required String hostel,
    required String floor,
    required String room,
    required String shift,
    required List<int> sidList,
    required List<String> statusList,
  }) async {
    final endpoint = ApiCollection.storeHostelAttendance(
      branchId: branchId,
      hostel: hostel,
      floor: floor,
      room: room,
      shift: shift,
      sidList: sidList,
      statusList: statusList,
    );

    final res = await getRequest(endpoint);

    debugPrint("STORE HOSTEL ATTENDANCE RESPONSE: $res");

    final isSuccess =
        res["success"] == true ||
        res["success"] == "true" ||
        res["success"] == 1;

    if (!isSuccess) {
      throw Exception(res["message"] ?? "Failed to save attendance");
    }
  }

  /// 3️⃣ Get rooms summary (for dashboard/results page)
  static Future<List<Map<String, dynamic>>> getRoomsAttendanceSummary({
    required String branch,
    required String date,
    required String hostel,
    required String floor,
    required String room,
  }) async {
    final endpoint = ApiCollection.roomsAttendance(
      branch: branch,
      date: date,
      hostel: hostel,
      floor: floor,
      room: room,
    );

    final res = await getRequest(endpoint);

    debugPrint("ROOMS ATTENDANCE SUMMARY RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      if (res["indexdata"] is List) {
        return List<Map<String, dynamic>>.from(res["indexdata"]);
      }
    }

    return [];
  }

  // ================= GET ROOMS BY FLOOR =================
  static Future<List<Map<String, dynamic>>> getRoomsByFloor(int floorId) async {
    final res = await getRequest(ApiCollection.getRoomsByFloor(floorId));

    debugPrint("GET ROOMS BY FLOOR RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    throw Exception("Failed to load rooms for floor $floorId");
  }

  // ================= ASSIGN INCHARGES =================
  static Future<void> assignIncharge({
    required int branchId,
    required int hostelId,
    required int staffId,
    required int floorId,
    required String rooms,
  }) async {
    final String? token = _box.read<String>("token");

    if (token == null || token.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    final Uri url = Uri.parse(
      ApiCollection.baseUrl + ApiCollection.assignIncharges,
    );

    final Map<String, dynamic> body = {
      "branch_id": branchId,
      "hostel": hostelId,
      "incharge": staffId,
      "floor": floorId,
      "rooms": rooms,
    };

    debugPrint("ASSIGN INCHARGE REQUEST: $body");

    final response = await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    debugPrint("ASSIGN INCHARGE RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    final isSuccess =
        decoded["success"] == true ||
        decoded["success"] == "true" ||
        decoded["success"] == 1;

    if (!isSuccess) {
      throw Exception(decoded["message"] ?? "Failed to assign incharge");
    }
  }

  // ================= GET FLOOR INCHARGES =================
  static Future<List<Map<String, dynamic>>> getFloorIncharges(
    int buildingId,
  ) async {
    final res = await getRequest(ApiCollection.getFloorIncharges(buildingId));

    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    // Sometimes the API returns a direct list (as seen in screenshot)
    if (res is Map && res.isEmpty) return [];

    return [];
  }

  // ================= GET FLOORS BY INCHARGE =================
  static Future<List<Map<String, dynamic>>> getFloorsByIncharge(
    int inchargeId,
  ) async {
    final res = await getRequest(ApiCollection.getFloorsByIncharge(inchargeId));

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    return [];
  }

  // ================= GET FLOORS BY HOSTEL =================
  static Future<List<Map<String, dynamic>>> getFloorsByHostel(
    int hostelId,
  ) async {
    final res = await getRequest(ApiCollection.getFloorsByHostel(hostelId));

    debugPrint("GET FLOORS BY HOSTEL RESPONSE: $res");

    if ((res["success"] == true ||
            res["success"] == "true" ||
            res["success"] == 1) &&
        res["indexdata"] != null) {
      return List<Map<String, dynamic>>.from(res["indexdata"]);
    }

    return [];
  }
}
