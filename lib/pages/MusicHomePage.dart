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

  // 首页“经典老歌”入口跳转的分类歌曲列表页参数
  static const int classicSongClassifyId = 2;
  static const String classicSongClassifyName = "经典老歌";

  // 首页“热门歌曲”入口跳转的分类歌曲列表页参数（对应后端“热门榜单”，id=1）
  static const int rankClassifyId = 1;
  static const String rankClassifyName = "热门歌曲";

  // 跳转到分类歌曲列表页，参数 {id, classifyName}
  void gotoClassifyList(int classifyId, String classifyName) {
    Map<String, dynamic> classifyParams = {
      "id": classifyId,
      "classifyName": classifyName
    };
    Routes.router.navigateTo(context,
        '/MusicClassifyListPage?musicClassifyModel=${Uri.encodeComponent(json.encode(classifyParams))}');
  }

  @override
  void initState() {
    super.initState();
    getMusicClassifyService().then((res) {
      allClassifies = (res.data as List?)?.map((item) {
            return MusicClassifyModel.fromJson(item);
          }).toList() ??
          [];
      if (!mounted) return;
      setState(() {
        // 原来写死 sublist(0, 4)：接口失败返回空列表时会抛
        // RangeError (end): Only valid value is 0: 4。
        currentClassifiesList
            .addAll(allClassifies.take(4).toList());
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
            left: ThemeSize.middleGap,
            right: ThemeSize.middleGap,
            top: ThemeSize.middleGap +
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
                  textColor: ThemeColors.gray,
                ),
                onLoad: () async {
                  if (currentClassifiesList.length == allClassifies.length) {
                    Fluttertoast.showToast(
                        msg: "已经到底了",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: ThemeColors.primary,
                        textColor: Colors.white,
                        fontSize: ThemeSize.middleFont);
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
        margin: EdgeInsets.only(bottom: ThemeSize.middleGap,top:ThemeSize.middleGap),
        width:
            MediaQuery.of(context).size.width - ThemeSize.middleGap * 2,
        padding: ThemeStyle.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MusicAvaterComponent(
                type: 'music',
                name: '',
                // userInfo 可能为 null（未登录或 Provider 尚未初始化），
                // 直接取 .avater 会抛 NoSuchMethodError 让整页红屏。
                avater: Provider.of<UserInfoProvider>(context).userInfo?.avater,
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
                                    color: ThemeColors.background,
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(
                                            ThemeSize.bigRadius)),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      left: ThemeSize.middleGap),
                                  child: Text(
                                    keyword,
                                    style: TextStyle(color: ThemeColors.grey),
                                  )));
                        }))),
            SizedBox(width: ThemeSize.middleGap),
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
            MediaQuery.of(context).size.width - ThemeSize.middleGap * 2,
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
            // 热门歌曲：跳转到分类歌曲列表页，参数 {id: 1, classifyName: "热门歌曲"}
            child: InkWell(
              onTap: () {
                gotoClassifyList(rankClassifyId, rankClassifyName);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("lib/assets/images/icon_music_rank.png",
                      width: ThemeSize.bigAvater, height: ThemeSize.bigAvater),
                  SizedBox(height: ThemeSize.smallMargin),
                  Text("热门歌曲")
                ],
              ),
            ),
            flex: 1,
          ),
          Expanded(
            // 经典老歌：跳转到分类歌曲列表页，参数 {id: 2, classifyName: "经典老歌"}
            child: InkWell(
              onTap: () {
                gotoClassifyList(classicSongClassifyId, classicSongClassifyName);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("lib/assets/images/icon_music_classics.png",
                      width: ThemeSize.bigAvater, height: ThemeSize.bigAvater),
                  SizedBox(height: ThemeSize.smallMargin),
                  Text("经典老歌")
                ],
              ),
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
            MediaQuery.of(context).size.width - ThemeSize.middleGap * 2,
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
                        color: ThemeColors.gray,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeColors.gray),
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
                    top: ThemeSize.middleGap,
                  ),
                  child: Row(
                    children: [
                      MusicAvaterComponent(
                          type: 'music',
                          name: '',
                          size: ThemeSize.middleAvater,
                          avater: musicItem.cover),
                      SizedBox(width: ThemeSize.middleGap),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(musicItem.songName,
                                style: TextStyle(
                                    fontSize: ThemeSize.middleFont)),
                            Text(
                              "${musicItem.authorName} - ${musicItem.albumName}",
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: ThemeColors.gray),
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
                      SizedBox(width: ThemeSize.middleGap),
                      Image.asset(
                        musicItem.isLike == 1
                            ? "lib/assets/images/icon_like_active.png"
                            : "lib/assets/images/icon_like.png",
                        width: ThemeSize.smallIcon,
                        height: ThemeSize.smallIcon,
                      ),
                      SizedBox(width: ThemeSize.middleGap),
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
                SizedBox(height: ThemeSize.middleGap),
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
                            SizedBox(height: ThemeSize.middleGap),
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
