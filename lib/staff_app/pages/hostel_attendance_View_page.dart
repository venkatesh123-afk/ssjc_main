import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:student_app/staff_app/controllers/hostel_controller.dart';
import '../controllers/branch_controller.dart';

class HostelAttendanceFilterPage extends StatefulWidget {
  const HostelAttendanceFilterPage({super.key});

  @override
  State<HostelAttendanceFilterPage> createState() =>
      _HostelAttendanceFilterPageState();
}

class _HostelAttendanceFilterPageState
    extends State<HostelAttendanceFilterPage> {
  String? _branch;
  String? _hostel;
  String? _floor;
  String? _room;
  String _month = '11';
  String? _selectedMonthName = 'November';

  final BranchController branchCtrl = Get.put(BranchController());
  final HostelController hostelCtrl = Get.put(HostelController());

  final Map<String, String> monthMap = {
    "January": "01",
    "February": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12",
  };

  // DARK COLORS
  static const Color dark1 = Color(0xFF1a1a2e);
  static const Color dark2 = Color(0xFF16213e);
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);
  static const Color neon = Color(0xFF00FFF5);

  @override
  void initState() {
    super.initState();

    // 1️⃣ Load branches
    branchCtrl.loadBranches();

    // 2️⃣ Listen branch list
    ever(branchCtrl.branches, (_) {
      // Auto select first branch
      if (branchCtrl.branches.isNotEmpty && _branch == null) {
        final b = branchCtrl.branches.first;
        setState(() => _branch = b.branchName);
        hostelCtrl.loadHostelsByBranch(b.id);
      }
    });

    // 3️⃣ Listen hostel list
    ever(hostelCtrl.hostels, (_) {
      // Auto select first hostel
      if (hostelCtrl.hostels.isNotEmpty && _hostel == null) {
        final h = hostelCtrl.hostels.first;
        setState(() => _hostel = h.buildingName);
        hostelCtrl.selectedHostel.value = h;
        hostelCtrl.loadFloorsAndRooms(h.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF16213e),

        // ---------------- APP BAR ----------------
        appBar: AppBar(
          backgroundColor: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.white.withOpacity(0.9),
          elevation: 0,
          title: Text(
            "View Hostel Attendance",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // ---------------- BODY ----------------
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [dark1, dark2, dark3, purpleDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
          ),

          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              kToolbarHeight + MediaQuery.of(context).padding.top + 16,
              16,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                // BRANCH
                Obx(
                  () => _neonDropdown(
                    context,
                    label: "Select Branch",
                    icon: Icons.school,
                    iconColor: neon,
                    value: _branch,
                    items: branchCtrl.branches
                        .map((b) => b.branchName)
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _branch = v;
                        _hostel = _floor = _room = null;
                      });

                      final branchObj = branchCtrl.branches.firstWhere(
                        (b) => b.branchName == v,
                      );
                      hostelCtrl.loadHostelsByBranch(branchObj.id);
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // HOSTEL
                Obx(
                  () => _neonDropdown(
                    context,
                    label: "Select Hostel",
                    icon: Icons.apartment,
                    iconColor: Colors.purpleAccent,
                    value: _hostel,
                    items: hostelCtrl.hostels
                        .map((h) => h.buildingName)
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _hostel = v;
                        _floor = _room = null;
                      });

                      final h = hostelCtrl.hostels.firstWhere(
                        (h) => h.buildingName == v,
                      );
                      hostelCtrl.selectedHostel.value = h;
                      hostelCtrl.loadFloorsAndRooms(h.id);
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // FLOOR
                Obx(
                  () => _neonDropdown(
                    context,
                    label: "Select Floor",
                    icon: Icons.layers,
                    iconColor: Colors.blueAccent,
                    value: _floor,
                    items: hostelCtrl.floors,
                    onChanged: (v) => setState(() {
                      _floor = v;
                      _room = null;
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                // ROOM
                Obx(
                  () => _neonDropdown(
                    context,
                    label: "Select Room",
                    icon: Icons.meeting_room,
                    iconColor: Colors.pinkAccent,
                    value: _room,
                    items: hostelCtrl.rooms,
                    onChanged: (v) => setState(() => _room = v),
                  ),
                ),
                const SizedBox(height: 14),

                // MONTH
                _neonDropdown(
                  context,
                  label: "Select Month",
                  icon: Icons.calendar_month,
                  iconColor: Colors.orangeAccent,
                  value: _selectedMonthName,
                  items: monthMap.keys.toList(),
                  onChanged: (v) => setState(() {
                    _selectedMonthName = v;
                    _month = monthMap[v!]!;
                    debugPrint("Selected Month Index: $_month");
                  }),
                ),
                const SizedBox(height: 24),

                // GET STUDENTS BUTTON
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.cyanAccent
                            : Theme.of(context).primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: hostelCtrl.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        hostelCtrl.isLoading.value
                            ? "Loading..."
                            : "Get Students",
                      ),
                      onPressed: hostelCtrl.isLoading.value
                          ? null
                          : () async {
                              if (_branch == null || _hostel == null) {
                                Get.snackbar(
                                  "Warning",
                                  "Select Branch and Hostel",
                                );
                                return;
                              }

                              await hostelCtrl.loadRoomAttendanceSummary(
                                branch: _branch!,
                                date: DateTime.now().toIso8601String().split(
                                  'T',
                                )[0],
                                hostel: _hostel!,
                                floor: _floor ?? 'All',
                                room: _room ?? 'All',
                              );

                              Get.toNamed('/hostelAttendanceResult');
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _neonButton(
                        label: "Add Attendance",
                        icon: Icons.add,
                        color: Colors.greenAccent,
                        onTap: () {
                          if (_branch == null ||
                              _hostel == null ||
                              _floor == null ||
                              _room == null) {
                            Get.snackbar("Error", "Please select all filters");
                            return;
                          }
                          // TODO: Navigate to Mark Attendance Page
                          Get.snackbar("Info", "Marking page coming soon");
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _neonButton(
                        label: "Check Status",
                        icon: Icons.check_circle,
                        color: Colors.blueAccent,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- DROPDOWN ----------------
  Widget _neonDropdown(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white24 : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: (value != null && items.contains(value)) ? value : null,
              dropdownColor: isDark ? dark2 : Theme.of(context).cardColor,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              iconEnabledColor: neon,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                border: InputBorder.none,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BUTTON ----------------
  Widget _neonButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        onPressed: onTap,
      ),
    );
  }
}
