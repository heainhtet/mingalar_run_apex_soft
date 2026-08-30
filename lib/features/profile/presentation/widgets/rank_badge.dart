import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 37,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _RankBadgePainter()),
          const Align(
            alignment: Alignment(0, -0.12),
            child: Icon(
              Icons.directions_run_rounded,
              size: 17,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadgePainter extends CustomPainter {
  const _RankBadgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ribbonPaint = Paint()..color = AppColors.rankRibbonColor;
    final darkRibbonPaint = Paint()..color = AppColors.rankRibbonDarkColor;

    canvas.drawPath(
      Path()
        ..moveTo(0, 9)
        ..lineTo(19, 9)
        ..lineTo(19, 27)
        ..lineTo(0, 27)
        ..lineTo(6, 18)
        ..close(),
      ribbonPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 9)
        ..lineTo(size.width - 19, 9)
        ..lineTo(size.width - 19, 27)
        ..lineTo(size.width, 27)
        ..lineTo(size.width - 6, 18)
        ..close(),
      ribbonPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(14, 9)
        ..lineTo(19, 9)
        ..lineTo(19, 15)
        ..close(),
      darkRibbonPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 14, 9)
        ..lineTo(size.width - 19, 9)
        ..lineTo(size.width - 19, 15)
        ..close(),
      darkRibbonPaint,
    );

    final shield = Path()
      ..moveTo(size.width / 2, 0.8)
      ..lineTo(49, 6.5)
      ..lineTo(47, 25)
      ..quadraticBezierTo(40, 32, size.width / 2, 36)
      ..quadraticBezierTo(22, 32, 15, 25)
      ..lineTo(13, 6.5)
      ..close();

    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.rankGoldStart, AppColors.rankGoldEnd],
      ).createShader(Offset.zero & size);
    canvas.drawPath(shield, shieldPaint);

    canvas.drawPath(
      shield,
      Paint()
        ..color = AppColors.rankGoldBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final innerShield = Path()
      ..moveTo(size.width / 2, 3.5)
      ..lineTo(46, 8)
      ..lineTo(44.4, 23.7)
      ..quadraticBezierTo(38.5, 29.2, size.width / 2, 32.8)
      ..quadraticBezierTo(23.5, 29.2, 17.6, 23.7)
      ..lineTo(16, 8)
      ..close();
    canvas.drawPath(
      innerShield,
      Paint()
        ..color = AppColors.white.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
