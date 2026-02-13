class HostelModel {
  final int id;
  final String buildingName;
  final String category;
  final String address;
  final int incharge;
  final int branchId;
  final int status;

  HostelModel({
    required this.id,
    required this.buildingName,
    required this.category,
    required this.address,
    required this.incharge,
    required this.branchId,
    required this.status,
  });

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    return HostelModel(
      id: json['id'] ?? 0,
      buildingName: json['buildingname'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      incharge: json['incharge'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      status: json['status'] ?? 0,
    );
  }
}
