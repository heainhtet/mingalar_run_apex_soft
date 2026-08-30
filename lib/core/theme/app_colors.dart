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

  /// Profile summary icon gradients and foregrounds
  static const Color totalRunIconGradientStart = Color(0x1A1819A7);
  static const Color totalRunIconGradientEnd = Color(0x661819A7);
  static const Color totalRunIconColor = Color(0xFF1819A7);

  static const Color distanceIconGradientStart = Color(0x33FFA500);
  static const Color distanceIconGradientEnd = Color(0x33FF8C00);
  static const Color distanceIconColor = Color(0xFF0783FF);

  static const Color caloriesIconGradientStart = Color(0x33FF4444);
  static const Color caloriesIconGradientEnd = Color(0x33CC0000);
  static const Color caloriesIconColor = Color(0xFFCC0000);

  static const Color paceIconGradientStart = Color(0x267B61FF);
  static const Color paceIconGradientEnd = Color(0x667B61FF);
  static const Color paceIconColor = Color(0xFF4936DF);

  /// Profile rank badge colors
  static const Color rankRibbonColor = Color(0xFF0A43A8);
  static const Color rankRibbonDarkColor = Color(0xFF052A6B);
  static const Color rankGoldStart = Color(0xFFFFE994);
  static const Color rankGoldEnd = Color(0xFFD3910B);
  static const Color rankGoldBorder = Color(0xFFA96905);

  ///White
  static const Color white = Color(0xFFFFFFFF);

  ///Black
  static const Color black = Color(0xFF000000);

  ///Qr Code
  static const Color qrCodeColor = Color(0xFF1C1B1F);

  /// Complete Record Color
  static const Color completeRecordColor = Color(0xFF05FF62);

  //Calender Card Border Color
  static const Color calenderCardBorderColor = Color(0xFF0690E1);

  ///Theme mode check
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Onboarding gradient start color.
  static Color onboardingGradientStartColor(BuildContext context) =>
      isDark(context) ? onboardingGradientStart : onboardingGradientStart;
}
