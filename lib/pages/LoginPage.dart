import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../router/index.dart';
import '../service/serverMethod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/crypto.dart';
import '../provider/UserInfoProvider.dart';
import 'package:provider/provider.dart';
import '../utils/LocalStorageUtils.dart';
import '../model/UserInfoModel.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    UserInfoModel? userInfo = Provider.of<UserInfoProvider>(context).userInfo;
    String userAccount = userInfo?.userAccount ?? "";
    String email = "";
    String code = "";
    TextEditingController userController = TextEditingController(text: userAccount);
    TextEditingController pwdController = TextEditingController(text: "");
    TextEditingController emailController = TextEditingController(text: "");
    TextEditingController codeController = TextEditingController(text: "");

    String password = "123456";
    return Scaffold(
        backgroundColor: ThemeColors.colorBg,
        body: SafeArea(
          child: Container(
            padding: ThemeStyle.padding,
            margin: ThemeStyle.padding,
            decoration: ThemeStyle.boxDecoration,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Center(
                        child: Image.asset(
                          "lib/assets/images/icon_logo.png",
                          width: ThemeSize.movieWidth / 2,
                          height: ThemeSize.movieWidth / 2,
                        )),
                    SizedBox(
                      height: ThemeSize.containerPadding * 2,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    tabIndex = 0;
                                  });
                                },
                                child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: ThemeSize.borderSize,
                                              //宽度
                                              color: tabIndex == 0
                                                  ? ThemeColors.orange
                                                  : Colors.transparent, //边框颜色
                                            ),
                                          )),
                                      child: const Text("账号密码登录"),
                                    )))),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  tabIndex = 1;
                                });
                              },
                              child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: ThemeSize.borderSize, //宽度
                                            color: tabIndex == 1
                                                ? ThemeColors.orange
                                                : Colors.transparent, //边框颜色
                                          ),
                                        )),
                                    child: const Text("邮箱验证码登录"),
                                  )),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: ThemeSize.containerPadding,
                    ),
                    tabIndex == 0
                        ? Column(
                      children: [
                        Container(
                            margin: ThemeStyle.margin,
                            padding: EdgeInsets.only(
                                left: ThemeSize.containerPadding),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        ThemeSize.superRadius)),
                                border: Border.all(
                                    color: ThemeColors.borderColor)),
                            child: TextField(
                                onChanged: (value) {
                                  if (value != "") {
                                    userAccount = value;
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "请输入用户名",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                        ThemeColors.disableColor,
                                        fontSize:
                                        ThemeSize.middleFontSize);
                                  }
                                },
                                controller: userController,
                                cursorColor: ThemeColors.grey, //设置光标
                                decoration: InputDecoration(
                                  hintText: "请输入用户名",
                                  icon: Image.asset(
                                      "lib/assets/images/icon_user.png",
                                      width: ThemeSize.smallIcon,
                                      height: ThemeSize.smallIcon),
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: ThemeColors.grey),
                                  contentPadding:
                                  EdgeInsets.only(left: 0.0),
                                  border: InputBorder.none,
                                ))),
                        Container(
                            padding: EdgeInsets.only(
                                left: ThemeSize.containerPadding),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        ThemeSize.superRadius)),
                                border: Border.all(
                                    color: ThemeColors.borderColor)),
                            child: TextField(
                                onChanged: (value) {
                                  if (value != "") {
                                    password = value;
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "请输入密码",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                        ThemeColors.disableColor,
                                        fontSize:
                                        ThemeSize.middleFontSize);
                                  }
                                },
                                controller: pwdController,
                                obscureText: true,
                                cursorColor: ThemeColors.grey,
                                //设置光标
                                decoration: InputDecoration(
                                  icon: Image.asset(
                                      "lib/assets/images/icon_password.png",
                                      width: ThemeSize.smallIcon,
                                      height: ThemeSize.smallIcon),
                                  hintText: "请输入密码",
                                  hintStyle: TextStyle(
                                      fontSize: ThemeSize.smallFontSize,
                                      color: ThemeColors.grey),
                                  contentPadding: EdgeInsets.only(
                                      left: ThemeSize.containerPadding),
                                  border: InputBorder.none,
                                )))
                      ],
                    )
                        : Column(children: [
                      Container(
                          margin: ThemeStyle.margin,
                          padding: EdgeInsets.only(
                              left: ThemeSize.containerPadding),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      ThemeSize.superRadius)),
                              border: Border.all(
                                  color: ThemeColors.borderColor)),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: TextField(
                                      onChanged: (value) {
                                        if (value != "") {
                                          email = value;
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "请输入邮箱",
                                              toastLength:
                                              Toast.LENGTH_SHORT,
                                              gravity:
                                              ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor:
                                              ThemeColors
                                                  .disableColor,
                                              fontSize: ThemeSize
                                                  .middleFontSize);
                                        }
                                      },
                                      controller: emailController,
                                      cursorColor:
                                      ThemeColors.grey, //设置光标
                                      decoration: InputDecoration(
                                        hintText: "请输入邮箱",
                                        icon: Image.asset(
                                            "lib/assets/images/icon_user.png",
                                            width: ThemeSize.smallIcon,
                                            height:
                                            ThemeSize.smallIcon),
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: ThemeColors.grey),
                                        contentPadding:
                                        EdgeInsets.only(left: 0.0),
                                        border: InputBorder.none,
                                      ))),
                              InkWell(
                                onTap: () async {
                                  await EasyLoading.show();
                                  sendEmailVertifyCodeService(email).then((res){
                                    Fluttertoast.showToast(
                                        msg: res.msg??"",
                                        toastLength:
                                        Toast.LENGTH_SHORT,
                                        gravity:
                                        ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                        ThemeColors
                                            .disableColor,
                                        fontSize: ThemeSize
                                            .middleFontSize);
                                    EasyLoading.dismiss(animation: true);
                                  });
                                },
                                child: Image.asset(
                                    "lib/assets/images/icon_send.png",
                                    width: ThemeSize.smallIcon,
                                    height: ThemeSize.smallIcon),
                              ),
                              SizedBox(width: ThemeSize.containerPadding)
                            ],
                          )),
                      Container(
                          margin: ThemeStyle.margin,
                          padding: EdgeInsets.only(
                              left: ThemeSize.containerPadding),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      ThemeSize.superRadius)),
                              border: Border.all(
                                  color: ThemeColors.borderColor)),
                          child: TextField(
                              onChanged: (value) {
                                if (value != "") {
                                  code = value;
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "请输入验证码",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor:
                                      ThemeColors.disableColor,
                                      fontSize:
                                      ThemeSize.middleFontSize);
                                }
                              },
                              controller: codeController,
                              cursorColor: ThemeColors.grey, //设置光标
                              decoration: InputDecoration(
                                hintText: "请输入验证码",
                                icon: Image.asset(
                                    "lib/assets/images/icon_code.png",
                                    width: ThemeSize.smallIcon,
                                    height: ThemeSize.smallIcon),
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: ThemeColors.grey),
                                border: InputBorder.none,
                              ))),
                    ]),
                    SizedBox(height: ThemeSize.containerPadding),
                  ],
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        if (tabIndex == 0) {
                          loginService(userAccount, password).then((res) async {
                            if (res.data != null) {
                              await LocalStorageUtils.setToken(res.token!);
                              await Fluttertoast.showToast(
                                  msg: "登录成功",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: ThemeSize.middleFontSize);
                              Provider.of<UserInfoProvider>(context,
                                      listen: false)
                                  .setUserInfo(
                                      UserInfoModel.fromJson(res.data));
                              Routes.router.navigateTo(
                                  context, '/MusicIndexPage',
                                  replace: true);

                            } else {
                              Fluttertoast.showToast(
                                  msg: "登录失败，账号或密码错误",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: ThemeSize.middleFontSize);
                            }
                          }).catchError((){
                            Fluttertoast.showToast(
                                msg: "登录失败，账号或密码错误",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: ThemeSize.middleFontSize);
                          });
                        } else if (email.trim() == "") {
                          Fluttertoast.showToast(
                              msg: "请输入邮箱",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: ThemeColors.disableColor,
                              fontSize: ThemeSize.middleFontSize);
                        } else if (code.trim() == "") {
                          Fluttertoast.showToast(
                              msg: "请输入验证码",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: ThemeColors.disableColor,
                              fontSize: ThemeSize.middleFontSize);
                        }else{
                          await EasyLoading.show();
                          loginByEmailService(emailController.text,codeController.text).then((res) async {
                            if (res.data != null) {
                              await LocalStorageUtils.setToken(res.token!);
                              await Fluttertoast.showToast(
                                  msg: "登录成功",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: ThemeSize.middleFontSize);
                              EasyLoading.dismiss();
                              Provider.of<UserInfoProvider>(context,
                                  listen: false)
                                  .setUserInfo(
                                  UserInfoModel.fromJson(res.data));
                              Routes.router.navigateTo(
                                  context, '/MusicIndexPage',
                                  replace: true);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "登录失败，账号或密码错误",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: ThemeSize.middleFontSize);
                            }
                          });
                        }
                      },
                      child: Container(
                        height: ThemeSize.buttonHeight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(
                              Radius.circular(ThemeSize.superRadius)),
                        ),
                        width: double.infinity,
                        child: Center(
                            child: Text("登录",
                                style:
                                    TextStyle(color: ThemeColors.colorWhite))),
                      ),
                    ),
                    SizedBox(height: ThemeSize.containerPadding),
                    InkWell(
                        onTap: () {
                          Routes.router.navigateTo(context, '/RegisterPage',
                              replace: false);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ThemeSize.superRadius)),
                                border:
                                    Border.all(color: ThemeColors.borderColor)),
                            width: double.infinity,
                            height: ThemeSize.buttonHeight,
                            child: const Center(child: Text("注册")))),
                    SizedBox(height: ThemeSize.containerPadding),
                    InkWell(
                        onTap: () {
                          Routes.router.navigateTo(
                              context, '/ForgetPasswordPage',
                              replace: false);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ThemeSize.superRadius)),
                                border:
                                    Border.all(color: ThemeColors.borderColor)),
                            width: double.infinity,
                            height: ThemeSize.buttonHeight,
                            child: const Center(child: Text("忘记密码"))))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
