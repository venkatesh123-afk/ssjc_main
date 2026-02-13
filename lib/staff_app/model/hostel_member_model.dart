class HostelMember {
  final String admNo;
  final String name;
  final String room;

  HostelMember({
    required this.admNo,
    required this.name,
    required this.room,
  });

  factory HostelMember.fromJson(Map<String, dynamic> json) {
    return HostelMember(
      admNo: json['admno'] ?? '',
      name: json['student_name'] ?? '',
      room: json['room']?.toString() ?? '',
    );
  }
}
