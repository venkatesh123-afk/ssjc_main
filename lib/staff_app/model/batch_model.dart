class BatchModel {
  final int id;
  final String batchName;
  final int courseId;
  final int groupId;
  final int branchId;
  final int status;

  BatchModel({
    required this.id,
    required this.batchName,
    required this.courseId,
    required this.groupId,
    required this.branchId,
    required this.status,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      batchName: json['batch'], // 🔥 FIX IS HERE
      courseId: json['course_id'],
      groupId: json['group_id'],
      branchId: json['branch_id'],
      status: json['status'],
    );
  }
}
