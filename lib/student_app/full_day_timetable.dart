import 'package:flutter/material.dart';
import 'package:student_app/student_app/weekly_timetable.dart';

class FullDayTimetablePage extends StatelessWidget {
  const FullDayTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade300
                  : Colors.blue.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              "Full Day Time Table",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ScheduleCard(
                      subject: "Maths",
                      time: "09:00 - 09:45",
                      instructor: "Mr. Ramesh",
                    ),
                    _ScheduleCard(
                      subject: "Physics",
                      time: "09:50 - 10:35",
                      instructor: "Ms. Anjali",
                    ),
                    _ScheduleCard(
                      subject: "Chemistry",
                      time: "10:40 - 11:25",
                      instructor: "Dr. Suresh",
                    ),
                    _ScheduleCard(
                      subject: "English",
                      time: "11:30 - 12:15",
                      instructor: "Mrs. Kavitha",
                    ),
                    _ScheduleCard(
                      subject: "Lunch Break",
                      time: "12:15 - 01:00",
                      instructor: null,
                    ),
                    _ScheduleCard(
                      subject: "Biology",
                      time: "01:00 - 01:45",
                      instructor: "Mr. Prakash",
                    ),
                    _ScheduleCard(
                      subject: "Computer Science",
                      time: "01:50 - 02:35",
                      instructor: "Ms. Swathi",
                    ),
                    _ScheduleCard(
                      subject: "Social",
                      time: "02:40 - 03:25",
                      instructor: "Mr. Naresh",
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // View Weekly Time Table Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeeklyTimetablePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text(
                    "View Weekly Time Table",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
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
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String subject;
  final String time;
  final String? instructor;
  final bool isLast;

  const _ScheduleCard({
    required this.subject,
    required this.time,
    this.instructor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Row(
            children: [
              Icon(Icons.description, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Instructor
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                instructor ?? "-",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
