import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../model/MuiscMySingerModel.dart';
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
  List<MusicModel> musicLikeList = [];// 我喜欢的歌曲
  // 创建一个从0到360弧度的补间动画 v * 2 * π
  bool isFoldFavoriteDirectory = false;// 是否折叠我的收藏夹
  bool isFoldFavoriteMusic = false;// 是否折叠我喜欢的歌曲
  bool isFoldFavoriteAuthor = false;// 是否折叠我喜欢的歌手
  bool isFoldRecord = false;// 是否折叠播放记录
  int totalLikeMusic = 0;// 喜欢的歌曲总数
  int totalFavoriteAuthor = 0;// 喜欢的歌手总数
  int totalRecord = 0;// 播放记录总数

  @override
  void initState() {
    super.initState();

    getMusicRecordService(1, 10).then((value) {
      setState(() {
        totalRecord = value.total!;
        playRecordList = value.data.map((item)=>MusicModel.fromJson(item)).toList();
      });
    });

    getMusicLikeService(1,5).then((value){
      setState(() {
        totalLikeMusic = value.total!;
        musicLikeList = value.data.map((item)=>MusicModel.fromJson(item)).toList();
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
                title: "我的收藏夹",
                operateWidget: Row(
                  children: [
                    Image.asset("lib/assets/images/icon_add.png",
                            width: ThemeSize.smallIcon,
                            color: ThemeColors.colorBg,
                            colorBlendMode: BlendMode.srcIn,
                            height: ThemeSize.smallIcon),
                    SizedBox(width: ThemeSize.containerPadding),
                    Image.asset("lib/assets/images/icon_refresh.png",
                        width: ThemeSize.smallIcon,
                        color: ThemeColors.colorBg,
                        colorBlendMode: BlendMode.srcIn,
                        height: ThemeSize.smallIcon)
                  ],
                )),
            FutureBuilder(
                future: getFavoriteDirectoryService(0),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  } else {
                    List<Widget> playMenuList = [];
                    snapshot.data?.data.forEach((item) {
                      FavoriteDirectoryModel favoriteDirectoryModel =
                          FavoriteDirectoryModel.fromJson(item);
                      playMenuList
                          .add(buildPlayMenuItem(favoriteDirectoryModel));
                    });
                    if (playMenuList.isEmpty) {
                      return Container();
                    } else {
                      return Column(children: playMenuList);
                    }
                  }
                })
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
                title: "我喜欢的歌曲",
                operateWidget: Row(
                  children: [
                    Image.asset("lib/assets/images/icon_refresh.png",
                        width: ThemeSize.smallIcon,
                        color: ThemeColors.disableColor,
                        colorBlendMode: BlendMode.srcIn,
                        height: ThemeSize.smallIcon),
                    SizedBox(width: totalLikeMusic > 5 ? ThemeSize.containerPadding : 0),
                    totalLikeMusic > 0 ? Text("更多",style: TextStyle(color: ThemeColors.disableColor,decoration: TextDecoration.underline, decorationColor: ThemeColors.disableColor)) : const SizedBox()
                  ],
                )),
            Column(
              children: musicLikeList.map((item) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: ThemeSize.containerPadding),
                  Row(
                    children: [
                      ClipOval(
                          child: Image.network(
                            HOST + item.cover,
                            width: ThemeSize.bigAvater,
                            height: ThemeSize.bigAvater,
                          )),
                      SizedBox(width: ThemeSize.containerPadding),
                      Expanded(
                        flex: 1,
                        child: Text(item.songName),
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
            )
          ],
        ));
  }

  // 创建我的歌单item
  Widget buildPlayMenuItem(FavoriteDirectoryModel favoriteDirectoryModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ThemeSize.containerPadding),
      InkWell(
        child: Row(
          children: [
            favoriteDirectoryModel.cover != null
                ? ClipOval(
                    child: Image.network(
                    "$HOST${favoriteDirectoryModel.cover}",
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
                      borderRadius: BorderRadius.circular(ThemeSize.bigAvater),
                    ),
                    child: Center(
                        child: Text(
                      favoriteDirectoryModel.name.substring(0, 1),
                      style: TextStyle(fontSize: ThemeSize.bigFontSize),
                    ))),
            SizedBox(width: ThemeSize.containerPadding),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(favoriteDirectoryModel.name),
                  SizedBox(height: ThemeSize.smallMargin),
                  Text("${favoriteDirectoryModel.total}首",
                      style: TextStyle(color: ThemeColors.subTitle))
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
              '/MusicFavoriteListPage?favoriteDirectoryModel=${Uri.encodeComponent(FavoriteDirectoryModel.stringify(favoriteDirectoryModel))}');
        },
      )
    ]);
  }

  // 我关注的歌手
  Widget buildFavoriteAuthorWidget() {
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
                onFold:(bool isFold){

                },
                title: "我关注的歌手",
                operateWidget: Row(
                  children: [
                    Image.asset("lib/assets/images/icon_refresh.png",
                        width: ThemeSize.smallIcon,
                        color: ThemeColors.disableColor,
                        colorBlendMode: BlendMode.srcIn,
                        height: ThemeSize.smallIcon),
                    SizedBox(width: ThemeSize.containerPadding),
                    Text("更多",style: TextStyle(color: ThemeColors.disableColor,decoration: TextDecoration.underline, decorationColor: ThemeColors.disableColor))
                  ],
                )),
            Offstage(offstage: isFoldFavoriteAuthor,child:FutureBuilder(
                future: getFavoriteAuthorService(1, 3),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  } else {
                    List<Widget> playMenuList = [];
                    snapshot.data?.data.forEach((item) {
                      MuiscMySingerModel mySingerModel =
                      MuiscMySingerModel.fromJson(item);
                      playMenuList.add(buildMySingerItem(mySingerModel));
                    });
                    if (playMenuList.isEmpty) {
                      return Container();
                    } else {
                      return Column(children: playMenuList);
                    }
                  }
                }))

          ],
        ));
  }

  Widget buildMySingerItem(MuiscMySingerModel mySingerModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ThemeSize.containerPadding),
      Row(
        children: [
          mySingerModel.avatar != null
              ? ClipOval(
                  child: Image.network(
                  mySingerModel.avatar!.contains("http")
                      ? mySingerModel.avatar!.replaceAll("{size}", "240")
                      : "$HOST${mySingerModel.avatar}",
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
                    borderRadius: BorderRadius.circular(ThemeSize.bigAvater),
                  ),
                  child: Center(
                      child: Text(
                    mySingerModel.authorName.substring(0, 1),
                    style: TextStyle(fontSize: ThemeSize.bigFontSize),
                  ))),
          SizedBox(width: ThemeSize.containerPadding),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mySingerModel.authorName),
                SizedBox(height: ThemeSize.smallMargin),
                Text("${mySingerModel.total}首",
                    style: TextStyle(color: ThemeColors.subTitle))
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
  }

  Widget buildRefreshWidget(Function(AnimationController) onTab){
    // 创建一个从0到360弧度的补间动画 v * 2 * π  会重复播放的控制器
    AnimationController repeatController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    // 创建一个从0到360弧度的补间动画 v * 2 * π
    Animation<double> curveAnimation = Tween<double>(begin: 0, end: 1).animate(repeatController);

    return RotationTransition(
        turns: curveAnimation,
        child: InkWell(
          child: Image.asset(
              "lib/assets/images/icon_refresh.png",
              width: ThemeSize.smallIcon,
              colorBlendMode: BlendMode.srcIn,
              color: ThemeColors.disableColor,
              height: ThemeSize.smallIcon),
          onTap: () {
            repeatController.forward();
            repeatController.repeat();
            onTab(repeatController);
          },
        ));
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
                onFold:(bool isFold){

                },
                title: "我最近播放的歌曲",
                operateWidget: Row(
                  children: [
                    buildRefreshWidget((AnimationController repeatController){
                      getMusicRecordService(1, 10).then((value) {
                        Future.delayed(const Duration(seconds: 1),(){
                          repeatController.stop(canceled: false);
                        });
                        setState(() {
                          totalRecord = value.total!;
                          playRecordList = value.data.map((item)=>MusicModel.fromJson(item)).toList();
                        });
                      });
                    }),
                    SizedBox(width: totalRecord > 5 ? ThemeSize.containerPadding : 0),
                    Text("更多",style: TextStyle(color: ThemeColors.disableColor,decoration: TextDecoration.underline, decorationColor: ThemeColors.disableColor))
                  ],
                )),
            Column(
              children: playRecordList.map((item) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: ThemeSize.containerPadding),
                  Row(
                    children: [
                      ClipOval(
                          child: Image.network(
                            HOST + item.cover,
                            width: ThemeSize.bigAvater,
                            height: ThemeSize.bigAvater,
                          )),
                      SizedBox(width: ThemeSize.containerPadding),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.songName),
                            SizedBox(height: ThemeSize.smallMargin),
                            Text("听过${item.times}次",
                                style: TextStyle(color: ThemeColors.subTitle))
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
            )
          ],
        ));
  }
}
