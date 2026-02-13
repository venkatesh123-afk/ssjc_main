class FloorInchargeModel {
  final int id;
  final String name;

  FloorInchargeModel({required this.id, required this.name});

  factory FloorInchargeModel.fromJson(Map<String, dynamic> json) {
    return FloorInchargeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }
}
