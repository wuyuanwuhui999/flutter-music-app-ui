import 'package:flutter/material.dart';
import './ThemeSize.dart';
import './ThemeColors.dart';

/// 全局样式规范
///
/// 对齐 flutter-chat-app-ui 项目的 theme/ThemeStyle.dart，
/// 并遵循 提示词.txt 中的间距与颜色要求。
class ThemeStyle {
  /// 模块/卡片容器装饰：白底 + 卡片圆角
  static const BoxDecoration boxDecoration = BoxDecoration(
    color: ThemeColors.white,
    borderRadius: BorderRadius.all(Radius.circular(ThemeSize.middleRadius)),
  );

  /// 模块之间的外边距（底部间距，规范值 middleGap）
  static const EdgeInsets margin = EdgeInsets.only(bottom: ThemeSize.middleGap);

  /// 模块内边距（四边，规范值 middleGap）
  static const EdgeInsets padding = EdgeInsets.all(ThemeSize.middleGap);

  /// 模块内边距（仅左右，规范值 middleGap）
  static const EdgeInsets paddingBox = EdgeInsets.only(
      left: ThemeSize.middleGap, right: ThemeSize.middleGap);

  /// 列的上下边距
  static const EdgeInsets columnPadding = EdgeInsets.only(
      top: ThemeSize.columnPadding, bottom: ThemeSize.columnPadding);

  /// 大标题文字样式
  static const TextStyle mainTitleStyle = TextStyle(
      color: ThemeColors.mainTitle,
      fontSize: ThemeSize.bigFont,
      fontWeight: FontWeight.bold);

  /// 副标题文字样式
  static const TextStyle subTitleStyle =
      TextStyle(color: ThemeColors.subTitle, fontSize: ThemeSize.smallFont);

  /// 单侧底部分割线
  static const BoxDecoration bottomDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(
            // 设置单侧边框的样式
              color: ThemeColors.gray,
              width: 1,
              style: BorderStyle.solid)));

  /// 主按钮装饰（规范：确定/激活按钮背景 primary，文字白色）
  static const BoxDecoration primaryButtonDecoration = BoxDecoration(
      color: ThemeColors.primary,
      borderRadius: BorderRadius.all(Radius.circular(ThemeSize.btnHeight / 2)));

  /// 取消按钮装饰（规范：背景透明，边框 gray）
  static const BoxDecoration cancelButtonDecoration = BoxDecoration(
      color: Colors.transparent,
      border: Border.fromBorderSide(
          BorderSide(color: ThemeColors.gray, width: 1)),
      borderRadius: BorderRadius.all(Radius.circular(ThemeSize.btnHeight / 2)));

  /// 禁用按钮装饰（规范：背景 gray）
  static const BoxDecoration disabledButtonDecoration = BoxDecoration(
      color: ThemeColors.gray,
      borderRadius: BorderRadius.all(Radius.circular(ThemeSize.btnHeight / 2)));

  /// 删除按钮装饰（规范：背景 warn）
  static const BoxDecoration warnButtonDecoration = BoxDecoration(
      color: ThemeColors.warn,
      borderRadius: BorderRadius.all(Radius.circular(ThemeSize.btnHeight / 2)));
}
