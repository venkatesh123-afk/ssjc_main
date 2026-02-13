import 'package:flutter/material.dart';
import 'package:student_app/student_app/announcement_page.dart';
import 'package:student_app/student_app/model/class_attendance.dart';
import 'package:student_app/student_app/model/hostel_attendance.dart';
import 'package:student_app/student_app/services/attendance_service.dart';
import 'package:student_app/student_app/services/hostel_attendance_service.dart';
import 'package:student_app/student_app/services/remarks_service.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/student_app/full_day_timetable.dart';
import 'package:student_app/student_app/upcoming_exams_page.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

enum TimeRange { academicYear, last3Months, last6Months }

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic> _attendanceData = {};

  // Graph Data
  List<Map<String, dynamic>> _chartData = [];
  List<Map<String, dynamic>> _allChartData = []; // Store all data
  List<String> _chartMonths = [];
  List<String> _allChartMonths = []; // Store all months
  double _chartMaxValue = 30;
  TimeRange _selectedTimeRange = TimeRange.academicYear;

  List<dynamic> _remarks = [];

  // Hostel Attendance Graph Data
  List<Map<String, dynamic>> _hostelChartData = [];
  List<Map<String, dynamic>> _allHostelChartData = []; // Store all data
  List<String> _hostelChartMonths = [];
  List<String> _allHostelChartMonths = []; // Store all months
  double _hostelChartMaxValue = 30;
  TimeRange _selectedHostelTimeRange = TimeRange.academicYear;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // Fetch Summary for Cards
      final summary = await AttendanceService.getAttendanceSummary();
      // Fetch Grid for Chart
      final grid = await AttendanceService.getAttendance();
      // Fetch Remarks
      final remarks = await RemarksService.getRemarks();
      // Fetch Hostel Attendance
      final hostelGrid = await HostelAttendanceService.getHostelAttendance();

      if (mounted) {
        setState(() {
          _attendanceData = summary;
          _processChartData(grid);
          _remarks = remarks;
          _processHostelChartData(hostelGrid);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("Error fetching dashboard data: $e");
      }
    }
  }

  void _processChartData(dynamic data) {
    try {
      if (data is! ClassAttendance) return;

      final monthsList = data.attendance;

      if (monthsList.isNotEmpty) {
        _allChartData.clear();
        _allChartMonths.clear();

        double maxVal = 0;

        // Store all data first
        for (var m in monthsList) {
          final monthName = m.monthName;
          final present = m.present;
          final absent = m.absent;
          final holidays = m.holidays;
          final outings = m.outings;
          final total = m.total;

          if (total > maxVal) maxVal = total.toDouble();

          _allChartMonths.add(monthName);
          _allChartData.add({
            'present': present,
            'absent': absent,
            'holidays': holidays,
            'outings': outings,
            'total': total,
            'month': monthName,
          });
        }

        // Apply time range filter
        _applyTimeRangeFilter();
        _chartMaxValue = maxVal > 0 ? maxVal + 2 : 30; // Add buffer
      }
    } catch (e) {
      print("Error processing chart data: $e");
    }
  }

  void _applyTimeRangeFilter() {
    _chartData.clear();
    _chartMonths.clear();

    int monthsToShow;
    switch (_selectedTimeRange) {
      case TimeRange.last3Months:
        monthsToShow = 3;
        break;
      case TimeRange.last6Months:
        monthsToShow = 6;
        break;
      case TimeRange.academicYear:
        monthsToShow = _allChartData.length;
        break;
    }

    final startIndex = _allChartData.length > monthsToShow
        ? _allChartData.length - monthsToShow
        : 0;

    for (int i = startIndex; i < _allChartData.length; i++) {
      if (i >= _allChartMonths.length) break;
      final data = _allChartData[i];
      final monthName = _allChartMonths[i];

      // Extract short month name (first 3 chars)
      final shortMonth = monthName.length > 3
          ? monthName.substring(0, 3)
          : monthName;

      _chartMonths.add(shortMonth);
      _chartData.add(data);
    }
  }

  void _processHostelChartData(HostelAttendance data) {
    try {
      _allHostelChartData.clear();
      _allHostelChartMonths.clear();

      double maxVal = 0;

      for (var m in data.attendance) {
        final monthName = m.monthName;
        final present = m.present;
        final absent = m.absent;
        final total = m.total;

        if (total > maxVal) maxVal = total.toDouble();

        _allHostelChartMonths.add(monthName);
        _allHostelChartData.add({
          'present': present,
          'absent': absent,
          'total': total,
          'totalHostelDays': present + absent,
          'month': monthName,
        });
      }

      _applyHostelTimeRangeFilter();
      _hostelChartMaxValue = maxVal > 0 ? maxVal + 2 : 30;
    } catch (e) {
      print("Error processing hostel chart data: $e");
    }
  }

  void _applyHostelTimeRangeFilter() {
    _hostelChartData.clear();
    _hostelChartMonths.clear();

    int monthsToShow;
    switch (_selectedHostelTimeRange) {
      case TimeRange.last3Months:
        monthsToShow = 3;
        break;
      case TimeRange.last6Months:
        monthsToShow = 6;
        break;
      case TimeRange.academicYear:
        monthsToShow = _allHostelChartData.length;
        break;
    }

    final startIndex = _allHostelChartData.length > monthsToShow
        ? _allHostelChartData.length - monthsToShow
        : 0;

    for (int i = startIndex; i < _allHostelChartData.length; i++) {
      if (i >= _allHostelChartMonths.length) break;
      final data = _allHostelChartData[i];
      final monthName = _allHostelChartMonths[i];

      // Extract short month name (first 3 chars)
      final shortMonth = monthName.length > 3
          ? monthName.substring(0, 3)
          : monthName;

      _hostelChartMonths.add(shortMonth);
      _hostelChartData.add(data);
    }
  }

  String _getTimeRangeLabel(TimeRange range) {
    switch (range) {
      case TimeRange.academicYear:
        return 'Academic Year';
      case TimeRange.last6Months:
        return 'Last 6 Months';
      case TimeRange.last3Months:
        return 'Last 3 Months';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const StudentAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Student Dashboard",
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text("Dashboard", style: const TextStyle(color: Colors.blue)),

            const SizedBox(height: 20),

            // Attendance Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Attendance",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (_isLoading)
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        _AttendanceTile(
                          icon: Icons.calendar_today,
                          iconColor: Colors.blue,
                          title: "Total Days",
                          value:
                              _attendanceData['total_working_days']
                                  ?.toString() ??
                              "-",
                        ),
                        _AttendanceTile(
                          icon: Icons.check_circle,
                          iconColor: Colors.green,
                          title: "Present",
                          value: _attendanceData['present']?.toString() ?? "-",
                        ),
                        _AttendanceTile(
                          icon: Icons.directions_run,
                          iconColor: Colors.cyan,
                          title: "Outings",
                          value: _attendanceData['outings']?.toString() ?? "-",
                        ),
                        _AttendanceTile(
                          icon: Icons.cancel,
                          iconColor: Colors.red,
                          title: "Absent",
                          value: _attendanceData['absent']?.toString() ?? "-",
                        ),
                        _AttendanceTile(
                          icon: Icons.event,
                          iconColor: Colors.amber,
                          title: "Holidays",
                          value: _attendanceData['holidays']?.toString() ?? "-",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Exam Stats Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Exam Stats",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),

                        _AttendanceTile(
                          icon: Icons.assignment,
                          iconColor: Colors.blue,
                          title: "Total Exam Questions",
                          value:
                              _attendanceData['total_exam_questions']
                                  ?.toString() ??
                              "200",
                        ),
                        _AttendanceTile(
                          icon: Icons.check_circle,
                          iconColor: Colors.green,
                          title: "Total Attempted Questions",
                          value:
                              _attendanceData['total_attempted_questions']
                                  ?.toString() ??
                              "150",
                        ),
                        _AttendanceTile(
                          icon: Icons.close,
                          iconColor: Colors.amber,
                          title: "Total Not Attempted",
                          value:
                              _attendanceData['total_not_attempted']
                                  ?.toString() ??
                              "50",
                        ),
                        _AttendanceTile(
                          icon: Icons.add_circle,
                          iconColor: Colors.cyan,
                          title: "Total +ve Questions",
                          value:
                              _attendanceData['total_positive_questions']
                                  ?.toString() ??
                              "120",
                        ),
                        _AttendanceTile(
                          icon: Icons.remove_circle,
                          iconColor: Colors.red,
                          title: "Total -ve Questions",
                          value:
                              _attendanceData['total_negative_questions']
                                  ?.toString() ??
                              "30",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rank Stats Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Rank Stats",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),

                        _RankTile(
                          icon: Icons.emoji_events,
                          iconColor: Colors.blue,
                          title: "Overall Rank",
                          value:
                              _attendanceData['overall_rank']?.toString() ??
                              "12",
                        ),
                        _RankTile(
                          icon: Icons.account_tree,
                          iconColor: Colors.green,
                          title: "Branch Wise Rank",
                          value:
                              _attendanceData['branch_wise_rank']?.toString() ??
                              "3",
                        ),
                        _RankTile(
                          icon: Icons.groups,
                          iconColor: Colors.cyan,
                          title: "Group Wise Rank",
                          value:
                              _attendanceData['group_wise_rank']?.toString() ??
                              "5",
                        ),
                        _RankTile(
                          icon: Icons.menu_book,
                          iconColor: Colors.amber,
                          title: "Course Wise Rank",
                          value:
                              _attendanceData['course_wise_rank']?.toString() ??
                              "8",
                        ),
                        _RankTile(
                          icon: Icons.layers,
                          iconColor: Colors.red,
                          title: "Batch Wise Rank",
                          value:
                              _attendanceData['batch_wise_rank']?.toString() ??
                              "2",
                          isLast: true,
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Time Table Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Time Table",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subject Cards
                  _TimeTableCard(
                    subject: "Maths",
                    time: "09:00 - 09:45",
                    instructor: "Mr. Ramesh",
                  ),
                  _TimeTableCard(
                    subject: "Physics",
                    time: "09:50 - 10:35",
                    instructor: "Ms. Anjali",
                  ),
                  _TimeTableCard(
                    subject: "Chemistry",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                  ),
                  _TimeTableCard(
                    subject: "English",
                    time: "11:30 - 12:15",
                    instructor: "Mrs. Kavitha",
                    isLast: true,
                  ),

                  // View All Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FullDayTimetablePage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                        label: const Text(
                          "View All",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Class Attendance Chart Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Class Attendance (Month-wise Days)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        PopupMenuButton<TimeRange>(
                          initialValue: _selectedTimeRange,
                          onSelected: (TimeRange value) {
                            setState(() {
                              _selectedTimeRange = value;
                              _applyTimeRangeFilter();
                            });
                          },
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getTimeRangeLabel(_selectedTimeRange),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<TimeRange>>[
                                PopupMenuItem<TimeRange>(
                                  value: TimeRange.academicYear,
                                  child: Text('Academic Year'),
                                ),
                                PopupMenuItem<TimeRange>(
                                  value: TimeRange.last6Months,
                                  child: Text('Last 6 Months'),
                                ),
                                PopupMenuItem<TimeRange>(
                                  value: TimeRange.last3Months,
                                  child: Text('Last 3 Months'),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _chartData.isEmpty
                        ? const SizedBox(
                            height: 200,
                            child: Center(child: Text("Loading chart data...")),
                          )
                        : _AttendanceChart(
                            key: const ValueKey('class_attendance_chart'),
                            months: _chartMonths,
                            maxValue: _chartMaxValue.toInt(),
                            data: _chartData,
                            selectedRange: _selectedTimeRange,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _LegendItem(color: Colors.green, label: "Present"),
                        _LegendItem(color: Colors.red, label: "Absent"),
                        _LegendItem(color: Colors.amber, label: "Outings"),
                        _LegendItem(color: Colors.blue, label: "Holidays"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ... (Rest of existing content: Hostel Attendance, Remarks, Announcements)
            // Keeping the rest of the file layout identical for brevity in this response, but assuming direct copy.
            // To ensure completeness, I will restore the bottom part.

            // Hostel Attendance Chart Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Hostel Attendance (Month-wise Days)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        PopupMenuButton<TimeRange>(
                          initialValue: _selectedHostelTimeRange,
                          onSelected: (TimeRange value) {
                            setState(() {
                              _selectedHostelTimeRange = value;
                              _applyHostelTimeRangeFilter();
                            });
                          },
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getTimeRangeLabel(_selectedHostelTimeRange),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<TimeRange>>[
                                PopupMenuItem<TimeRange>(
                                  value: TimeRange.academicYear,
                                  child: Text('Academic Year'),
                                ),
                                PopupMenuItem<TimeRange>(
                                  value: TimeRange.last6Months,
                                  child: Text('Last 6 Months'),
                                ),
                                PopupMenuItem<TimeRange>(
                                  value: TimeRange.last3Months,
                                  child: Text('Last 3 Months'),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),
                  // Fallback or duplicate chart if needed, or static for now
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _hostelChartData.isEmpty
                        ? const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text("Loading hostel attendance data..."),
                            ),
                          )
                        : _AttendanceChart(
                            key: const ValueKey('hostel_attendance_chart'),
                            months: _hostelChartMonths,
                            maxValue: _hostelChartMaxValue.toInt(),
                            data: _hostelChartData,
                            isHostel: true,
                            selectedRange: _selectedHostelTimeRange,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(color: Colors.green, label: "Present"),
                        const SizedBox(width: 24),
                        _LegendItem(color: Colors.red, label: "Absent"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Remarks & Announcements (Simplified placeholders to complete the file structure)
            // Remarks Card
            _DashboardSectionCard(
              title: "Remarks",
              emptyMessage: _remarks.isNotEmpty
                  ? (_remarks.first['remarks'] ??
                        _remarks.first['remark'] ??
                        "New Remark Available")
                  : "No remarks found",
              buttonText: "View All Remarks",
              onTap: () {},
            ),
            const SizedBox(height: 20),

            // Announcements Card
            _DashboardSectionCard(
              title: "Announcements",
              emptyMessage: "No announcements found",
              buttonText: "View All Announcements",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnouncementsDialog()),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Exams Card
            _DashboardSectionCard(
              title: "Upcoming Exams",
              emptyMessage: "No upcoming exams",
              buttonText: "View All Exams",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpcomingExams(
                    color: Colors.blue,
                    date: '',
                    title: '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Student Calendar - Displayed Inline
            const StudentCalendar(showAppBar: false, isInline: true),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ... Using Existing Helper Widgets (_AttendanceTile, _RankTile, _TimeTableCard, _AttendanceChart, _LegendItem, _AnnouncementItem)
// I will include them below to ensure the file runs standalone.

class _AttendanceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isLast;

  const _AttendanceTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
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
        ),
      ],
    );
  }
}

class _RankTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isLast;
  final bool isHighlighted;

  const _RankTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.isLast = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: isHighlighted
              ? iconColor.withOpacity(0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 52,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}

class _TimeTableCard extends StatelessWidget {
  final String subject;
  final String time;
  final String instructor;
  final bool isLast;
  const _TimeTableCard({
    required this.subject,
    required this.time,
    required this.instructor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$time • $instructor",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 32,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}

class _AttendanceChart extends StatelessWidget {
  final List<String> months;
  final int maxValue;
  final List<Map<String, dynamic>> data;
  final bool isHostel;
  final TimeRange selectedRange;

  const _AttendanceChart({
    super.key,
    required this.months,
    required this.maxValue,
    required this.data,
    required this.selectedRange,
    this.isHostel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: Row(
            children: [
              // Y-axis Title "No. of Days"
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'No. of Days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue.toDouble(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) =>
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.white,
                        tooltipPadding: const EdgeInsets.all(12),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex < 0 ||
                              groupIndex >= data.length ||
                              groupIndex >= months.length)
                            return null;

                          final monthData = data[groupIndex];
                          final monthName = months[groupIndex];

                          // Only show tooltip on first rod to avoid duplicates
                          if (rodIndex != 0) return null;

                          final present = monthData['present'] ?? 0;
                          final absent = monthData['absent'] ?? 0;
                          final outings = monthData['outings'] ?? 0;
                          final holidays = monthData['holidays'] ?? 0;
                          final total =
                              monthData['total'] ??
                              (present + absent + outings + holidays);
                          final percentage = total > 0
                              ? ((present / total) * 100).toStringAsFixed(1)
                              : '0.0';

                          return BarTooltipItem(
                            '',
                            const TextStyle(),
                            children: [
                              TextSpan(
                                text: '$monthName 2025\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              TextSpan(
                                text: '\n',
                                style: const TextStyle(fontSize: 4),
                              ),
                              TextSpan(
                                text: '● ',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Present Days : $present\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              TextSpan(
                                text: '● ',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Absent Days : $absent\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              if (!isHostel) ...[
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Outing Days : $outings\n',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                TextSpan(
                                  text: '● ',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Holidays : $holidays\n',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ] else ...[
                                TextSpan(
                                  text: '🏩 ',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                TextSpan(
                                  text:
                                      'Total Hostel Days : ${monthData['totalHostelDays'] ?? (present + absent)}\n',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                              TextSpan(
                                text: '\n',
                                style: const TextStyle(fontSize: 4),
                              ),
                              TextSpan(
                                text: '📅 ',
                                style: const TextStyle(fontSize: 14),
                              ),
                              TextSpan(
                                text: 'Working Days : $total\n',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              TextSpan(
                                text: '📊 ',
                                style: const TextStyle(fontSize: 14),
                              ),
                              TextSpan(
                                text: isHostel
                                    ? 'Hostel Attendance % : $percentage%'
                                    : 'Attendance % : $percentage%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= months.length)
                              return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        left: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    barGroups: List.generate(data.length, (index) {
                      if (index >= months.length)
                        return BarChartGroupData(x: index, barRods: []);
                      final d = data[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (d['present'] ?? 0).toDouble(),
                            color: Colors.green,
                            width: 8,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          if (isHostel)
                            BarChartRodData(
                              toY: (d['absent'] ?? 0).toDouble(),
                              color: Colors.red,
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          if (!isHostel) ...[
                            BarChartRodData(
                              toY: (d['absent'] ?? 0).toDouble(),
                              color: Colors.red,
                              width: 6,
                            ),
                            BarChartRodData(
                              toY: (d['outings'] ?? 0).toDouble(),
                              color: Colors.amber,
                              width: 6,
                            ),
                            BarChartRodData(
                              toY: (d['holidays'] ?? 0).toDouble(),
                              color: Colors.blue,
                              width: 6,
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selectedRange == TimeRange.academicYear
              ? 'Academic Year'
              : selectedRange == TimeRange.last6Months
              ? 'Last 6 Months'
              : 'Last 3 Months',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _AnnouncementItem extends StatelessWidget {
  final Color iconColor;
  final String text;
  final String source;
  final bool isLast;
  const _AnnouncementItem({
    required this.iconColor,
    required this.text,
    required this.source,
    required this.isLast,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.campaign, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      source,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 48,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
      ],
    );
  }
}

class _DashboardSectionCard extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final String buttonText;
  final VoidCallback onTap;

  const _DashboardSectionCard({
    required this.title,
    required this.emptyMessage,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).cardColor, // Or a slightly different header color if desired, but user screenshot shows same color background with just text
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Divider(
                  height: 24, // space above and below divider
                  thickness: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ],
            ),
          ),

          // Body (Empty State + Button)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Blue Button
                SizedBox(
                  width: 250, // Fixed width or relative to screen
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB), // Blue color
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
