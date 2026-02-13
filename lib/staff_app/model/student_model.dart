class StudentModel {
  final String admNo;
  final int sid;
  final String sFirstName;
  final String sLastName;
  final String fatherName;
  final String mobile;
  final String status;
  final String branchName;
  final String groupName;
  final String batch;

  StudentModel({
    required this.admNo,
    required this.sid,
    required this.sFirstName,
    required this.sLastName,
    required this.fatherName,
    required this.mobile,
    required this.status,
    required this.branchName,
    required this.groupName,
    required this.batch,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      admNo: json['admno'] ?? '',
      sid: json['sid'] ?? 0,
      sFirstName: json['sfname'] ?? '',
      sLastName: json['slname'] ?? '',
      fatherName: json['fname'] ?? '',
      mobile: json['pmobile'] ?? '',
      status: json['status'] ?? '',
      branchName: json['branch_name'] ?? '',
      groupName: json['groupname'] ?? '',
      batch: json['batch'] ?? '',
    );
  }
}
