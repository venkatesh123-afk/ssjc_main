import 'dart:math';
import 'package:flutter/material.dart';
import 'package:student_app/student_app/exam_details_dialog.dart';
import 'package:student_app/student_app/exam_summary_dialog.dart';
import 'package:student_app/student_app/exam_weekend_details.dart';
import 'package:student_app/student_app/marks_grades_page.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/services/exams_service.dart';
import 'package:student_app/student_app/student_calendar.dart';
import 'package:student_app/student_app/studentdrawer.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/theme_controllers.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  // State for filtering
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Completed, 2: Online, 3: Offline
  String _searchQuery = "";
  String _selectedSubject = "All Subjects";
  final List<String> _subjects = ["All Subjects"];
  String _selectedProctoringType = "All Proctoring Types";
  final List<String> _proctoringTypes = [
    "All Proctoring Types",
    "Proctored",
    "Non-Proctored",
  ];

  // Data lists
  List<ExamModel> _currentTabExams = [];
  bool _isLoading = true;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Stats
  int _upcomingCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch online exams from API
      final response = await ExamsService.getOnlineExams();

      if (mounted) {
        setState(() {
          // Parse API response
          List<dynamic> apiExams = [];

          if (response['data'] != null && response['data'] is List) {
            apiExams = response['data'];
          } else if (response['exams'] != null && response['exams'] is List) {
            apiExams = response['exams'];
          }

          // Convert API data to ExamModel and categorize
          List<ExamModel> onlineExams = [];
          List<ExamModel> upcomingExams = [];
          List<ExamModel> completedExams = [];

          for (var examData in apiExams) {
            final exam = ExamModel(
              id:
                  examData['exam_id']?.toString() ??
                  examData['id']?.toString() ??
                  '',
              title:
                  examData['examname'] ??
                  examData['exam_name'] ??
                  examData['title'] ??
                  'Untitled Exam',
              subject:
                  examData['subject'] ?? response['course_name'] ?? 'General',
              date: examData['exam_date'] ?? examData['date'] ?? 'N/A',
              time: examData['exam_time'] ?? examData['time'] ?? 'N/A',
              board: examData['board'] ?? '',
              type: _parseExamType(examData['exam_type']),
              color: Colors.blue, // You can map colors based on subject
              progress: examData['progress']?.toDouble() ?? 0.0,
            );

            // Add to online exams list
            onlineExams.add(exam);

            // Categorize based on status
            final status = examData['status']?.toString().toLowerCase() ?? '';
            if (status == 'completed' || examData['is_completed'] == true) {
              completedExams.add(exam);
            } else {
              upcomingExams.add(exam);
            }
          }

          // Update the static lists in ExamModel (if you want to keep using them)
          // Or you can store them in state variables
          ExamModel.onlineExams.clear();
          ExamModel.onlineExams.addAll(onlineExams);

          // Update counts
          _upcomingCount = upcomingExams.isNotEmpty
              ? upcomingExams.length
              : ExamModel.upcomingExams.length;
          _completedCount = completedExams.isNotEmpty
              ? completedExams.length
              : ExamModel.completedExams.length;

          // Populate subjects
          final uniqueSubjects = onlineExams.map((e) => e.subject).toSet();
          _subjects.clear();
          _subjects.add("All Subjects");
          _subjects.addAll(uniqueSubjects);

          _updateCurrentTabExams();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback to static data if API fails
          _upcomingCount = ExamModel.upcomingExams.length;
          _completedCount = ExamModel.completedExams.length;

          final uniqueSubjects = ExamModel.upcomingExams
              .map((e) => e.subject)
              .toSet();
          _subjects.clear();
          _subjects.add("All Subjects");
          _subjects.addAll(uniqueSubjects);

          _updateCurrentTabExams();
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load exams: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateCurrentTabExams() {
    // Select the source list based on tab
    List<ExamModel> source;
    switch (_selectedTabIndex) {
      case 0:
        source = ExamModel.upcomingExams;
        break;
      case 1:
        source = ExamModel.completedExams;
        break;
      case 2:
        source = ExamModel.onlineExams;
        break;
      case 3:
        source = ExamModel.offlineExams;
        break;
      default:
        source = [];
    }

    setState(() {
      _currentTabExams = source;
      _currentPage = 1; // Reset to page 1 on tab switch
    });
  }

  List<ExamModel> _getFilteredAndPagedExams() {
    // Safety check
    if (_currentTabExams.isEmpty) return [];

    // 1. Filter
    List<ExamModel> filtered = _currentTabExams.where((exam) {
      // Subject Filter
      if (_selectedSubject != "All Subjects" &&
          exam.subject != _selectedSubject) {
        return false;
      }
      // Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return exam.title.toLowerCase().contains(query) ||
            exam.board.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // 2. Paginate
    final totalItems = filtered.length;
    if (totalItems == 0) return [];

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= totalItems) {
      // If start index is out of bounds (e.g. after filtering), reset or show empty
      return [];
    }

    int endIndex = min(startIndex + _itemsPerPage, totalItems);

    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages() {
    if (_currentTabExams.isEmpty) return 1;

    // Calculate total pages for current filtered list
    List<ExamModel> filtered = _currentTabExams.where((exam) {
      if (_selectedSubject != "All Subjects" &&
          exam.subject != _selectedSubject)
        return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return exam.title.toLowerCase().contains(query) ||
            exam.board.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    if (filtered.isEmpty) return 1;

    return (filtered.length / _itemsPerPage).ceil();
  }

  String _parseExamType(dynamic type) {
    if (type == null) return "Online";
    final t = type.toString().toLowerCase();
    if (t == "0" || t == "online") return "Online";
    if (t == "1" || t == "offline") return "Offline";
    return "Online"; // Default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const StudentAppBar(title: ""),
      drawer: const StudentDrawerPage(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Exams",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Manage your exams and view results",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: StudentThemeController.themeMode,
                            builder: (context, mode, _) {
                              return Row(children: [
                                  
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StudentCalendar(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_month, size: 18),

                            label: const Text("Open Calendar"),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats Cards
                  Column(
                    children: [
                      _buildStatCard(
                        title: "Upcoming Exams",
                        value: "$_upcomingCount",
                        subtext: "10",
                        icon: Icons.calendar_today,
                        iconColor: Colors.blue,
                        content: null,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        title: "Avg. Score",
                        value: "375.0%",
                        subtext: "Based on 1 completed exams",
                        icon: Icons.emoji_events_outlined,
                        iconColor: Colors.green,
                        content: null,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        title: "Class Rank",
                        value: "1/85",
                        subtext: "Top 10 of the class",
                        icon: Icons.star_outline,
                        iconColor: Colors.purple,
                        content: null,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        title: "Study Hours",
                        value: "32 hrs",
                        subtext: "Recommended for upcoming exams",
                        icon: Icons.access_time,
                        iconColor: Colors.teal,
                        content: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tab Container
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tabs Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTabItem(
                                0,
                                "Upcoming Exams",
                                _upcomingCount,
                                Icons.calendar_today_outlined,
                              ),
                              const SizedBox(width: 24),
                              _buildTabItem(
                                1,
                                "Completed Exams",
                                _completedCount,
                                Icons.check_circle_outline,
                              ),
                              const SizedBox(width: 24),
                              _buildTabItem(
                                2,
                                "Online Exam",
                                ExamModel.onlineExams.length,
                                Icons.computer,
                              ),
                              const SizedBox(width: 24),
                              _buildTabItem(
                                3,
                                "Offline Exam",
                                ExamModel.offlineExams.length,
                                Icons.class_outlined,
                              ),
                            ],
                          ),
                        ),

                        // Online Exam Banner
                        if (_selectedTabIndex == 2) _buildOnlineExamBanner(),
                        const SizedBox(height: 24),
                        // Filters: Dropdown + Search
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.surface
                                      : Colors.white,
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedSubject,
                                    isExpanded: true,
                                    dropdownColor: theme.cardColor,
                                    items: _subjects
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(() => _selectedSubject = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (_selectedTabIndex == 2) ...[
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.surface
                                        : Colors.white,
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedProctoringType,
                                      isExpanded: true,
                                      dropdownColor: theme.cardColor,
                                      items: _proctoringTypes
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                  color: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null)
                                          setState(
                                            () => _selectedProctoringType = val,
                                          );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              flex: 3,
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.surface
                                      : Colors.white,
                                  hintText: _selectedTabIndex == 2
                                      ? "Search online exams..."
                                      : "Search exams...",
                                  hintStyle: TextStyle(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  suffixIcon: _selectedTabIndex == 2
                                      ? Icon(
                                          Icons.search,
                                          size: 20,
                                          color:
                                              theme.textTheme.bodySmall?.color,
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Completed Exam Banner (Only on Completed Tab)
                        if (_selectedTabIndex == 1 &&
                            _getFilteredAndPagedExams().isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.lightGreen.shade50.withOpacity(0.5),
                              border: Border.all(
                                color: isDark
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.lightGreen.shade200,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.green.shade200
                                            : Colors.green.shade900,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              "Your overall performance is Excellent! Average score: ",
                                        ),
                                        TextSpan(
                                          text: "375.0%",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.green.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // List Header & Items
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double minTableWidth = 1000;
                            double actualWidth = max(
                              constraints.maxWidth,
                              minTableWidth,
                            );

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: actualWidth,
                                child: Column(
                                  children: [
                                    // Header
                                    _selectedTabIndex == 1
                                        ? _buildCompletedHeader()
                                        : _selectedTabIndex == 2
                                        ? _buildOnlineExamHeader()
                                        : _buildStandardHeader(),

                                    // List Items with Pagination Logic
                                    ..._getFilteredAndPagedExams().map((exam) {
                                      if (_selectedTabIndex == 1) {
                                        return _buildCompletedExamRow(exam);
                                      }
                                      if (_selectedTabIndex == 2) {
                                        return _buildOnlineExamRow(exam);
                                      }
                                      return _buildStandardExamRow(exam);
                                    }),

                                    if (_getFilteredAndPagedExams().isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Center(
                                          child: Text(
                                            "No exams found.",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Pagination Controls
                        if (_getTotalPages() > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              // Page numbers
                              ...List.generate(_getTotalPages(), (index) {
                                int pageNum = index + 1;
                                bool isCurrent = pageNum == _currentPage;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _currentPage = pageNum),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Colors.blue.shade50
                                          : Colors.transparent,
                                      border: isCurrent
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent,
                                            ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "$pageNum",
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.blue
                                            : Colors.grey[700],
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              IconButton(
                                onPressed: _currentPage < _getTotalPages()
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    Widget? content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 8),
              if (content != null)
                content
              else
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtext,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, int count, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _updateCurrentTabExams();
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodySmall?.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // STANDARD / UPCOMING Header
  Widget _buildStandardHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Exam Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Date & Time",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Preparation",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COMPLETED Header
  Widget _buildCompletedHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Exam",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Marks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Percentage",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Grade & Rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Performance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ONLINE EXAM Header
  Widget _buildOnlineExamHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Exam Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Exam Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Schedule",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Requirements",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineExamBanner() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withOpacity(0.1)
            : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withOpacity(0.3)
              : const Color(0xFFBAE6FD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: isDark ? theme.colorScheme.primary : const Color(0xFF0EA5E9),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Online Exam Information",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0C4A6E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Take online exams from anywhere with internet connection. Ensure you have webcam and microphone enabled.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: isDark
                        ? theme.textTheme.bodySmall?.color
                        : Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineExamRow(ExamModel exam) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Exam Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(exam.board, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildOnlineBadge(
                        "Online",
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.primary,
                        Icons.computer,
                      ),
                      const SizedBox(width: 6),
                      if (exam.isProctored)
                        _buildOnlineBadge(
                          "Proctored",
                          Colors.green.withOpacity(0.1),
                          isDark
                              ? Colors.green.shade300
                              : const Color(0xFF22C55E),
                          null,
                        ),
                      const SizedBox(width: 6),
                      if (exam.progress == 100)
                        _buildOnlineBadge(
                          "Completed",
                          Colors.green.withOpacity(0.1),
                          isDark
                              ? Colors.green.shade300
                              : const Color(0xFF22C55E),
                          null,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Exam ID: ${exam.id}",
                  style: TextStyle(
                    color: isDark
                        ? Colors.pinkAccent.shade100
                        : const Color(0xFFEC4899),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. Exam Details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Duration: ", exam.duration ?? "N/A"),
                const SizedBox(height: 4),
                _buildDetailRow("Questions: ", "${exam.questions ?? 'N/A'}"),
                const SizedBox(height: 4),
                _buildDetailRow("Passing: ", exam.passingMarks ?? "N/A"),
              ],
            ),
          ),

          // 3. Schedule
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exam.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exam.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Platform: ${exam.platform ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // 4. Requirements
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (exam.hasWebcam)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 12,
                          color: isDark
                              ? Colors.redAccent.shade100
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Webcam",
                          style: TextStyle(
                            color: isDark
                                ? Colors.redAccent.shade100
                                : const Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (exam.hasInternet)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Internet",
                      style: TextStyle(
                        color: isDark
                            ? Colors.green.shade300
                            : const Color(0xFF22C55E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 5. Actions
          Expanded(
            flex: 2,
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showExamSummaryDialog(context, exam.id);
                  },
                  icon: const Icon(Icons.bar_chart, size: 14),
                  label: const Text("View Result"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(double.infinity, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExamWeekendDetails(examId: '${exam.id}'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: const Text("Instructions"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(double.infinity, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineBadge(
    String label,
    Color bgColor,
    Color textColor,
    IconData? icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodyMedium?.color,
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // STANDARD / UPCOMING ROW
  Widget _buildStandardExamRow(ExamModel exam) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Exam Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(exam.board, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Type: Unknown ",
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exam.type,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: ${exam.id}",
                  style: TextStyle(
                    color: isDark ? Colors.redAccent.shade100 : Colors.red[300],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // 2. Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exam.date,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exam.time,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Preparation
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: exam.progress / 100,
                          backgroundColor: theme.brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey.shade200,
                          color: theme.colorScheme.primary,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${exam.progress.toInt()}%",
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${exam.progress.toInt()}% Prepared",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // 4. Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.computer,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Online Exam",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Actions
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ExamDetailsDialog(examId: exam.id),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 14),
                label: const Text("Details"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textTheme.bodyLarge?.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COMPLETED ROW
  Widget _buildCompletedExamRow(ExamModel exam) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Exam Name column (Title, Board, ID)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    children: [
                      TextSpan(
                        text: exam.board,
                      ), // Removed bullet for simplicity
                      const TextSpan(text: " • Online"),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Exam ID in pink/red
                Text(
                  "Exam ID: ${exam.id}",
                  style: TextStyle(
                    color: isDark
                        ? Colors.pinkAccent.shade100
                        : Colors.pink[300],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Marks
          Expanded(
            flex: 1,
            child: Text(
              exam.marks ?? "-",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),

          // 3. Percentage
          Expanded(
            flex: 2,
            child: Text(
              exam.percentage ?? "-",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          // 4. Grade & Rank
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Grade Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exam.grade ?? "-",
                    style: TextStyle(
                      color: isDark
                          ? Colors.amber.shade200
                          : Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Rank: ${exam.rank ?? 'N/A'}",
                    style: TextStyle(
                      color: isDark
                          ? Colors.cyan.shade200
                          : Colors.cyan.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Performance
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  exam.performance ?? "Good",
                  style: TextStyle(
                    color: isDark
                        ? Colors.orange.shade200
                        : Colors.orange.shade800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),

          // 6. Actions
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Marks
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MarksGradesPage(examId: exam.id, exam: {}),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 14,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Marks",
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Score Card (Color Button)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showExamSummaryDialog(context, exam.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Score Card",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Download
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      try {
                        final data = await ExamsService.downloadExamReport(
                          exam.id,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Report downloaded (${(data.length / 1024).toStringAsFixed(2)} KB)",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to download: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            size: 14,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Download",
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
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

void _showExamSummaryDialog(BuildContext context, String examId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ExamSummaryDialog(examId: examId)),
  );
}
