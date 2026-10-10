// SB-004 · 记账领域模型（PRD §4：领域层不依赖 Flutter，本文件禁 import flutter）.
// 金额以分为单位（整数 >0）；类目 1–32 字符；来源默认 manual.

/// 默认类目（合成占位，6 项；中性瓦片+文字，未定色板前不引颜色）.
const List<String> defaultCategories = <String>[
  '餐饮',
  '交通',
  '购物',
  '居住',
  '娱乐',
  '其他',
];

/// 金额字符串 → 分（null = 非法）. 支持 "12.34"/"12"/"0.5"，前后空格容忍.
int? parseAmountToFen(String raw) {
  final String s = raw.trim();
  if (s.isEmpty) return null;
  if (s.startsWith('-') || s.startsWith('+')) return null;
  final List<String> parts = s.split('.');
  if (parts.length > 2) return null;
  if (parts[0].isEmpty && (parts.length == 1 || parts[1].isEmpty)) return null;
  final RegExp digits = RegExp(r'^\d+$');
  if (!digits.hasMatch(parts[0].isEmpty ? '0' : parts[0])) return null;
  final int yuan = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? -1;
  if (yuan < 0) return null;
  int fen = yuan * 100;
  if (parts.length == 2) {
    final String dec = parts[1];
    if (dec.isEmpty) return null;
    if (!digits.hasMatch(dec) || dec.length > 2) return null;
    fen += dec.length == 1 ? int.parse(dec) * 10 : int.parse(dec);
  }
  if (fen <= 0) return null;
  if (fen > 100000000) return null; // 上限 100 万，防误触.
  return fen;
}

/// 分 → 显示串（"12.34"/"12"）.
String formatFen(int fen) {
  final int yuan = fen ~/ 100;
  final int rest = fen % 100;
  if (rest == 0) return '$yuan';
  if (rest % 10 == 0) return '$yuan.${rest ~/ 10}';
  return '$yuan.${rest.toString().padLeft(2, '0')}';
}

/// 领域校验：返回 null = 合法，否则为错误文案.
String? validateEntry({
  required int? amountFen,
  required String category,
  required String note,
}) {
  if (amountFen == null || amountFen <= 0) return '金额须大于 0';
  if (category.isEmpty || category.length > 32) return '类目为 1–32 字';
  if (note.length > 200) return '备注最多 200 字';
  return null;
}

/// 不可变记账草稿（UI 与 DAO 之间传递）.
class EntryDraft {
  EntryDraft({
    required this.amountFen,
    required this.category,
    this.note = '',
    this.source = 'manual',
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  final int amountFen;
  final String category;
  final String note;
  final String source;
  final DateTime occurredAt;

  String? validate() =>
      validateEntry(amountFen: amountFen, category: category, note: note);
}

EntryDraft draftNow({
  required int amountFen,
  required String category,
  String note = '',
  String source = 'manual',
}) {
  return EntryDraft(
    amountFen: amountFen,
    category: category,
    note: note,
    source: source,
    occurredAt: DateTime.now(),
  );
}
