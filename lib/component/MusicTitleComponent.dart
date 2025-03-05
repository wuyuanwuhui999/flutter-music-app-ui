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

  @override
  void initState() {
    super.initState();
    isFold = widget.isFold!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        RotatedBox(
          quarterTurns: isFold ? 1 : 0,
          child: InkWell(
              onTap: () {
                setState(() {
                  isFold = !isFold;
                });
                widget.onFold?.call(isFold);
              },
              child: Image.asset("lib/assets/images/icon_down.png",
                  color: ThemeColors.disableColor,
                  colorBlendMode: BlendMode.srcIn,
                  width: ThemeSize.smallIcon, height: ThemeSize.smallIcon)
          ),
        )
        ,
        SizedBox(width: ThemeSize.smallMargin),
        Text(widget.title),
        const Expanded(flex: 1, child: SizedBox()),
        widget.operateWidget ?? Text("更多",style: TextStyle(color: ThemeColors.disableColor,decoration: TextDecoration.underline, decorationColor: ThemeColors.disableColor)),
      ],
    );
  }
}
