import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/ThemeColors.dart';

enum Action {
  Ok,
  Cancel,
}

class CustomDialogComponent {
  final BuildContext context;
  final Widget Function(BuildContext) builder;
  final String name;
  final Function okCallback;

  CustomDialogComponent({
    required this.context,
    required this.builder,
    required this.name,
    required this.okCallback,
  });

  Future<void> show() async {
    final action = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(name),
          content: builder(context),
          actions: [
            CupertinoDialogAction(
              child: const Text('确认', style: TextStyle(color: ThemeColors.primary)),
              onPressed: () {
                Navigator.pop(context, Action.Ok);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, Action.Cancel);
              },
              child: const Text('取消', style: TextStyle(color: ThemeColors.warn)),
            ),
          ],
        );
      },
    );

    switch (action) {
      case Action.Ok:
        okCallback();
        break;
      case Action.Cancel:
        break;
      default:
    }
  }
}
