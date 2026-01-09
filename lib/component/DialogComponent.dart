import 'package:flutter/material.dart';
import 'package:flutter_music_app/theme/ThemeSize.dart';

class DialogComponent extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? leftIcon;
  final Function? onClose;
  final double topMarginRatio;
  final bool showDivider;

  const DialogComponent({
    super.key,
    required this.title,
    required this.content,
    this.leftIcon,
    this.onClose,
    this.topMarginRatio = 0.2,
    this.showDivider = true
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topMargin = screenHeight * topMarginRatio;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 灰色透明遮罩层
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (onClose != null) {
                  onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ),

          // 弹出层内容
          Positioned(
            top: topMargin,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ThemeSize.bigRadius),
                  topRight: Radius.circular(ThemeSize.bigRadius),
                ),
              ),
              child: Column(
                children: [
                  // 标题栏
                  SizedBox(
                    height: ThemeSize.titleBarHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        leftIcon != null ?
                        Align(
                          alignment: Alignment.centerLeft,
                          child: leftIcon,
                        )
                            : const SizedBox(),
                        // 标题
                        Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: ThemeSize.middleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 关闭按钮
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              if (onClose != null) {
                                onClose!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 分隔线
                  showDivider ? const Divider(height: 1, thickness: 1) : const SizedBox(),

                  // 自定义内容区域
                  Expanded(
                    child: content,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}