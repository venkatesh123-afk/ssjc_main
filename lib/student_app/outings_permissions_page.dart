import 'package:flutter/material.dart';
import 'package:student_app/student_app/outing_details_page.dart';
import 'package:student_app/student_app/services/outing_service.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/student_app/studentdrawer.dart';

class OutingsPermissionsPage extends StatefulWidget {
  const OutingsPermissionsPage({super.key});

  @override
  State<OutingsPermissionsPage> createState() => _OutingsPermissionsPageState();
}

class _OutingsPermissionsPageState extends State<OutingsPermissionsPage> {
  bool _isLoading = true;
  List<dynamic> _outings = [];
  int _monthlyLimit = 8; // Assuming static limit for now
  int _used = 0;
  String _lastOutingDate = "N/A";
  bool _isAscending = false;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await OutingService.getOutings();
      if (mounted) {
        setState(() {
          _outings = response['data'] is List ? response['data'] : [];
          _monthlyLimit =
              int.tryParse(response['total_outings']?.toString() ?? '8') ?? 8;
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    // Calculate used outings for current month
    _used = _outings.where((o) {
      final dateStr = o['out_date'] ?? o['date'];
      if (dateStr == null) return false;
      try {
        final date = DateTime.parse(dateStr);
        return date.month == now.month && date.year == now.year;
      } catch (e) {
        return false;
      }
    }).length;

    // Find last outing date
    if (_outings.isNotEmpty) {
      // Sort temporarily to find latest
      final sorted = List.from(_outings);
      sorted.sort((a, b) {
        final da = DateTime.tryParse(a['out_date'] ?? '') ?? DateTime(1900);
        final db = DateTime.tryParse(b['out_date'] ?? '') ?? DateTime(1900);
        return db.compareTo(da);
      });
      final last = sorted.first;
      final dateStr = last['out_date'] ?? last['date'];
      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr);
          _lastOutingDate = "${date.day} ${_month(date.month)} ${date.year}";
        } catch (_) {
          _lastOutingDate = dateStr;
        }
      }
    }
  }

  void _sortOutings(bool asc) {
    setState(() {
      _isAscending = asc;
      _outings.sort((a, b) {
        final da = DateTime.tryParse(a['out_date'] ?? '') ?? DateTime(1900);
        final db = DateTime.tryParse(b['out_date'] ?? '') ?? DateTime(1900);
        return asc ? da.compareTo(db) : db.compareTo(da);
      });
    });
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildRuleItem(
    BuildContext context,
    String text, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2563EB), width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: Colors.grey.shade300),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const StudentAppBar(title: ""),
      drawer: const StudentDrawerPage(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= Header Row =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 380;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                size: isMobile ? 22 : 24,
                              ),
                              const SizedBox(width: 8),

                              // IMPORTANT: Expanded prevents overflow
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Outings & Permissions",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isMobile ? 18 : 24,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "View your outing records and permissions",
                                      maxLines: isMobile ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: _fetchData,
                      icon: Icon(
                        Icons.refresh,
                        size: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      label: Text(
                        "Refresh",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= Info Container (Image Section) =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(
                            0xFF1E3A5F,
                          ) // Dark blue background for dark mode
                        : const Color(0xFFEFF6FF), // light blue background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(
                              0xFF3B82F6,
                            ) // Darker border for dark mode
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(
                                  0xFF3B82F6,
                                ) // Darker blue for dark mode
                              : const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _used == 0
                              ? [
                                  Text(
                                    "No outings this month",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "You haven't used any outings this month.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade300
                                          : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    "$_used outings this month",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "You have used $_used of $_monthlyLimit outings.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade300
                                          : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats Cards
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _statCard(
                        title: "Monthly Limit",
                        value: "$_monthlyLimit outings",
                        valueColor: const Color(0xFF2563EB),
                      ),

                      const SizedBox(height: 16),

                      _statCard(
                        title: "Used",
                        value: "$_used",
                        valueColor: Colors.green,
                      ),

                      const SizedBox(height: 16),

                      _statCard(
                        title: "Remaining",
                        value: "${_monthlyLimit - _used} outings",
                        valueColor: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _statCard(
                        title: "Last Outing",
                        value: _lastOutingDate,
                        valueColor: const Color(0xFF2563EB),
                      ),
                    ],
                  ),

            const SizedBox(height: 24),

            // Outing Records
            _isLoading
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= Tabs =================
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _selectedTabIndex == 0
                                            ? const Color(0xFF2563EB)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Outing Records (${_outings.length})",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: _selectedTabIndex == 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _selectedTabIndex == 0
                                          ? const Color(0xFF2563EB)
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 1),
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _selectedTabIndex == 1
                                            ? const Color(0xFF2563EB)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Rules & Guidelines",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: _selectedTabIndex == 1
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _selectedTabIndex == 1
                                          ? const Color(0xFF2563EB)
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // ================= Tab Content =================
                        if (_selectedTabIndex == 0) ...[
                          // ================= Scrollable Content (Records) =================
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ================= Header =================
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade800.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      // DATE
                                      SizedBox(
                                        width: 150,
                                        child: Row(
                                          children: [
                                            Text(
                                              "Date",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Sort icons
                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _sortOutings(true),
                                                  child: Icon(
                                                    Icons.keyboard_arrow_up,
                                                    size: 16,
                                                    color: _isAscending
                                                        ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _sortOutings(false),
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    size: 16,
                                                    color: !_isAscending
                                                        ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // TIMING
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          "Timing",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                      // PURPOSE
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          "Purpose",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                      // TYPE
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          "Type",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                      // STATUS
                                      SizedBox(
                                        width: 130,
                                        child: Row(
                                          children: [
                                            Text(
                                              "Status",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.filter_list,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ACTION
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          "Action",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ================= Records =================
                                if (_outings.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Center(
                                      child: Text(
                                        "No records found",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),

                                ..._outings.map((r) {
                                  final dateStr =
                                      r['out_date']?.toString() ?? '';
                                  final timeStr =
                                      r['outing_time']?.toString() ?? '';
                                  final purpose =
                                      r['purpose']?.toString() ?? 'N/A';
                                  final type =
                                      r['outingtype']?.toString() ??
                                      'Self Outing';
                                  final status =
                                      r['status']?.toString().toLowerCase() ??
                                      'pending';

                                  final isHomePass = type
                                      .toLowerCase()
                                      .contains('home');

                                  // Color coding for Type
                                  final typeColor = isHomePass
                                      ? Colors.blue
                                      : Colors.orange.shade700;
                                  final typeBg = isHomePass
                                      ? Colors.blue.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1);

                                  // Color coding for Status
                                  Color statusColor = Colors.grey;
                                  IconData statusIcon =
                                      Icons.hourglass_empty_rounded;

                                  if (status == 'approved') {
                                    statusColor = Colors.green;
                                    statusIcon = Icons.check_circle_outline;
                                  } else if (status == 'rejected') {
                                    statusColor = Colors.red;
                                    statusIcon = Icons.highlight_off;
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).dividerColor.withValues(alpha: 0.5),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // DATE
                                        SizedBox(
                                          width: 150,
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today_outlined,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                dateStr,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // TIMING
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            timeStr,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        // PURPOSE
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            purpose,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // TYPE
                                        SizedBox(
                                          width: 140,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: typeBg,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                type,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: typeColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // STATUS
                                        SizedBox(
                                          width: 130,
                                          child: Row(
                                            children: [
                                              Icon(
                                                statusIcon,
                                                color: statusColor,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // ACTION
                                        SizedBox(
                                          width: 100,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      OutingDetailsPage(
                                                        outing: r,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12,
                                                  ),
                                              side: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.visibility_outlined,
                                                  size: 16,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "View",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ] else ...[
                          // ================= Rules & Guidelines Context =================
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Outing Rules & Guidelines",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildRuleItem(
                                  context,
                                  "Maximum 8 outings per month",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Day outings: 8 AM to 8 PM",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Night outings require special permission",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Overnight stays need parent consent",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Medical emergencies have priority",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Submit requests at least 24 hours in advance",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Always carry your ID card during outings",
                                ),
                                _buildRuleItem(
                                  context,
                                  "Inform hostel warden about any delays",
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            // stat section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Stats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _statRow("Total Outings", _outings.length.toString()),
                  const SizedBox(height: 8),
                  _statRow(
                    "Approved",
                    _outings
                        .where(
                          (o) =>
                              o['status'].toString().toLowerCase() ==
                              'approved',
                        )
                        .length
                        .toString(),
                  ),
                  const SizedBox(height: 8),
                  _statRow(
                    "Rejected",
                    _outings
                        .where(
                          (o) =>
                              o['status'].toString().toLowerCase() ==
                              'rejected',
                        )
                        .length
                        .toString(),
                  ),
                  const SizedBox(height: 8),
                  _statRow(
                    "Pending",
                    _outings
                        .where(
                          (o) =>
                              o['status'].toString().toLowerCase() == 'pending',
                        )
                        .length
                        .toString(),
                  ),
                  const SizedBox(height: 8),
                  _statRow(
                    "Success Rate",
                    _outings.isNotEmpty
                        ? "${((_outings.where((o) => o['status'].toString().toLowerCase() == 'approved').length / _outings.length) * 100).toStringAsFixed(0)}%"
                        : "0%",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_outings.isEmpty)
                    const Text("No recent activity")
                  else
                    ..._outings.take(3).map((o) {
                      final dateStr = o['out_date'] ?? o['date'] ?? '';
                      final d = DateTime.tryParse(dateStr) ?? DateTime.now();
                      final formattedDate =
                          "${d.day} ${_month(d.month)} ${d.year}";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _activityItem(
                          o['reason'] ?? 'Outing',
                          formattedDate,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _activityItem(String title, String date) {
  return Builder(
    builder: (context) => Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.green.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "$title ($date)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _statRow(String label, String value) {
  return Builder(
    builder: (context) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label :",
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    ),
  );
}

Widget _statCard({
  required String title,
  required String value,
  required Color valueColor,
}) {
  return Builder(
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    ),
  );
}

// ignore: unused_element
class _OutingRecordItem extends StatelessWidget {
  final String date;
  final String outTime;
  final String inTime;
  final String purpose;
  final bool isHomePass;

  const _OutingRecordItem({
    required this.date,
    required this.outTime,
    required this.inTime,
    required this.purpose,
    required this.isHomePass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Out: $outTime",
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  "In: $inTime",
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              purpose,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: isHomePass
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Home Pass",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
        ],
      ),
    );
  }
}
