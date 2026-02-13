class CourseModel {
  final int id;
  final String courseName;
  final int groupId;
  final int branchId;
  final int status;

  CourseModel({
    required this.id,
    required this.courseName,
    required this.groupId,
    required this.branchId,
    required this.status,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      courseName: json['coursename'] ?? '',
      groupId: json['group_id'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      status: json['status'] is String
          ? int.tryParse(json['status']) ?? 0
          : json['status'] ?? 0,
    );
  }
}
