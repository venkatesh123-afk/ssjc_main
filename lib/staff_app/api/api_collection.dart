class ApiCollection {
  static const String baseUrl = "https://stage.srisaraswathigroups.in/api";

  // ================= LOGIN =================
  static String login({required String username, required String password}) {
    return "/login"
        "?user_login=${Uri.encodeQueryComponent(username)}"
        "&password=${Uri.encodeQueryComponent(password)}";
  }

  // ================= COMMON =================
  static const String branchList = "/branchlist";
  static String groupsByBranch(int branchId) => "/groupslistbybranch/$branchId";
  static String coursesByGroup(int groupId) => "/courselistbygroup/$groupId";
  static String batchesByCourse(int courseId) => "/batchlistbycourse/$courseId";
  static String shiftsByBranch(int branchId) => "/shiftlistbybranch/$branchId";
  static String studentByAdmNo(String admNo) =>
      "/getstudentdetailsbysearch/$admNo";

  // ================= OUTING =================
  static const String outingList =
      "/outinglist?branch[]=All&report_type=All&daybookfilter=All&firstdate=&nextdate=";

  static const String pendingOutingList = "/getpendingoutinglist";

  // ================= HR =================
  static const String departmentsList = "/departmentslist";
  static const String designationsList = "/designationslist";
  static const String examsList = "/exams_list";
  static const String myProfile = "/myprofile";
  static String addHostelMember = "/addhostelmember";
  static String editHostelMember = "/edithostelmember";
  static String deleteHostelMember = "/deletehostelmember";
  static const String assignIncharges = "/assignincharges";

  static String feeHeadsByBranch(int branchId) => "/feeheadsbybranch/$branchId";
  static String getHostelsByBranch(int branchId) =>
      "/gethostelsbybranch/$branchId";

  // ================= MONTHLY ATTENDANCE (ACADEMIC) =================
  static String monthlyAttendance({
    required int branchId,
    required int groupId,
    required int courseId,
    required int batchId,
    required String month,
    required int shiftId,
  }) {
    return "/monthlyattendanceList"
        "?branchid=$branchId"
        "&groupid=$groupId"
        "&courseid=$courseId"
        "&batchid=$batchId"
        "&month=$month"
        "&shift=$shiftId";
  }

  // ============================================================
  // 🏨 HOSTEL ATTENDANCE (NEW – IMPORTANT)
  // ============================================================

  /// 1️⃣ Get students in a hostel room
  static String getRoomStudentsAttendance({
    required String shift,
    required String date,
    required String param, // room id
  }) {
    return "/getroomstudents_attendance"
        "?shift=$shift"
        "&date=$date"
        "&param=$param";
  }

  static String hostelMembersList({
    required String type,
    required String param,
  }) {
    return "/hostelmemberslist?type=$type&param=$param";
  }

  /// 2️⃣ Store hostel attendance (GET as per backend)
  static String storeHostelAttendance({
    required String branchId,
    required String hostel,
    required String floor,
    required String room,
    required String shift,
    required List<int> sidList,
    required List<String> statusList,
  }) {
    final sids = sidList.map((e) => "sid[]=$e").join("&");
    final status = statusList.map((e) => "at_status[]=$e").join("&");

    return "/store_hostel_attendance"
        "?branch_id=$branchId"
        "&hostel=$hostel"
        "&floor=$floor"
        "&room=$room"
        "&shift=$shift"
        "&$sids"
        "&$status";
  }

  /// 3️⃣ Get room attendance (student-wise)
  static String getRoomAttendance({required String roomId}) {
    return "/getroomattendance?param=$roomId";
  }

  static String getVerifyAttendance({
    required int branchId,
    required int shiftId,
  }) {
    return "/getverify_attendance?branch_id=$branchId&shift=$shiftId";
  }

  /// 4️⃣ Rooms attendance summary (dashboard)
  static String roomsAttendance({
    required String branch,
    required String date,
    required String hostel,
    required String floor,
    required String room,
  }) {
    return "/rooms-attendance"
        "?branch=$branch"
        "&date=$date"
        "&hostel=$hostel"
        "&floor=$floor"
        "&room=$room";
  }

  /// 5️⃣ Hostel attendance monthly grid
  static String hostelAttendanceGrid(int sid) {
    return "/hostel-attendance-grid/$sid";
  }

  static String getRoomsByFloor(int floorId) => "/getroomsbyfloor/$floorId";

  static String getFloorIncharges(int buildingId) =>
      "/getfloorincharges/$buildingId";

  static String getFloorsByIncharge(int inchargeId) =>
      "/getfloorsbyincharge/$inchargeId";

  static String getFloorsByHostel(int hostelId) =>
      "/getfloorsbyhostel/$hostelId";
}
