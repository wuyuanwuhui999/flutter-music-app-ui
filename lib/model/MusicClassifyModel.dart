class MusicClassifyModel {
  int id;// 分类id
  String classifyName; // 分类时间
  int? permission;// 权限
  int? classifyRank; // 分类排名
  String? cover;// 分类图标
  int? disabled;// 是否禁用
  String createTime;// 创建时间
  String updateTime;// 更新时间

  MusicClassifyModel({
    required this.id,
    required this.classifyName,
    this.permission,
    this.classifyRank,
    this.cover,
    this.disabled,
    required this.createTime,
    required this.updateTime
  });

  //工厂模式-用这种模式可以省略New关键字
  factory MusicClassifyModel.fromJson(dynamic json) {
    return MusicClassifyModel(
        id: _toInt(json["id"]) ?? 0,
        // 后端 getMusicCategory 返回的字段是 category（如"酷狗飙升榜"），
        // 不是 classifyName。原代码取 classifyName 得到 null，而该字段是
        // 必填 String，直接抛 "type 'Null' is not a subtype of type 'String'"，
        // 导致首页分类区整块空白。
        classifyName: json["classifyName"] ?? json["category"] ?? "",
        permission: _toInt(json["permission"]),
        classifyRank: _toInt(json["classifyRank"]),
        // 后端字段名是 img，不是 cover
        cover: json["cover"] ?? json["img"],
        disabled: _toInt(json["disabled"]),
        createTime: json["createTime"] ?? "",
        updateTime: json["updateTime"] ?? ""
    );
  }

  /// 宽松地把后端返回值转成 int?，兼容 "68" / 68 / null。
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "classifyName": classifyName,
      "permission": permission,
      "classifyRank": classifyRank,
      "disabled": disabled,
      "createTime": createTime,
      "updateTime": updateTime
    };
  }
}
