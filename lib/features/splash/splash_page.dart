import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/assets_constant.dart';
import '../../core/database/app_preferences.dart';
import '../../core/routers/app_router.gr.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/text_extensions.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _brandOffset;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.72, curve: Curves.easeOutBack),
      ),
    );
    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );
    _brandOffset = Tween<Offset>(begin: const Offset(0, 0.24), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.32, 1, curve: Curves.easeOutCubic),
          ),
        );
    _controller.forward();
    _navigationTimer = Timer(
      const Duration(milliseconds: 2300),
      _navigateFromSplash,
    );
  }

  void _navigateFromSplash() {
    if (!mounted) return;
    final preferences = ref.read(appPreferencesProvider);
    context.router.replaceAll([
      if (preferences.hasCompletedOnboarding)
        const WrapperRoute()
      else
        const OnBoardingRoute(),
    ]);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingGradientEnd,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.onboardingGradientStart,
              AppColors.onboardingGradientEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return _SplashBackground(progress: _controller.value);
                },
              ),
            ),
            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _logoScale,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                18 *
                                    (1 -
                                        Curves.easeOutCubic.transform(
                                          _controller.value,
                                        )),
                              ),
                              child: Container(
                                width: 132,
                                height: 132,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withAlpha(24),
                                  borderRadius: BorderRadius.circular(36),
                                  border: Border.all(
                                    color: AppColors.white.withAlpha(50),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withAlpha(34),
                                      blurRadius: 32,
                                      offset: const Offset(0, 18),
                                    ),
                                    BoxShadow(
                                      color: AppColors.white.withAlpha(
                                        (10 + (_controller.value * 18)).round(),
                                      ),
                                      blurRadius: 38,
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  AssetsConstant.appLogo,
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SlideTransition(
                            position: _brandOffset,
                            child: Column(
                              children: [
                                Text(
                                  'onboarding.appName'.tr(),
                                  style: AppTextStyles.semiBold().white
                                      .s(32)
                                      .copyWith(
                                        color: AppColors.defaultPrimaryText,
                                        height: 1,
                                        letterSpacing: -0.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  'onboarding.clubName'.tr(),
                                  style: AppTextStyles.regular().white
                                      .s(14)
                                      .copyWith(
                                        color: AppColors.defaultPrimaryText
                                            .withAlpha(190),
                                        height: 1,
                                        letterSpacing: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SplashBackgroundPainter(progress));
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(progress);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.white.withAlpha((7 + (eased * 13)).round());
    final center = Offset(size.width * 0.5, size.height * 0.46);
    for (final radius in [150.0, 230.0, 320.0]) {
      canvas.drawCircle(center, radius * (0.88 + (eased * 0.12)), paint);
    }

    final linePaint = Paint()
      ..color = AppColors.white.withAlpha((eased * 24).round());
    final travel = (1 - eased) * size.width * 0.18;
    final lineY = center.dy;
    for (var index = 0; index < 3; index++) {
      final width = 42.0 + (index * 24);
      final y = lineY - 58 + (index * 44);
      final left = size.width * 0.08 - travel - (index * 10);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, y, width, 3),
        const Radius.circular(999),
      );
      canvas.drawRRect(rect, linePaint);

      final mirroredLeft = size.width - left - width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(mirroredLeft, y, width, 3),
          const Radius.circular(999),
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) {
    return (oldDelegate.progress - progress).abs() > 1 / (math.pi * 1000);
  }
}
