class UserInfoModel{
  String? id;
  String? avater;
  String? birthday;
  String createDate;
  String? email;
  String? role;
  int? sex;
  String? telephone;
  String updateDate;
  String userAccount;
  String username;
  String? sign;
  String? region;
  int? disabled;
  int? permission;
  UserInfoModel({
    this.id,
    this.avater,
    this.birthday,
    required this.createDate,
    this.email,
    this.role,
    this.sex,
    this.telephone,
    required this.updateDate,
    required this.userAccount,
    required this.username,
    this.sign,
    this.region,
    this.disabled,
    this.permission
  });
  //工厂模式-用这种模式可以省略New关键字
  factory UserInfoModel.fromJson(dynamic json){
    return UserInfoModel(
      avater: json["avater"],
      birthday: json["birthday"],
      createDate: json["createDate"],
      email: json["email"],
      role: json["role"],
      sex: json["sex"],
      telephone: json["telephone"],
      updateDate: json["updateDate"],
      userAccount: json["userAccount"],
      username: json["username"],
      sign: json["sign"],
      region: json["region"],
      disabled:json["disabled"],
      permission:json["permission"]
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "avater": avater,
      "birthday": birthday,
      "createDate": createDate,
      "email": email,
      "role": role,
      "sex": sex,
      "telephone": telephone,
      "updateDate": updateDate,
      "userAccount": userAccount,
      "username": username,
      "sign": sign,
      "region": region
    };
  }

  dynamic get(String propertyName) {
    var _mapRep = toMap();
    if (_mapRep.containsKey(propertyName)) {
      return _mapRep[propertyName];
    }
    throw ArgumentError('propery not found');
  }
}