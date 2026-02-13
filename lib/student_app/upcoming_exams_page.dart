import 'package:flutter/material.dart';
import 'package:student_app/student_app/model/exam_item.dart';
import 'package:student_app/student_app/student_app_bar.dart';

class UpcomingExams extends StatefulWidget {
  const UpcomingExams({
    super.key,
    required MaterialColor color,
    required String date,
    required String title,
  });

  @override
  State<UpcomingExams> createState() => _UpcomingExamsState();
}

class _UpcomingExamsState extends State<UpcomingExams> {
  final int itemsPerPage = 10;
  int currentPage = 1;

  late final List<ExamModel> exams;

  @override
  void initState() {
    super.initState();

    exams = [
      ExamModel(
        title: "Mathematics Unit Test",
        date: "22nd July, 2024",
        color: Colors.blue,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Physics Monthly Assessment",
        date: "28th July, 2024",
        color: Colors.cyan,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Chemistry Laboratory Exam",
        date: "5th August, 2024",
        color: Colors.green,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "English Mid-Term Exam",
        date: "12th August, 2024",
        color: Colors.amber,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Computer Science Practical",
        date: "18th August, 2024",
        color: Colors.red,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Biology Theory Exam",
        date: "25th August, 2024",
        color: Colors.blue,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Social Studies Test",
        date: "2nd September, 2024",
        color: Colors.green,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Physics Practical",
        date: "9th September, 2024",
        color: Colors.cyan,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Mathematics Final",
        date: "16th September, 2024",
        color: Colors.amber,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Chemistry Theory",
        date: "23rd September, 2024",
        color: Colors.red,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),

      // ---------- PAGE 2 ----------
      ExamModel(
        title: "English Literature",
        date: "30th September, 2024",
        color: Colors.blue,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Computer Theory",
        date: "7th October, 2024",
        color: Colors.green,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Biology Practical",
        date: "14th October, 2024",
        color: Colors.cyan,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),

      ExamModel(
        title: "Social Project Submission",
        date: "21st October, 2024",
        color: Colors.amber,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
      ExamModel(
        title: "Final Semester Exams",
        date: "28th October, 2024",
        color: Colors.red,
        time: '',
        board: '',
        progress: 0,
        type: '',
        id: '',
        subject: '',
      ),
    ];
  }

  int get totalPages => (exams.length / itemsPerPage).ceil();

  List<ExamModel> get pageData {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, exams.length);
    return exams.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const StudentAppBar(title: "Upcoming Exams"),
      body: SafeArea(
        child: Column(
          children: [
            // ===== SCROLLABLE CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /* ---------------- HEADER ---------------- */
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "All Upcoming Exams (${exams.length})",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),

                    /* ---------------- LIST ---------------- */
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: List.generate(
                          pageData.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExamCard(item: pageData[index]),
                          ),
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),

                    /* ---------------- PAGINATION ---------------- */
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Page $currentPage of $totalPages",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Showing ${(currentPage - 1) * itemsPerPage + 1}"
                            "-${((currentPage - 1) * itemsPerPage + pageData.length)} "
                            "of ${exams.length} exams",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // PREVIOUS
                              OutlinedButton.icon(
                                onPressed: currentPage > 1
                                    ? () => setState(() => currentPage--)
                                    : null,
                                icon: const Icon(Icons.chevron_left, size: 18),
                                label: const Text("Previous"),
                              ),

                              // PAGE NUMBERS
                              Row(
                                children: List.generate(totalPages, (index) {
                                  final page = index + 1;
                                  final isActive = page == currentPage;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => currentPage = page),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFF2563EB)
                                              : Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF2563EB),
                                          ),
                                        ),
                                        child: Text(
                                          "$page",
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : const Color(0xFF2563EB),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              // NEXT
                              OutlinedButton.icon(
                                onPressed: currentPage < totalPages
                                    ? () => setState(() => currentPage++)
                                    : null,
                                label: const Text("Next"),
                                icon: const Icon(Icons.chevron_right, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== FIXED CLOSE BUTTON =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: Theme.of(context).cardColor,
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/* ================= CARD ================= */

class ExamCard extends StatelessWidget {
  final ExamModel item;

  const ExamCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
