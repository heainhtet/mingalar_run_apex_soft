import 'package:flutter/material.dart';

abstract final class AppColors {
  // ══════════════════════════════════════════
  //  DEFAULT THEME  — BACKGROUND
  // ══════════════════════════════════════════

  ///ONBOARDING SCREEN GRADIENT
  static const Color onboardingGradientStart = Color(0xFF0049FF);
  static const Color onboardingGradientEnd = Color(0xFF193CB8);
  // background: linear-gradient(135deg, #0049FF 0%, #193CB8 100%);

  ///HOME SCREEN GRADIENT
  static const Color homeGradientStart = Color(0xFF0049FF);
  static const Color homeGradientEnd = Color(0xFF1440AA);
  // background: linear-gradient(180deg, #0049FF 0%, #1440AA 116.73%);

  /// RUN SCREEN GRADIENT
  static const Color runGradientStart = Color(0xFF155DFC);
  static const Color runGradientEnd = Color(0xFF193CB8);
  // background: linear-gradient(135deg, #155DFC 0%, #193CB8 100%);

  /// PROFILE SCREEN GRADIENT
  static const Color profileGradientStart = Color(0xFF193CB8);
  static const Color profileGradientEnd = Color(0xFF155DFC);
  // background: linear-gradient(135deg, #193CB8 0%, #155DFC 100%);

  //Run screen top header background color
  static const Color topHeaderBackground = Color(0xFF001D68);

  // ══════════════════════════════════════════
  //  DEFAULT THEME — TEXT
  // ══════════════════════════════════════════

  /// Main text.
  static const Color defaultPrimaryText = Color(0xFFFFFFFF);

  /// Default black text
  static const Color defaultBlackText = Color(0xFF000000);

  /// Card Label Text.
  static const Color cardLabelText = Color(0xFF101828);

  /// Card Description Text.
  static const Color cardDescriptionText = Color(0xFF4A5565);

  /// Feature view all text HOME
  static const Color featureViewAllText = Color(0xFF6A6A6A);

  /// Default text color for onboarding welcome screen
  static const Color onBoardingWelcomeText = Color(0xFF155DFC);

  /// Counter text color
  static const Color counterTextColor = Color(0xFFA1A1A1);

  ///Score text color
  static const Color scoreTextColor = Color(0xFF333333);

  ///Score summary text color
  static const Color scoreSumLabelTextColor = Color(0xFF6A7282);
  // ══════════════════════════════════════════
  //  DEFAULT THEME — UI ELEMENTS
  // ══════════════════════════════════════════

  ///Home screen week days icon color
  static const Color inactiveIconColor = Color(0xFFD9D9D9);
  static const Color activeIconColor = Color(0xFFFAFAFA);

  ///Run screen tab indicator color
  static const Color tabIndicatorColor = Color(0xFF014AFE);

  ///Primary Button Color
  static const Color primaryButtonColor = Color(0xFF155DFC);

  /// Profile page tile color
  static const Color profileTileColor = Color(0xFF5A89FF);

  ///White
  static const Color white = Color(0xFFFFFFFF);

  ///Black
  static const Color black = Color(0xFF000000);

  ///Theme mode check
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Onboarding gradient start color.
  static Color onboardingGradientStartColor(BuildContext context) =>
      isDark(context) ? onboardingGradientStart : onboardingGradientStart;
}
