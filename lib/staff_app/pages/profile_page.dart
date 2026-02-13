import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:student_app/staff_app/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // ✅ KEEP GRADIENTS HERE
  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF1a1a2e),
      Color(0xFF16213e),
      Color(0xFF0f3460),
      Color(0xFF533483),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0f3460), Color(0xFF533483)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkAppBarGradient = LinearGradient(
    colors: [Color(0xFF0f172a), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color lightBackground = Color(0xFFF6F7FB);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    // Get or create ProfileController
    if (Get.isRegistered<ProfileController>()) {
      controller = Get.find<ProfileController>();
      // Refresh profile to check if user changed (fetchProfile handles user change detection)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchProfile();
      });
    } else {
      controller = Get.put(ProfileController());
    }
  }

  // ===== DARK GRADIENTS =====
  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF1a1a2e),
      Color(0xFF16213e),
      Color(0xFF0f3460),
      Color(0xFF533483),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // static const LinearGradient darkAppBarGradient = LinearGradient(
  //   colors: [
  //     Color(0xFF0f172a),
  //     Color(0xFF111827),
  //   ],
  // );

  static const Color lightBackground = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: isDark ? null : lightBackground,

        // ================= APP BAR =================
        appBar: AppBar(
          title: const Text("Profile"),
          elevation: 0,
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: Colors.transparent,
          flexibleSpace: isDark
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: ProfilePage.darkAppBarGradient,
                  ),
                )
              : null,
        ),

        // ================= BODY =================
        body: Column(
          children: [
            // ---------- PROFILE HEADER ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isDark ? darkHeaderGradient : null,
                color: isDark ? null : Colors.white,
              ),
              child: Row(
                children: [
                  Obx(() {
                    if (controller.isLoading.value ||
                        controller.profile.value == null) {
                      return const CircleAvatar(
                        radius: 36,
                        child: Icon(Icons.person),
                      );
                    }

                    final avatar = controller.profile.value!.avatar;

                    // 🚫 BLOCK fake/default avatar
                    final bool hasValidAvatar =
                        avatar.isNotEmpty && avatar != "avatar.png";

                    return CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF0f3460),
                      child: hasValidAvatar
                          ? ClipOval(
                              child: Image.network(
                                "https://dev.srisaraswathigroups.in/uploads/$avatar",
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return const Icon(Icons.person, size: 40);
                                },
                              ),
                            )
                          : const Icon(Icons.person, size: 40),
                    );
                  }),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value ||
                          controller.profile.value == null) {
                        return const SizedBox(); // ✅ SAFE PLACEHOLDER
                      }

                      final p = controller.profile.value!; // ✅ NOW SAFE

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _headerText("Email: ${p.email}", isDark),
                          _headerText("Phone Number: ${p.mobile}", isDark),
                          _headerText("User ID: ${p.userLogin}", isDark),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1a1a2e).withOpacity(0.25),
                    const Color(0xFF0f3460).withOpacity(0.35),
                    const Color(0xFF533483).withOpacity(0.25),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                          Color(0xFF0f3460),
                          Color(0xFF533483),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isDark ? null : Colors.white,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: TabBar(
                isScrollable: true,

                // ✅ ACTIVE TAB
                labelColor: isDark ? Colors.white : const Color(0xFF0f3460),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),

                // ✅ INACTIVE TAB
                unselectedLabelColor: isDark
                    ? Colors.white70
                    : const Color(0xFF64748B),

                // ✅ INDICATOR (CLEAN, MATCHING)
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3,
                    color: isDark ? Colors.white : const Color(0xFF533483),
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // ❌ REMOVE DEFAULT DIVIDER (CAUSE OF MISMATCH)
                dividerColor: Colors.transparent,

                tabs: const [
                  Tab(text: "Profile"),
                  Tab(text: "Attendance"),
                  Tab(text: "Pay Scale"),
                  Tab(text: "Leaves"),
                  Tab(text: "Change Password"),
                  Tab(text: "TFA"),
                ],
              ),
            ),

            // ---------- TAB CONTENT ----------
            Expanded(
              child: TabBarView(
                children: [
                  ProfileTab(isDark: isDark),
                  AttendanceTab(isDark: isDark),
                  PayScaleTab(isDark: isDark),
                  LeavesTab(isDark: isDark),
                  ChangePasswordTab(isDark: isDark),
                  TfaTab(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _headerText(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark
              ? const Color(0xFFE5E7EB).withOpacity(0.85) // soft white
              : const Color(0xFF475569), // slate for light
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final bool isDark;
  const ProfileTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      // ✅ BLOCK UI UNTIL DATA EXISTS
      if (controller.isLoading.value || controller.profile.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // ✅ SAFE NOW
      final p = controller.profile.value!;

      return SingleChildScrollView(
        child: Column(
          children: [
            // ================= PERSONAL INFORMATION =================
            _sectionContainer(
              title: "Personal Information",
              children: [
                _infoCard("Name", p.name),
                _infoCard("Father's Name", p.father),
                _infoCard("Gender", p.gender),
                _infoCard("Date of Birth", p.dob),
                _infoCard("Nationality", p.nationality),
                _infoCard("Marital Status", p.marital),
                _infoCard("Religion", p.religion),
                _infoCard("Community", p.community),
              ],
            ),

            // ================= CONTACT INFORMATION =================
            _sectionContainer(
              title: "Contact Information",
              children: [
                _infoCard("Phone", p.mobile),
                _infoCard("Email", p.email),
                _infoCard("Current Address", p.cAddress),
                _infoCard("Permanent Address", p.pAddress),
              ],
            ),

            // ================= PROFESSIONAL INFORMATION =================
            _sectionContainer(
              title: "Professional Information",
              children: [
                _infoCard("Designation", p.designation),
                _infoCard("Job Type", p.jobType),
                _infoCard("Department", p.department),
                _infoCard("Experience", "N/A"),
                _infoCard("Specialization", "N/A"),
                _infoCard("Date of Joining", p.doj),
                _infoCard("Branch", "N/A"),
                _infoCard("Shift", p.shift),
              ],
            ),

            // ================= EDUCATION =================
            _sectionContainer(
              title: "Education",
              children: [
                _infoCard("Qualification", "N/A"),
                _infoCard("Passing Year", "N/A"),
                _infoCard("College", "N/A"),
                _infoCard("Percentage", "N/A"),
              ],
            ),

            // ================= EXPERIENCE =================
            _sectionContainer(
              title: "Experience",
              children: [
                _infoCard("Experience", "N/A"),
                _infoCard("Last Company", "N/A"),
                _infoCard("Duration", "N/A"),
              ],
            ),

            // ================= IDENTIFICATION =================
            _sectionContainer(
              title: "Identification",
              children: [
                _infoCard("PAN", p.pan),
                _infoCard("Aadhar", p.aadhar),
                _infoCard("Passport", "N/A"),
                _infoCard("Driving License", "N/A"),
                _infoCard("PF Number", "N/A"),
                _infoCard("ESI Number", "N/A"),
              ],
            ),

            // ================= BANK DETAILS =================
            _sectionContainer(
              title: "Bank Details",
              children: [
                _infoCard("Account Number", p.bankAcc),
                _infoCard("Bank Name", p.bank),
                _infoCard("IFSC Code", p.ifsc),
                _infoCard("MICR Code", "N/A"),
                _infoCard("Bank Branch", "N/A"),
              ],
            ),

            // ================= OTHER DETAILS =================
            _sectionContainer(
              title: "Other Details",
              children: [
                _infoCard("Academic Year", "N/A"),
                _infoCard("Remarks", "N/A"),
                _infoCard("Status", "Active"),
                _infoCard("Role", "Principal"),
                _infoCard("Employee ID", "666700"),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ================= SECTION CONTAINER =================
  Widget _sectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // ✅ 2 cards per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35, // ✅ Pay Scale look
            children: children,
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.cardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// PAY SCALE TAB
////////////////////////////////////////////////////////////////
class PayScaleTab extends StatelessWidget {
  final bool isDark;
  const PayScaleTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Pay Scale"),
          _grid([
            _infoCard("Branch", "N/A"),
            _infoCard("Salary Head", "N/A"),
            _infoCard("Amount", "N/A"),
            _infoCard("Created At", "N/A"),
            _infoCard("Updated At", "N/A"),
          ]),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // ---------------- GRID LAYOUT ----------------
  Widget _grid(List<Widget> children) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }

  // ---------------- INFO CARD ----------------
  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.cardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// CHANGE PASSWORD TAB (FINAL – IMAGE MATCHED)
////////////////////////////////////////////////////////////////
class ChangePasswordTab extends StatelessWidget {
  final bool isDark;
  const ChangePasswordTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: isDark ? ProfilePage.cardGradient : null,
              color: isDark ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TITLE =====
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 28),

                // ===== CURRENT PASSWORD =====
                _label("Current Password", isDark),
                _field("Enter Current Password", isDark),

                const SizedBox(height: 20),

                // ===== NEW PASSWORD =====
                _label("New Password", isDark),
                _field("Enter New Password", isDark),

                const SizedBox(height: 20),

                // ===== CONFIRM PASSWORD =====
                _label("Confirm Password", isDark),
                _field("Re-Enter Password", isDark),

                const SizedBox(height: 34),

                // ===== BUTTON =====
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C7CE6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 38,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  // ================= LABEL =================
  Widget _label(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _field(String hint, bool isDark) {
    return TextField(
      obscureText: true,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : const Color(0xFF374151),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.10)
            : const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.35)
                : const Color(0xFF7C7CE6),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// LEAVES TAB
////////////////////////////////////////////////////////////////
class LeavesTab extends StatelessWidget {
  final bool isDark;
  const LeavesTab({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Leaves"),
          const SizedBox(height: 8),
          _grid([
            _infoCard("Leave Type", "N/A"),
            _infoCard("From Date", "N/A"),
            _infoCard("To Date", "N/A"),
            _infoCard("Days", "N/A"),
            _infoCard("Reason", "N/A"),
            _infoCard("Status", "N/A"),
          ]),
        ],
      ),
    );
  }

  // ---------- TITLE ----------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  // ---------- GRID ----------
  Widget _grid(List<Widget> children) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }

  // ---------- CARD ----------
  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.cardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////
/// TFA TAB – MATCHES PAY SCALE UI
////////////////////////////////////////////////////////////////
class TfaTab extends StatefulWidget {
  final bool isDark;
  const TfaTab({super.key, required this.isDark});

  @override
  State<TfaTab> createState() => _TfaTabState();
}

class _TfaTabState extends State<TfaTab> {
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isDark ? ProfilePage.darkHeaderGradient : null,
        color: widget.isDark ? null : Colors.transparent,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            Text(
              "Two Factor Authentication",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // ===== MAIN CARD (LIKE PAY SCALE CARD) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: widget.isDark ? ProfilePage.cardGradient : null,
                color: widget.isDark ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!widget.isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Column(
                children: [
                  // ===== SWITCH ROW =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Enable 2FA",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF7C7CE6),
                        inactiveThumbColor: widget.isDark
                            ? Colors.white70
                            : null,
                        onChanged: (value) {
                          setState(() => isEnabled = value);
                          _showResultDialog(value);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== QR CODE CARD =====
                  if (isEnabled)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        "assets/QRcode.svg",
                        width: 160,
                        height: 160,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                "2026 © SSJC.",
                style: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ENABLE / DISABLE DIALOG =================
  void _showResultDialog(bool enabled) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CHECK ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.15),
                ),
                child: const Icon(Icons.check, size: 46, color: Colors.green),
              ),

              const SizedBox(height: 18),

              const Text(
                "Good job!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                enabled
                    ? "Two Factor Authentication Successfully Enabled"
                    : "Two Factor Authentication Successfully Disabled",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF533483),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// ATTENDANCE TAB – VERTICAL TABLE (LIGHT & DARK THEME)
////////////////////////////////////////////////////////////////
class AttendanceTab extends StatelessWidget {
  final bool isDark;
  const AttendanceTab({super.key, required this.isDark});

  static const double cellHeight = 46;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? ProfilePage.darkHeaderGradient : null,
        color: isDark ? null : Colors.transparent,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Staff Attendance (2026)"),
            const SizedBox(height: 16),
            _attendanceTable(),
          ],
        ),
      ),
    );
  }

  // ================= TABLE =================
  Widget _attendanceTable() {
    return Column(
      children: [
        _headerRow(),
        ...List.generate(31, (i) => _dayRow(i + 1)),
        const SizedBox(height: 16),
        _summaryRow(),
      ],
    );
  }

  // ================= HEADER ROW =================
  Widget _headerRow() {
    return Row(children: [_headerCell("Day"), _headerCell("Jan 2026")]);
  }

  // ================= DAY ROW =================
  Widget _dayRow(int day) {
    return Row(
      children: [_dataCell("Day $day", isLabel: true), _dataCell("N/A")],
    );
  }

  // ================= SUMMARY =================
  Widget _summaryRow() {
    return Row(
      children: [
        _summaryCard("WD", "0"),
        const SizedBox(width: 10),
        _summaryCard("PD", "0"),
        const SizedBox(width: 10),
        _summaryCard("AD", "0"),
      ],
    );
  }

  // ================= HEADER CELL =================
  Widget _headerCell(String text) {
    return Expanded(
      child: Container(
        height: cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isDark ? ProfilePage.cardGradient : null,
          color: isDark ? null : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  // ================= DATA CELL =================
  Widget _dataCell(String text, {bool isLabel = false}) {
    return Expanded(
      child: Container(
        height: cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isDark ? ProfilePage.cardGradient : null,
          color: isDark ? null : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isLabel ? FontWeight.w600 : FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY CARD (FIXED) =================
  Widget _summaryCard(String title, String value) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: isDark ? ProfilePage.cardGradient : null,
          color: isDark ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TITLE =================
  Widget _title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
