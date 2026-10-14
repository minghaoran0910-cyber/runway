// SB-034 · 金额脱敏（纯 Dart，禁 import flutter）.
// 口径：保首位数字 + 位数，其余位以 □ 覆盖；账本原文永不上传，上报前金额必经本函数.
// 例：3612000 分 -> '¥3□□□□□□'；0 -> '¥0'；-1234 -> '-¥1□□□'.
// 文案禁词复用成就表（achievementBannedWords），不另建第二套.

/// 分 -> 脱敏串（首位 + □；单数字位原样，量级无隐私可藏）.
String maskAmountFen(int fen) {
  if (fen == 0) return '¥0';
  final bool neg = fen < 0;
  final String digits = fen.abs().toString();
  final String body = digits.length == 1
      ? digits
      : '${digits[0]}${'□' * (digits.length - 1)}';
  return '${neg ? '-' : ''}¥$body';
}

/// 断言串中不含原值数字体（单数字位除外；供测试与上报前自检用）.
bool maskedHidesRaw({required int fen, required String masked}) {
  if (fen.abs() < 10) return true;
  return !masked.contains(fen.abs().toString());
}
