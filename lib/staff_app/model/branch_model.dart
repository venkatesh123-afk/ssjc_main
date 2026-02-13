class BranchModel {
  final int id;
  final String branchName;

  BranchModel({required this.id, required this.branchName});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(id: json['id'], branchName: json['branch_name']);
  }

  get branchId => null;

  void operator [](String other) {}
}
