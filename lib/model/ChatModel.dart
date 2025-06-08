import '../enum/PositionEnum.dart';

class ChatModel {
  final String? text;
  final PositionEnum position;
  final String? thinkContent;
  final String? responseContent;
  final bool? start;

  ChatModel({
    this.text,
    required this.position,
    this.thinkContent,
    this.responseContent,
    this.start,
  });

}
