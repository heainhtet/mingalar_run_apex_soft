import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/routers/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/onboarding_content_card.dart';
import '../widgets/onboarding_header.dart';

@RoutePage()
class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  const Positioned(
                    top: 36,
                    left: 24,
                    right: 24,
                    child: _EntranceAnimation(
                      offset: Offset(0, -0.12),
                      child: OnboardingHeader(),
                    ),
                  ),
                  Positioned(
                    top: constraints.maxHeight * 0.33,
                    left: 22,
                    right: 22,
                    bottom: 0,
                    child: _EntranceAnimation(
                      offset: const Offset(0, 0.06),
                      child: OnboardingContentCard(
                        onGetStarted: () => _continueToApp(context),
                        onSignIn: () => _continueToApp(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _continueToApp(BuildContext context) {
    context.router.replaceAll([const WrapperRoute()]);
  }
}

class _EntranceAnimation extends StatelessWidget {
  const _EntranceAnimation({required this.child, required this.offset});

  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: FractionalTranslation(
            translation: Offset(
              offset.dx * (1 - value),
              offset.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
