import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_music_app/component/MusicAvaterComponent.dart';
import 'package:flutter_music_app/model/DocModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/api.dart';
import '../component/SelectDialogComponent.dart';
import '../component/TriangleComponent.dart';
import '../enum/ConnectionStatus.dart';
import '../enum/PositionEnum.dart';
import '../model/AiModel.dart';
import '../model/ChatHistoryGroupModel.dart';
import '../model/ChatHistoryModel.dart';
import '../model/ChatModel.dart';
import '../service/serverMethod.dart';
import '../provider/UserInfoProvider.dart';
import '../model/UserInfoModel.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';
import '../common/constant.dart';
import '../utils/LocalStorageUtils.dart';
import '../utils/common.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<AiModel> modelList = [];
  String activeModelName = "";
  int pageNum = 1;
  int total = 0;
  String prompt = "";
  bool loading = false;
  String token = "";
  String chatId = generateSecureID();
  WebSocketChannel? channel;
  String message = "";
  StreamSubscription? subscription; // 保存订阅对象
  String thinkContent = "";
  String responseContent = "";
  String type = "";
  bool showThink = false;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  List<ChatModel> chatList = [
    ChatModel(
        position: PositionEnum.left,
        thinkContent: "",
        responseContent: "你好，我是智能音乐助手小吴同学，请问有什么可以帮助您？"),
  ];
  Map<String, List<List<ChatHistoryModel>>> timeAgoGroupMap = {};
  bool showHistory = false;
  bool showMyDoc = false;
  List<DocModel> myDocList = [];
  EasyRefreshController easyRefreshController = EasyRefreshController();
  TextEditingController controller = TextEditingController(); // 姓名
  // 使用正则表达式进行匹配
  final RegExp startThinkPattern = RegExp(r'^<think>');
  final RegExp endThinkPattern = RegExp(r'</think>');
  bool showClearIcon = false;
  ScrollController scrollController = ScrollController();
  String language = "zh";

  @override
  void initState() {
    LocalStorageUtils.getToken().then((res) {
      token = res;
    });

    getModelListService().then((res) {
      final models = res.data.map((item) => AiModel.fromJson(item)).toList();
      setState(() {
        modelList = models;
        activeModelName = models.first.modelName; // 确保首次赋值
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    // 1. 取消订阅（停止监听消息）
    subscription?.cancel();

    // 2. 关闭连接
    channel?.sink.close();

    // 3. 释放资源
    subscription = null;
    channel = null;
    super.dispose(); // 最后调用父类dispose
  }

  useHistory() {
    getChatHistoryService(pageNum, PAGE_SIZE).then((res) {
      List<dynamic> items =
          res.data.map((item) => ChatHistoryModel.fromJson(item)).toList();

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

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 关闭 WebSocket 连接
  closeWebSocket() {
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }

    if (channel != null) {
      try {
        channel!.sink.close();
      } catch (e) {
        debugPrint('关闭 WebSocket 时出错: $e');
      } finally {
        channel = null;
      }
    }
    setState(() {
      _connectionStatus = ConnectionStatus.disconnected;
      loading = false;
    });
  }

  useWebsocket() {
    if (!prompt.isNotEmpty) {
      return Fluttertoast.showToast(
          msg: "请输入聊天内容",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: ThemeSize.middleFontSize);
    } else if (loading) {
      return;
    }
    setState(() {
      chatList.add(ChatModel(
          thinkContent: "",
          position: PositionEnum.right,
          responseContent: controller.text));
    });
    scrollToBottom();
    // 如果已有连接但未连接成功，先关闭旧连接
    channel = IOWebSocketChannel.connect(
      "${HOST.replaceAll("http", "ws")}${servicePath['chatWs']}", // 免费测试服务器
      pingInterval: const Duration(seconds: 30), // 心跳检测
    );

    subscription = channel?.stream.listen((value) {
      message += value;
      setState(() {
        loading = true;
        _connectionStatus = ConnectionStatus.connected;
        if (value != "[completed]") {
          // 使用正则提取内容
          // 检查当前消息是否符合条件
          if (startThinkPattern.hasMatch(message) &&
              endThinkPattern.hasMatch(message) &&
              !endThinkPattern.hasMatch(value)) {
            // 追加到响应内容
            responseContent += value;
          } else {
            // 追加到思考内容
            thinkContent += value;
          }
        } else {
          //对话已完成
          message = "";
          loading = false;
          chatList.add(ChatModel(
            responseContent: responseContent,
            thinkContent: thinkContent,
            position: PositionEnum.left,
          ));
          thinkContent = responseContent = "";
        }
      });
      scrollToBottom();
    }, onError: (error) {
      setState(() {
        _connectionStatus = ConnectionStatus.error;
        loading = false;
        Fluttertoast.showToast(msg: "连接错误: $error");
      });
    }, onDone: () {
      closeWebSocket();
    });
    chatId = chatId.isNotEmpty ? chatId : generateSecureID();
    Map<String, dynamic> payload = {
      "modelName": activeModelName,
      "token": token, // 替换为实际用户ID
      "chatId": chatId, // 替换为实际聊天ID
      "prompt": prompt,
      "type": type,
      "showThink": showThink,
      "language":language
    };
    controller.text = "";

    channel?.sink.add(json.encode(payload));
    setState(() {
      prompt = "";
      loading = true;
    });
  }

  useMyDocList() {
    getMyDocListService().then((res) {
      setState(() {
        myDocList = res.data.map((item) => DocModel.fromJson(item)).toList();
      });
    });
  }

  useTabModel() {
    BottomSelectionDialog.show(
      context: context,
      options: modelList.map((item) {
        return item.modelName;
      }).toList(),
      onTap: (selectedOption) {
        setState(() {
          activeModelName = selectedOption;
        });
      },
    );
  }

  // 头部
  Widget buildHeaderWidget() {
    return Container(
      padding: const EdgeInsets.all(ThemeSize.containerPadding),
      decoration: const BoxDecoration(color: ThemeColors.colorWhite),
      child: Row(
        children: [
          Opacity(
            opacity: ThemeSize.opacity,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Image.asset('lib/assets/images/icon_back.png',
                  width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
            ),
          ),
          Expanded(
              child: Text(
            "当前接入模型：${activeModelName}",
            textAlign: TextAlign.center,
          )),
          PopupMenuButton<String>(
            color: ThemeColors.popupMenuColor.withOpacity(1),
            child: Image.asset('lib/assets/images/icon_menu.png',
                width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
            onSelected: (String item) {
              if (item == "上传文档") {
              } else if (item == "我的文档") {
                setState(() {
                  showMyDoc = true;
                });
                useMyDocList();
              } else if (item == "会话记录") {
                setState(() {
                  showHistory = true;
                });
                useHistory();
              } else if (item == "切换模型") {
                useTabModel();
              }
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                    value: "上传文档",
                    child: Text(
                      "上传文档",
                      style: TextStyle(color: ThemeColors.colorWhite),
                    )),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem<String>(
                    value: "我的文档",
                    child: Text("我的文档",
                        style: TextStyle(color: ThemeColors.disableColor))),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem<String>(
                    value: "会话记录",
                    child: Text("会话记录",
                        style: TextStyle(color: ThemeColors.disableColor))),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem<String>(
                    value: "切换模型",
                    child: Text("切换模型",
                        style: TextStyle(color: ThemeColors.disableColor))),
              ];
            },
          )
        ],
      ),
    );
  }

  Widget buildChatList() {
    return Expanded(
        flex: 1,
        child: ListView(
            controller: scrollController, // 绑定控制器
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.only(
                bottom: ThemeSize.containerPadding,
                left: ThemeSize.containerPadding,
                right: ThemeSize.containerPadding),
            children: [
              ...chatList.map((item) {
                return Padding(
                    padding:
                        const EdgeInsets.only(top: ThemeSize.containerPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PositionEnum.left == item.position
                            ? Container(
                                margin: const EdgeInsets.only(
                                    top: ThemeSize.smallMargin),
                                child: Row(
                                  children: [
                                    Image.asset('lib/assets/images/icon_ai.png',
                                        width: ThemeSize.middleIcon,
                                        height: ThemeSize.middleIcon),
                                    const SizedBox(width: ThemeSize.miniMargin),
                                    const TriangleComponent(
                                        size: ThemeSize.miniIcon,
                                        color: Colors.white),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        Expanded(
                            flex: 1,
                            child: Wrap(
                              alignment: PositionEnum.left == item.position
                                  ? WrapAlignment.start
                                  : WrapAlignment.end,
                              children: [
                                Container(
                                    padding: ThemeStyle.padding,
                                    decoration: ThemeStyle.boxDecoration,
                                    child: Column(
                                      children: [
                                        item.thinkContent != ""
                                            ? Text(
                                                item.thinkContent ?? "",
                                                style: const TextStyle(
                                                    color:
                                                        ThemeColors.subTitle),
                                              )
                                            : const SizedBox(),
                                        Text(item.responseContent ?? ""),
                                      ],
                                    ))
                              ],
                            )),
                        PositionEnum.right == item.position
                            ? Container(
                                margin: const EdgeInsets.only(
                                    top: ThemeSize.smallMargin),
                                child: Row(
                                  children: [
                                    Transform.rotate(
                                      angle: pi, // 旋转-90度（π/2弧度）
                                      child: const TriangleComponent(
                                          size: ThemeSize.miniIcon,
                                          color: Colors.white),
                                    ),
                                    MusicAvaterComponent(
                                        type: 'music',
                                        name: '',
                                        avater: Provider.of<UserInfoProvider>(
                                                context)
                                            .userInfo
                                            .avater,
                                        size: ThemeSize.middleIcon)
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ));
              }),
              loading
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: ThemeSize.containerPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                top: ThemeSize.smallMargin),
                            child: Row(
                              children: [
                                Image.asset('lib/assets/images/icon_ai.png',
                                    width: ThemeSize.middleIcon,
                                    height: ThemeSize.middleIcon),
                                const SizedBox(width: ThemeSize.miniMargin),
                                const TriangleComponent(
                                    size: ThemeSize.miniIcon,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  Container(
                                    padding: ThemeStyle.padding,
                                    decoration: ThemeStyle.boxDecoration,
                                    child: Column(
                                      children: [
                                        Text(
                                          thinkContent.isEmpty
                                              ? "正在思考中"
                                              : thinkContent,
                                          style: const TextStyle(
                                              color: ThemeColors.disableColor),
                                        ),
                                        responseContent.isNotEmpty
                                            ? Text(responseContent)
                                            : const SizedBox(),
                                      ],
                                    ),
                                  )
                                ],
                              ))
                        ],
                      ))
                  : const SizedBox()
            ]));
  }

  Widget buildTypeWidget() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(ThemeSize.smallMargin),
          decoration: const BoxDecoration(color: ThemeColors.colorBg),
          child: Row(
            children: [
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showThink = !showThink;
                    });
                  },

                  ///圆角
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ThemeColors.colorWhite,
                    foregroundColor: ThemeColors.colorWhite,
                    side: BorderSide(
                        color:
                            showThink ? Colors.orange : ThemeColors.subTitle),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSize.bigRadius), // 圆角
                    ),
                  ),
                  child: Text(
                    '深度思考',
                    style: TextStyle(
                        fontSize: ThemeSize.middleFontSize,
                        color:
                            showThink ? Colors.orange : ThemeColors.subTitle),
                  )),
              const SizedBox(width: ThemeSize.containerPadding),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      type = type == "document" ? "" : "document";
                    });
                  },

                  ///圆角
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ThemeColors.colorWhite,
                    // 背景色（可选）
                    foregroundColor: ThemeColors.colorWhite,
                    // 文字颜色
                    side: BorderSide(
                        color: type == "document"
                            ? Colors.orange
                            : ThemeColors.subTitle),
                    // 设置边框颜色（这里是黑色）
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSize.bigRadius), // 圆角
                    ),
                  ),
                  child: Text(
                    '查询文档',
                    style: TextStyle(
                        fontSize: ThemeSize.middleFontSize,
                        color: type == "document"
                            ? Colors.orange
                            : ThemeColors.subTitle),
                  )),
              SizedBox(width: ThemeSize.containerPadding),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      type = type == "db" ? "" : "db";
                    });
                  },

                  ///圆角
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ThemeColors.colorWhite,
                    // 背景色（可选）
                    foregroundColor: ThemeColors.colorWhite,
                    // 文字颜色
                    side: BorderSide(
                        color: type == "db"
                            ? Colors.orange
                            : ThemeColors.subTitle),
                    // 设置边框颜色（这里是黑色）
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSize.bigRadius), // 圆角
                    ),
                  ),
                  child: Text(
                    '查询数据库',
                    style: TextStyle(
                        fontSize: ThemeSize.middleFontSize,
                        color: type == "db"
                            ? Colors.orange
                            : ThemeColors.subTitle),
                  )),
              SizedBox(width: ThemeSize.containerPadding),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      language = language == "zh" ? "en" : "zh";
                    });
                  },

                  ///圆角
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ThemeColors.colorWhite,
                    // 背景色（可选）
                    foregroundColor: ThemeColors.colorWhite,
                    // 文字颜色
                    side: BorderSide(
                        color: type == "db"
                            ? Colors.orange
                            : ThemeColors.subTitle),
                    // 设置边框颜色（这里是黑色）
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeSize.bigRadius), // 圆角
                    ),
                  ),
                  child: Row(children: [
                    Text(language == "zh" ? "中文" : "英文",
                        style: const TextStyle(
                            color: ThemeColors.mainTitle,
                            fontSize: ThemeSize.middleFontSize)),
                    const SizedBox(width: ThemeSize.miniMargin),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(language == "zh" ? 1.0 : -1.0, 1.0),
                      // 根据参数决定是否翻转
                      child: Image.asset(
                        "lib/assets/images/icon_switch.png",
                        width: ThemeSize.smallIcon,
                        height: ThemeSize.smallIcon,
                      ),
                    )
                  ]))
            ],
          ),
        ));
  }

  Widget buildInputWidget() {
    return Container(
        padding: ThemeStyle.padding,
        decoration: const BoxDecoration(color: ThemeColors.colorWhite),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                chatList = [];
                chatId = "";
              });
            },
            child: Image.asset("lib/assets/images/icon_chat.png",
                width: ThemeSize.middleIcon, height: ThemeSize.middleIcon),
          ),
          const SizedBox(width: ThemeSize.containerPadding),
          Expanded(
              flex: 1,
              child: Container(
                  height: ThemeSize.buttonHeight,
                  //修饰黑色背景与圆角
                  decoration: const BoxDecoration(
                    color: ThemeColors.colorBg,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ThemeSize.superRadius)),
                  ),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.only(left: ThemeSize.smallMargin * 2),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  prompt = value;
                                });
                              },
                              controller: controller,
                              cursorColor: ThemeColors.grey, //设置光标
                              decoration: const InputDecoration(
                                hintText: "有问题，尽管问",
                                hintStyle: TextStyle(
                                    fontSize: ThemeSize.smallFontSize,
                                    color: ThemeColors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    bottom: ThemeSize.smallMargin),
                              ))),
                      prompt != ""
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  controller.text = ""; //清除输入框的值
                                });
                              },
                              child: Image.asset(
                                "lib/assets/images/icon_clear.png",
                                height: ThemeSize.smallIcon,
                                width: ThemeSize.smallIcon,
                              ))
                          : const SizedBox(),
                      const SizedBox(width: ThemeSize.smallMargin)
                    ],
                  ))),
          const SizedBox(width: ThemeSize.containerPadding),
          GestureDetector(
              onTap:useWebsocket,
              child: Container(
                height: ThemeSize.buttonHeight,
                width: ThemeSize.buttonHeight,
                decoration: const BoxDecoration(
                  color: ThemeColors.colorBg,
                  borderRadius:
                      BorderRadius.all(Radius.circular(ThemeSize.superRadius)),
                ),
                child: Center(
                  child: loading
                      ? Container(
                          width: ThemeSize.miniIcon,
                          height: ThemeSize.miniIcon,
                          decoration: const BoxDecoration(
                              color: ThemeColors.disableColor),
                        )
                      : Image.asset("lib/assets/images/icon_send.png",
                          width: ThemeSize.smallIcon,
                          height: ThemeSize.smallIcon),
                ),
              ))
        ]));
  }

  // 对话列表
  Widget buildChatWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width, // 使用实际屏幕宽度
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          buildHeaderWidget(),
          buildChatList(),
          buildTypeWidget(),
          buildInputWidget()
        ],
      ),
    );
  }

  // 历史记录弹窗
  Widget buildHistoryWidget() {
    return showHistory
        ? Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: SizedBox(
                width: MediaQuery.of(context).size.width, // 使用实际屏幕宽度
                height: MediaQuery.of(context).size.height,
                child: Row(children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(color: Colors.white),
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
                              children: timeAgoGroupMap.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((indexedEntry) {
                                final index = indexedEntry.key;
                                final item = indexedEntry.value;
                                final isLast =
                                    index == timeAgoGroupMap.entries.length - 1;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.key,
                                      style: const TextStyle(
                                          color: ThemeColors.disableColor),
                                    ),
                                    ...item.value.map((bItem) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            chatList.clear();
                                            chatId = bItem.first.chatId;
                                            showHistory = false;
                                            for (var cItem in bItem) {
                                              chatList
                                                ..add(ChatModel(
                                                    position:
                                                        PositionEnum.right,
                                                    responseContent:
                                                        cItem.prompt))
                                                ..add(ChatModel(
                                                    position: PositionEnum.left,
                                                    thinkContent:
                                                        cItem.thinkContent,
                                                    responseContent:
                                                        cItem.responseContent));
                                            }
                                          });
                                        },
                                        child: Text(bItem.first.prompt),
                                      );
                                    }),
                                    SizedBox(
                                        height: isLast
                                            ? 0
                                            : ThemeSize.containerPadding)
                                  ],
                                );
                              }).toList(),
                            ))),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showHistory = false;
                        });
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(color: ThemeColors.popupMenuColor),
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  )
                ])),
          )
        : const SizedBox();
  }

  Widget buildDocListWidget() {
    return showMyDoc
        ? Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: SizedBox(
                width: MediaQuery.of(context).size.width, // 使用实际屏幕宽度
                height: MediaQuery.of(context).size.height,
                child: Row(children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: EasyRefresh(
                          child: Container(
                        padding: ThemeStyle.padding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: myDocList.asMap().entries.map((entry) {
                            return Container(
                                padding: EdgeInsets.only(
                                    bottom: entry.key != myDocList.length - 1
                                        ? ThemeSize.containerPadding
                                        : 0),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  width: entry.key != myDocList.length - 1
                                      ? 1
                                      : 0, //宽度
                                  color: entry.key != myDocList.length - 1
                                      ? ThemeColors.disableColor
                                      : ThemeColors.colorWhite, //边框颜色
                                ))),
                                child: Slidable(
                                    endActionPane: ActionPane(
                                      motion: ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            showCustomDialog(
                                                context,
                                                SizedBox(),
                                                '确定删除文档:${entry.value.name}',
                                                () {
                                              deleteMyDocumentService(
                                                      entry.value.id)
                                                  .then((res) {
                                                Fluttertoast.showToast(
                                                    msg: "删除成功",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: ThemeColors
                                                        .disableColor,
                                                    fontSize: ThemeSize
                                                        .middleFontSize);
                                                setState(() {
                                                  myDocList.removeAt(entry.key);
                                                });
                                              });
                                            });
                                          },
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: '删除',
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            formatTimeAgo(
                                                entry.value.createTime),
                                            style: TextStyle(
                                                color:
                                                    ThemeColors.disableColor),
                                          ),
                                          Text(entry.value.name)
                                        ])));
                          }).toList(),
                        ),
                      ))),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showMyDoc = false;
                        });
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(color: ThemeColors.popupMenuColor),
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  )
                ])),
          )
        : const SizedBox();
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
              buildChatWidget(),
              buildDocListWidget(),
              buildHistoryWidget()
            ],
          )),
    );
  }
}
