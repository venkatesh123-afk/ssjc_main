import 'package:get/get.dart';
import '../api/api_service.dart';
import '../model/hostel_model.dart';

class HostelController extends GetxController {
  var isLoading = false.obs;

  var hostels = <HostelModel>[].obs;
  var selectedHostel = Rxn<HostelModel>();

  // DYNAMIC FILTER DATA
  var members = <Map<String, dynamic>>[].obs;
  var floors = <String>[].obs;
  var rooms = <String>[].obs;
  var roomsList = <Map<String, dynamic>>[].obs;

  // DATA FOR RESULTS PAGE
  var roomsSummary = <Map<String, dynamic>>[].obs;

  // STUDENTS FOR MARKING PAGE
  var roomStudents = <Map<String, dynamic>>[].obs;

  Future<void> loadRoomStudents({
    required String shift,
    required String date,
    required String roomId,
  }) async {
    try {
      isLoading(true);
      roomStudents.clear();
      final data = await ApiService.getRoomStudentsAttendance(
        shift: shift,
        date: date,
        param: roomId,
      );
      roomStudents.assignAll(data);
    } catch (e) {
      print("LOAD STUDENTS ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadHostelsByBranch(int branchId) async {
    try {
      isLoading(true);
      hostels.clear();
      selectedHostel.value = null;
      floors.clear();
      rooms.clear();

      final rawList = await ApiService.getHostelsByBranch(branchId);
      final parsed = rawList.map((e) => HostelModel.fromJson(e)).toList();

      hostels.assignAll(parsed);
    } catch (e) {
      print("HOSTEL CONTROLLER ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Extracts unique floors and rooms for a hostel
  Future<void> loadFloorsAndRooms(int hostelId) async {
    try {
      isLoading(true);
      floors.clear();
      rooms.clear();
      members.clear();

      // Fetch all members for this hostel to extract structure
      final data = await ApiService.getHostelMembers(
        type: 'hostel',
        param: hostelId.toString(),
      );

      members.assignAll(data);

      final Set<String> fSet = {};
      final Set<String> rSet = {};

      for (final m in data) {
        if (m['floor'] != null) fSet.add(m['floor'].toString());
        if (m['room'] != null) rSet.add(m['room'].toString());
      }

      floors.assignAll(fSet.toList()..sort());
      rooms.assignAll(rSet.toList()..sort());
    } catch (e) {
      print("LOAD STRUCTURE ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Load summary for result page
  Future<void> loadRoomAttendanceSummary({
    required String branch,
    required String date,
    required String hostel,
    required String floor,
    required String room,
  }) async {
    try {
      isLoading(true);
      roomsSummary.clear();

      final data = await ApiService.getRoomsAttendanceSummary(
        branch: branch,
        date: date,
        hostel: hostel,
        floor: floor,
        room: room,
      );

      roomsSummary.assignAll(data);
    } catch (e) {
      print("LOAD SUMMARY ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Submit marked attendance
  Future<bool> submitAttendance({
    required String branchId,
    required String hostel,
    required String floor,
    required String room,
    required String shift,
    required List<int> sidList,
    required List<String> statusList,
  }) async {
    try {
      isLoading(true);
      await ApiService.storeHostelAttendance(
        branchId: branchId,
        hostel: hostel,
        floor: floor,
        room: room,
        shift: shift,
        sidList: sidList,
        statusList: statusList,
      );
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRoomsByFloor(int floorId) async {
    try {
      isLoading(true);
      roomsList.clear();
      final data = await ApiService.getRoomsByFloor(floorId);
      roomsList.assignAll(data);
    } catch (e) {
      print("FETCH ROOMS BY FLOOR ERROR: $e");
    } finally {
      isLoading(false);
    }
  }
}
