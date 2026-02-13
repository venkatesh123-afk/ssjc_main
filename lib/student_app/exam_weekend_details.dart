import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/exams_service.dart';

class ExamWeekendDetails extends StatefulWidget {
  final String examId;
  const ExamWeekendDetails({super.key, required this.examId});

  @override
  State<ExamWeekendDetails> createState() => _ExamWeekendDetailsState();
}

class _ExamWeekendDetailsState extends State<ExamWeekendDetails> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _examData = {};

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
  }

  Future<void> _fetchExamDetails() async {
    try {
      final data = await ExamsService.getExamDetails(widget.examId);
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
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
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

    // Parse API data
    final student = _examData['student'] ?? {};
    final exam = _examData['exam'] ?? {};
    final examName = exam['exam_name'] ?? 'Weekend Exam';
    final studentName = student['student_name'] ?? 'N/A';
    final branch = student['branch'] ?? 'N/A';
    final examId = exam['exam_id']?.toString() ?? widget.examId;
    final hallticket = student['hallticket'] ?? 'N/A';
    final group = student['group'] ?? 'N/A';

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
            color: colorScheme.surface,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 900,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Details: $examName',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// TAB
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 50,
                          height: 2,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// DETAILS TABLE
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          _row(theme, 'Student Name', studentName),
                          _divider(theme),
                          _row(theme, 'Hall Ticket', hallticket),
                          _divider(theme),
                          _row(theme, 'Branch', branch),
                          _divider(theme),
                          _row(theme, 'Group', group),
                          _divider(theme),
                          _row(theme, 'Exam Name', examName),
                          _divider(theme),
                          _row(
                            theme,
                            'Exam ID',
                            examId,
                            valueColor: const Color(0xFFEC4899),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// INSTRUCTIONS
                    Text(
                      'Instructions:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _bullet(
                      theme,
                      'Webcam must be enabled throughout the exam',
                    ),
                    _bullet(theme, 'Stable internet connection required'),
                    _bullet(theme, 'No external assistance allowed'),
                    _bullet(theme, 'Time limits will be strictly enforced'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// TABLE ROW
  static Widget _row(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    bool badge = false,
  }) {
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
          Container(width: 1, color: theme.dividerColor),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: badge
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF16A34A).withOpacity(0.2)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Enabled',
                        style: TextStyle(
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? colorScheme.onSurface,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _divider(ThemeData theme) {
    return Divider(height: 1, thickness: 1, color: theme.dividerColor);
  }

  static Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
