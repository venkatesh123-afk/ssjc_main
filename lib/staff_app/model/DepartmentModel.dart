class DepartmentModel {
  final int id;
  final String department;
  final int branchId;
  final int status;
  final int sessionId;
  final String branchName;

  DepartmentModel({
    required this.id,
    required this.department,
    required this.branchId,
    required this.status,
    required this.sessionId,
    required this.branchName,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      department: json['department']?.toString() ?? "",
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id'].toString()) ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status'].toString()) ?? 0,
      sessionId: json['session_id'] is int
          ? json['session_id']
          : int.tryParse(json['session_id'].toString()) ?? 0,
      branchName: json['branch_name']?.toString() ?? "",
    );
  }
}
