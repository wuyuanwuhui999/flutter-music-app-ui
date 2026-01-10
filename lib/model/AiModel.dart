
class AiModel {
  final String id;
  final String modelName;

  AiModel({
    required this.id,
    required this.modelName,
  });

  //工厂模式-用这种模式可以省略New关键字
  factory AiModel.fromJson(Map<String, dynamic> json){
    return AiModel(
        id: json["id"],
        modelName: json['modelName'],
    );
  }
}
