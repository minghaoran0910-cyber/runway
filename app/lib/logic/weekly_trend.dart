// SB-030 · 周趋势纯函数（本周 7 天每日支出 + 归一化，纯 Dart 禁 flutter）.
// 口径：每日支出=当日 transactions 金额合计（自然日）；周一起算复用 grain_report.weekStartFor，禁第二套周界.
// 归一化：empty/全平（含单点 spike 外其余 0 但 min==max 情况）→ 全 0.5 中线，避免除零；
//   极差大 → (v-min)/(max-min) 0..1.
import 'dashboard_stats.dart';
import 'grain_report.dart';

/// 本周 7 天每日支出（周一→周日，缺天为 0）.
List<int> weekDailySpend({
  required List<DashboardFlow> flows,
  required DateTime now,
}) {
  final DateTime start = weekStartFor(now);
  final List<int> out = List<int>.filled(7, 0);
  for (final DashboardFlow f in flows) {
    final DateTime d = DateTime(
      f.occurredAt.year,
      f.occurredAt.month,
      f.occurredAt.day,
    );
    final int idx = d.difference(start).inDays;
    if (idx >= 0 && idx < 7) {
      out[idx] += f.amountFen;
    }
  }
  return out;
}

/// 趋势归一化（0..1，供 TrendLine 纵坐标；空/全平→全 0.5）.
List<double> normalizeTrend(List<int> values) {
  if (values.isEmpty) return <double>[];
  int min = values.first;
  int max = values.first;
  for (final int v in values) {
    if (v < min) min = v;
    if (v > max) max = v;
  }
  if (max == min) {
    return List<double>.filled(values.length, 0.5);
  }
  final int span = max - min;
  return values.map((int v) => (v - min) / span).toList();
}
