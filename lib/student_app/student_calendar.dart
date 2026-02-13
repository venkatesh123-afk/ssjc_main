import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/student_app/student_app_bar.dart';
import 'package:student_app/student_app/services/calendar_service.dart';

class StudentCalendar extends StatefulWidget {
  final bool showAppBar;
  final bool isInline;

  const StudentCalendar({
    super.key,
    this.showAppBar = true,
    this.isInline = false,
  });

  @override
  State<StudentCalendar> createState() => _StudentCalendarState();
}

class _StudentCalendarState extends State<StudentCalendar> {
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final data = await CalendarService.getCalendarEvents();
      final Map<DateTime, List<CalendarEvent>> newEvents = {};

      for (var item in data) {
        // Adapt fields based on actual API response keys
        final String title = item['title'] ?? item['event_name'] ?? 'Event';
        final String? dateStr =
            item['start'] ?? item['date'] ?? item['event_date'];

        if (dateStr != null) {
          try {
            final date = DateTime.parse(dateStr);
            // Normalize to date only (no time)
            final key = DateTime(date.year, date.month, date.day);

            if (newEvents[key] == null) {
              newEvents[key] = [];
            }

            // Randomly assign or parse color if available
            final color = Colors.blue;

            newEvents[key]!.add(CalendarEvent(title, color));
          } catch (e) {
            debugPrint("Error parsing date: $dateStr");
          }
        }
      }

      if (mounted) {
        setState(() {
          _events = newEvents;
        });
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
      if (mounted) {
        setState(() {});
      }
    }
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysBefore = first.weekday % 7;
    first.subtract(Duration(days: daysBefore));
    final last = DateTime(month.year, month.month + 1, 0);
    final daysAfter = 7 - (last.weekday % 7) - 1;
    last.add(
      Duration(days: daysAfter == -1 ? 6 : daysAfter),
    ); // Fix if saturday

    // Easier approach: Just display 6 weeks (42 days) to cover all cases
    // Or just generating accurate days for the month grid
    // Logic: finding the first Sunday associated with this month block
    var start = first.subtract(
      Duration(days: first.weekday == 7 ? 0 : first.weekday),
    ); // Start from Sunday

    return List.generate(42, (index) => start.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    // Days logic
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;

    // 0 = Sunday, 1 = Monday... 6 = Saturday (Standard US calendar)
    // DateTime.weekday returns 1=Mon...7=Sun.
    // We want 0=Sun. So map 7->0.
    final firstWeekday = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;

    final totalSlots = firstWeekday + daysInMonth;
    (totalSlots / 7).ceil();

    final events = _getEventsForMonth();

    final mainColumn = Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Days of week
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _WeekDayLabel("S"),
                    _WeekDayLabel("M"),
                    _WeekDayLabel("T"),
                    _WeekDayLabel("W"),
                    _WeekDayLabel("T"),
                    _WeekDayLabel("F"),
                    _WeekDayLabel("S"),
                  ],
                ),
              ),

              // Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: totalSlots,
                itemBuilder: (context, index) {
                  if (index < firstWeekday || index >= totalSlots) {
                    return const SizedBox();
                  }

                  final day = index - firstWeekday + 1;
                  final date = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    day,
                  );
                  final isToday =
                      date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  final dayEvents = _events[date] ?? [];

                  return Column(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: isToday ? theme.primaryColor : null,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$day",
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      if (dayEvents.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayEvents.take(3).map((e) {
                            return Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: e.color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Events List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "EVENTS THIS MONTH",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Events List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.withOpacity(0.1),
            indent: 16,
            endIndent: 16,
            height: 1,
          ),
          itemBuilder: (context, index) {
            if (index < 0 || index >= events.length)
              return const SizedBox.shrink();
            final entry = events[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      "${entry.date.day}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: entry.event.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.event.title,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            (theme.textTheme.bodyLarge?.color ?? Colors.black)
                                .withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );

    if (widget.isInline) {
      return mainColumn;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar ? const StudentAppBar(title: "") : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.showAppBar)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Academic Calendar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: SingleChildScrollView(child: mainColumn)),
          ],
        ),
      ),
    );
  }

  // Helper to flatten events for the list
  List<EventEntry> _getEventsForMonth() {
    final List<EventEntry> list = [];
    _daysInMonth(_currentMonth); // Using the grid logic's month dates

    // Better: Iterate specific days of this month
    final lastDay = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    for (int i = 1; i <= lastDay; i++) {
      final d = DateTime(_currentMonth.year, _currentMonth.month, i);
      if (_events.containsKey(d)) {
        for (var e in _events[d]!) {
          list.add(EventEntry(d, e));
        }
      }
    }
    return list;
  }
}

class CalendarEvent {
  final String title;
  final Color color;
  CalendarEvent(this.title, this.color);
}

class EventEntry {
  final DateTime date;
  final CalendarEvent event;
  EventEntry(this.date, this.event);
}

class _WeekDayLabel extends StatelessWidget {
  final String label;
  const _WeekDayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
