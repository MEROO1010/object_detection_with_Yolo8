import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String message, {String tag = 'App'}) {
    if (kDebugMode) dev.log(message, name: tag);
  }

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'App',
  }) {
    dev.log(message, name: tag, error: error, stackTrace: stackTrace, level: 1000);
  }
}
