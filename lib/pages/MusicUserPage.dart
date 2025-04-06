import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_music_app/model/MusicAuthorModel.dart';
import 'package:provider/provider.dart';
import '../model/FavoriteDirectoryModel.dart';
import '../router/index.dart';
import '../service/serverMethod.dart';
import '../provider/UserInfoProvider.dart';
import '../model/UserInfoModel.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';
import '../common/constant.dart';
import '../model/MusicModel.dart';
import '../component/MusicTitleComponent.dart';

class MusicUserPage extends StatefulWidget {
  const MusicUserPage({super.key});

  @override
  _MusicUserPageState createState() => _MusicUserPageState();
}

class _MusicUserPageState extends State<MusicUserPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  List<MusicModel> playRecordList = []; // 播放记录列表
  List<MusicModel> musicLikeList = []; // 我喜欢的歌曲
  List<MusicAuthorModel> authorList = []; // 我喜欢的歌手
  List<FavoriteDirectoryModel> favoriteDirectoryList = []; // 收藏夹
  // 创建一个从0到360弧度的补间动画 v * 2 * π
  bool isFoldFavoriteDirectory = false; // 是否折叠我的收藏夹
  bool isFoldFavoriteMusic = false; // 是否折叠我喜欢的歌曲
  bool isFoldFavoriteAuthor = false; // 是否折叠我喜欢的歌手
  bool isFoldRecord = false; // 是否折叠播放记录
  int totalLikeMusic = 0; // 喜欢的歌曲总数
  int totalFavoriteAuthor = 0; // 喜欢的歌手总数
  int totalRecord = 0; // 播放记录总数

  @override
  void initState() {
    super.initState();
    useFavoriteDirectory();
    useMusicLike();
    useMusicRecord();
    useFavoriteAuthor();
  }

  ///@author: wuwenqiang
  ///@description: 喜欢的歌曲
  ///@date: 2025-03-05 21:25
  Future<void> useMusicLike() async {
    await getMusicLikeService(1, 5).then((value) {
      setState(() {
        totalLikeMusic = value.total!;
        musicLikeList =
            value.data.map((item) => MusicModel.fromJson(item)).toList();
      });
    });
  }

  ///@author: wuwenqiang
  ///@description: 播放记录
  ///@date: 2025-03-05 21:25
  Future<void> useMusicRecord() async {
    await getMusicRecordService(1, 10).then((value) {
      setState(() {
        totalRecord = value.total!;
        playRecordList =
            value.data.map((item) => MusicModel.fromJson(item)).toList();
      });
    });
  }

  ///@author: wuwenqiang
  ///@description: 播放记录
  ///@date: 2025-03-05 21:25
  Future<void> useFavoriteAuthor() async {
    await getFavoriteAuthorService(1, 5).then((value) {
      setState(() {
        totalFavoriteAuthor = value.total!;
        authorList =
            value.data.map((item) => MusicAuthorModel.fromJson(item)).toList();
      });
    });
  }

  Future<void> useFavoriteDirectory() async {
    await getFavoriteDirectoryService(0).then((value) {
      setState(() {
        favoriteDirectoryList = value.data
            .map((item) => FavoriteDirectoryModel.fromJson(item))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).padding.top + ThemeSize.containerPadding),
      buildUserInfoWidget(),
      buildFavoriteDirectoryWidget(),
      buildMusicLikeWidget(),
      buildFavoriteAuthorWidget(),
      buildRecordList()
    ]));
  }

  // 用户模块
  Widget buildUserInfoWidget() {
    UserInfoModel userInfo = Provider.of<UserInfoProvider>(context).userInfo;
    return Container(
      decoration: ThemeStyle.boxDecoration,
      margin: ThemeStyle.margin,
      width: MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
      padding: ThemeStyle.padding,
      child: Row(
        children: [
          ClipOval(
              child: userInfo.avater != null
                  ? Image.network(
                      //从全局的provider中获取用户信息
                      "$HOST${userInfo.avater}",
                      height: ThemeSize.bigAvater,
                      width: ThemeSize.bigAvater,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "lib/assets/images/default_avater.png",
                      width: ThemeSize.middleIcon,
                      height: ThemeSize.middleIcon,
                    )),
          SizedBox(width: ThemeSize.containerPadding),
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userInfo.username,
                      style: TextStyle(fontSize: ThemeSize.bigFontSize)),
                  SizedBox(height: ThemeSize.smallMargin),
                  Text(userInfo.sign ?? "",
                      style: TextStyle(color: ThemeColors.subTitle))
                ],
              )),
          InkWell(
            onTap: () {
              Routes.router.navigateTo(context, '/UserPage');
            },
            child: Image.asset("lib/assets/images/icon_edit.png",
                width: ThemeSize.middleIcon, height: ThemeSize.middleIcon),
          )
        ],
      ),
    );
  }

  Widget buildFavoriteDirectoryWidget() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MusicTitleComponent(
                onFold: (isFold) {
                  setState(() {
                    isFoldFavoriteDirectory = isFold;
                  });
                },
                title: "我的收藏夹",
                operateWidget: Row(
                  children: [
                    Image.asset("lib/assets/images/icon_add.png",
                        width: ThemeSize.smallIcon,
                        color: ThemeColors.disableColor,
                        colorBlendMode: BlendMode.srcIn,
                        height: ThemeSize.smallIcon),
                    SizedBox(width: ThemeSize.containerPadding),
                    InkWell(
                        onTap: () async {
                          EasyLoading.show();
                          await useFavoriteDirectory();
                          EasyLoading.dismiss();
                        },
                        child: Image.asset("lib/assets/images/icon_refresh.png",
                            width: ThemeSize.smallIcon,
                            color: ThemeColors.disableColor,
                            colorBlendMode: BlendMode.srcIn,
                            height: ThemeSize.smallIcon))
                  ],
                )),
            Offstage(
              offstage: isFoldFavoriteDirectory,
              child: Column(
                  children: favoriteDirectoryList.asMap().entries.map((entry) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ThemeSize.containerPadding),
                      InkWell(
                        child: Row(
                          children: [
                            entry.value.cover != null
                                ? ClipOval(
                                    child: Image.network(
                                    "$HOST${entry.value.cover}",
                                    width: ThemeSize.bigAvater,
                                    height: ThemeSize.bigAvater,
                                  ))
                                : Container(
                                    width: ThemeSize.bigAvater,
                                    height: ThemeSize.bigAvater,
                                    //超出部分，可裁剪
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: ThemeColors.colorBg,
                                      borderRadius: BorderRadius.circular(
                                          ThemeSize.bigAvater),
                                    ),
                                    child: Center(
                                        child: Text(
                                      entry.value.name.substring(0, 1),
                                      style: TextStyle(
                                          fontSize: ThemeSize.bigFontSize),
                                    ))),
                            SizedBox(width: ThemeSize.containerPadding),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.value.name),
                                  SizedBox(height: ThemeSize.smallMargin),
                                  Text("${entry.value.total}首",
                                      style: TextStyle(
                                          color: ThemeColors.subTitle))
                                ],
                              ),
                            ),
                            Image.asset(
                              "lib/assets/images/icon_music_play.png",
                              width: ThemeSize.smallIcon,
                              height: ThemeSize.smallIcon,
                            ),
                            SizedBox(width: ThemeSize.containerPadding * 2),
                            SizedBox(width: ThemeSize.containerPadding * 2),
                            Image.asset(
                              "lib/assets/images/icon_music_menu.png",
                              width: ThemeSize.smallIcon,
                              height: ThemeSize.smallIcon,
                            )
                          ],
                        ),
                        onTap: () {
                          Routes.router.navigateTo(context,
                              '/MusicFavoriteListPage?favoriteDirectoryModel=${Uri.encodeComponent(FavoriteDirectoryModel.stringify(entry.value))}');
                        },
                      )
                    ]);
              }).toList()),
            )
          ],
        ));
  }

  // 我喜欢的歌曲
  Widget buildMusicLikeWidget() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MusicTitleComponent(
                onFold: (isFold) {
                  setState(() {
                    isFoldFavoriteMusic = isFold;
                  });
                },
                title: "我喜欢的歌曲",
                operateWidget: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        EasyLoading.show();
                        await useMusicLike();
                        EasyLoading.dismiss();
                      },
                      child: Image.asset("lib/assets/images/icon_refresh.png",
                          width: ThemeSize.smallIcon,
                          color: ThemeColors.disableColor,
                          colorBlendMode: BlendMode.srcIn,
                          height: ThemeSize.smallIcon),
                    ),
                    SizedBox(
                        width: totalLikeMusic > 5
                            ? ThemeSize.containerPadding
                            : 0),
                    totalLikeMusic > 0
                        ? Text("更多",
                            style: TextStyle(
                                color: ThemeColors.disableColor,
                                decoration: TextDecoration.underline,
                                decorationColor: ThemeColors.disableColor))
                        : const SizedBox()
                  ],
                )),
            Offstage(
                offstage: isFoldFavoriteMusic,
                child: Column(
                  children: musicLikeList.asMap().entries.map((entry) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ThemeSize.containerPadding),
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
                                HOST + entry.value.cover,
                                width: ThemeSize.bigAvater,
                                height: ThemeSize.bigAvater,
                              )),
                              SizedBox(width: ThemeSize.containerPadding),
                              Expanded(
                                flex: 1,
                                child: Text(entry.value.songName),
                              ),
                              Image.asset(
                                "lib/assets/images/icon_music_play.png",
                                width: ThemeSize.smallIcon,
                                height: ThemeSize.smallIcon,
                              ),
                              SizedBox(width: ThemeSize.containerPadding * 2),
                              Image.asset(
                                "lib/assets/images/icon_delete.png",
                                width: ThemeSize.smallIcon,
                                height: ThemeSize.smallIcon,
                              ),
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
                ))
          ],
        ));
  }

  // 我关注的歌手
  Widget buildFavoriteAuthorWidget() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MusicTitleComponent(
              onFold: (bool isFold) {
                setState(() {
                  isFoldFavoriteAuthor = isFold;
                });
              },
              title: "我关注的歌手",
              operateWidget: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      EasyLoading.show();
                      await useFavoriteAuthor();
                      EasyLoading.dismiss();
                    },
                    child: Image.asset("lib/assets/images/icon_refresh.png",
                        width: ThemeSize.smallIcon,
                        color: ThemeColors.disableColor,
                        colorBlendMode: BlendMode.srcIn,
                        height: ThemeSize.smallIcon),
                  ),
                  SizedBox(width: totalFavoriteAuthor > 5 ? ThemeSize.containerPadding : 0),
                  totalFavoriteAuthor > 5 ? Text("更多",
                      style: TextStyle(
                          color: ThemeColors.disableColor,
                          decoration: TextDecoration.underline,
                          decorationColor: ThemeColors.disableColor)) : const SizedBox()
                ],
              )),
          Offstage(
              offstage: isFoldFavoriteAuthor,
              child: Column(
                  children: authorList.asMap().entries.map((entry) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ThemeSize.containerPadding),
                      entry.key != 0
                          ? Divider(height: 1, color: ThemeColors.disableColor)
                          : const SizedBox(),
                      SizedBox(
                          height:
                              entry.key != 0 ? ThemeSize.containerPadding : 0),
                      Row(
                        children: [
                          entry.value.avatar != null
                              ? ClipOval(
                                  child: Image.network(
                                  entry.value.avatar!.contains("http")
                                      ? entry.value.avatar!
                                          .replaceAll("{size}", "240")
                                      : "$HOST${entry.value.avatar}",
                                  width: ThemeSize.bigAvater,
                                  height: ThemeSize.bigAvater,
                                ))
                              : Container(
                                  width: ThemeSize.bigAvater,
                                  height: ThemeSize.bigAvater,
                                  //超出部分，可裁剪
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: ThemeColors.colorBg,
                                    borderRadius: BorderRadius.circular(
                                        ThemeSize.bigAvater),
                                  ),
                                  child: Center(
                                      child: Text(
                                    entry.value.authorName!.substring(0, 1),
                                    style: TextStyle(
                                        fontSize: ThemeSize.bigFontSize),
                                  ))),
                          SizedBox(width: ThemeSize.containerPadding),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.value.authorName!),
                                SizedBox(height: ThemeSize.smallMargin),
                                Text("${entry.value.total}首",
                                    style:
                                        TextStyle(color: ThemeColors.subTitle))
                              ],
                            ),
                          ),
                          Image.asset(
                            "lib/assets/images/icon_music_play.png",
                            width: ThemeSize.smallIcon,
                            height: ThemeSize.smallIcon,
                          ),
                          SizedBox(width: ThemeSize.containerPadding * 2),
                          Image.asset(
                            "lib/assets/images/icon_delete.png",
                            width: ThemeSize.smallIcon,
                            height: ThemeSize.smallIcon,
                          ),
                          SizedBox(width: ThemeSize.containerPadding * 2),
                          Image.asset(
                            "lib/assets/images/icon_music_menu.png",
                            width: ThemeSize.smallIcon,
                            height: ThemeSize.smallIcon,
                          )
                        ],
                      )
                    ]);
              }).toList()))
        ]));
  }

  // 最近播放的歌曲
  Widget buildRecordList() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.containerPadding * 2,
        padding: ThemeStyle.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MusicTitleComponent(
                onFold: (bool isFold) {
                  setState(() {
                    isFoldRecord = isFold;
                  });
                },
                title: "我最近播放的歌曲",
                operateWidget: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        EasyLoading.show();
                        await useMusicRecord();
                        EasyLoading.dismiss();
                      },
                      child: Image.asset("lib/assets/images/icon_refresh.png",
                          width: ThemeSize.smallIcon,
                          colorBlendMode: BlendMode.srcIn,
                          color: ThemeColors.disableColor,
                          height: ThemeSize.smallIcon),
                    ),
                    SizedBox(
                        width:
                            totalRecord > 5 ? ThemeSize.containerPadding : 0),
                    totalRecord > 10 ? Text("更多",
                        style: TextStyle(
                            color: ThemeColors.disableColor,
                            decoration: TextDecoration.underline,
                            decorationColor: ThemeColors.disableColor)) : const SizedBox()
                  ],
                )),
            Offstage(
              offstage: isFoldRecord,
              child: Column(
                children: playRecordList.asMap().entries.map((entry) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ThemeSize.containerPadding),
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
                              HOST + entry.value.cover,
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
                            Image.asset(
                              "lib/assets/images/icon_music_play.png",
                              width: ThemeSize.smallIcon,
                              height: ThemeSize.smallIcon,
                            ),
                            SizedBox(width: ThemeSize.containerPadding * 2),
                            Image.asset(
                              "lib/assets/images/icon_delete.png",
                              width: ThemeSize.smallIcon,
                              height: ThemeSize.smallIcon,
                            ),
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
            )
          ],
        ));
  }
}
