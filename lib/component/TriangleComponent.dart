import 'package:flutter/material.dart';
import 'dart:ui';

class TriangleComponent extends StatelessWidget {
  final double size;
  final Color color;

  const TriangleComponent({
    super.key,
    this.size = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrianglePainter(color: color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // 从左上角开始绘制三角形
    path.moveTo(0, size.height / 2); // 左顶点（三角形尖端）
    path.lineTo(size.width, 0);      // 右上角
    path.lineTo(size.width, size.height); // 右下角
    path.close(); // 闭合路径

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}