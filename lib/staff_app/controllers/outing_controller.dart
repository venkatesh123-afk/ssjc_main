import 'package:get/get.dart';
import 'package:student_app/staff_app/api/api_service.dart';
import 'package:student_app/staff_app/model/outing_model.dart';
import 'package:student_app/staff_app/model/OutingInfo.dart';

class OutingController extends GetxController {
  // ================= LOADING =================
  final RxBool isLoading = false.obs;

  // ================= OUTING LIST =================
  final RxList<OutingModel> outingList = <OutingModel>[].obs;
  final RxList<OutingModel> filteredList = <OutingModel>[].obs;

  // ================= FILTER STATES =================
  final RxString selectedBranch = "All".obs;
  final RxString selectedStatus = "All".obs;
  final RxBool isTodayFilter = false.obs;
  final RxString searchQuery = "".obs;

  DateTime? fromDate;
  DateTime? toDate;

  // ================= SUMMARY (TOP CARDS) =================
  final Rx<OutingInfo?> outPassInfo = Rx<OutingInfo?>(null);
  final Rx<OutingInfo?> homePassInfo = Rx<OutingInfo?>(null);
  final Rx<OutingInfo?> selfOutingInfo = Rx<OutingInfo?>(null);
  final Rx<OutingInfo?> selfHomeInfo = Rx<OutingInfo?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchOutings();
  }

  // ================= FETCH OUTINGS =================
  Future<void> fetchOutings() async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> res = await ApiService.getOutingListRaw();

      // ===== LIST DATA =====
      final List listData = res['indexdata'] ?? [];
      final list = listData.map((e) => OutingModel.fromJson(e)).toList();

      outingList.assignAll(list);
      filteredList.assignAll(list);

      // ===== SUMMARY DATA =====
      final info = res['outing_info'];
      if (info != null) {
        if (info['outpass']?.isNotEmpty == true) {
          outPassInfo.value = OutingInfo.fromJson(info['outpass'][0]);
        }
        if (info['homepass']?.isNotEmpty == true) {
          homePassInfo.value = OutingInfo.fromJson(info['homepass'][0]);
        }
        if (info['selfouting']?.isNotEmpty == true) {
          selfOutingInfo.value = OutingInfo.fromJson(info['selfouting'][0]);
        }
        if (info['selfhome']?.isNotEmpty == true) {
          selfHomeInfo.value = OutingInfo.fromJson(info['selfhome'][0]);
        }
      }
    } catch (e) {
      print("❌ OutingController error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= APPLY ALL FILTERS =================
  void applyFilters() {
    List<OutingModel> temp = outingList.toList();

    // 🔹 BRANCH
    if (selectedBranch.value != "All") {
      temp = temp.where((o) => o.branch == selectedBranch.value).toList();
    }

    // 🔹 STATUS
    if (selectedStatus.value != "All") {
      temp = temp.where((o) => o.status == selectedStatus.value).toList();
    }

    // 🔹 TODAY
    if (isTodayFilter.value) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      temp = temp.where((o) => o.outDate == today).toList();
    }

    // 🔹 CUSTOM DATE
    if (fromDate != null && toDate != null) {
      temp = temp.where((o) {
        final date = DateTime.tryParse(o.outDate);
        if (date == null) return false;
        return !date.isBefore(fromDate!) && !date.isAfter(toDate!);
      }).toList();
    }

    // 🔹 SEARCH
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      temp = temp
          .where(
            (o) =>
                o.studentName.toLowerCase().contains(q) ||
                o.admno.toLowerCase().contains(q),
          )
          .toList();
    }

    filteredList.assignAll(temp);
  }

  // ================= FILTER ACTIONS =================
  void search(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void filterToday() {
    isTodayFilter.value = true;
    fromDate = null;
    toDate = null;
    applyFilters();
  }

  void filterByBranch(String branch) {
    selectedBranch.value = branch;
    applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    applyFilters();
  }

  void filterByCustomDate(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    isTodayFilter.value = false;
    applyFilters();
  }

  // ================= DATE DROPDOWN FILTER =================
  void filterByDate(String type) {
    final now = DateTime.now();

    isTodayFilter.value = false;
    fromDate = null;
    toDate = null;

    switch (type) {
      case "Today":
        filterToday();
        return;

      case "Yesterday":
        fromDate = DateTime(now.year, now.month, now.day - 1);
        toDate = fromDate;
        break;

      case "Last7Days":
        fromDate = now.subtract(const Duration(days: 6));
        toDate = now;
        break;

      case "ThisMonth":
        fromDate = DateTime(now.year, now.month, 1);
        toDate = now;
        break;

      case "LastMonth":
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        fromDate = lastMonth;
        toDate = DateTime(now.year, now.month, 0);
        break;

      case "All":
        filterAll();
        return;

      case "Custom":
        // UI will open date picker
        return;
    }

    applyFilters();
  }

  // ================= RESET =================
  void filterAll() {
    selectedBranch.value = "All";
    selectedStatus.value = "All";
    isTodayFilter.value = false;
    searchQuery.value = "";
    fromDate = null;
    toDate = null;
    filteredList.assignAll(outingList);
  }

  // ================= COUNTS =================
  int countApproved() =>
      filteredList.where((o) => o.status == "Approved").length;

  int countPending() => filteredList.where((o) => o.status == "Pending").length;

  int countNotReported() =>
      filteredList.where((o) => o.status == "Not Reported").length;
}
