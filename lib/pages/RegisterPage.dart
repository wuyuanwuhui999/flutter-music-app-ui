import 'package:flutter/material.dart';
import '../theme/ThemeSize.dart';
import '../component/NavigatorTitleComponent.dart';
import '../theme/ThemeColors.dart';
import '../theme/ThemeStyle.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  int groupValue = 0;
  FocusNode userFocusNode = FocusNode();

  void _handleRadioValueChanged(int? value) {
    setState(() {
      groupValue = value!;
    });
  }

  @override
  void initState() {
    super.initState();
    userFocusNode.addListener(()  {
      if (!userFocusNode.hasFocus)  {
        // 失去焦点时执行操作（如验证输入）

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.colorBg,
        body: SafeArea(
            top: true,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  const NavigatorTitleComponent(title: "注册"),
                  SizedBox(height: ThemeSize.containerPadding),
                  Container(
                      decoration: ThemeStyle.boxDecoration,
                      margin: ThemeStyle.paddingBox,
                      padding: ThemeStyle.paddingBox,
                      child: Column(
                        children: [
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    Text("*",
                                        style: TextStyle(
                                            color: ThemeColors.warnColor)),
                                    const Text("用户名")
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  focusNode: userFocusNode,
                                  decoration: InputDecoration(

                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "请输入用户名",
                                  ),
                                  onChanged: (value) {

                                  },

                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    Text("*",
                                        style: TextStyle(
                                            color: ThemeColors.warnColor)),
                                    const Text("密码")
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "请输入密码",
                                  ),
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    Text("*",
                                        style: TextStyle(
                                            color: ThemeColors.warnColor)),
                                    const Text("确认密码")
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "确认密码",
                                  ),
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    Text("*",
                                        style: TextStyle(
                                            color: ThemeColors.warnColor)),
                                    const Text("昵称")
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "请输入昵称",
                                  ),
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 80,
                                child: Row(
                                  children: [
                                    Text("*",
                                        style: TextStyle(
                                            color: ThemeColors.warnColor)),
                                    const Text("邮箱")
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "请输入邮箱地址",
                                  ),
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 80,
                                child: Text("性别"),
                              ),
                              Expanded(
                                flex: 1,
                                child:
                                Column(children: [
                                  Row(
                                    children: <Widget>[
                                      const Text("男"),
                                      Radio(
                                          value: 0,
                                          groupValue: groupValue,
                                          // title: Text("男"),
                                          onChanged: _handleRadioValueChanged),
                                      SizedBox(width: ThemeSize.containerPadding),
                                      const Text("女"),
                                      Radio(
                                          value: 1,
                                          groupValue: groupValue,
                                          onChanged: _handleRadioValueChanged),
                                    ],
                                  ),
                                  Divider(height: 1,color:ThemeColors.borderColor)
                                ],)
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 80,
                                child: Text("区域"),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "请输入区域",
                                  ),
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                          Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 80,
                                child: Text("个性签名"),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ThemeColors.disableColor)),
                                    hintText: "请输入个性签名",
                                  ),
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: ThemeSize.containerPadding),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.all(ThemeSize.containerPadding),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                            color: const Color.fromRGBO(237, 237, 237, 1))),
                    child: MaterialButton(
                      onPressed: () {},
                      child: const Text("注册",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1))),
                    ),
                  )
                ],
              ),
            )));
    ;
  }
}
