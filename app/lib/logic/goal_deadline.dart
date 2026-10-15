// SB-041 · 目标期限纯逻辑（ISO 日期串 yyyy-MM-dd，可空；DESIGN §7 得到框架，纯 Dart）.
// 口径：空=无期限（调用方不渲染该行）；合法日期→"预计 M月d日攒到"（得到框架，零禁词）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

/// 期限合法性（可空；填了须为 yyyy-MM-dd 合法日历日期）.
String? validateDeadlineDate(String raw) {
  final String t = raw.trim();
  if (t.isEmpty) return null;
  final RegExpMatch? m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(t);
  if (m == null) return '期限须为 yyyy-MM-dd 日期';
  final int y = int.parse(m.group(1)!);
  final int mo = int.parse(m.group(2)!);
  final int d = int.parse(m.group(3)!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return '期限须为 yyyy-MM-dd 日期';
  final DateTime dt = DateTime(y, mo, 1).add(Duration(days: d - 1));
  if (dt.year != y || dt.month != mo || dt.day != d) {
    return '期限须为 yyyy-MM-dd 日期';
  }
  return null;
}

/// 归一化（空→null；合法→yyyy-MM-dd；非法→null，调用方须先 validate）.
String? normalizeDeadline(String raw) {
  final String t = raw.trim();
  if (t.isEmpty) return null;
  if (validateDeadlineDate(t) != null) return null;
  return t;
}

/// 解析 ISO 日期串（空/非法→null）.
DateTime? parseDeadline(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  if (validateDeadlineDate(raw) != null) return null;
  return DateTime.parse(raw.trim());
}

/// 目标卡期限行文案（得到框架；空/非法→''，调用方不渲染该行）.
String formatDeadlineLine(String? raw) {
  final DateTime? dt = parseDeadline(raw);
  if (dt == null) return '';
  return '预计 ${dt.month}月${dt.day}日攒到';
}
