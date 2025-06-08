
class AiModel {
  final int id;
  final String modelName;
  final String updateTime;
  final String createTime;

  AiModel({
    required this.id,
    required this.modelName,
    required this.updateTime,
    required this.createTime,
  });

  //工厂模式-用这种模式可以省略New关键字
  factory AiModel.fromJson(Map<String, dynamic> json){
    return AiModel(
        id: json["id"],
        modelName: json['modelName'],
        updateTime: json["updateTime"],
        createTime: json["createTime"]
    );
  }
}
