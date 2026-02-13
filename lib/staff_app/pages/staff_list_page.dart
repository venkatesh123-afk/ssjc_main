import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/staff_controller.dart';
import '../model/staff_model.dart';
import '../widgets/search_field.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  // ================= COLORS =================
  static const Color dark1 = Color(0xFF1a1a2e);
  static const Color dark2 = Color(0xFF16213e);
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);
  static const Color neon = Color(0xFF00FFF5);

  final StaffController controller = Get.put(StaffController());

  String _query = "";
  bool _snackbarShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStaff();
    });
  }

  void _addStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add Staff (Demo Action)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Staff List",
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
          onPressed: () => Get.back(),
        ),
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ================= BACKGROUND =================
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [dark1, dark2, dark3, purpleDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
            ),
          ),

          Column(
            children: [
              const SizedBox(
                  height:
                      95), // ================= DEPARTMENT DROPDOWN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final selected = controller.selectedDepartment.value;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white24
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        // ✅ ALWAYS HAVE A VALUE
                        value: controller.uniqueDepartments.contains(selected)
                            ? selected
                            : 'ALL',

                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDark ? neon : Colors.black54,
                        ),
                        dropdownColor: isDark ? dark2 : Colors.white,

                        // ✅ DROPDOWN ITEMS
                        items: controller.uniqueDepartments
                            .map(
                              (dept) => DropdownMenuItem<String>(
                                value: dept,
                                child: Text(
                                  dept,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: dept == selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                            .toList(),

                        // ✅ CHANGE FILTER
                        onChanged: (value) {
                          if (value != null) {
                            controller.setDepartment(value);
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // ================= SEARCH =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: SearchField(
                    hint: "Search designation / branch / ID",
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFFB5C7E8) : Colors.black54,
                    ),
                    textColor: isDark ? Colors.white : Colors.black,
                    iconColor: isDark ? neon : Colors.black54,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= STAFF LIST =================
              Expanded(
                child: Obx(() {
                  // ERROR SNACKBAR
                  if (controller.errorMessage.isNotEmpty && !_snackbarShown) {
                    _snackbarShown = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.snackbar(
                        "Error",
                        controller.errorMessage.value,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  }

                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final query = _query.toLowerCase();
                  final List<StaffModel> filtered =
                      controller.filteredDesignations.where((s) {
                    return s.designation.toLowerCase().contains(query) ||
                        s.branchName.toLowerCase().contains(query) ||
                        s.id.toString().contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        "No staff found",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final StaffModel s = filtered[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),

                        // ✅ LIGHT THEME WHITE CARD
                        decoration: BoxDecoration(
                          color: isDark ? null : Colors.white,
                          gradient: isDark
                              ? LinearGradient(
                                  colors: [
                                    dark3.withOpacity(0.55),
                                    purpleDark.withOpacity(0.55),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? neon.withOpacity(0.35)
                                : Theme.of(context).dividerColor,
                            width: 1.2,
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
                          children: [
                            // ================= TEXT SECTION =================
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.designation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.branchName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFB5C7E8)
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ID: ${s.id}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ================= SERIAL BADGE =================
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: neon,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${i + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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

          // ================= ADD STAFF BUTTON =================
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: _addStaff,
                icon: Icon(
                  Icons.add,
                  color: isDark ? Colors.black : Colors.white,
                ),
                label: Text(
                  "Add Staff",
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? neon : Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
