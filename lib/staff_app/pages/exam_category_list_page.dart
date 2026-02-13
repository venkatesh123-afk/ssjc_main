import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/branch_controller.dart';
import '../controllers/exam_category_controller.dart';
import '../model/branch_model.dart';

class ExamCategoryListPage extends StatefulWidget {
  const ExamCategoryListPage({super.key});

  @override
  State<ExamCategoryListPage> createState() => _ExamCategoryListPageState();
}

class _ExamCategoryListPageState extends State<ExamCategoryListPage> {
  // ================= DARK COLORS =================
  static const Color dark1 = Color(0xFF1a1a2e);
  static const Color dark2 = Color(0xFF16213e);
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);
  static const Color neon = Color(0xFF00FFF5);

  final BranchController branchCtrl = Get.put(BranchController());
  final ExamCategoryController categoryCtrl = Get.put(ExamCategoryController());

  String _query = "";
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();
    branchCtrl.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          "Exam Categories",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),

      // ================= BODY =================
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [dark1, dark2, dark3],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // ================= SEARCH =================
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        isDark ? Colors.white.withOpacity(0.12) : Colors.white,
                    hintText: "Search category...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? neon : Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ================= BRANCH DROPDOWN =================
                Obx(() {
                  if (branchCtrl.isLoading.value) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: selectedBranchId,
                    dropdownColor: isDark ? dark1 : Colors.white, // ✅ FIX
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.white,
                      hintText: "Select Branch",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: branchCtrl.branches
                        .map<DropdownMenuItem<int>>((BranchModel b) {
                      return DropdownMenuItem<int>(
                        value: b.id,
                        child: Text(
                          b.branchName,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : Colors.black, // ✅ FIX
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBranchId = value;
                      });
                    },
                  );
                }),

                const SizedBox(height: 16),

                // ================= CARD LIST =================
                Expanded(
                  child: Obx(() {
                    if (categoryCtrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (selectedBranchId == null) {
                      return Center(
                        child: Text(
                          "Please select a branch to view categories",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final filtered = categoryCtrl.categories.where((c) {
                      final matchesSearch = c['category']
                          .toString()
                          .toLowerCase()
                          .contains(_query.toLowerCase());

                      final matchesBranch = c['branch_id'] == selectedBranchId;

                      return matchesSearch && matchesBranch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          "No categories found",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? LinearGradient(
                                    colors: [
                                      dark3.withOpacity(0.6),
                                      purpleDark.withOpacity(0.6),
                                    ],
                                  )
                                : null,
                            color: isDark ? null : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? neon.withOpacity(0.35)
                                  : Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "S.No: ${index + 1}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Active",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _infoRow("Category", item['category'], isDark),
                                _infoRow("Branch", item['branch_name'], isDark),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
