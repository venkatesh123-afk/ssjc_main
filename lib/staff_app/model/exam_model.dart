class ExamModel {
  final int id;
  final String examName;
  final String category;
  final String marksEntry;
  final String grades;
  final String enableAttendance;
  final String attendanceMonths;
  final String branchName;
  final String status;

  ExamModel({
    required this.id,
    required this.examName,
    required this.category,
    required this.marksEntry,
    required this.grades,
    required this.enableAttendance,
    required this.attendanceMonths,
    required this.branchName,
    required this.status,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? 0,

      examName: json['examname']?.toString() ?? '',

      // category sometimes string, sometimes object/int
      category: json['category']?.toString() ?? '',

      // 🔑 force to string
      marksEntry: json['marksentry']?.toString() ?? '',
      grades: json['grades']?.toString() ?? '',
      enableAttendance: json['enable_attendance']?.toString() ?? '',
      attendanceMonths: json['attendance_months']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
