import 'package:flutter/material.dart';
import '../router/index.dart';
import '../utils/common.dart';

/*-----------------------头像组件------------------------*/
class AvaterComponent extends StatelessWidget {
  final String avater;
  final double size;
  final String? userId;

  const AvaterComponent({super.key,  required this.size,required this.avater,this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: ClipOval(
        child: avater != "" ? Image.network(
          //从全局的provider中获取用户信息
          getMusicCover(avater),
          height: size,
          width: size,
          fit: BoxFit.cover,
        ) : Image.asset(
          //从全局的provider中获取用户信息
          "lib/assets/images/default_avater.png",
          height: size,
          width: size,
          fit: BoxFit.cover,
        )

    ),onTap: (){
      if(userId == null){
        Routes.router.navigateTo(context, '/UserPage');
      }else{
        Routes.router.navigateTo(context, '/UserInfoPage');
      }
    });
  }
}
/*-----------------------头像组件------------------------*/
