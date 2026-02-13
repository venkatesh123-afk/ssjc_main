import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hostel_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/staff_controller.dart';
import '../model/hostel_model.dart';
import 'add_hostel_page.dart';

/// ================= HOSTEL LIST PAGE =================
class HostelListPage extends StatefulWidget {
  const HostelListPage({super.key});

  @override
  State<HostelListPage> createState() => _HostelListPageState();
}

class _HostelListPageState extends State<HostelListPage> {
  final HostelController hostelCtrl = Get.put(HostelController());
  final BranchController branchCtrl = Get.put(BranchController());
  final StaffController staffCtrl = Get.put(StaffController());

  @override
  void initState() {
    super.initState();
    // 1. Load Branches & Staff
    // 2. Load Hostels for the first branch (default)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      staffCtrl.fetchStaff();
      if (branchCtrl.branches.isEmpty) {
        branchCtrl.loadBranches().then((_) {
          _loadHostelsForFirstBranch();
        });
      } else {
        _loadHostelsForFirstBranch();
      }
    });
  }

  void _loadHostelsForFirstBranch() {
    if (branchCtrl.branches.isNotEmpty) {
      // Create a default selection if none
      branchCtrl.selectedBranch.value ??= branchCtrl.branches.first;

      final selected = branchCtrl.selectedBranch.value;
      if (selected != null) {
        hostelCtrl.loadHostelsByBranch(selected.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                  Color(0xFF533483),
                ]
              : const [Color(0xFFF5F6FA), Color(0xFFE8ECF4)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        /// APP BAR
        appBar: AppBar(
          title: const Text("Hostel Buildings"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Optional: Branch Selector Indicator
            Obx(() {
              if (branchCtrl.isLoading.isTrue) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),
          ],
        ),

        /// ADD BUTTON
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("Add Building"),
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          onPressed: () => Get.to(() => const AddHostelPage()),
        ),

        /// BODY
        body: Obx(() {
          if (hostelCtrl.isLoading.isTrue || branchCtrl.isLoading.isTrue) {
            return const Center(child: CircularProgressIndicator());
          }

          if (branchCtrl.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No branches found."),
                  ElevatedButton(
                    onPressed: () => branchCtrl.loadBranches(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (hostelCtrl.hostels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apartment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No hostels found for ${branchCtrl.selectedBranch.value?.branchName ?? 'this branch'}",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHostelsForFirstBranch,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(14),
            child: width < 700
                ? ListView.separated(
                    itemCount: hostelCtrl.hostels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _hostelCard(context, hostelCtrl.hostels[i]),
                  )
                : GridView.builder(
                    itemCount: hostelCtrl.hostels.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.22,
                        ),
                    itemBuilder: (_, i) =>
                        _hostelCard(context, hostelCtrl.hostels[i]),
                  ),
          );
        }),
      ),
    );
  }

  /// ================= HOSTEL CARD =================
  Widget _hostelCard(BuildContext context, HostelModel hostel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Convert status int to String
    final statusText = hostel.status == 1 ? "Active" : "Inactive";
    final statusColor = hostel.status == 1
        ? Colors.greenAccent
        : Colors.redAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.35) : Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hostel.buildingName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),
              const Divider(height: 10),

              _miniInfoRow(context, "Incharge ID", hostel.incharge.toString()),
              _miniInfoRow(context, "Category", hostel.category),
              _miniInfoRow(context, "Address", hostel.address),

              // ✅ Spacer ONLY when height is bounded (Grid)
              if (hasBoundedHeight) const Spacer(),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: "Edit",
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                          size: 20,
                        ),
                        onPressed: () => _showEditDialog(context, hostel),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: "Delete",
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= MINI INFO ROW =================
  Widget _miniInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "$label:",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT DIALOG =================
  void _showEditDialog(BuildContext context, HostelModel hostel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: hostel.buildingName);
    final addrCtrl = TextEditingController(text: hostel.address);

    final RxnInt selectedIncharge = RxnInt(hostel.incharge);
    final RxnInt selectedBranch = RxnInt(hostel.branchId);
    final RxString selectedStatus = RxString(
      hostel.status == 1 ? "Active" : "Inactive",
    );
    final RxString selectedCategory = RxString(hostel.category);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF2D2D3A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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

                _buildLabel("Building Name *", isDark),
                _buildTextField("Building Name", isDark, controller: nameCtrl),

                const SizedBox(height: 16),
                _buildLabel("Category", isDark),
                Obx(
                  () => _buildDropdown(
                    ["BOYS HOSTEL", "GIRLS HOSTEL"],
                    isDark,
                    value: selectedCategory.value,
                    onChanged: (val) => selectedCategory.value = val!,
                  ),
                ),

                const SizedBox(height: 16),
                _buildLabel("Address *", isDark),
                _buildTextField("Address", isDark, controller: addrCtrl),

                const SizedBox(height: 16),
                _buildLabel("Incharge *", isDark),
                Obx(
                  () => _buildDropdown(
                    [
                      "Select Staff",
                      ...staffCtrl.staffList.map((s) => s.designation),
                    ],
                    isDark,
                    value:
                        staffCtrl.staffList
                            .firstWhereOrNull(
                              (s) => s.id == selectedIncharge.value,
                            )
                            ?.designation ??
                        "Select Staff",
                    onChanged: (val) {
                      final s = staffCtrl.staffList.firstWhereOrNull(
                        (s) => s.designation == val,
                      );
                      selectedIncharge.value = s?.id;
                    },
                  ),
                ),

                const SizedBox(height: 16),
                _buildLabel("Branch *", isDark),
                Obx(
                  () => _buildDropdown(
                    [
                      "Select Branch",
                      ...branchCtrl.branches.map((b) => b.branchName),
                    ],
                    isDark,
                    value:
                        branchCtrl.branches
                            .firstWhereOrNull(
                              (b) => b.id == selectedBranch.value,
                            )
                            ?.branchName ??
                        "Select Branch",
                    onChanged: (val) {
                      final b = branchCtrl.branches.firstWhereOrNull(
                        (b) => b.branchName == val,
                      );
                      selectedBranch.value = b?.id;
                    },
                  ),
                ),

                const SizedBox(height: 16),
                _buildLabel("Status", isDark),
                Obx(
                  () => _buildDropdown(
                    ["Select", "Active", "Inactive"],
                    isDark,
                    value: selectedStatus.value,
                    onChanged: (val) => selectedStatus.value = val!,
                  ),
                ),

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C79E0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Update Hostel",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= DELETE DIALOG =================
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ),
              const Icon(
                Icons.error_outline,
                color: Color(0xFFfcc4a6),
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                "Are you sure? You want to delete this Hostel",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "This is soft delete. This will hide data.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C79E0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Yes, Delete it!"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS (SAME AS FLOORS PAGE) =================

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
            color: isDark ? const Color(0xFF00FFF5) : const Color(0xFF7C79E0),
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
