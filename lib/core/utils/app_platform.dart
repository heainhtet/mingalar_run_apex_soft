import 'dart:io';

abstract final class AppPlatform {
  static final String operatingSystem = Platform.operatingSystem;

  static final bool isIOS = operatingSystem == 'ios';
  static final bool isAndroid = operatingSystem == 'android';
}
