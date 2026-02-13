class AttendanceRecord {
  final String batch;
  final int total;
  final int present;
  final int absent;

  AttendanceRecord({
    required this.batch,
    required this.total,
    required this.present,
    required this.absent,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      batch: json['batch']?.toString() ?? '',
      total: int.tryParse(json['Total']?.toString() ?? '0') ?? 0,
      present: int.tryParse(json['TotalPresent']?.toString() ?? '0') ?? 0,
      absent: int.tryParse(json['TotalAbsent']?.toString() ?? '0') ?? 0,
    );
  }
}
