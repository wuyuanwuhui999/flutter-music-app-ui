import '../enum/PositionEnum.dart';

class ChatModel {
  final PositionEnum position;
  final String? thinkContent;
  final String? responseContent;

  ChatModel({
    required this.position,
    this.thinkContent = "",
    this.responseContent = "",
  });

  //工厂模式-用这种模式可以省略New关键字
  factory ChatModel.fromJson(Map<String, dynamic> json){
    return ChatModel(
        position: json['position'],
        thinkContent: json["thinkContent"],
        responseContent:json["responseContent"]
    );
  }
}
