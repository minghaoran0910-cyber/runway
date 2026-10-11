// SB-020 · 常买价格眼引擎（PRD §2 看见层 / §5 全本地；纯 Dart，禁 import flutter）.
// 聚合键 = 类目原文 trim + '｜' + 备注原文 trim，精确匹配，禁模糊合并.
// 备注空即无键（不合并所有空备注）；类目空即无键.
// ≥3 条同键才出统计；<3 条返回 null（不显示不猜）.

import 'entry.dart';

/// 价格键：null = 无键（备注空/类目空，不参与统计）.
String? priceKeyFor({required String category, required String note}) {
  final String c = category.trim();
  final String n = note.trim();
  if (c.isEmpty || n.isEmpty) return null;
  return '$c｜$n';
}

/// 同键价格统计（最近 10 笔为走势样本，时间倒序输入亦可）.
class PriceStats {
  const PriceStats({
    required this.key,
    required this.count,
    required this.avgFen,
    required this.minFen,
    required this.latestFen,
    required this.medianFen,
    required this.recentFen,
  });

  final String key;
  final int count;
  final int avgFen;
  final int minFen;
  final int latestFen;
  final int medianFen;

  /// 最近 ≤10 笔金额（按输入顺序取尾部；调用方保证时间顺序）.
  final List<int> recentFen;
}

/// ≥3 条出统计，否则 null.
PriceStats? summarizePrices({required String key, required List<int> amounts}) {
  if (amounts.length < 3) return null;
  int sum = 0;
  int min = amounts.first;
  for (final int a in amounts) {
    sum += a;
    if (a < min) min = a;
  }
  final int avg = sum ~/ amounts.length;
  final List<int> sorted = List<int>.from(amounts)..sort();
  final int median = sorted[sorted.length ~/ 2];
  final int start = amounts.length > 10 ? amounts.length - 10 : 0;
  return PriceStats(
    key: key,
    count: amounts.length,
    avgFen: avg,
    minFen: min,
    latestFen: amounts.last,
    medianFen: median,
    recentFen: amounts.sublist(start),
  );
}

/// 交易行按价格键分组（只收有键行；金额按输入顺序保留）.
Map<String, List<int>> groupByPriceKey(
  List<({String category, String note, int amountFen})> rows,
) {
  final Map<String, List<int>> out = <String, List<int>>{};
  for (final r in rows) {
    final String? k = priceKeyFor(category: r.category, note: r.note);
    if (k == null) continue;
    out.putIfAbsent(k, () => <int>[]).add(r.amountFen);
  }
  return out;
}

/// 同键全部统计（<3 条的键直接丢弃，不猜）.
Map<String, PriceStats> summarizeAll(
  List<({String category, String note, int amountFen})> rows,
) {
  final Map<String, List<int>> groups = groupByPriceKey(rows);
  final Map<String, PriceStats> out = <String, PriceStats>{};
  for (final MapEntry<String, List<int>> e in groups.entries) {
    final PriceStats? s = summarizePrices(key: e.key, amounts: e.value);
    if (s != null) out[e.key] = s;
  }
  return out;
}

/// "较均价 ±X"中性陈述（只陈述，无说教、无禁词）.
/// 0 差返回"与均价持平".
String describeVsAvg({required int currentFen, required int avgFen}) {
  final int diff = currentFen - avgFen;
  if (diff == 0) return '与均价持平';
  final String sign = diff > 0 ? '+' : '-';
  final int abs = diff.abs();
  return '较均价 $sign${formatFen(abs)}';
}

/// 目标单价联动：手动锁定优先（manual 非空即用），否则跟随该键中位数.
/// 两者皆空返回 null（不猜）.
int? resolveGoalPrice({int? manualPriceFen, int? followMedianFen}) {
  if (manualPriceFen != null && manualPriceFen > 0) return manualPriceFen;
  if (followMedianFen != null && followMedianFen > 0) return followMedianFen;
  return null;
}
