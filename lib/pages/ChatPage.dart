import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../model/AiModel.dart';
import '../model/ChatHistoryGroupModel.dart';
import '../model/ChatHistoryModel.dart';
import '../service/serverMethod.dart';
import '../provider/UserInfoProvider.dart';
import '../model/UserInfoModel.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';
import '../common/constant.dart';
import '../utils/common.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<AiModel> modelList = [];
  AiModel? activeModel;
  int pageNum = 1;
  int total = 0;
  Map<String, List<List<ChatHistoryModel>>> timeAgoGroupMap = {};
  bool showHistory = false;
  EasyRefreshController easyRefreshController = EasyRefreshController();

  @override
  void initState() {
    getModelListService().then((res) {
      final models = res.data.map((item) => AiModel.fromJson(item)).toList();
      setState(() {
        modelList = models;
        activeModel = models.first; // 确保首次赋值
      });
    });
    super.initState();
  }

  useHistory() {
    getChatHistoryService(pageNum, PAGE_SIZE).then((res) {
      List<dynamic> items =
          res.data.map((item) => ChatHistoryModel.fromJson(item)).toList();

      // // 计算时间差
      // for (var item in items) {
      //   item.timeAgo = formatTimeAgo(item.createTime);
      // }

      // 按chatId分组
      final chatIdGroup = <String, List<ChatHistoryModel>>{};
      for (var item in items) {
        chatIdGroup.putIfAbsent(item.chatId, () => []);
        chatIdGroup[item.chatId]!.add(item);
      }

      // 反转每个chatId组内的顺序
      for (var key in chatIdGroup.keys) {
        chatIdGroup[key] = chatIdGroup[key]!.reversed.toList();
      }

      // 按timeAgo分组
      final mTimeAgoGroupMap = <String, List<List<ChatHistoryModel>>>{};
      for (var chatIdList in chatIdGroup.values) {
        if (chatIdList.isNotEmpty) {
          final timeAgo = chatIdList.first.timeAgo ?? "";
          mTimeAgoGroupMap.putIfAbsent(timeAgo, () => []);
          mTimeAgoGroupMap[timeAgo]!.add(chatIdList);
        }
      }

      // 转换为最终分组结构
      final groups = mTimeAgoGroupMap.entries
          .map((entry) => ChatHistoryGroupModel(
                timeAgo: entry.key,
                list: entry.value,
              ))
          .toList();

      // 按时间倒序排序
      groups.sort((a, b) {
        // 这里简化排序逻辑，实际应根据时间值排序
        return b.timeAgo.compareTo(a.timeAgo);
      });
      setState(() {
        total = res.total!;
        timeAgoGroupMap = mTimeAgoGroupMap;
      });
    });
  }

  // 历史记录弹窗
  Widget buildHistoryWidget(){
    return showHistory
        ? Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      right: 0,
      child: Container(
          width: MediaQuery.of(context).size.width, // 使用实际屏幕宽度
          height: MediaQuery.of(context).size.height,
          child: Row(children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: Colors.white),
              child: EasyRefresh(
                  controller: easyRefreshController,
                  footer: ClassicalFooter(
                    loadText: '上拉加载',
                    loadReadyText: '准备加载',
                    loadingText: '加载中...',
                    loadedText: '加载完成',
                    noMoreText: '没有更多',
                    bgColor: Colors.transparent,
                    textColor: ThemeColors.disableColor,
                  ),
                  onLoad: () async {
                    pageNum++;
                    if (total <= pageNum * PAGE_SIZE) {
                      Fluttertoast.showToast(
                          msg: "已经到底了",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          fontSize: ThemeSize.middleFontSize);
                    } else {}
                  },
                  child: Container(
                      padding: ThemeStyle.padding,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:  timeAgoGroupMap.entries.toList().asMap().entries.map((indexedEntry) {
                      final index = indexedEntry.key;
                      final item = indexedEntry.value;
                      final isLast = index == timeAgoGroupMap.entries.length - 1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(item.key,style: TextStyle(color: ThemeColors.disableColor),),
                          ...item.value.map((bItem){
                            return Text(bItem.first.prompt);
                          }),
                          SizedBox(height: isLast?0:ThemeSize.containerPadding)
                        ],);
                    }).toList(),))
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: ThemeColors.popupMenuColor),
                height: MediaQuery.of(context).size.height,
              ),
            )
          ])),
    )
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    UserInfoModel userInfoModel =
        Provider.of<UserInfoProvider>(context).userInfo;
    return Scaffold(
      backgroundColor: ThemeColors.colorBg,
      body: SafeArea(
          top: true,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width, // 使用实际屏幕宽度
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ThemeSize.containerPadding),
                      decoration: BoxDecoration(color: ThemeColors.colorWhite),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: ThemeSize.opacity,
                            child: Image.asset(
                                'lib/assets/images/icon_back.png',
                                width: ThemeSize.smallIcon,
                                height: ThemeSize.smallIcon),
                          ),
                          Expanded(
                              child: Text(
                            "当前接入模型：${activeModel?.modelName ?? ''}",
                            textAlign: TextAlign.center,
                          )),
                          Opacity(
                            opacity: ThemeSize.opacity,
                            child: InkWell(
                              child: Image.asset(
                                  'lib/assets/images/icon_menu.png',
                                  width: ThemeSize.smallIcon,
                                  height: ThemeSize.smallIcon),
                              onTap: () {
                                setState(() {
                                  showHistory = true;
                                });
                                useHistory();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              buildHistoryWidget()
            ],
          )),
    );
  }
}
