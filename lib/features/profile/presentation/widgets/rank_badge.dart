import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_rank.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.tier});

  final ProfileTier tier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 37,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _RankBadgePainter(tier)),
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
  const _RankBadgePainter(this.tier);

  final ProfileTier tier;

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

    final colors = switch (tier) {
      ProfileTier.bronze => const [Color(0xFFF0B68B), Color(0xFF9A4B1E)],
      ProfileTier.silver => const [Color(0xFFF3F6FA), Color(0xFF8B9AAD)],
      ProfileTier.gold => const [
        AppColors.rankGoldStart,
        AppColors.rankGoldEnd,
      ],
      ProfileTier.platinum => const [Color(0xFFE9E8FF), Color(0xFF7167C9)],
      ProfileTier.diamond => const [Color(0xFFC4F7FF), Color(0xFF1689AE)],
    };
    final border = switch (tier) {
      ProfileTier.bronze => const Color(0xFF7A3514),
      ProfileTier.silver => const Color(0xFF687789),
      ProfileTier.gold => AppColors.rankGoldBorder,
      ProfileTier.platinum => const Color(0xFF5147A1),
      ProfileTier.diamond => const Color(0xFF086C91),
    };
    final shieldPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Offset.zero & size);
    canvas.drawPath(shield, shieldPaint);

    canvas.drawPath(
      shield,
      Paint()
        ..color = border
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
  bool shouldRepaint(covariant _RankBadgePainter oldDelegate) =>
      oldDelegate.tier != tier;
}
