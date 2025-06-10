import 'ChatHistoryModel.dart';

class ChatHistoryGroupModel {
  final String timeAgo;
  final List<List<ChatHistoryModel>> list;

  ChatHistoryGroupModel({required this.timeAgo, required this.list});
}
