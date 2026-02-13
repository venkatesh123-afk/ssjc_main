class ExamCategory {
  final int id;
  final String category;
  final String branchName;

  ExamCategory({
    required this.id,
    required this.category,
    required this.branchName,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    return ExamCategory(
      id: json['id'],
      category: json['category'],
      branchName: json['branch_name'] ?? '',
    );
  }
}
