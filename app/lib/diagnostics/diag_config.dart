// SB-034 · 诊断通道配置（纯 Dart，本文件禁 import flutter；debug 态由调用方传入）.
// 三道闸：内容闸见 diag_mask；开关闸 = debug 硬闸 + 用户开关；时效闸 = 内置过期熄火.
// 注入：--dart-define=DIAG_ENDPOINT=... --dart-define=DIAG_TOKEN=... --dart-define=DIAG_EXPIRY_MS=...
// 未注入（空串 / 0）= 未配置 = 默认关闭（golden 默认环境零行为）.

/// 编译期注入值（生产读取；测试走纯函数传参覆盖）.
class DiagEnv {
  const DiagEnv._();

  static const String endpoint = String.fromEnvironment(
    'DIAG_ENDPOINT',
    defaultValue: '',
  );
  static const String token = String.fromEnvironment(
    'DIAG_TOKEN',
    defaultValue: '',
  );
  static const int expiryMs = int.fromEnvironment(
    'DIAG_EXPIRY_MS',
    defaultValue: 0,
  );
}

/// 是否过期（expiryMs <= 0 视为未配置即过期关闭；默认拒绝）.
bool diagIsExpired({required int expiryMs, required DateTime now}) {
  if (expiryMs <= 0) return true;
  return now.millisecondsSinceEpoch >= expiryMs;
}

/// 是否配齐（endpoint + token 非空）.
bool diagIsConfigured({required String endpoint, required String token}) {
  return endpoint.isNotEmpty && token.isNotEmpty;
}

/// 总闸（纯函数，可单测）：debug 开 + 用户开 + 配齐 + 未过期，四者缺一即关.
bool diagIsEnabled({
  required bool debugMode,
  required bool userEnabled,
  required String endpoint,
  required String token,
  required int expiryMs,
  required DateTime now,
}) {
  if (!debugMode) return false;
  if (!userEnabled) return false;
  if (!diagIsConfigured(endpoint: endpoint, token: token)) return false;
  if (diagIsExpired(expiryMs: expiryMs, now: now)) return false;
  return true;
}
