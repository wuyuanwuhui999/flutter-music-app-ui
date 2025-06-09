// md5 加密
import 'package:flutter/cupertino.dart';

import '../common/constant.dart';

String formatTime(String data) {
  // 获取当前时间对象
  DateTime now = DateTime.now();
  DateTime date = DateTime.parse(data);
  // 相差多少分钟
  int minutes = now.difference(date).inMinutes;
  if(minutes < 1){
    return '刚刚';
  }else if(minutes >= 1 && minutes < 60){
    return '$minutes分钟前';
  }else if(minutes >= 60 && minutes < 60*24){
    return '${(minutes/60).truncate()}小时前';
  }else if(minutes > 60 * 24 && minutes <  60 * 24 *30){
    return '${(minutes/60/24).truncate()}天前';
  }else if(minutes > 60 * 24 * 30 && minutes <  60 * 24 *30 *12){
    return '${(minutes/60 / 24 / 30).truncate()}个月前';
  }else{
    return data;
  }
}

///补零
String zeroFill(int i) {
return i >= 10 ? "$i" : "0$i";
}

///毫秒转成时分秒
String getDuration(int sec){
    int h = sec ~/  3600;
    int m = (sec % 3600) ~/ 60;
    int s = sec % 60;
    if(h > 0){
      return "${zeroFill(h)}:${zeroFill(m)}:${zeroFill(s)}";
    }
    return  "${zeroFill(m)}:${zeroFill(s)}";
}

String  getMusicCover (String cover) {
  return cover.contains('http') ? cover.replaceAll('{size}', '480') : HOST + cover;
}

enum Action { Ok, Cancel }

Future showCustomDialog(BuildContext context,Widget body,String name,Function ok) async {
  final action = await showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('修改$name'),
        content:body,
        actions: [
          CupertinoDialogAction(
            child: Text('确认'),
            onPressed: () {
              Navigator.pop(context, Action.Ok);
            },
          ),
          CupertinoDialogAction(
            child: Text('取消'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, Action.Cancel);
            },
          ),
        ],
      );
    },
  );

  switch (action) {
    case Action.Ok:
      ok();
      break;
    case Action.Cancel:
      break;
    default:
  }
}

// 时间格式化工具
String formatTimeAgo(String dateString) {
  final date = DateTime.parse(dateString);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) {
    return "刚刚";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes}分钟前";
  } else if (difference.inHours < 24) {
    return "${difference.inHours}小时前";
  } else if (difference.inDays < 30) {
    return "${difference.inDays}天前";
  } else if(difference.inDays < 365){
    final months = (difference.inDays / 30).floor();
    return "$months月前";
  }else{
    final years = (difference.inDays / 365).floor();
    return "$years年前";
  }
}