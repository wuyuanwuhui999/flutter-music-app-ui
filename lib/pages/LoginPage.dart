import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_music_app/utils/HttpUtil.dart';
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
  // 登录进行中标志。必须作为 State 字段：原来声明在 build() 内部的局部变量
  // 每次重建都会被重置为 false，导致防重复点击完全失效。
  bool loading = false;

  // 输入值同样必须是 State 字段。原来 userAccount/password 声明在 build() 内，
  // onChanged 闭包只改到"当次 build"的变量；一旦重建（例如登录成功后
  // setUserInfo 触发通知），password 会被重置回默认值 "123456"，
  // 于是第二次登录就用错误密码，表现为"先提示成功、紧接着提示失败"。
  String userAccount = "";
  String password = "";
  String email = "";
  String code = "";

  // 控制器也必须在 initState 创建。放在 build() 里每次重建都会新建一个，
  // 导致输入内容/光标丢失。
  late TextEditingController userController;
  late TextEditingController pwdController;
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController codeController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    final UserInfoModel? userInfo =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;
    userAccount = userInfo?.userAccount ?? "";
    userController = TextEditingController(text: userAccount);
    pwdController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    userController.dispose();
    pwdController.dispose();
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.background,
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
                          width: ThemeSize.bigIcon,
                          height: ThemeSize.bigIcon,
                        )),
                    SizedBox(
                      height: ThemeSize.middleGap * 2,
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
                      height: ThemeSize.middleGap,
                    ),
                    tabIndex == 0
                        ? Column(
                      children: [
                        Container(
                            height: ThemeSize.inputHeight,
                            margin: ThemeStyle.margin,
                            padding: EdgeInsets.only(
                                left: ThemeSize.middleGap),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        ThemeSize.inputHeight / 2)),
                                border: Border.all(
                                    color: ThemeColors.gray)),
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
                                        ThemeColors.gray,
                                        fontSize:
                                        ThemeSize.middleFont);
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
                            height: ThemeSize.inputHeight,
                            padding: EdgeInsets.only(
                                left: ThemeSize.middleGap),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        ThemeSize.inputHeight / 2)),
                                border: Border.all(
                                    color: ThemeColors.gray)),
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
                                        ThemeColors.gray,
                                        fontSize:
                                        ThemeSize.middleFont);
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
                                      fontSize: ThemeSize.smallFont,
                                      color: ThemeColors.grey),
                                  contentPadding: EdgeInsets.only(
                                      left: ThemeSize.middleGap),
                                  border: InputBorder.none,
                                )))
                      ],
                    )
                        : Column(children: [
                      Container(
                          height: ThemeSize.inputHeight,
                          margin: ThemeStyle.margin,
                          padding: EdgeInsets.only(
                              left: ThemeSize.middleGap),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      ThemeSize.inputHeight / 2)),
                              border: Border.all(
                                  color: ThemeColors.gray)),
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
                                              ThemeColors.gray,
                                              fontSize: ThemeSize.middleFont);
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
                                        ThemeColors.gray,
                                        fontSize: ThemeSize.middleFont);
                                    EasyLoading.dismiss(animation: true);
                                  });
                                },
                                child: Image.asset(
                                    "lib/assets/images/icon_send.png",
                                    width: ThemeSize.smallIcon,
                                    height: ThemeSize.smallIcon),
                              ),
                              SizedBox(width: ThemeSize.middleGap)
                            ],
                          )),
                      Container(
                          margin: ThemeStyle.margin,
                          padding: EdgeInsets.only(
                              left: ThemeSize.middleGap),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      ThemeSize.superRadius)),
                              border: Border.all(
                                  color: ThemeColors.gray)),
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
                                      ThemeColors.gray,
                                      fontSize:
                                      ThemeSize.middleFont);
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
                    SizedBox(height: ThemeSize.middleGap),
                  ],
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        if (tabIndex == 0) {
                          if(loading)return;
                          loading = true;
                          loginService(userAccount, password).then((res) async {
                            loading = false;
                            if (res.data != null) {
                              String token = 'Bearer ${res.token}';
                              HttpUtil.getInstance().setToken(token);
                              await LocalStorageUtils.setToken(token);
                              if (!mounted) return;
                              // Toast 不要 await：Android 上它的 Future 可能不 complete，
                              // await 会让后面跳转的代码永远执行不到。
                              Fluttertoast.showToast(
                                  msg: "登录成功",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: ThemeSize.middleFont);
                              // 写入用户信息。UserInfoModel.fromJson 曾经因后端把
                              // sex 返回成字符串 "0" 而抛类型异常，中断整个流程导致
                              // "提示登录成功却不跳转"——模型已做宽松转换。
                              try {
                                Provider.of<UserInfoProvider>(context,
                                        listen: false)
                                    .setUserInfo(
                                        UserInfoModel.fromJson(res.data));
                              } catch (e) {
                                debugPrint("[LOGIN] 解析用户信息失败: $e");
                              }
                              // 等当前帧绘制完再跳转：setUserInfo 会同步触发
                              // notifyListeners，同帧内直接跳转可能被打断。
                              if (!mounted) return;
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
                                  fontSize: ThemeSize.middleFont);
                            }
                          }).catchError((err){
                            loading = false;
                            Fluttertoast.showToast(
                                msg: "登录失败，账号或密码错误",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: ThemeSize.middleFont);
                          });
                        } else if (email.trim() == "") {
                          Fluttertoast.showToast(
                              msg: "请输入邮箱",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: ThemeColors.gray,
                              fontSize: ThemeSize.middleFont);
                        } else if (code.trim() == "") {
                          Fluttertoast.showToast(
                              msg: "请输入验证码",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: ThemeColors.gray,
                              fontSize: ThemeSize.middleFont);
                        }else{
                          // EasyLoading.show() 的 Future 同样不应 await：
                          // 它要等到 dismiss 才完成，await 会把自己锁死。
                          EasyLoading.show();
                          loginByEmailService(emailController.text,codeController.text).then((res) async {
                            if (res.data != null) {
                              String token = 'Bearer ${res.token}';
                              await LocalStorageUtils.setToken(token);
                              HttpUtil.getInstance().setToken(token);
                              // 同账号密码登录：Toast 不可 await，否则跳转永不执行
                              Fluttertoast.showToast(
                                  msg: "登录成功",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: ThemeSize.middleFont);
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
                                  fontSize: ThemeSize.middleFont);
                            }
                          });
                        }
                      },
                      child: Container(
                        height: ThemeSize.buttonHeight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(
                              Radius.circular(ThemeSize.buttonHeight / 2)),
                        ),
                        width: double.infinity,
                        child: Center(
                            child: Text("登录",
                                style:
                                    TextStyle(color: ThemeColors.white))),
                      ),
                    ),
                    SizedBox(height: ThemeSize.middleGap),
                    InkWell(
                        onTap: () {
                          Routes.router.navigateTo(context, '/RegisterPage',
                              replace: false);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ThemeSize.buttonHeight / 2)),
                                border:
                                    Border.all(color: ThemeColors.gray)),
                            width: double.infinity,
                            height: ThemeSize.buttonHeight,
                            child: const Center(child: Text("注册")))),
                    SizedBox(height: ThemeSize.middleGap),
                    InkWell(
                        onTap: () {
                          Routes.router.navigateTo(
                              context, '/ForgetPasswordPage',
                              replace: false);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ThemeSize.buttonHeight / 2)),
                                border:
                                    Border.all(color: ThemeColors.gray)),
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
