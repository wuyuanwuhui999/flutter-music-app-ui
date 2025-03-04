import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeColors.dart';

class MusicTitleComponent extends StatefulWidget {
  final String title;
  final bool? isFold;
  final Function(bool)? onFold;
  final Widget? operateWidget;

  const MusicTitleComponent({super.key, required this.title, this.isFold = false, this.onFold, this.operateWidget,});

  @override
  MusicTitleComponentState createState() => MusicTitleComponentState();
}

class MusicTitleComponentState extends State<MusicTitleComponent>
    with TickerProviderStateMixin {
  late bool isFold;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    isFold = widget.isFold!;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =  Tween<double>(begin: 0, end: 90 * (pi / 180)).animate(_controller);
  }

  ///@author: wuwenqiang
  ///@description: 展开或者折叠
  ///@date: 2025-03-04 22:52
  void useFold() {

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        InkWell(
          onTap: () {
            widget.onFold?.call(isFold);
          },
            child: RotationTransition(
          turns: _animation,
          child: InkWell(
              onTap: () {
                if (_controller.status == AnimationStatus.completed) {
                  _controller.reverse();
                  isFold = true;
                } else {
                  _controller.forward();
                  isFold = false;
                }
              },
              child: Image.asset("lib/assets/images/icon_down.png",
                  width: ThemeSize.smallIcon, height: ThemeSize.smallIcon)
          ),
        ))
        ,
        SizedBox(width: ThemeSize.smallMargin),
        Text(widget.title),
        const Expanded(flex: 1, child: SizedBox()),
        widget.operateWidget ?? Text("更多",style: TextStyle(color: ThemeColors.disableColor,decoration: TextDecoration.underline, decorationColor: ThemeColors.disableColor)),
      ],
    );
  }
}
