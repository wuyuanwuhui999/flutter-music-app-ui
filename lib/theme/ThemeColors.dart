import 'package:flutter/material.dart';

/// 全局颜色规范
///
/// 命名与取值对齐 flutter-chat-app-ui 项目的 theme/ThemeColors.dart，
/// 并遵循 提示词.txt 第 3 节「颜色与主题规范」：
/// - 页面背景色：background
/// - 应用主色调：primary
/// - 确定/激活按钮：primary + 白色文字
/// - 取消按钮：透明背景 + gray 边框与文字
/// - 禁用按钮：gray 背景
/// - 删除按钮：warn 背景
class ThemeColors {
  /// 页面背景色
  static const Color background = Color.fromRGBO(238, 238, 238, 1);

  /// 应用主色调
  static const Color primary = Color.fromRGBO(255, 174, 0, 1);

  /// 中性灰：取消按钮边框/文字、禁用按钮背景、普通边框与分割线
  static const Color gray = Color.fromRGBO(221, 221, 221, 1);

  /// 白色：卡片背景、主按钮文字
  static const Color white = Color.fromRGBO(255, 255, 255, 1);

  /// 主标题文字色
  static const Color mainTitle = Color.fromRGBO(102, 102, 102, 1);

  /// 副标题文字色
  static const Color subTitle = Color.fromRGBO(153, 153, 153, 1);

  /// 弹窗遮罩
  static const Color popupMenu = Color.fromRGBO(0, 0, 0, 0.5);

  /// 警示色：删除按钮背景、失败提示
  static const Color warn = Color.fromRGBO(247, 69, 59, 1);

  // ===== 音乐项目独有的辅助色（chat 项目无对应项）=====

  /// 高亮/激活色（如选中态文字）
  static const Color activeColor = Color.fromRGBO(24, 144, 255, 1);

  /// 蓝色辅助色
  static const Color blueColor = Color.fromRGBO(62, 125, 155, 1);

  /// 黑色 10% 透明
  static const Color opacityBlack = Color.fromRGBO(0, 0, 0, 0.1);

  /// 白色 30% 透明
  static const Color opacityWhite = Color.fromRGBO(255, 255, 255, 0.3);

  /// Material 主题橙色（用于跟随系统橙色组件）
  static const Color orange = Colors.orange;

  /// Material 主题灰色（用于跟随系统灰色组件）
  static const Color grey = Colors.grey;
}
