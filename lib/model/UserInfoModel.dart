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
      createDate: json["createDate"] ?? "",
      email: json["email"],
      role: json["role"],
      // 后端把 sex 以字符串返回（实测为 "0"），而字段是 int?，
      // 直接赋值会抛 "type 'String' is not a subtype of type 'int?'"。
      // 这个异常会中断登录流程，导致"提示登录成功但不跳转"。
      sex: _toInt(json["sex"]),
      telephone: json["telephone"],
      updateDate: json["updateDate"] ?? "",
      userAccount: json["userAccount"] ?? "",
      username: json["username"] ?? "",
      sign: json["sign"],
      region: json["region"],
      disabled: _toInt(json["disabled"]),
      permission: _toInt(json["permission"])
    );
  }

  /// 宽松地把后端返回值转成 int?，兼容 "0" / 0 / null / "" 等情况。
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
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