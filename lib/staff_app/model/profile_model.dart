class ProfileModel {
  final String name;
  final String avatar;
  final String email;
  final String userLogin;
  final String father;
  final String gender;
  final String dob;
  final String doj;
  final String jobType;
  final String shift;
  final String designation;
  final String department;
  final String mobile;
  final String nationality;
  final String marital;
  final String religion;
  final String community;
  final String cAddress;
  final String pAddress;
  final String pan;
  final String aadhar;
  final String bankAcc;
  final String bank;
  final String ifsc;

  ProfileModel({
    required this.name,
    required this.avatar,
    required this.email,
    required this.userLogin,
    required this.father,
    required this.gender,
    required this.dob,
    required this.doj,
    required this.jobType,
    required this.shift,
    required this.designation,
    required this.department,
    required this.mobile,
    required this.nationality,
    required this.marital,
    required this.religion,
    required this.community,
    required this.cAddress,
    required this.pAddress,
    required this.pan,
    required this.aadhar,
    required this.bankAcc,
    required this.bank,
    required this.ifsc,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      email: json['email'] ?? '',
      userLogin: json['user_login'] ?? '',
      father: json['user_father'] ?? '',
      gender: json['user_gender'] ?? '',
      dob: json['user_dob'] ?? '',
      doj: json['user_doj'] ?? '',
      jobType: json['user_jobtype'] ?? '',
      shift: json['shift'] ?? '',
      designation: json['user_designation'] ?? '',
      department: json['user_department'] ?? '',
      mobile: json['user_mobile'] ?? '',
      nationality: json['user_nationality'] ?? '',
      marital: json['user_marital'] ?? '',
      religion: json['user_religion'] ?? '',
      community: json['user_community'] ?? '',
      cAddress: json['user_caddress'] ?? '',
      pAddress: json['user_paddress'] ?? '',
      pan: json['user_pan'] ?? '',
      aadhar: json['user_aadhar'] ?? '',
      bankAcc: json['user_bankacno'] ?? '',
      bank: json['user_bank'] ?? '',
      ifsc: json['user_ifsc'] ?? '',
    );
  }
}
