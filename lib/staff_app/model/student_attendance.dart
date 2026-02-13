/// ================= ATTENDANCE DAY KEYS =================
const List<String> attendanceDayKeys = [
  "one",
  "two",
  "three",
  "four",
  "five",
  "six",
  "seven",
  "eight",
  "nine",
  "ten",
  "oneone",
  "onetwo",
  "onethree",
  "onefour",
  "onefive",
  "onesix",
  "oneseven",
  "oneeight",
  "onenine",
  "twozero",
  "twoone",
  "twotwo",
  "twothree",
  "twofour",
  "twofive",
  "twosix",
  "twoseven",
  "twoeight",
  "twonine",
  "threezero",
  "threeone"
];

class StudentAttendance {
  final String sfname;
  final String slname;
  final String admno;

  /// key = day (one, two, ...)
  /// value = P / A / -
  final Map<String, String> attendance;

  StudentAttendance({
    required this.sfname,
    required this.slname,
    required this.admno,
    required this.attendance,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    final Map<String, String> attendanceMap = {};

    for (final day in attendanceDayKeys) {
      attendanceMap[day] = json[day]?.toString() ?? "-";
    }

    return StudentAttendance(
      sfname: json['sfname']?.toString() ?? '',
      slname: json['slname']?.toString() ?? '',
      admno: json['admno']?.toString() ?? '',
      attendance: attendanceMap,
    );
  }
}
