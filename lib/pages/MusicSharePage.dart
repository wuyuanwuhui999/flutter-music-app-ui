import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';
import '../component/SelectDialogComponent.dart';
import '../service/serverMethod.dart';
import '../model/CircleModel.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeColors.dart';
import '../theme/ThemeSize.dart';
import '../model/MusicModel.dart';
import '../component/MusicAvaterComponent.dart';
import '../common/config.dart';

class MusicSharePage extends StatefulWidget {
  final MusicModel musicModel;
  const MusicSharePage({super.key,required this.musicModel});

  @override
  _MusicSharePageState createState() => _MusicSharePageState();
}

class _MusicSharePageState extends State<MusicSharePage>
    with TickerProviderStateMixin, RouteAware {

 CircleModel circleModel = CircleModel(
     id:0,
     relationId:0,
     content:"",
     type:"",
     userId:"",
     username:"",
     createTime:"",
     updateTime:"",
     permission:0,
      key: GlobalKey()
 );
 bool loading = false;

 @override
 void initState() {
   circleModel.permission = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.colorBg,
        body: SafeArea(
          top: true,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                buildBtnWidget(),
                Padding(
                  padding: ThemeStyle.padding,
                  child: Column(
                    children: [
                      buildTextAreaWidget(),
                      SizedBox(height: ThemeSize.containerPadding),
                      buildMusicWidget(),
                      SizedBox(height: ThemeSize.containerPadding),
                      buildPermissionWidget()
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  ///@author: wuwenqiang
  ///@description: 创建头部按钮
  /// @date: 2024-07-13 17:33
  Widget buildBtnWidget(){
    return Container(
        padding: ThemeStyle.padding,
        decoration: BoxDecoration(color: ThemeColors.colorWhite),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  height: ThemeSize.buttonHeight,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                          fontSize: ThemeSize.middleFontSize),
                    ),
                  )),
              Container(
                  height: ThemeSize.buttonHeight,
                  child: ElevatedButton(
                    onPressed: useSave,
                    child: Text(
                      '发布',
                      style: TextStyle(
                          color: ThemeColors.colorWhite,
                          fontSize: ThemeSize.middleFontSize),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ))
            ]));
  }

  ///@author: wuwenqiang
  ///@description: 创建文本框
  /// @date: 2024-07-13 17:33
  Widget buildTextAreaWidget(){
    return Container(
        height: ThemeSize.textareaHeight,
        decoration: BoxDecoration(
            color: ThemeColors.disableColor,
            borderRadius: BorderRadius.all(
                Radius.circular(ThemeSize.middleRadius))),
        padding: ThemeStyle.padding,
        child: TextField(
          onChanged: (String value){
            circleModel.content = value;
          },
            maxLines:10,decoration:const InputDecoration(
          filled: false,
          contentPadding: EdgeInsets.zero,
          hintText:'这一刻的想法',
          border: InputBorder.none, // 去掉边框
        ))
    );
  }

  ///@author: wuwenqiang
  ///@description: 创建音乐模块
  /// @date: 2024-07-13 18:16
  Widget buildMusicWidget(){
    return Container(
      decoration: ThemeStyle.boxDecoration,
      padding: ThemeStyle.padding,
      child: Row(children: [
        MusicAvaterComponent(type:'music',name:'',avater:widget.musicModel.cover,size:ThemeSize.middleAvater),
        SizedBox(width: ThemeSize.containerPadding),
        Text('${widget.musicModel.authorName} - ${widget.musicModel.songName}')
      ],),
    );
  }

  ///@author: wuwenqiang
  ///@description: 创建音乐模块
  /// @date: 2024-07-13 18:16
  Widget buildPermissionWidget(){
    return Container(
      decoration: ThemeStyle.boxDecoration,
      padding: ThemeStyle.padding,
      child: InkWell(
        onTap:(){
          BottomSelectionDialog.show(
            context:context,
            options:["私密", "公开"],
            onTap:(String value) {
              Navigator.pop(context);
              setState(() {
                circleModel.permission = value == "私密" ? 0 : 1;
              });
            });
      }, child: Row(children: [
        Image.asset(
          'lib/assets/images/icon_permission.png',
          height: ThemeSize.middleIcon,
          width: ThemeSize.middleIcon,
          fit: BoxFit.cover,
        ),
        SizedBox(width: ThemeSize.containerPadding),
        const Expanded(flex: 1, child: Text('谁可以看')),
        Text(PermissionMap[circleModel.permission]!),
        SizedBox(width: ThemeSize.smallMargin),
        Image.asset(
          'lib/assets/images/icon_arrow.png',
          height: ThemeSize.smallIcon,
          width: ThemeSize.smallIcon,
          fit: BoxFit.cover,
        ),
      ]))
    );
  }

  ///@author: wuwenqiang
  ///@description: 保存说说
  /// @date: 2024-07-13 20:34
  useSave(){
    if(loading)return;
    loading = true;
    circleModel.relationId = widget.musicModel.id;
    circleModel.type = CircleEnum.MUSIC.toString().split('.').last;
    saveCircleService(circleModel).then((value){
      Fluttertoast.showToast(
          msg: "发布成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: ThemeSize.middleFontSize);
      loading = false;
      Navigator.pop(context);
    }).catchError((){
      loading = false;
    });
  }
}
