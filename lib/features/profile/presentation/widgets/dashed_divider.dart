import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    required this.color,
    this.dashWidth = 2,
    this.gapWidth = 3,
  });

  final Color color;
  final double dashWidth;
  final double gapWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DashedDividerPainter(
          color: color,
          dashWidth: dashWidth,
          gapWidth: gapWidth,
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter({
    required this.color,
    required this.dashWidth,
    required this.gapWidth,
  });

  final Color color;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += dashWidth + gapWidth) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) {
    return color != oldDelegate.color ||
        dashWidth != oldDelegate.dashWidth ||
        gapWidth != oldDelegate.gapWidth;
  }
}
