class StaffModel {
  final int id;
  final String designation;
  final String department;
  final String branchName;

  StaffModel({
    required this.id,
    required this.designation,
    required this.department,
    required this.branchName,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      branchName: json['branch_name'] ?? '',
    );
  }
}
