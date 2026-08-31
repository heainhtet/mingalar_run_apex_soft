import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Shared development logger. Never include coordinates or personal data.
final Logger logger = Logger(
  filter: DevelopmentFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 100,
    colors: !kIsWeb,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
