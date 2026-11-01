/// 全局尺寸规范
///
/// 命名与取值对齐 flutter-chat-app-ui 项目的 theme/ThemeSize.dart，
/// 便于两个项目共用同一套 UI 规范（参考 提示词.txt 第 2 节）。
/// 已删除本项目从未引用的冗余常量。
class ThemeSize {
  // ===== 间距 =====

  /// 模块之间的内边距和外边距（规范：所有间距统一用它）
  static const double middleGap = 15;

  /// 小边距
  static const double smallMargin = 10;

  /// 超小边距
  static const double miniMargin = 5;

  /// 列的上下边距
  static const double columnPadding = 20;

  // ===== 圆角 =====

  /// 卡片/模块圆角
  static const double middleRadius = 10;

  /// 大圆角
  static const double bigRadius = 20;

  /// 加大版圆角
  static const double superRadius = 30;

  /// 小圆角
  static const double minBtnRadius = 5;

  // ===== 按钮与输入框 =====

  /// 中等按钮宽度
  static const double btnWidth = 70;

  /// 中等按钮高度（规范：圆角 = btnHeight / 2）
  static const double btnHeight = 35;

  /// 输入框/搜索框高度（规范：圆角 = inputHeight / 2）
  static const double inputHeight = 45;

  /// 按钮高度（音乐项目常用的大按钮，与 btnHeight 区分：登录、注册等主操作按钮）
  static const double buttonHeight = 40;

  // ===== 图标 =====

  /// 大图标
  static const double bigIcon = 75;

  /// 中等图标
  static const double middleIcon = 30;

  /// 小图标
  static const double smallIcon = 20;

  /// 超小图标
  static const double miniIcon = 15;

  /// 播放控制图标（音乐项目特有）
  static const double playIcon = 25;

  /// 播放器唱片圈大小（音乐项目特有）
  static const double minPlayIcon = 80;

  /// 图标透明度（规范：图标透明度 0.5）
  static const double opacity = 0.5;

  // ===== 字体 =====

  /// 常规字体（小）
  static const double smallFont = 14;

  /// 常规字体
  static const double middleFont = 16;

  /// 常规字体（规范中的 normalFont，与 middleFont 同值，保留两种写法以便渐进迁移）
  static const double normalFont = 16;

  /// 大标题字体
  static const double bigFont = 20;

  // ===== 头像 =====

  /// 小头像
  static const double smallAvater = 30;

  /// 中等头像
  static const double middleAvater = 50;

  /// 大头像
  static const double bigAvater = 60;

  // ===== 其他 =====

  /// 边框大小
  static const double borderSize = 3;

  /// 多行文本框的高度
  static const double textareaHeight = 150;

  /// 标题栏高度
  static const double titleBarHeight = 50;

  /// 每页显示大小
  static const int pageSize = 20;

  // ===== 音乐项目独有布局常量 =====

  /// 弹出点赞和评论菜单的宽度
  static const double menuWidth = 180;

  /// 弹出点赞和评论菜单的高度
  static const double menuHeight = 40;

  /// 底部导航条高度
  static const double bottomBarHeight = 85;
}
