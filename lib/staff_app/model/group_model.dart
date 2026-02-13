class GroupModel {
  final int id;
  final String name;
  final int status;

  GroupModel({required this.id, required this.name, required this.status});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['groupname'],
      status: json['status'],
    );
  }

  String? get groupName => null;
}
