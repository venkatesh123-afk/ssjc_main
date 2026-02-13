class StudentProfile {
  final int? sid;
  final String? admno;
  final String? sfname;
  final String? slname;
  final String? fname;
  final String? mname;
  final String? dob;
  final String? gender;
  final String? caste;
  final String? subcaste;
  final String? aadharno;
  final String? mandal;
  final String? village;
  final String? address;
  final String? pmobile;
  final String? amobile;
  final String? tenthgpa;
  final String? lastschool;
  final String? lastschooladdress;
  final String? appno;
  final String? date;
  final int? branchId;
  final int? groupId;
  final int? batchId;
  final int? courseId;
  final String? admtype;
  final String? actualfee;
  final String? committedfee;
  final String? feestatus;
  final String? admstatus;
  final String? appstatus;
  final String? status;
  final String? photo;

  StudentProfile({
    this.sid,
    this.admno,
    this.sfname,
    this.slname,
    this.fname,
    this.mname,
    this.dob,
    this.gender,
    this.caste,
    this.subcaste,
    this.aadharno,
    this.mandal,
    this.village,
    this.address,
    this.pmobile,
    this.amobile,
    this.tenthgpa,
    this.lastschool,
    this.lastschooladdress,
    this.appno,
    this.date,
    this.branchId,
    this.groupId,
    this.batchId,
    this.courseId,
    this.admtype,
    this.actualfee,
    this.committedfee,
    this.feestatus,
    this.admstatus,
    this.appstatus,
    this.status,
    this.photo,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      sid: json['sid'],
      admno: json['admno']?.toString(),
      sfname: json['sfname'],
      slname: json['slname'],
      fname: json['fname'],
      mname: json['mname'],
      dob: json['dob'],
      gender: json['gender'],
      caste: json['caste'],
      subcaste: json['subcaste'],
      aadharno: json['aadharno'],
      mandal: json['mandal'],
      village: json['village'],
      address: json['address'],
      pmobile: json['pmobile'],
      amobile: json['amobile'],
      tenthgpa: json['tenthgpa']?.toString(),
      lastschool: json['lastschool'],
      lastschooladdress: json['lastschooladdress'],
      appno: json['appno']?.toString(),
      date: json['date'],
      branchId: json['branch_id'],
      groupId: json['group_id'],
      batchId: json['batch_id'],
      courseId: json['course_id'],
      admtype: json['admtype'],
      actualfee: json['actualfee']?.toString(),
      committedfee: json['committedfee']?.toString(),
      feestatus: json['feestatus'],
      admstatus: json['admstatus'],
      appstatus: json['appstatus'],
      status: json['status'],
      photo: json['photo'],
    );
  }
}
