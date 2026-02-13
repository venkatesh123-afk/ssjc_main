import 'package:get/get.dart';
import '../api/api_service.dart';
import '../model/floor_model.dart';
import '../model/floor_incharge_model.dart';

class FloorController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var floors = <FloorModel>[].obs;
  var floorIncharges = <FloorInchargeModel>[].obs;

  Future<void> fetchFloorsByIncharge(int inchargeId) async {
    try {
      isLoading(true);
      errorMessage('');
      final rawList = await ApiService.getFloorsByIncharge(inchargeId);
      floors.assignAll(rawList.map((e) => FloorModel.fromJson(e)).toList());
    } catch (e) {
      errorMessage(e.toString());
      print("FETCH FLOORS ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFloorIncharges(int buildingId) async {
    try {
      isLoading(true);
      errorMessage('');
      final rawList = await ApiService.getFloorIncharges(buildingId);
      floorIncharges.assignAll(
        rawList.map((e) => FloorInchargeModel.fromJson(e)).toList(),
      );
    } catch (e) {
      errorMessage(e.toString());
      print("FETCH INCHARGES ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFloorsByHostel(int hostelId) async {
    try {
      isLoading(true);
      errorMessage('');
      final rawList = await ApiService.getFloorsByHostel(hostelId);
      floors.assignAll(rawList.map((e) => FloorModel.fromJson(e)).toList());
    } catch (e) {
      errorMessage(e.toString());
      print("FETCH FLOORS BY HOSTEL ERROR: $e");
    } finally {
      isLoading(false);
    }
  }
}
