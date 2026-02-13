import 'package:flutter/material.dart';
import 'package:student_app/student_app/answer_key_dialog.dart';
import 'package:student_app/student_app/services/exams_service.dart';

class ExamSummaryDialog extends StatefulWidget {
  final String examId;
  const ExamSummaryDialog({super.key, required this.examId});

  @override
  State<ExamSummaryDialog> createState() => _ExamSummaryDialogState();
}

class _ExamSummaryDialogState extends State<ExamSummaryDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _examData = {};

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final data = await ExamsService.getExamSummary(widget.examId);
      if (mounted) {
        setState(() {
          _examData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Show loading or error state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Error: $_errorMessage",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      );
    }

    // Parse API Data
    final String studentName =
        _examData['student_name'] ?? _examData['student_full_name'] ?? 'N/A';
    final String examName =
        _examData['exam_name'] ?? _examData['title'] ?? 'Exam';
    final String submittedAt = _examData['submitted_at'] ?? 'N/A';

    final Map<String, dynamic> result =
        (_examData['result'] != null && _examData['result'] is Map)
        ? Map<String, dynamic>.from(_examData['result'])
        : {};

    final String totalMarks = (result['total_marks'] ?? 0).toString();
    final String totalTime =
        result['time_spent'] ?? result['total_time'] ?? '00:01:35';

    final String correct = (result['correct'] ?? 0).toString();
    final String wrong = (result['wrong'] ?? 0).toString();
    final String skipped = (result['skipped'] ?? 0).toString();

    final String scoreDisplay = totalMarks;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 32,
            vertical: isMobile ? 20 : 40,
          ),
          child: Material(
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            color: theme.cardColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2563EB).withOpacity(0.1)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Color(0xFF2563EB),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Exam Summary",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Overview of your performance",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.grey.shade300 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Info Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem("Student Name", studentName, isDark),
                          const SizedBox(height: 12),
                          _buildInfoItem("Exam Name", examName, isDark),
                          const SizedBox(height: 12),
                          _buildInfoItem("Submitted At", submittedAt, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stat Cards
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryStatCard(
                          "Total Marks",
                          scoreDisplay,
                          null,
                          const Color(0xFF2563EB),
                          isDark
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : const Color(0xFFF0F7FF),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryStatCard(
                          "Total Time",
                          totalTime,
                          Icons.history,
                          const Color(0xFF10B981),
                          isDark
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFFF0FDF4),
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Performance Tiles
                    Row(
                      children: [
                        _buildPerformanceTile(
                          "Correct",
                          correct,
                          Icons.check_circle_outline,
                          const Color(0xFF10B981),
                          isDark
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFFF0FDF4),
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildPerformanceTile(
                          "Wrong",
                          wrong,
                          Icons.cancel_outlined,
                          const Color(0xFFEF4444),
                          isDark
                              ? const Color(0xFFEF4444).withOpacity(0.1)
                              : const Color(0xFFFEF2F2),
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildPerformanceTile(
                          "Skipped",
                          skipped,
                          Icons.remove_circle_outline,
                          const Color(0xFFF59E0B),
                          isDark
                              ? const Color(0xFFF59E0B).withOpacity(0.1)
                              : const Color(0xFFFFFBEB),
                          theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart Container (Only if data exists)
                    if (_examData['time_analysis'] != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time Per Question (sec)",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              height: 150,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildBar(9, "Q1", 9, isDark),
                                  _buildBar(4, "Q2", 4, isDark),
                                  _buildBar(4, "Q3", 4, isDark),
                                  _buildBar(56, "Q4", 56, isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Footer Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnswerKeyDialog(exam: {}),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text("View Answer Key"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            foregroundColor: theme.textTheme.bodyMedium?.color,
                          ),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStatCard(
    String title,
    String value,
    IconData? icon,
    Color color,
    Color bgColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTile(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height, String label, int value, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5E9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
