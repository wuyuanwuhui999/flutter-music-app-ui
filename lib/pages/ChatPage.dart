import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../model/AiModel.dart';
import '../service/serverMethod.dart';
import '../provider/UserInfoProvider.dart';
import '../model/UserInfoModel.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<AiModel> modelList = [];
  AiModel? activeModel;

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

  @override
  Widget build(BuildContext context) {
    UserInfoModel userInfoModel =
        Provider.of<UserInfoProvider>(context).userInfo;
    return Scaffold(
      backgroundColor: ThemeColors.colorBg,
      body: SafeArea(
          top: true,
          child: Container(
              child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
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
                            child: Image.asset(
                                'lib/assets/images/icon_menu.png',
                                width: ThemeSize.smallIcon,
                                height: ThemeSize.smallIcon),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ))),
    );
  }
}
