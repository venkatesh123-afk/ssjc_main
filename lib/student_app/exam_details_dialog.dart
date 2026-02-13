import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/exams_service.dart';

class ExamDetailsDialog extends StatefulWidget {
  final String examId;
  const ExamDetailsDialog({super.key, required this.examId});

  @override
  State<ExamDetailsDialog> createState() => _ExamDetailsDialogState();
}

class _ExamDetailsDialogState extends State<ExamDetailsDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _examData;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _fetchExamDetails();
  }

  Future<void> _fetchExamDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ExamsService.getExamDetails(widget.examId);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['success'] == true) {
            _studentData = response['student'] as Map<String, dynamic>?;
            _examData = response['exam'] as Map<String, dynamic>?;
          } else {
            _errorMessage = 'Failed to load exam details';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 24 : 40,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 250,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 3,
        color: Color(0xFF4F46E5),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _fetchExamDetails,
                child: const Text('Retry'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final String title = _examData?['exam_name'] ?? 'WEEKEND TEST-10';
    final String subject = _examData?['subject_name'] ?? 'EAMCET';
    final String branch = _studentData?['branch'] ?? 'SSJC-VIDHYA BHAVAN';
    final String examType = 'Online Exam';
    final String duration = _examData?['duration']?.toString() ?? '—';
    final String examId = _examData?['exam_id']?.toString() ?? '589';

    String dateStr = '—';
    if (_examData?['exam_date'] != null) {
      dateStr = _examData!['exam_date'];
      if (_examData?['exam_time'] != null) {
        dateStr += ' at ${_examData!['exam_time']}';
      }
    } else {
      dateStr = '2024-03-15 at 10:00 AM';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Details: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 22, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 18),

          /// TAB BAR (SIMULATED)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Details',
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 52,
                height: 2.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// DATA TABLE
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Column(
              children: [
                _row('Subject', subject),
                _divider(),
                _row('Branch', branch),
                _divider(),
                _row('Exam Type', examType),
                _divider(),
                _row('Duration', duration),
                _divider(),
                _row('Exam ID', examId, valueColor: const Color(0xFFEC4899)),
                _divider(),
                _row('Date', dateStr),
              ],
            ),
          ),
          const SizedBox(height: 32),

          /// INSTRUCTIONS
          const Text(
            'Instructions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8.0, right: 12.0),
                child: Icon(Icons.circle, size: 5, color: Colors.black87),
              ),
              Expanded(
                child: Text(
                  'Standard exam instructions apply.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ),
          ),
          Container(width: 1.5, color: const Color(0xFFE5E7EB)),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 0, thickness: 1.5, color: Color(0xFFE5E7EB));
  }
}
