class OutingRecord {
  final DateTime date;
  final String outTime;
  final String inTime;
  final String purpose;
  final bool isHomePass;

  OutingRecord({
    required this.date,
    required this.outTime,
    required this.inTime,
    required this.purpose,
    required this.isHomePass,
  });
}
