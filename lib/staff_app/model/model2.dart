class StudentModel {
  final int outingId; // API: id
  final String admNo; // API: admno
  final String name; // API: student_name
  final String status; // API: status
  final String permissionBy; // API: permission
  final String? image; // API: profile_pic

  StudentModel({
    required this.outingId,
    required this.admNo,
    required this.name,
    required this.status,
    required this.permissionBy,
    this.image,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      outingId: json['id'] ?? 0,
      admNo: json['admno']?.toString() ?? '',
      name: json['student_name'] ?? '',
      status: json['status'] ?? '',
      permissionBy: json['permission'] ?? '',
      image: json['profile_pic'],
    );
  }
}
