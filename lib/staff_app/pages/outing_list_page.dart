import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:student_app/staff_app/controllers/branch_controller.dart';
import 'package:student_app/staff_app/pages/issue_outing.dart';
import 'package:student_app/staff_app/controllers/outing_controller.dart';

class OutingListPage extends StatefulWidget {
  const OutingListPage({super.key});

  @override
  State<OutingListPage> createState() => _OutingListPageState();
}

class _OutingListPageState extends State<OutingListPage> {
  bool showStudents = false;
  TextEditingController searchController = TextEditingController();
  int selectedFilter = 0;

  final OutingController controller = Get.put(OutingController());
  final BranchController branchController = Get.put(BranchController());
  @override
  void initState() {
    super.initState();
    branchController.loadBranches(); // 👈 LOAD BRANCH API
  }

  String selectedStatus = "All";
  String selectedDateFilter = "All";
  DateTime? fromDate;
  DateTime? toDate;

  Widget branchDropdown(bool isDark) {
    return Obx(() {
      if (branchController.isLoading.value) {
        return const SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return DropdownButtonFormField<String>(
        initialValue: selectedBranch,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? Colors.white10 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: [
          const DropdownMenuItem(value: "All", child: Text("All")),
          ...branchController.branches.map(
            (b) => DropdownMenuItem(
              value: b.branchName,
              child: Text(b.branchName),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedBranch = value!;
          });
          controller.filterByBranch(value!);
        },
      );
    });
  }

  String selectedBranch = "All";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f1c2e) : Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                    Color(0xFF533483),
                  ]
                : [
                    Color(0xFFE0F2FE),
                    Color(0xFFBAE6FD),
                    Color(0xFF7DD3FC),
                    Color(0xFF38BDF8),
                  ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildAppTitle(context),
                const SizedBox(height: 18.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double itemWidth = (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // 🔴 OUT PASS
                        SizedBox(
                          width: itemWidth,
                          child: Obx(() {
                            final info = controller.outPassInfo.value;
                            return outingCard(
                              "Out Pass",
                              info?.total.toString() ?? "0",
                              Colors.redAccent,
                              Icons.exit_to_app_rounded,
                              pending: info?.pending ?? 0,
                              approved: info?.approved ?? 0,
                              notReported: info?.notReported ?? 0,
                            );
                          }),
                        ),

                        // 🟣 HOME PASS
                        SizedBox(
                          width: itemWidth,
                          child: Obx(() {
                            final info = controller.homePassInfo.value;
                            return outingCard(
                              "Home Pass",
                              info?.total.toString() ?? "0",
                              Colors.deepPurpleAccent,
                              Icons.home,
                              pending: info?.pending ?? 0,
                              approved: info?.approved ?? 0,
                              notReported: info?.notReported ?? 0,
                            );
                          }),
                        ),

                        // 🟠 SELF OUTING
                        SizedBox(
                          width: itemWidth,
                          child: Obx(() {
                            final info = controller.selfOutingInfo.value;
                            return outingCard(
                              "Self Outing",
                              info?.total.toString() ?? "0",
                              Colors.orangeAccent,
                              Icons.exit_to_app,
                              pending: info?.pending ?? 0,
                              approved: info?.approved ?? 0,
                              notReported: info?.notReported ?? 0,
                            );
                          }),
                        ),

                        // 🟢 SELF HOME
                        SizedBox(
                          width: itemWidth,
                          child: Obx(() {
                            final info = controller.selfHomeInfo.value;
                            return outingCard(
                              "Self Home",
                              info?.total.toString() ?? "0",
                              Colors.teal,
                              Icons.home,
                              pending: info?.pending ?? 0,
                              approved: info?.approved ?? 0,
                              notReported: info?.notReported ?? 0,
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 25),

                // FILTER SECTION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filter Options",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ✅ BRANCH DROPDOWN
                      branchDropdown(isDark),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          isExpanded: true, // ⭐ IMPORTANT
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? Colors.white10 : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items:
                              const [
                                "All",
                                "Pending",
                                "Approved",
                                "Not Reported",
                              ].map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      status,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedStatus = value);
                            controller.filterByStatus(value);
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedDateFilter,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.white10 : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "All", child: Text("All")),
                          DropdownMenuItem(
                            value: "Today",
                            child: Text("Today"),
                          ),
                          DropdownMenuItem(
                            value: "Yesterday",
                            child: Text("Yesterday"),
                          ),
                          DropdownMenuItem(
                            value: "Last7Days",
                            child: Text("Last 7 Days"),
                          ),
                          DropdownMenuItem(
                            value: "ThisMonth",
                            child: Text("This Month"),
                          ),
                          DropdownMenuItem(
                            value: "Custom",
                            child: Text("Custom"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedDateFilter = value!);
                          controller.filterByDate(value!);
                        },
                      ),
                      if (selectedDateFilter == "Custom") ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  fromDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    initialDate: DateTime.now(),
                                  );
                                },
                                child: Text(
                                  fromDate == null
                                      ? "From Date"
                                      : fromDate!.toString().substring(0, 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  toDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    initialDate: DateTime.now(),
                                  );
                                },
                                child: Text(
                                  toDate == null
                                      ? "To Date"
                                      : toDate!.toString().substring(0, 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (fromDate != null && toDate != null) {
                              controller.filterByCustomDate(fromDate!, toDate!);
                            }
                          },
                          child: const Text("Apply Date Filter"),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // SEARCH BAR
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search students...",
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey,
                                  ),
                                ),
                                onChanged: controller.search,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // BOTTOM BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: const Text("Filter Students"),
                        onPressed: () => setState(() => showStudents = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: const Text("Issue Outing"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IssueOutingPage(
                                studentName: '',
                                outingType: '',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // STUDENT LIST (API DATA)
                if (showStudents)
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (controller.filteredList.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "No outing records found",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredList.length,
                      itemBuilder: (context, index) {
                        final o = controller.filteredList[index];

                        return InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF193C68), Color(0xFF462A78)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                // ================= LEFT SIDE =================
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        o.studentName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        o.admno,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white70,
                                            size: 17,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "${o.outDate} • ${o.outingTime}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // ================= RIGHT SIDE =================
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: o.status == "Approved"
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: Text(
                                        o.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        o.outingType,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: Colors.lightBlueAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            "Outing list",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget outingCard(
    String title,
    String count,
    Color color,
    IconData icon, {
    required int pending,
    required int approved,
    required int notReported,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pending: $pending",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "Approved: $approved",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "Not Reported: $notReported",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget filterButton(String text, bool selected, bool isDark) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? Colors.lightBlue
            : isDark
            ? Colors.white12
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected
              ? Colors.white
              : isDark
              ? Colors.white
              : Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

Widget dropDown(BuildContext context, String text) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF293042) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade400),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 15,
          ),
        ),
        Icon(
          Icons.arrow_drop_down,
          color: isDark ? Colors.white : Colors.black54,
        ),
      ],
    ),
  );
}
