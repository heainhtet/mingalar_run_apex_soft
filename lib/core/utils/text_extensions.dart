import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension TextStyleHelpers on TextStyle {
  // Color Helpers
  TextStyle get white => copyWith(color: AppColors.defaultPrimaryText);
  TextStyle get black => copyWith(color: AppColors.defaultBlackText);
  TextStyle get primary => copyWith(color: AppColors.defaultPrimaryText);

  // Size Helper
  TextStyle s(double size) => copyWith(fontSize: size);

  // Weight Helpers (Since we are using Manrope)
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);
}
