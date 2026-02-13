class FeeHeadModel {
  final int id;
  final String feeHead;
  final String feeGroup;
  final String admission;
  final int status;
  final int? branchId;
  final int? sessionId;
  final String? branchName;

  FeeHeadModel({
    required this.id,
    required this.feeHead,
    required this.feeGroup,
    required this.admission,
    required this.status,
    this.branchId,
    this.sessionId,
    this.branchName,
  });

  factory FeeHeadModel.fromJson(Map<String, dynamic> json) {
    return FeeHeadModel(
      id: json['id'],
      feeHead: json['feehead'],
      feeGroup: json['feegroup'],
      admission: json['admission'],
      status: json['status'],
      branchId: json['branch_id'],
      sessionId: json['session_id'],
      branchName: json['branch_name'],
    );
  }
}
