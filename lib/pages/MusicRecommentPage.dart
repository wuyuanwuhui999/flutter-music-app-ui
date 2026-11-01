import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import '../component/MusicAvaterComponent.dart';
import 'package:provider/provider.dart';
import '../router/index.dart';
import '../model/MusicModel.dart';
import '../model/MusicClassifyModel.dart';
import '../provider/PlayerMusicProvider.dart';
import '../service/serverMethod.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';
import '../common/constant.dart';

class MusicRecommentPage extends StatefulWidget {
  const MusicRecommentPage({super.key});

  @override
  _MusicRecommentPageState createState() => _MusicRecommentPageState();
}

class _MusicRecommentPageState extends State<MusicRecommentPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 推荐页取歌所用的分类 ID。
  ///
  /// 原来这里硬编码为 1，但后端 music_category 表的自增 ID 从 68 开始
  /// （68=酷狗飙升榜、69=酷狗TOP500...），根本不存在 id=1 的分类，
  /// 所以 getMusicListByCategoryId?categoryId=1 永远返回
  /// {"status":"SUCCESS","total":0,"data":[]}——接口通、但没数据，
  /// 表现为推荐页空白。
  /// 现在改为从 getMusicCategory 动态取第一个有歌曲的分类。
  static const int fallbackCategoryId = 68;
  int recommendCategoryId = fallbackCategoryId;
  bool _categoryResolved = false;

  int pageNum = 2; // 初始化加载两页共20条数据，后面每页加载10条
  int pageSize = 10;
  int total = 0;
  List<MusicModel> musicModelList = [];
  List<String> iconList = [
    "lib/assets/images/icon_no1.png",
    "lib/assets/images/icon_no2.png",
    "lib/assets/images/icon_no3.png"
  ];
  late MusicModel currentPlayingMusicModel;
  late bool playing;
  EasyRefreshController easyRefreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    getRecommendMusicList(1, 20);
    usePlayState();
  }

  /// 获取播放状态
  usePlayState() {
    AudioPlayer player =
        Provider.of<PlayerMusicProvider>(context, listen: false).player;
    player.onPlayerStateChanged.listen((event) {
      setState(() {
        playing = event.index == 1;
      });
    });
  }

  /// 解析出真正有歌曲的分类 ID，然后拉取列表。
  /// 原来直接用硬编码的 1 请求，后端该分类不存在，返回空列表。
  Future<void> _resolveCategoryAndLoad() async {
    if (_categoryResolved) return;
    try {
      final res = await getMusicClassifyService();
      final list = (res.data as List?) ?? [];
      final enabled = list
          .map((e) => MusicClassifyModel.fromJson(e))
          .where((c) => c.disabled == 0)
          .toList();
      if (enabled.isNotEmpty) {
        recommendCategoryId = enabled.first.id;
      }
    } catch (e) {
      debugPrint("[RECOMMENT] 解析分类失败，回退到 $fallbackCategoryId: $e");
    }
    _categoryResolved = true;
  }

  void getRecommendMusicList(int pageNum, pageSize) {
    _resolveCategoryAndLoad().then((_) {
      if (!mounted) return;
      getMusicListByClassifyIdService(recommendCategoryId, pageNum, pageSize, 1)
          .then((res) {
        if (!mounted) return;
        setState(() {
          // total 可能是 null（接口失败时），原来是 res.total! 会崩
          total = res.total ?? 0;
          for (var item in res.data) {
            item['classifyId'] = recommendCategoryId;
            item['pageNum'] = pageNum;
            item['pageSize'] = pageSize;
            item['isRedis'] = 0;
            musicModelList.add(MusicModel.fromJson(item));
          }
        });
        easyRefreshController.finishLoad(
            success: true, noMore: musicModelList.length >= total);
      });
    });
  }

  // 创建音乐列表项
  Widget buildMusicItem(
      List<MusicModel> musicModelList, MusicModel musicModel, int index) {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        margin: ThemeStyle.margin,
        width:
            MediaQuery.of(context).size.width - ThemeSize.middleGap * 2,
        padding: ThemeStyle.padding,
        child: Row(children: [
          index < iconList.length
              ? Image.asset(iconList[index],
                  width: ThemeSize.middleIcon, height: ThemeSize.middleIcon)
              : SizedBox(
                  width: ThemeSize.middleIcon,
                  height: ThemeSize.middleIcon,
                  child: Center(
                      child: Text(
                    (index + 1).toString(),
                  ))),
          SizedBox(width: ThemeSize.middleGap),
          MusicAvaterComponent(type:'music',name:'',size: ThemeSize.middleAvater,avater:musicModel.cover),
          SizedBox(width: ThemeSize.middleGap),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(musicModel.songName,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: ThemeSize.smallMargin),
                Text(musicModel.authorName,
                    style: TextStyle(color: ThemeColors.gray)),
              ],
            ),
          ),
          InkWell(
              child: Image.asset(
                  playing && musicModel.id == currentPlayingMusicModel.id
                      ? "lib/assets/images/icon_music_playing_grey.png"
                      : "lib/assets/images/icon_music_play.png",
                  width: ThemeSize.smallIcon,
                  height: ThemeSize.smallIcon),
              onTap: () async {
                PlayerMusicProvider provider = Provider.of<PlayerMusicProvider>(context, listen: false);
                if(provider.classifyName != '推荐歌曲'){
                  await getMusicListByClassifyIdService(recommendCategoryId, 1, MAX_FAVORITE_NUMBER, 1).then((value){
                    provider.setClassifyMusic(value.data.map((element) => MusicModel.fromJson(element)).toList(),musicModel,index,'推荐歌曲');
                  });
                }else if(musicModel.id != provider.musicModel?.id){
                  provider.setPlayMusic(musicModel, true);
                }
                Routes.router.navigateTo(context, '/MusicPlayerPage');
              }),
          SizedBox(width: ThemeSize.middleGap),
          InkWell(child: Image.asset(
              "lib/assets/images/icon_like${musicModel.isLike == 1 ? "_active" : ""}.png",
              width: ThemeSize.smallIcon,
              height: ThemeSize.smallIcon),onTap: (){
            if(musicModel.isLike == 0){
              insertMusicLikeService(musicModel.id).then((res) => {
                if(res.data > 0){
                  setState(() {
                    musicModel.isLike = 1;
                  })
                }
              });
            }else{
              deleteMusicLikeService(musicModel.id).then((res) => {
                if(res.data > 0){
                  setState(() {
                    musicModel.isLike = 0;
                  })
                }
              });
            }
          }),
          SizedBox(width: ThemeSize.middleGap),
          Image.asset("lib/assets/images/icon_music_menu.png",
              width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
        ]));
  }

  List<Widget> buildMusicWedgetList() {
    List<Widget> musicWedgetList = [];
    int index = 0;
    musicModelList.forEach((element) {
      musicWedgetList.add(buildMusicItem(musicModelList, element, index));
      index++;
    });
    return musicWedgetList;
  }

  @override
  Widget build(BuildContext context) {
    // AutomaticKeepAliveClientMixin 要求调用，否则 keep-alive 不生效，
    // 切到其他 tab 再回来时页面状态会丢。
    super.build(context);
    currentPlayingMusicModel =
        Provider.of<PlayerMusicProvider>(context).musicModel;
    playing = Provider.of<PlayerMusicProvider>(context).playing;
    return Container(
      width: MediaQuery.of(context).size.width,
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
          pageNum++;
          if (total <= musicModelList.length) {
            Fluttertoast.showToast(
                msg: "已经到底了",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: ThemeSize.middleFont);
          } else {
            getRecommendMusicList(pageNum, pageSize);
          }
        },
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + ThemeSize.middleGap),
            ...buildMusicWedgetList()
          ],
        ),
      ),
    );
  }
}
