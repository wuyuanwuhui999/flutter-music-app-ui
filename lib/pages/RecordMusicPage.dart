import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../common/constant.dart';
import '../model/MusicModel.dart';
import '../provider/PlayerMusicProvider.dart';
import '../router/index.dart';
import '../service/serverMethod.dart';
import '../theme/ThemeColors.dart';
import '../component/NavigatorTitleComponent.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import '../theme/ThemeSize.dart';
import '../theme/ThemeStyle.dart';
import '../utils/common.dart';

class RecordMusicPage extends StatefulWidget {
  const RecordMusicPage({super.key});

  @override
  RecordMusicPageState createState() => RecordMusicPageState();
}

class RecordMusicPageState extends State<RecordMusicPage> {
  EasyRefreshController easyRefreshController = EasyRefreshController();
  int pageNum = 1;
  int total = 0;
  List<MusicModel>musicList = [];

  @override
  void initState() {
    super.initState();
    useMusicList();
  }

  ///@author: wuwenqiang
  ///@description: 根据分类获取列表
  ///@date: 2024-02-28 22:20
  useMusicList() {
    getMusicRecordService(pageNum, PAGE_SIZE).then((value) {
      setState(() {
        total = value.total!;
        musicList =
            value.data.map((item) => MusicModel.fromJson(item)).toList();
      });
      easyRefreshController.finishLoad(success: true,noMore: musicList.length == total);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.colorBg,
        body: SafeArea(
        top: true,
        child:  SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const NavigatorTitleComponent(title: '最近听过的歌曲'),
              Expanded(
                  flex: 1,
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
                      if (pageNum * PAGE_SIZE < total) {
                        pageNum++;
                        useMusicList();
                      }else{
                        Fluttertoast.showToast(
                            msg: "已经到底了",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: ThemeSize.middleFontSize);
                      }
                    },
                    child: Padding(
                      padding: ThemeStyle.padding,
                      child: Container(
                        decoration: ThemeStyle.boxDecoration,
                        padding: ThemeStyle.padding,
                        child: Column(children:musicList.asMap().entries.map((entry) {
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: entry.key != 0 ? ThemeSize.containerPadding : 0),
                                entry.key != 0
                                    ? Divider(
                                    height: 1, color: ThemeColors.disableColor)
                                    : const SizedBox(),
                                SizedBox(
                                    height: entry.key != 0
                                        ? ThemeSize.containerPadding
                                        : 0),
                                Row(
                                  children: [
                                    ClipOval(
                                        child: Image.network(
                                          getMusicCover(entry.value.cover),
                                          width: ThemeSize.bigAvater,
                                          height: ThemeSize.bigAvater,
                                        )),
                                    SizedBox(width: ThemeSize.containerPadding),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(entry.value.songName),
                                          SizedBox(height: ThemeSize.smallMargin),
                                          Text("听过${entry.value.times}次",
                                              style: TextStyle(
                                                  color: ThemeColors.subTitle))
                                        ],
                                      ),
                                    ),
                                    InkWell(onTap: (){
                                      PlayerMusicProvider provider = Provider.of<PlayerMusicProvider>(context, listen: false);
                                      provider.insertMusic(entry.value,provider.playIndex);
                                      Routes.router.navigateTo(context, '/MusicPlayerPage');
                                    },child: Image.asset(
                                      "lib/assets/images/icon_music_play.png",
                                      width: ThemeSize.smallIcon,
                                      height: ThemeSize.smallIcon,
                                    ))
                                    ,
                                    SizedBox(width: ThemeSize.containerPadding * 2),
                                    Image.asset(
                                      "lib/assets/images/icon_music_menu.png",
                                      width: ThemeSize.smallIcon,
                                      height: ThemeSize.smallIcon,
                                    )
                                  ],
                                )
                              ]);
                        }).toList(),
                      ),
                    ),
                  )),
              ),
            ],
          ),
        ),));
}}