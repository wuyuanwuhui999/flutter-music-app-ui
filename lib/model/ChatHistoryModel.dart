class ChatHistoryModel {
  final int id;
  final int modelId;
  final String userId;
  final String? files;
  final String chatId;
  final String prompt;
  final String content;
  final String createTime;
  final String? thinkContent;
  final String? responseContent;
  final String timeAgo;

  ChatHistoryModel({
    required this.id,
    required this.modelId,
    required this.userId,
    this.files,
    required this.chatId,
    required this.prompt,
    required this.content,
    required this.createTime,
    this.thinkContent,
    this.responseContent,
    required this.timeAgo,
  });

  //工厂模式-用这种模式可以省略New关键字
  factory ChatHistoryModel.fromJson(Map<String, dynamic> json){
    return ChatHistoryModel(
        id: json["id"],
        modelId: json['modelId'],
        userId: json["userId"],
        files:json["files"],
        chatId:json["chatId"],
        prompt:json["prompt"],
        content:json["content"],
        thinkContent:json["thinkContent"],
        responseContent:json["responseContent"],
        timeAgo:json["timeAgo"],
        createTime: json["createTime"]
    );
  }
}