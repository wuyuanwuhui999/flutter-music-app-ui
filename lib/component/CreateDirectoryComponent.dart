import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/ThemeSize.dart';
import '../service/serverMethod.dart';
import '../theme/ThemeColors.dart';
import '../model/FavoriteDirectoryModel.dart';

class CreateDirectoryComponent extends StatefulWidget {
  final Function onCreate;
  final Function onCancle;
  const CreateDirectoryComponent({super.key, required this.onCreate,required this.onCancle});

  @override
  CreateDirectoryComponentState createState() => CreateDirectoryComponentState();
}

class CreateDirectoryComponentState extends State<CreateDirectoryComponent> {
  List<FavoriteDirectoryModel> favoriteDirectory = []; // 收藏夹
  List<int> selectedValues = []; // 选中的收藏夹id
  bool isCreateDirectoryComponent = false; // 是否显示创建收藏夹界面
  TextEditingController favoriteNameController = TextEditingController();
  bool disableCreateBtn = true;

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            '*',
            style: TextStyle(color: Colors.red),
          ),
          Text('名称'),
          SizedBox(width: ThemeSize.containerPadding),
          Expanded(
            flex: 1,
            child: Container(
                height: ThemeSize.buttonHeight,
                padding: EdgeInsets.only(left: ThemeSize.containerPadding),
                decoration: BoxDecoration(
                    color: ThemeColors.colorBg,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ThemeSize.middleRadius))),
                child: TextField(
                    onChanged: (String value) {
                      setState(() {
                        disableCreateBtn = value == '';
                      });
                    },
                    textAlign: TextAlign.start,
                    controller: favoriteNameController,
                    cursorColor: ThemeColors.grey,
                    //设置光标
                    decoration: InputDecoration(
                      hintText: "请输入收藏夹名称",
                      hintStyle: TextStyle(
                          fontSize: ThemeSize.smallFontSize,
                          color: ThemeColors.grey),
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.only(bottom: ThemeSize.smallMargin),
                    ))),
          )
        ]),
        SizedBox(height: ThemeSize.containerPadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
                opacity: 0,
                child: Text('*', style: TextStyle(color: Colors.red))),
            Text('封面'),
            SizedBox(width: ThemeSize.containerPadding),
            Container(
              decoration: BoxDecoration(
                  color: ThemeColors.colorBg,
                  borderRadius: BorderRadius.all(
                      Radius.circular(ThemeSize.middleRadius))),
              width: ThemeSize.bigAvater,
              height: ThemeSize.bigAvater,
              child: Center(
                child: Image.asset('lib/assets/images/icon_add.png',
                    width: ThemeSize.middleIcon, height: ThemeSize.middleIcon),
              ),
            )
          ],
        ),
        SizedBox(height: ThemeSize.containerPadding),
        Opacity(
            opacity: disableCreateBtn ? 0.5 : 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius:
                BorderRadius.all(Radius.circular(ThemeSize.superRadius)),
              ),
              width: double.infinity,
              height: ThemeSize.buttonHeight,
              child: InkWell(
                  onTap: () {
                    if (favoriteNameController.text == '') {
                      Fluttertoast.showToast(
                          msg: "请输入收藏夹名称",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          fontSize: ThemeSize.middleFontSize);
                    }else{
                      insertFavoriteDirectoryService(FavoriteDirectoryModel(
                          name: favoriteNameController.text))
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: "创建收藏夹成功",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            textColor: Colors.white,
                            fontSize: ThemeSize.middleFontSize);
                        favoriteNameController.text = '';
                        widget.onCreate(FavoriteDirectoryModel.fromJson(value.data));
                      });
                    }

                  },
                  child: Center(
                      child: Text(
                        '创建',
                        style: TextStyle(color: ThemeColors.colorWhite),
                      ))),
            )),
        SizedBox(height: ThemeSize.containerPadding),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ThemeColors.borderColor),
            borderRadius:
            BorderRadius.all(Radius.circular(ThemeSize.superRadius)),
          ),
          height: ThemeSize.buttonHeight,
          child: InkWell(
              onTap: () {
                widget.onCancle();
              },
              child: Center(child: Text('取消'))),
        )
      ],
    );
  }
}
