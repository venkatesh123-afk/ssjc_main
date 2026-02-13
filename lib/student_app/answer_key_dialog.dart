import 'dart:math';
import 'package:flutter/material.dart';

class AnswerKeyDialog extends StatefulWidget {
  final Map<String, dynamic> exam;

  const AnswerKeyDialog({super.key, required this.exam});

  @override
  State<AnswerKeyDialog> createState() => _AnswerKeyDialogState();
}

class _AnswerKeyDialogState extends State<AnswerKeyDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _objectiveQuestions = [
    {
      'qNo': 1,
      'type': 'MCQ',
      'yourAnswer': 'A',
      'correctAnswer': 'A',
      'isCorrect': true,
      'marks': '+5.00',
    },
  ];

  final List<Map<String, dynamic>> _fillBlankQuestions = [
    {
      'qNo': 1,
      'type': 'Fill Blank',
      'yourAnswer': '1',
      'correctAnswer': '1',
      'isCorrect': true,
      'marks': '+5.00',
    },
    {
      'qNo': 2,
      'type': 'Fill Blank',
      'yourAnswer': 'a',
      'correctAnswer': 'A',
      'isCorrect': true,
      'marks': '+5.00',
    },
  ];

  final List<Map<String, dynamic>> _trueFalseQuestions = [
    {
      'qNo': 1,
      'type': 'True/False',
      'yourAnswer': 'B',
      'correctAnswer': 'B',
      'isCorrect': true,
      'marks': '+5.00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 24 : 48,
      ),
      child: Material(
        elevation: 22,
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1100,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.vpn_key_outlined,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Answer Key',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detailed analysis of questions',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// TABS
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
                  indicatorColor: colorScheme.primary,
                  tabs: const [
                    Tab(text: "Objectives (1)"),
                    Tab(text: "Fill Blanks (2)"),
                    Tab(text: "True/False (1)"),
                    Tab(text: "Theory (0)"),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuestionTable(theme, _objectiveQuestions),
                      _buildQuestionTable(theme, _fillBlankQuestions),
                      _buildQuestionTable(theme, _trueFalseQuestions),
                      _buildEmptyState(colorScheme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTable(
    ThemeData theme,
    List<Map<String, dynamic>> questions,
  ) {
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double minWidth = 800;
        final double actualWidth = max(constraints.maxWidth, minWidth);

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: actualWidth,
                child: Column(
                  children: [
                    _buildTableHeader(theme),
                    ...questions.map((q) => _buildTableRow(theme, q)).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HEADER (NO DIVIDER BELOW)
  Widget _buildTableHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 80, child: Text("Q.No")),
          SizedBox(width: 150, child: Text("Type")),
          Expanded(child: Text("Your Answer")),
          Expanded(child: Text("Correct Answer")),
          SizedBox(width: 120, child: Text("Result")),
          SizedBox(
            width: 100,
            child: Text("Marks", textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ThemeData theme, Map<String, dynamic> question) {
    final colorScheme = theme.colorScheme;
    final isCorrect = question['isCorrect'] as bool;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isCorrect
            ? colorScheme.primary.withOpacity(0.05)
            : colorScheme.error.withOpacity(0.05),
      ),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text('${question['qNo']}')),
          SizedBox(width: 150, child: Text(question['type'])),
          Expanded(child: Text(question['yourAnswer'])),
          Expanded(child: Text(question['correctAnswer'])),
          SizedBox(width: 120, child: Text(isCorrect ? "Correct" : "Wrong")),
          SizedBox(
            width: 100,
            child: Text(question['marks'], textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            "No data",
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
