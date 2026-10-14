// SB-034 · 崩溃双挂（flutter 层；core 纯 Dart 可单测，本文件只做接线）.
// FlutterError + PlatformDispatcher 双挂，崩溃即发；旧 handler 原样保留；自体永不抛.

import 'package:flutter/foundation.dart';

import 'diag_reporter.dart';

class DiagHook {
  DiagHook._();

  static bool _installed = false;

  /// 安装（main 内 kDebugMode 门后调用一次；重复安装无操作）.
  static void install(DiagReporter reporter) {
    if (_installed) return;
    _installed = true;
    final FlutterExceptionHandler? prevFlutter = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      try {
        reporter.reportCrash(
          details.exception,
          details.stack ?? StackTrace.empty,
        );
      } catch (_) {
        // 诊断通道自体静默，保主流程.
      }
      if (prevFlutter != null) {
        prevFlutter(details);
      } else {
        FlutterError.presentError(details);
      }
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      try {
        reporter.reportCrash(error, stack);
      } catch (_) {
        // 诊断通道自体静默，保主流程.
      }
      return true;
    };
  }

  @visibleForTesting
  static void resetForTest() {
    _installed = false;
  }
}
