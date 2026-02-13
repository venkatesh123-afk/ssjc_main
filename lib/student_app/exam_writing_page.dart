import 'dart:async';
import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/exams_service.dart';

class ExamWritingPage extends StatefulWidget {
  final String examId;
  final String examName;

  const ExamWritingPage({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<ExamWritingPage> createState() => _ExamWritingPageState();
}

class _ExamWritingPageState extends State<ExamWritingPage> {
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;

  Timer? _timer;
  int _secondsElapsed = 0;

  final Map<int, String> _answers = {};
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String _formatTime(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ExamsService.getExamQuestions(widget.examId);

      List<dynamic> questions = [];

      if (data['data'] != null && data['data']['questions'] is List) {
        questions = data['data']['questions'];
      } else if (data['questions'] is List) {
        questions = data['questions'];
      } else if (data['exam'] != null && data['exam']['questions'] is List) {
        questions = data['exam']['questions'];
      }

      if (mounted) {
        setState(() {
          _questions = questions;
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

  Future<void> _saveCurrentAnswer({bool isReview = false}) async {
    if (_questions.isEmpty) return;

    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final q = _questions[_currentQuestionIndex];

    _answers[_currentQuestionIndex] = answer;

    final payload = {
      "exam_id": widget.examId,
      "question_id": q['id'] ?? q['question_id'],
      "section_id": q['section_id'] ?? 0,
      "answer": answer,
      "time_spent_total": _formatTime(_secondsElapsed),
      "is_review": isReview ? 1 : 0,
    };

    await ExamsService.saveAnswer(payload);
  }

  void _nextQuestion() async {
    await _saveCurrentAnswer();
    if (_currentQuestionIndex < _questions.length - 1) {
      if (mounted) {
        setState(() {
          _currentQuestionIndex++;
          _answerController.text = _answers[_currentQuestionIndex] ?? '';
        });
      }
    } else {
      _showFinishDialog();
    }
  }

  void _prevQuestion() async {
    await _saveCurrentAnswer();
    if (_currentQuestionIndex > 0) {
      if (mounted) {
        setState(() {
          _currentQuestionIndex--;
          _answerController.text = _answers[_currentQuestionIndex] ?? '';
        });
      }
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Finish Exam?'),
        content: const Text('Are you sure you want to submit your exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              _submitExam();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExam() async {
    setState(() => _isLoading = true);
    try {
      final success = await ExamsService.submitExam(widget.examId);
      if (success) {
        final summary = await ExamsService.getExamSummary(widget.examId);
        if (mounted) {
          _showSummaryDialog(summary['data'] ?? summary['result'] ?? summary);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit exam. Please try again.'),
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSummaryDialog(dynamic data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final result = data is Map ? data : {};
        return AlertDialog(
          title: const Text('Exam Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Total Marks', '${result['total_marks'] ?? 0}'),
              _summaryRow('Correct', '${result['correct'] ?? 0}'),
              _summaryRow('Wrong', '${result['wrong'] ?? 0}'),
              _summaryRow('Skipped', '${result['skipped'] ?? 0}'),
              const Divider(),
              _summaryRow(
                'Score',
                '${result['score_percentage'] ?? result['score'] ?? 0}%',
                isBold: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close summary dialog
                Navigator.pop(context); // Return to list
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.examName),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: $_errorMessage"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchQuestions,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : _questions.isEmpty
          ? const Center(child: Text("No questions found"))
          : Column(
              children: [
                // Question Palette
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _questions.length,
                    itemBuilder: (_, i) {
                      final isCurrent = i == _currentQuestionIndex;
                      final isAnswered = _answers.containsKey(i);

                      return GestureDetector(
                        onTap: () async {
                          await _saveCurrentAnswer();
                          if (mounted) {
                            setState(() {
                              _currentQuestionIndex = i;
                              _answerController.text = _answers[i] ?? '';
                            });
                          }
                        },
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? Colors.blue
                                : isAnswered
                                ? Colors.green
                                : cardColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color:
                                  i == _currentQuestionIndex ||
                                      _answers.containsKey(i)
                                  ? Colors.white
                                  : theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),

                // Question & Answer
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _questions[_currentQuestionIndex]['question'] ??
                              _questions[_currentQuestionIndex]['question_text'] ??
                              'Question not available',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Your Answer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _answerController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Type your answer...',
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentQuestionIndex > 0
                            ? _prevQuestion
                            : null,
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? 'Finish'
                              : 'Save & Next',
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
