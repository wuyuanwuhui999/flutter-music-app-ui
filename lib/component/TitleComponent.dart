import 'package:flutter/material.dart';
import '../theme/ThemeStyle.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';

class TitleComponent extends StatelessWidget {
  final String title;
  const TitleComponent({super.key,required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: ThemeStyle.margin,
        padding: EdgeInsets.only(left: ThemeSize.miniMargin),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 3, //宽度
              color: ThemeColors.primary, //边框颜色
            ),
          ),
        ),
        child: Text(title));
  }
}