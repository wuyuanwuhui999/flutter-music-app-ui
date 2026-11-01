class MusicAuthorModel {
  int id;//主键
  String authorId;// 歌手id
  String? authorName;// 歌手名称
  String? language;// 语言
  int? isPublish;// 是否发布
  String? avatar;// 头像
  int? type;// 类型
  String? country;// 国家
  String? birthday;// 生日
  int? identity;// 身份
  int? rank;// 排名
  String createTime;// 创建时间
  String updateTime;// 更新时间
  int total;// 歌曲总数
  int? isLike;

  MusicAuthorModel(
      {
        required this.id,
        required this.authorId,
        required this.authorName,
      this.language,
      this.isPublish,
      this.avatar,
      this.type,
      this.country,
      this.birthday,
      this.identity,
      this.rank,
        required this.createTime,
        required this.updateTime,
        required this.total,
        this.isLike
  });

  //工厂模式-用这种模式可以省略New关键字
  factory MusicAuthorModel.fromJson(dynamic json) {
    return MusicAuthorModel(
        id: _toInt(json["id"]) ?? 0,
        // 后端 getMusicAuthorListByCategoryId 返回的 authorId 是 int
        // （文档示例 "authorId":6051570），而字段是 String，直接赋值会抛
        // "type 'int' is not a subtype of type 'String'"，导致歌手列表整块空白。
        authorId: json["authorId"]?.toString() ?? "",
        authorName: json["authorName"],
        language: json["language"],
        isPublish: _toInt(json["isPublish"]),
        avatar: json["avatar"],
        type: _toInt(json["type"]),
        country: json["country"],
        birthday: json["birthday"],
        identity: _toInt(json["identity"]),
        rank: _toInt(json["rank"]),
        createTime: json["createTime"] ?? "",
        updateTime: json["updateTime"] ?? "",
        total: _toInt(json["total"]) ?? 0,
        isLike: _toInt(json["isLike"])
    );
  }

  /// 宽松地把后端返回值转成 int?，兼容 "6051570" / 6051570 / null。
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
      "authorId": authorId,
      "authorName": authorName,
      "language": language,
      "isPublish": isPublish,
      "avatar": avatar,
      "type": type,
      "country": country,
      "birthday": birthday,
      "identity": identity,
      "rank": rank,
      "createTime": createTime,
      "updateTime": updateTime,
      "total": total
    };
  }
}
