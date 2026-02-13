class OutingModel {
  final int id;
  final String admno;
  final String studentName;
  final String outingType;
  final String outDate;
  final String outingTime;
  final String purpose;
  final String status;
  final String permission;
  final String branch;

  OutingModel({
    required this.id,
    required this.admno,
    required this.studentName,
    required this.outingType,
    required this.outDate,
    required this.outingTime,
    required this.purpose,
    required this.status,
    required this.permission,
    required this.branch,
  });

  factory OutingModel.fromJson(Map<String, dynamic> json) {
    return OutingModel(
      id: json['id'],
      admno: json['admno'] ?? '',
      studentName: json['student_name'] ?? '',
      outingType: json['outingtype'] ?? '',
      outDate: json['out_date'] ?? '',
      outingTime: json['outing_time'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? '',
      permission: json['permission'] ?? '',
      branch: json['branch'] ?? '',
    );
  }
}
