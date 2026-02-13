class DesignationModel {
  final int id;
  final String designation;
  final int branchId;
  final String department;
  final int status;
  final int sessionId;
  final String branchName;

  DesignationModel({
    required this.id,
    required this.designation,
    required this.branchId,
    required this.department,
    required this.status,
    required this.sessionId,
    required this.branchName,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      designation: json['designation']?.toString() ?? "",
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id'].toString()) ?? 0,
      department: json['department']?.toString() ?? "",
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
