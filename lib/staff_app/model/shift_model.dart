class ShiftModel {
  final int id;
  final String shiftName;
  final int status;

  ShiftModel({
    required this.id,
    required this.shiftName,
    required this.status,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      shiftName: json['shift_name'],
      status: json['status'],
    );
  }
}
