import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../model/MusicClassifyModel.dart';
import '../model/MusicAuthorModel.dart';
import '../model/MusicModel.dart';
import '../provider/PlayerMusicProvider.dart';
import '../service/serverMethod.dart';
import '../provider/UserInfoProvider.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';
import '../common/constant.dart';
import '../utils/LocalStorageUtils.dart';
import '../router/index.dart';
import '../component/MusicAvaterComponent.dart';

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  MusicHomePageState createState() => MusicHomePageState();
}

class MusicHomePageState extends State<MusicHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<MusicClassifyModel> currentClassifiesList = [];
  List<MusicClassifyModel> allClassifies = [];
  EasyRefreshController easyRefreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    getMusicClassifyService().then((res) {
      allClassifies = res.data.map((item) {
        return MusicClassifyModel.fromJson(item);
      }).toList();
      setState(() {
        currentClassifiesList.addAll(allClassifies.sublist(0, 4));
      });
    });
  }

  @override
  deactivate() {
    super.deactivate();
  }

  void _getCategoryItem() {
    if (currentClassifiesList.length < allClassifies.length) {
      setState(() {
        currentClassifiesList.add(allClassifies[currentClassifiesList.length]);
      });
      easyRefreshController.finishLoad(
          success: true,
          noMore: currentClassifiesList.length == allClassifies.length);
    }
  }

  List<Widget> buildCurrentClassifiesWidget() {
    List<Widget> currentClassifiesWidget = [];
    for (var element in currentClassifiesList) {
      currentClassifiesWidget.add(buildMusicModuleByClassifyIdWidget(element));
    }
    return currentClassifiesWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
            left: ThemeSize.containerPadding,
            right: ThemeSize.containerPadding,
            top: ThemeSize.containerPadding +
                MediaQuery.of(context).padding.top),
        child: Column(children: <Widget>[
          buildSearchWidget(),
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
                  if (currentClassifiesList.length == allClassifies.length) {
                    Fluttertoast.showToast(
                        msg: "已经到底了",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: ThemeSize.middleFontSize);
                  } else {
                    _getCategoryItem();
                  }
                },
                child: Column(
                  children: [
                    buildClassifyWidget(),
                    ...buildCurrentClassifiesWidget(),
                  ],
                ),
              ))
        ]));
  }

  Widget buildSearchWidget() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MusicAvaterComponent(
                type: 'music',
                name: '',
                avater: Provider.of<UserInfoProvider>(context).userInfo.avater,
                size: ThemeSize.middleAvater),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.only(left: ThemeSize.smallMargin),
                    child: FutureBuilder(
                        future: getKeyWordMusicService(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container();
                          }
                          var result = snapshot.data;
                          String keyword = "";
                          if (result != null && result.data != null) {
                            MusicModel musicModel =
                                MusicModel.fromJson(result.data);
                            PlayerMusicProvider musicProvider =
                                Provider.of<PlayerMusicProvider>(context);
                            if (musicProvider.musicModel == null) {
                              // 如果缓存中没有正在播放的歌曲，用推荐的歌曲作为正在播放的歌曲
                              musicProvider.setPlayMusic(musicModel, false);
                              LocalStorageUtils.setPlayMusic(musicModel);
                            }
                            keyword =
                                '${musicModel.authorName} - ${musicModel.songName}';
                          }
                          return InkWell(
                              onTap: () {
                                Routes.router.navigateTo(context,
                                    '/MusicSearchPage?keyword=${Uri.encodeComponent(keyword)}');
                              },
                              child: Container(
                                  height: ThemeSize.buttonHeight,
                                  //修饰黑色背景与圆角
                                  decoration: new BoxDecoration(
                                    color: ThemeColors.colorBg,
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(
                                            ThemeSize.bigRadius)),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      left: ThemeSize.containerPadding),
                                  child: Text(
                                    keyword,
                                    style: TextStyle(color: ThemeColors.grey),
                                  )));
                        }))),
            SizedBox(width: ThemeSize.containerPadding),
            InkWell(
              child: Image.asset("lib/assets/images/icon_ai.png",
                  width: ThemeSize.middleIcon, height: ThemeSize.middleIcon),
              onTap: () {
                Routes.router.navigateTo(context, '/ChatPage');
              },
            )
          ],
        ));
  }

  Widget buildClassifyWidget() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Row(children: [
          Expanded(
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("lib/assets/images/icon_music_singer.png",
                      width: ThemeSize.bigAvater, height: ThemeSize.bigAvater),
                  SizedBox(height: ThemeSize.smallMargin),
                  Text("歌手")
                ],
              ),
              onTap: () {
                Routes.router.navigateTo(context, '/MusicAuthorCategoryPage');
              },
            ),
            flex: 1,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Routes.router.navigateTo(context, '/MusicCategoryPage');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("lib/assets/images/icon_music_classify.png",
                      width: ThemeSize.bigAvater, height: ThemeSize.bigAvater),
                  SizedBox(height: ThemeSize.smallMargin),
                  Text("分类歌曲")
                ],
              ),
            ),
            flex: 1,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("lib/assets/images/icon_music_rank.png",
                  width: ThemeSize.bigAvater, height: ThemeSize.bigAvater),
              SizedBox(height: ThemeSize.smallMargin),
              Text("排行榜")
            ],
          )),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("lib/assets/images/icon_music_classics.png",
                    width: ThemeSize.bigAvater, height: ThemeSize.bigAvater),
                SizedBox(height: ThemeSize.smallMargin),
                Text("经典老歌")
              ],
            ),
            flex: 1,
          )
        ]));
  }

  // 获取分类音乐
  Widget buildMusicModuleByClassifyIdWidget(
      MusicClassifyModel musicClassifyModel) {
    return Container(
        key: ValueKey(musicClassifyModel.classifyName),
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("lib/assets/images/icon_down.png",
                    width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
                SizedBox(width: ThemeSize.smallMargin),
                Text(musicClassifyModel.classifyName),
                const Expanded(flex: 1, child: SizedBox()),
                InkWell(
                  child: Text(
                    "更多",
                    style: TextStyle(
                        color: ThemeColors.disableColor,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeColors.disableColor),
                  ),
                  onTap: () {
                    if (musicClassifyModel.classifyName == "推荐歌手") {
                      Routes.router
                          .navigateTo(context, '/MusicAuthorCategoryPage');
                    } else {
                      Routes.router.navigateTo(context,
                          '/MusicClassifyListPage?musicClassifyModel=${Uri.encodeComponent(json.encode(musicClassifyModel.toMap()))}');
                    }
                  },
                )
              ],
            ),
            musicClassifyModel.classifyName == "推荐歌手"
                ? buildMusicAuthorListWidget()
                : buildMusicListByClassifyId(musicClassifyModel)
          ],
        ));
  }

  // 获取音乐列表
  Widget buildMusicListByClassifyId(MusicClassifyModel classifyModel) {
    PlayerMusicProvider provider =
        Provider.of<PlayerMusicProvider>(context, listen: false);
    return FutureBuilder(
        future: getMusicListByClassifyIdService(classifyModel.id, 1, 3, 1),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            List<MusicModel> musicModelList = [];
            List<Widget> musicWidgetList = [];
            int i = -1;
            snapshot.data?.data.forEach((element) {
              int index = ++i;
              element['classifyId'] = classifyModel.id;
              element['pageNum'] = 1;
              element['pageSize'] = 20;
              element['isRedis'] = 1;
              MusicModel musicItem = MusicModel.fromJson(element);
              musicModelList.add(musicItem);
              musicWidgetList.add(Padding(
                  padding: EdgeInsets.only(
                    top: ThemeSize.containerPadding,
                  ),
                  child: Row(
                    children: [
                      MusicAvaterComponent(
                          type: 'music',
                          name: '',
                          size: ThemeSize.middleAvater,
                          avater: musicItem.cover),
                      SizedBox(width: ThemeSize.containerPadding),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(musicItem.songName,
                                style: TextStyle(
                                    fontSize: ThemeSize.middleFontSize)),
                            Text(
                              "${musicItem.authorName} - ${musicItem.albumName}",
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: ThemeColors.disableColor),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                          child: Image.asset(
                            provider.playing &&
                                    musicItem.id == provider.musicModel?.id
                                ? "lib/assets/images/icon_music_playing_grey.png"
                                : "lib/assets/images/icon_music_play.png",
                            width: ThemeSize.smallIcon,
                            height: ThemeSize.smallIcon,
                          ),
                          onTap: () async {
                            if (provider.classifyName !=
                                classifyModel.classifyName) {
                              await getMusicListByClassifyIdService(
                                      classifyModel.id,
                                      1,
                                      MAX_FAVORITE_NUMBER,
                                      1)
                                  .then((value) {
                                provider.setClassifyMusic(
                                    value.data
                                        .map((element) =>
                                            MusicModel.fromJson(element))
                                        .toList(),
                                    musicItem,
                                    index,
                                    classifyModel.classifyName);
                              });
                            } else if (musicItem.id !=
                                provider.musicModel?.id) {
                              provider.setPlayMusic(musicItem, true);
                            }
                            Routes.router
                                .navigateTo(context, '/MusicPlayerPage');
                          }),
                      SizedBox(width: ThemeSize.containerPadding),
                      Image.asset(
                        musicItem.isLike == 1
                            ? "lib/assets/images/icon_like_active.png"
                            : "lib/assets/images/icon_like.png",
                        width: ThemeSize.smallIcon,
                        height: ThemeSize.smallIcon,
                      ),
                      SizedBox(width: ThemeSize.containerPadding),
                      Image.asset(
                        "lib/assets/images/icon_music_menu.png",
                        width: ThemeSize.smallIcon,
                        height: ThemeSize.smallIcon,
                      )
                    ],
                  )));
            });
            return Column(children: musicWidgetList);
          }
        });
  }

  // 获取歌手列表
  Widget buildMusicAuthorListWidget() {
    return FutureBuilder(
        future: getMusicAuthorListByCategoryIdService(0, 1, 5),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            List authorsList = snapshot.data?.data as List;
            // 动态计算歌手头像大小
            return Column(
              children: [
                SizedBox(height: ThemeSize.containerPadding),
                Row(
                    children: authorsList.cast().map((item) {
                  MusicAuthorModel authorModel =
                      MusicAuthorModel.fromJson(item);
                  return Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Routes.router.navigateTo(context,
                              '/MusicAuthorListPage?authorModel=${Uri.encodeComponent(json.encode(item))}');
                        },
                        child: Column(
                          children: [
                            MusicAvaterComponent(
                                type: 'author',
                                avater: authorModel.avatar,
                                size: ThemeSize.middleAvater,
                                name: authorModel.authorName![0]),
                            SizedBox(height: ThemeSize.containerPadding),
                            Text(authorModel.authorName!)
                          ],
                        ),
                      ));
                }).toList())
              ],
            );
          }
        });
  }
}
