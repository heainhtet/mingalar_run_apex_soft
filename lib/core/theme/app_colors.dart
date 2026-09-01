import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color onboardingGradientStart = Color(0xFF0049FF);
  static const Color onboardingGradientEnd = Color(0xFF193CB8);

  static const Color homeGradientStart = Color(0xFF0049FF);
  static const Color homeGradientEnd = Color(0xFF1440AA);

  static const Color runGradientStart = Color(0xFF155DFC);
  static const Color runGradientEnd = Color(0xFF193CB8);

  static const Color profileGradientStart = Color(0xFF193CB8);
  static const Color profileGradientEnd = Color(0xFF155DFC);

  static const Color topHeaderBackground = Color(0xFF001D68);

  static const Color defaultPrimaryText = Color(0xFFFFFFFF);
  static const Color defaultBlackText = Color(0xFF000000);
  static const Color cardLabelText = Color(0xFF101828);
  static const Color cardDescriptionText = Color(0xFF4A5565);
  static const Color featureViewAllText = Color(0xFF6A6A6A);
  static const Color onBoardingWelcomeText = Color(0xFF155DFC);
  static const Color counterTextColor = Color(0xFFA1A1A1);
  static const Color scoreTextColor = Color(0xFF333333);
  static const Color scoreSumLabelTextColor = Color(0xFF6A7282);

  static const Color inactiveIconColor = Color(0xFFD9D9D9);
  static const Color activeIconColor = Color(0xFFFAFAFA);
  static const Color tabIndicatorColor = Color(0xFF014AFE);
  static const Color primaryButtonColor = Color(0xFF155DFC);
  static const Color profileTileColor = Color(0xFF5A89FF);

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

  static const Color rankRibbonColor = Color(0xFF0A43A8);
  static const Color rankRibbonDarkColor = Color(0xFF052A6B);
  static const Color rankGoldStart = Color(0xFFFFE994);
  static const Color rankGoldEnd = Color(0xFFD3910B);
  static const Color rankGoldBorder = Color(0xFFA96905);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color qrCodeColor = Color(0xFF1C1B1F);
  static const Color completeRecordColor = Color(0xFF05FF62);
  static const Color calenderCardBorderColor = Color(0xFF0690E1);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static const Color _darkPage = Color(0xFF081126);
  static const Color _darkSurface = Color(0xFF121C33);
  static const Color _darkSurfaceMuted = Color(0xFF1A2742);
  static const Color _darkPrimaryText = Color(0xFFF5F7FF);
  static const Color _darkSecondaryText = Color(0xFFAEB9CF);
  static const Color _darkTertiaryText = Color(0xFF7E8AA3);
  static const Color _darkDivider = Color(0xFF2B3B5B);
  static const Color _darkHomeGradientStart = Color(0xFF102D83);
  static const Color _darkHomeGradientEnd = Color(0xFF081840);
  static const Color _darkRunGradientStart = Color(0xFF123994);
  static const Color _darkRunGradientEnd = Color(0xFF0B1F58);
  static const Color _darkProfileGradientStart = Color(0xFF112C78);
  static const Color _darkProfileGradientEnd = Color(0xFF0B245F);

  static Color pageBackground(BuildContext context) =>
      isDark(context) ? _darkPage : white;

  static Color surface(BuildContext context) =>
      isDark(context) ? _darkSurface : white;

  static Color mutedSurface(BuildContext context) => isDark(context)
      ? _darkSurfaceMuted
      : scoreSumLabelTextColor.withAlpha(13);

  static Color primaryText(BuildContext context) =>
      isDark(context) ? _darkPrimaryText : cardLabelText;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? _darkSecondaryText : scoreSumLabelTextColor;

  static Color tertiaryText(BuildContext context) =>
      isDark(context) ? _darkTertiaryText : featureViewAllText;

  static Color divider(BuildContext context) =>
      isDark(context) ? _darkDivider : scoreSumLabelTextColor.withAlpha(48);

  static Color shadow(BuildContext context, {int lightAlpha = 26}) =>
      isDark(context) ? black.withAlpha(110) : black.withAlpha(lightAlpha);

  static List<Color> homeGradient(BuildContext context) => isDark(context)
      ? const [_darkHomeGradientStart, _darkHomeGradientEnd]
      : const [homeGradientStart, homeGradientEnd];

  static List<Color> runGradient(BuildContext context) => isDark(context)
      ? const [_darkRunGradientStart, _darkRunGradientEnd]
      : const [runGradientStart, runGradientEnd];

  static List<Color> profileGradient(BuildContext context) => isDark(context)
      ? const [_darkProfileGradientStart, _darkProfileGradientEnd]
      : const [profileGradientStart, profileGradientEnd];

  static Color navigationBackground(BuildContext context) =>
      isDark(context) ? const Color(0xFF0A1D50) : tabIndicatorColor;

  static Color onboardingGradientStartColor(BuildContext context) =>
      isDark(context) ? onboardingGradientStart : onboardingGradientStart;
}
