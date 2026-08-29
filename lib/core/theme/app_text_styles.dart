// import 'package:flutter/material.dart';

// class AppTextStyles {
//   // Poppins font family
//   static const String fontFamily = 'Poppins';

//   // Headlines
//   static TextStyle headlineLarge({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 32,
//       fontWeight: fontWeight ?? FontWeight.w700,
//       color: color,
//     );
//   }

//   static TextStyle headlineMedium({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 28,
//       fontWeight: fontWeight ?? FontWeight.w600,
//       color: color,
//     );
//   }

//   static TextStyle headlineSmall({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 24,
//       fontWeight: fontWeight ?? FontWeight.w600,
//       color: color,
//     );
//   }

//   // Title
//   static TextStyle titleLarge({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 22,
//       fontWeight: fontWeight ?? FontWeight.w600,
//       color: color,
//     );
//   }

//   static TextStyle titleMedium({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 18,
//       fontWeight: fontWeight ?? FontWeight.w500,
//       color: color,
//     );
//   }

//   static TextStyle titleSmall({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 16,
//       fontWeight: fontWeight ?? FontWeight.w500,
//       color: color,
//     );
//   }

//   // Body
//   static TextStyle bodyLarge({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 16,
//       fontWeight: fontWeight ?? FontWeight.w400,
//       color: color,
//     );
//   }

//   static TextStyle bodyMedium({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 14,
//       fontWeight: fontWeight ?? FontWeight.w400,
//       color: color,
//     );
//   }

//   static TextStyle bodySmall({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 12,
//       fontWeight: fontWeight ?? FontWeight.w400,
//       color: color,
//     );
//   }

//   // Label
//   static TextStyle labelLarge({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 14,
//       fontWeight: fontWeight ?? FontWeight.w500,
//       color: color,
//     );
//   }

//   static TextStyle labelMedium({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 12,
//       fontWeight: fontWeight ?? FontWeight.w500,
//       color: color,
//     );
//   }

//   static TextStyle labelSmall({
//     Color? color,
//     FontWeight? fontWeight,
//     double? fontSize,
//   }) {
//     return TextStyle(
//       fontFamily: fontFamily,
//       fontSize: fontSize ?? 10,
//       fontWeight: fontWeight ?? FontWeight.w500,
//       color: color,
//     );
//   }
// }
import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Poppins';

  // Base style to avoid repetition
  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      // Myanmar glyphs become visually disconnected with wide tracking.
      // Keep the shared value at the maximum that remains readable in both
      // supported languages.
      letterSpacing: 0.5,
    );
  }

  // Define specific weights mapped to your Manrope config
  static TextStyle thin({double? size, Color? color}) =>
      _base(fontSize: size ?? 12, fontWeight: FontWeight.w100, color: color);
  static TextStyle light({double? size, Color? color}) =>
      _base(fontSize: size ?? 14, fontWeight: FontWeight.w300, color: color);
  static TextStyle regular({double? size, Color? color}) =>
      _base(fontSize: size ?? 16, fontWeight: FontWeight.w400, color: color);
  static TextStyle medium({double? size, Color? color}) =>
      _base(fontSize: size ?? 16, fontWeight: FontWeight.w500, color: color);
  static TextStyle semiBold({double? size, Color? color}) =>
      _base(fontSize: size ?? 18, fontWeight: FontWeight.w600, color: color);
  static TextStyle bold({double? size, Color? color}) =>
      _base(fontSize: size ?? 20, fontWeight: FontWeight.w700, color: color);
  static TextStyle extraBold({double? size, Color? color}) =>
      _base(fontSize: size ?? 24, fontWeight: FontWeight.w800, color: color);
  static TextStyle extraBold1({double? size, Color? color}) =>
      _base(fontSize: size ?? 28, fontWeight: FontWeight.w900, color: color);
}
