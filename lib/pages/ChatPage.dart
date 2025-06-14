import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_music_app/component/MusicAvaterComponent.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../api/api.dart';
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
  AiModel? activeModel;
  int pageNum = 1;
  int total = 0;
  String prompt = "";
  bool loading = false;
  String token = "";
  String chatId = generateSecureID();
  WebSocketChannel? _channel;
  String message = "";
  StreamSubscription? _subscription; // 保存订阅对象
  String thinkContent = "";
  String responseContent = "";
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  List<ChatModel> chatList = [
    ChatModel(
        position: PositionEnum.left,
        thinkContent: "",
        responseContent: "你好，我是智能音乐助手小吴同学，请问有什么可以帮助您？")
  ];
  Map<String, List<List<ChatHistoryModel>>> timeAgoGroupMap = {};
  bool showHistory = false;
  EasyRefreshController easyRefreshController = EasyRefreshController();
  TextEditingController controller = TextEditingController(); // 姓名
  // 使用正则表达式进行匹配
  final RegExp startThinkPattern = RegExp(r'^<think>');
  final RegExp endThinkPattern = RegExp(r'</think>');
  bool showClearIcon = false;

  @override
  void initState() {
    LocalStorageUtils.getToken().then((res) {
      token = res;
    });

    getModelListService().then((res) {
      final models = res.data.map((item) => AiModel.fromJson(item)).toList();
      setState(() {
        modelList = models;
        activeModel = models.first; // 确保首次赋值
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // 1. 取消订阅（停止监听消息）
    _subscription?.cancel();

    // 2. 关闭连接
    _channel?.sink.close();

    // 3. 释放资源
    _subscription = null;
    _channel = null;

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

  /// 关闭 WebSocket 连接
  closeWebSocket() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (e) {
        debugPrint('关闭 WebSocket 时出错: $e');
      } finally {
        _channel = null;
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
    // 如果已有连接但未连接成功，先关闭旧连接
    if (_channel != null && _connectionStatus != ConnectionStatus.connected) {
      closeWebSocket();
    }

    _channel ??= IOWebSocketChannel.connect(
      "${HOST.replaceAll("http", "ws")}${servicePath['chatWs']}", // 免费测试服务器
      pingInterval: const Duration(seconds: 30), // 心跳检测
    );

    _subscription ??= _channel?.stream.listen((value) {
      message += value;
      setState(() {
        print(value);
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
    }, onError: (error) {
      setState(() {
        _connectionStatus = ConnectionStatus.error;
        loading = false;
        Fluttertoast.showToast(msg: "连接错误: $error");
      });
    }, onDone: () {
      setState(() {
        _connectionStatus = ConnectionStatus.disconnected;
        loading = false;
      });
    });
    chatId = chatId.isNotEmpty ? chatId : generateSecureID();
    Map<String, dynamic> payload = {
      "modelId": activeModel?.id,
      "token": token, // 替换为实际用户ID
      "chatId": chatId, // 替换为实际聊天ID
      "prompt": prompt,
      "files": [] // 如果需要上传文件，请根据实际情况调整
    };
    controller.text = "";
    setState(() {
      prompt = "";
    });
    _channel?.sink.add(json.encode(payload));
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
            child: Image.asset('lib/assets/images/icon_back.png',
                width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
          ),
          Expanded(
              child: Text(
            "当前接入模型：${activeModel?.modelName ?? ''}",
            textAlign: TextAlign.center,
          )),
          Opacity(
            opacity: ThemeSize.opacity,
            child: InkWell(
              child: Image.asset('lib/assets/images/icon_menu.png',
                  width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
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
    );
  }

  Widget buildChatList() {
    return Expanded(
        flex: 1,
        child: ListView(
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
                              alignment: WrapAlignment.end,
                              children: [
                                Container(
                                    padding: ThemeStyle.padding,
                                    decoration: ThemeStyle.boxDecoration,
                                    child: item.thinkContent != ""
                                        ? Column(
                                            children: [
                                              Text(
                                                item.thinkContent ?? "",
                                                style: const TextStyle(
                                                    color:
                                                        ThemeColors.subTitle),
                                              ),
                                              Text(item.responseContent ?? ""),
                                            ],
                                          )
                                        : Text(item.responseContent ?? ""))
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
              loading && (thinkContent != "" || responseContent != "")
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
                                alignment: WrapAlignment.end,
                                children: [
                                  Container(
                                    padding: ThemeStyle.padding,
                                    decoration: ThemeStyle.boxDecoration,
                                    child: Column(
                                      children: [
                                        thinkContent != ""
                                            ? Text(
                                                thinkContent,
                                                style: const TextStyle(
                                                    color: ThemeColors
                                                        .disableColor),
                                              )
                                            : const SizedBox(),
                                        Text(responseContent ?? ""),
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
              onTap: () {
                useWebsocket();
              },
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
        children: [buildHeaderWidget(), buildChatList(), buildInputWidget()],
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

  @override
  Widget build(BuildContext context) {
    UserInfoModel userInfoModel =
        Provider.of<UserInfoProvider>(context).userInfo;
    return Scaffold(
      backgroundColor: ThemeColors.colorBg,
      body: SafeArea(
          top: true,
          child: Stack(
            children: [buildChatWidget(), buildHistoryWidget()],
          )),
    );
  }
}
