import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Poppins';

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
      letterSpacing: 0.5,
    );
  }

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
