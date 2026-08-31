import 'dart:io';

/// Immutable platform facts read once during application startup.
///
/// Layout code can use these values without repeatedly consulting inherited
/// widgets or doing platform detection during rebuilds.
abstract final class AppPlatform {
  static final String operatingSystem = Platform.operatingSystem;

  static final bool isIOS = operatingSystem == 'ios';
  static final bool isAndroid = operatingSystem == 'android';
}
