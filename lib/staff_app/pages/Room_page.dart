import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hostel_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/staff_controller.dart';
import '../widgets/search_field.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final HostelController _hostelController = Get.put(HostelController());
  final BranchController _branchController = Get.put(BranchController());
  final StaffController _staffController = Get.put(StaffController());
  String _query = '';

  // Dialog Selection State
  final RxnInt _selectedBranchId = RxnInt();
  final RxnInt _selectedHostelId = RxnInt();
  final RxnInt _selectedStaffId = RxnInt();
  final RxnInt _selectedFloorId = RxnInt();
  final TextEditingController _assignRoomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    _hostelController.fetchRoomsByFloor(1);
    _branchController.loadBranches();
    _staffController.fetchStaff();
  }

  // ================= DARK COLORS =================
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);
  static const Color neon = Color(0xFF00FFF5);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Rooms List",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= BODY =================
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                    Color(0xFF533483),
                  ]
                : const [Color(0xFFF5F6FA), Color(0xFFE8ECF4)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 95),

            // ================= SEARCH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white24
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: SearchField(
                  hint: 'Search room / floor / hostel',
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFFB5C7E8) : Colors.black54,
                  ),
                  textColor: isDark ? Colors.white : Colors.black,
                  iconColor: isDark ? neon : Colors.black54,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= BUTTONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: "Assign Incharge",
                      icon: Icons.add,
                      color: const Color(0xFFfbbd5c), // Amber
                      onTap: () => _showAssignInchargeDialog(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: "Add New Room",
                      icon: Icons.add,
                      color: const Color(0xFF27ae60), // Emerald Green
                      onTap: () => _showAddRoomDialog(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ================= ROOM LIST =================
            Expanded(
              child: Obx(() {
                if (_hostelController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = _hostelController.roomsList.where((r) {
                  final roomName = r['roomname']?.toString() ?? '';
                  final floorName = r['floor']?['floorname']?.toString() ?? '';
                  final hostelName =
                      r['hostel']?['buildingname']?.toString() ?? '';
                  final branchName =
                      r['branch']?['branch_name']?.toString() ?? '';
                  final category = r['hostel']?['category']?.toString() ?? '';

                  return roomName.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      floorName.toLowerCase().contains(_query.toLowerCase()) ||
                      hostelName.toLowerCase().contains(_query.toLowerCase()) ||
                      branchName.toLowerCase().contains(_query.toLowerCase()) ||
                      category.toLowerCase().contains(_query.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      "No rooms found",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    final floorName =
                        r['floor']?['floorname']?.toString() ?? 'N/A';
                    final hostelName =
                        r['hostel']?['buildingname']?.toString() ?? 'N/A';
                    final branchName =
                        r['branch']?['branch_name']?.toString() ?? 'N/A';
                    final category =
                        r['hostel']?['category']?.toString() ?? 'N/A';
                    final phone =
                        r['branch']?['branch_phone1']?.toString() ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? LinearGradient(
                                colors: [
                                  dark3.withOpacity(0.45),
                                  purpleDark.withOpacity(0.45),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.08),
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.08),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? neon.withOpacity(0.35)
                              : Theme.of(context).dividerColor,
                          width: 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? neon.withOpacity(0.22)
                                : Colors.black12,
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Room: ${r['roomname']}",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? neon.withOpacity(0.15)
                                            : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? neon : Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Floor: $floorName",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFB5C7E8)
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Hostel: $hostelName",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFB5C7E8)
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Branch: $branchName",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFB5C7E8)
                                        : Colors.black54,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: isDark ? neon : Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      phone,
                                      style: TextStyle(
                                        color: isDark ? neon : Colors.black54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ROOM BADGE
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: neon,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              r['roomname']?.toString() ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTION BUTTON BUILDER =================
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DIALOGS =================

  void _showAssignInchargeDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reset state when opening
    _selectedBranchId.value = null;
    _selectedHostelId.value = null;
    _selectedStaffId.value = null;
    _selectedFloorId.value = null;
    _assignRoomsController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF2D2D3A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLabel("Branch *", isDark),
                  Obx(() {
                    final items = [
                      "Select Branch",
                      ..._branchController.branches.map((b) => b.branchName),
                    ];
                    final selectedName = _branchController.branches
                        .firstWhereOrNull(
                          (b) => b.id == _selectedBranchId.value,
                        )
                        ?.branchName;

                    return _buildDropdown(
                      items,
                      isDark,
                      value: selectedName ?? "Select Branch",
                      onChanged: (val) {
                        final branch = _branchController.branches
                            .firstWhereOrNull((b) => b.branchName == val);
                        _selectedBranchId.value = branch?.id;
                        _selectedHostelId.value = null;
                        _selectedFloorId.value = null;
                        if (branch != null) {
                          _hostelController.loadHostelsByBranch(branch.id);
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildLabel("Building *", isDark),
                  Obx(() {
                    final items = [
                      "Select",
                      ..._hostelController.hostels.map((h) => h.buildingName),
                    ];
                    final selectedName = _hostelController.hostels
                        .firstWhereOrNull(
                          (h) => h.id == _selectedHostelId.value,
                        )
                        ?.buildingName;

                    return _buildDropdown(
                      items,
                      isDark,
                      value: selectedName ?? "Select",
                      onChanged: (val) {
                        final hostel = _hostelController.hostels
                            .firstWhereOrNull((h) => h.buildingName == val);
                        _selectedHostelId.value = hostel?.id;
                        _selectedFloorId.value = null;
                        if (hostel != null) {
                          _hostelController.loadFloorsAndRooms(hostel.id);
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildLabel("Incharge *", isDark),
                  Obx(() {
                    final uniqueDesignations = _staffController.staffList
                        .map((s) => s.designation)
                        .where((d) => d.isNotEmpty)
                        .toSet()
                        .toList();
                    final items = ["Select", ...uniqueDesignations];

                    final selectedStaff = _staffController.staffList
                        .firstWhereOrNull(
                          (s) => s.id == _selectedStaffId.value,
                        );
                    final selectedName = selectedStaff?.designation;

                    return _buildDropdown(
                      items,
                      isDark,
                      value: selectedName ?? "Select",
                      onChanged: (val) {
                        final staff = _staffController.staffList
                            .firstWhereOrNull((s) => s.designation == val);
                        _selectedStaffId.value = staff?.id;
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildLabel("Floor *", isDark),
                  Obx(() {
                    final items = ["Select", ..._hostelController.floors];
                    final selectedValue = _selectedFloorId.value != null
                        ? _selectedFloorId.value.toString()
                        : "Select";

                    return _buildDropdown(
                      items,
                      isDark,
                      value: items.contains(selectedValue)
                          ? selectedValue
                          : "Select",
                      onChanged: (val) {
                        _selectedFloorId.value = int.tryParse(val ?? '');
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildLabel("Assing Rooms *", isDark),
                  _buildTextField(
                    "",
                    isDark,
                    controller: _assignRoomsController,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_selectedBranchId.value == null ||
                            _selectedHostelId.value == null ||
                            _selectedStaffId.value == null ||
                            _selectedFloorId.value == null ||
                            _assignRoomsController.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please fill all required fields",
                          );
                          return;
                        }

                        final success = await _staffController.assignIncharge(
                          branchId: _selectedBranchId.value!,
                          hostelId: _selectedHostelId.value!,
                          staffId: _selectedStaffId.value!,
                          floorId: _selectedFloorId.value!,
                          rooms: _assignRoomsController.text,
                        );

                        if (success) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C79E0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Assign Rooms",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF2D2D3A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLabel("Room Name *", isDark),
                  _buildTextField("Room Number", isDark),
                  const SizedBox(height: 16),
                  _buildLabel("Capacity *", isDark),
                  _buildTextField("ROOM CAPACITY", isDark),
                  const SizedBox(height: 16),
                  _buildLabel("Branch *", isDark),
                  Obx(
                    () => _buildDropdown([
                      "Select Branch",
                      ..._branchController.branches.map((b) => b.branchName),
                    ], isDark),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Building *", isDark),
                  _buildDropdown(["Select"], isDark),
                  const SizedBox(height: 16),
                  _buildLabel("Floor *", isDark),
                  _buildDropdown(["Select"], isDark),
                  const SizedBox(height: 16),
                  _buildLabel("Status", isDark),
                  _buildDropdown(["Select", "Active", "Inactive"], isDark),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C79E0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Add Room",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? Colors.white70 : const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    bool isDark, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white38 : const Color(0xFFD1D5DB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? neon : const Color(0xFF7C79E0),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    bool isDark, {
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    final selectedValue = (value != null && items.contains(value))
        ? value
        : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.white38 : const Color(0xFFD1D5DB),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          dropdownColor: isDark ? const Color(0xFF2D2D3A) : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
