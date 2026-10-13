import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/dashboard_stats.dart';
import 'package:runway/logic/weekly_trend.dart';

// SB-030 · 周趋势四态单测（空/单点/全平/极差大）+ 实算口径.
void main() {
  test('SB-030 空数据归一化为空', () {
    expect(normalizeTrend(<int>[]), isEmpty);
  });

  test('SB-030 全零画中线 0.5', () {
    final List<double> n = normalizeTrend(<int>[0, 0, 0, 0, 0, 0, 0]);
    expect(n, everyElement(0.5));
  });

  test('SB-030 单点 spike 归一为 0/1', () {
    final List<double> n = normalizeTrend(<int>[0, 0, 0, 5000, 0, 0, 0]);
    expect(n[3], 1.0);
    expect(n[0], 0.0);
    expect(n[6], 0.0);
  });

  test('SB-030 全平画中线 0.5', () {
    final List<double> n = normalizeTrend(<int>[
      3000,
      3000,
      3000,
      3000,
      3000,
      3000,
      3000,
    ]);
    expect(n, everyElement(0.5));
  });

  test('SB-030 极差大归一 0..1', () {
    final List<double> n = normalizeTrend(<int>[
      100,
      10000,
      200,
      50000,
      300,
      400,
      500,
    ]);
    expect(n[0], 0.0);
    expect(n[3], 1.0);
    for (final double v in n) {
      expect(v, inInclusiveRange(0.0, 1.0));
    }
  });

  test('SB-030 本周 7 天实算（周一→周日分桶）', () {
    // 2026-10-14 周三；本周一=10-12.
    final DateTime now = DateTime(2026, 10, 14, 12);
    final List<DashboardFlow> flows = <DashboardFlow>[
      DashboardFlow(
        amountFen: 5000,
        category: '食',
        occurredAt: DateTime(2026, 10, 12, 10),
      ),
      DashboardFlow(
        amountFen: 12000,
        category: '居',
        occurredAt: DateTime(2026, 10, 14, 9),
      ),
      DashboardFlow(
        amountFen: 10000,
        category: '行',
        occurredAt: DateTime(2026, 10, 5, 10),
      ),
    ];
    final List<int> daily = weekDailySpend(flows: flows, now: now);
    expect(daily.length, 7);
    expect(daily[0], 5000);
    expect(daily[2], 12000);
    expect(daily[1], 0);
    expect(daily.reduce((int a, int b) => a + b), 17000);
  });
}
