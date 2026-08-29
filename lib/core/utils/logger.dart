import 'dart:developer';

import 'package:flutter/foundation.dart';

final logger = AppLogger.instance;

class AppLogger {
  AppLogger._();
  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  void d(String message) {
    if (kDebugMode) {
      log(message);
    }
  }

  void e(String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      log(message, stackTrace: stackTrace);
    }
  }

  void i(String message) {
    if (kDebugMode) {
      log(message);
    }
  }

  void w(String message) {
    if (kDebugMode) {
      log(message);
    }
  }
}
