class OutingInfo {
  final int total;
  final int pending;
  final int approved;
  final int notReported;

  OutingInfo({
    required this.total,
    required this.pending,
    required this.approved,
    required this.notReported,
  });

  factory OutingInfo.fromJson(Map<String, dynamic> json) {
    return OutingInfo(
      total: int.tryParse(json['total'].toString()) ?? 0,
      pending: int.tryParse(json['pending'].toString()) ?? 0,
      approved: int.tryParse(json['approved'].toString()) ?? 0,
      notReported: int.tryParse(json['not_reported'].toString()) ?? 0,
    );
  }
}
