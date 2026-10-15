// SB-004 · 记账领域模型（PRD §4：领域层不依赖 Flutter，本文件禁 import flutter）.
// 金额以分为单位（整数 >0）；类目 1–32 字符；来源默认 manual.

/// 默认类目（SB-028 统一为短名系，与规则引擎 ruleCategories 一致；
/// 存量长名经 canonicalCategory 归一显示，新数据一律短名）.
const List<String> defaultCategories = <String>['食', '行', '居', '玩', '用', '其他'];

/// 金额字符串 → 分（null = 非法）. 支持 "12.34"/"12"/"0.5"，前后空格容忍.
int? parseAmountToFen(String raw) {
  // SB-041 · 容忍千分位逗号（SB-033 formatFen 回填如 "1,299" 须能解析回分，
  // 否则目标编辑页预填大金额必校验失败）.
  final String s = raw.trim().replaceAll(',', '');
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

/// 分 → 显示串（"12.34"/"12"；千分位+tabular 由 UI 保证，见 SB-033）.
/// 全 App 唯一金额格式化入口，禁各页自造格式；负数保留符号（测试/退档链用）.
String formatFen(int fen) {
  final bool neg = fen < 0;
  final int abs = fen.abs();
  final int yuan = abs ~/ 100;
  final int rest = abs % 100;
  final String intPart = _groupThousands(yuan);
  final String dec;
  if (rest == 0) {
    dec = '';
  } else if (rest % 10 == 0) {
    dec = '.${rest ~/ 10}';
  } else {
    dec = '.${rest.toString().padLeft(2, '0')}';
  }
  return '${neg ? '-' : ''}$intPart$dec';
}

/// ¥ 前缀单一入口（SB-043 · 金额展示面统一货币符号）.
String formatFenYuan(int fen) => '¥${formatFen(fen)}';

/// 标题级金额：四舍五入到元 + ¥ 前缀（SB-043 · 标题数字去小数噪声）.
String formatFenHead(int fen) {
  final int yuan = (fen / 100).round();
  return '${yuan < 0 ? '-' : ''}¥${_groupThousands(yuan.abs())}';
}

/// 千分位分组（纯 Dart，禁 intl 新依赖）.
String _groupThousands(int n) {
  final String s = n.toString();
  if (s.length <= 3) return s;
  final StringBuffer b = StringBuffer();
  final int first = s.length % 3;
  if (first > 0) b.write(s.substring(0, first));
  for (int i = first; i < s.length; i += 3) {
    if (b.isNotEmpty) b.write(',');
    b.write(s.substring(i, i + 3));
  }
  return b.toString();
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
