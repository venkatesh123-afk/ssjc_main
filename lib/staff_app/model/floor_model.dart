class FloorModel {
  final int id;
  final String floorName;
  final int building;
  final int branchId;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  FloorModel({
    required this.id,
    required this.floorName,
    required this.building,
    required this.branchId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      floorName: json['floorname'] ?? '',
      building: json['building'] is int
          ? json['building']
          : int.parse(json['building'].toString()),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.parse(json['branch_id'].toString()),
      status: json['status'] is int
          ? json['status']
          : int.parse(json['status'].toString()),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
