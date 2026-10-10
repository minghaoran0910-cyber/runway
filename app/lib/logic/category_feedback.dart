// SB-005 · 纠正回写 + 其他占比汇总（PRD §2 纠偏固化 / §3 其他>5%故障，纯 Dart）.
// 本文件禁 import flutter；依赖同层 category_rules（纯 Dart → 纯 Dart，方向合规）.

import 'category_rules.dart';

/// 纠正表：用户手工纠正一次，同类商户/关键词下次自动生效（卡验收 2）.
/// 键为归一化（去空格+小写）后的商户/备注；商户命中优先于备注.
/// 会话级内存存储（跨重启持久化待 G4，见 REVIEW_REQUEST 偏差声明 D1）.
class CategoryCorrections {
  final Map<String, String> _byMerchant = <String, String>{};
  final Map<String, String> _byNote = <String, String>{};

  static String normalize(String s) => s.trim().toLowerCase();

  /// 记录一次手工纠正（商户/备注至少其一非空，否则无键可存直接返回）.
  void record({
    String merchant = '',
    String note = '',
    required String category,
  }) {
    final String m = normalize(merchant);
    if (m.isNotEmpty) _byMerchant[m] = category;
    final String n = normalize(note);
    if (n.isNotEmpty) _byNote[n] = category;
  }

  /// 查询纠正（供 [classifyTransaction] 作 correctionLookup 直接传入）.
  String? lookup({required String merchant, required String note}) {
    final String m = normalize(merchant);
    if (m.isNotEmpty && _byMerchant.containsKey(m)) return _byMerchant[m];
    final String n = normalize(note);
    if (n.isNotEmpty && _byNote.containsKey(n)) return _byNote[n];
    return null;
  }

  int get size => _byMerchant.length + _byNote.length;
}

/// 类目金额汇总（卡验收 3：为 SB-006 看板与 G5 指标供数）.
class CategorySummary {
  const CategorySummary({required this.fenByCategory, required this.totalFen});

  final Map<String, int> fenByCategory;
  final int totalFen;

  int get otherFen => fenByCategory[otherCategory] ?? 0;

  double get otherShare => totalFen <= 0 ? 0 : otherFen / totalFen;

  /// PRD §3：其他金额占比 >5% 即分类系统故障.
  bool get otherFault => otherShare > 0.05;
}

/// 对一批（金额分，类目）做汇总；旧类目名自动归一（存量兼容）.
CategorySummary summarizeFlows(
  Iterable<({int amountFen, String category})> flows,
) {
  final Map<String, int> map = <String, int>{};
  int total = 0;
  for (final ({int amountFen, String category}) f in flows) {
    final String c = canonicalCategory(f.category);
    map.update(c, (int v) => v + f.amountFen, ifAbsent: () => f.amountFen);
    total += f.amountFen;
  }
  return CategorySummary(fenByCategory: map, totalFen: total);
}
