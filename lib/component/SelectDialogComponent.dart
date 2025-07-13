import 'package:flutter/material.dart';
import '../theme/ThemeSize.dart';
import '../theme/ThemeColors.dart';
import '../theme/ThemeStyle.dart';

class BottomSelectionDialog {
  static void show({
    required BuildContext context,
    required List<String> options,
    required Function(String) onTap,
  }) {
    const divider = Divider(height: 1, color: ThemeColors.borderColor);

    // 构建选项列表
    final optionWidgets = options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Column(
        children: [
          InkWell(
            child: Container(
              padding: ThemeStyle.padding,
              alignment: Alignment.center,
              child: Text(
                option
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onTap(option);
            },
          ),
          if (index != options.length - 1) divider,
        ],
      );
    }).toList();

    showModalBottomSheet(
      backgroundColor:Colors.white,
      context: context,
      isScrollControlled: false,
      builder: (ctx) {
        return Container(
          color: ThemeColors.grey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: const EdgeInsets.only(
                      left: ThemeSize.containerPadding,
                      right: ThemeSize.containerPadding),
                  decoration: const BoxDecoration(
                    color: ThemeColors.colorWhite,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ThemeSize.middleRadius)),
                  ),
                  child: Column(children: optionWidgets)),
              InkWell(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(ThemeSize.containerPadding),
                  decoration: const BoxDecoration(
                    color: ThemeColors.colorWhite,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ThemeSize.middleRadius)),
                  ),
                  padding: const EdgeInsets.all(ThemeSize.containerPadding),
                  child: const Center(child: Text('取消')),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }
}