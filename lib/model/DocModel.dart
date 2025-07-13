class DocModel{
  String id;// 文档id
  String appId; // 租户id
  String name; // 文档名称
  String ext; // 文档格式
  String userId;// 用户id
  String createTime;//创建时间
  String updateTime;// 更新时间
  DocModel({
    required this.id,
    required this.appId,
    required this.name,
    required this.ext,
    required this.userId,
    required this.createTime,
    required this.updateTime,
  });
  //工厂模式-用这种模式可以省略New关键字
  factory DocModel.fromJson(dynamic json){
    return DocModel(
        id:json['id'],
        appId:json['appId'],
        name:json['name'],
        ext:json['ext'],
        userId:json['userId'],
        createTime:json['createTime'],
        updateTime:json['updateTime']
    );
  }
}