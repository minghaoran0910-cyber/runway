import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/dashboard_stats.dart';

import 'fixed_clock.dart';

// SB-012 · 性能预算单测（合成 1 万条库，纯函数口径）：
// 1. 看板聚合（冷启动数据通路代理）<1.5s；2. "其他"占比 <5%（SB-005 口径复用）.
// 真机冷启动/帧 trace/包体由 tool/perf_check.sh + 监工真机走查留数，本文件只锁可测部分.

List<DashboardFlow> _syntheticFlows(int n, {double otherRatio = 0.02}) {
  final DateTime now = FixedClock.today();
  const List<String> cats = <String>['食', '行', '用', '居', '玩'];
  final List<DashboardFlow> out = <DashboardFlow>[];
  final int otherEvery = (1 / otherRatio).round();
  for (int i = 0; i < n; i++) {
    final bool isOther = i % otherEvery == 0;
    out.add(
      DashboardFlow(
        amountFen: 100 + (i % 900),
        category: isOther ? '其他' : cats[i % cats.length],
        occurredAt: now.subtract(Duration(hours: i % 72)),
      ),
    );
  }
  return out;
}

void main() {
  test('SB-012 性能预算：1 万条聚合 <1.5s', () {
    final List<DashboardFlow> flows = _syntheticFlows(10000);
    final DateTime now = FixedClock.today();
    final Stopwatch sw = Stopwatch()..start();
    final DashboardSummary s = computeDashboard(
      flows: flows,
      now: now,
      goalFen: 1000000,
    );
    sw.stop();
    expect(s.monthCount, greaterThan(0));
    expect(
      sw.elapsedMilliseconds,
      lessThan(1500),
      reason: '1 万条聚合 ${sw.elapsedMilliseconds}ms 超预算 1500ms',
    );
  });

  test('SB-012 "其他"占比 <5%（合成 2% 数据集）', () {
    final List<DashboardFlow> flows = _syntheticFlows(10000);
    final DashboardSummary s = computeDashboard(
      flows: flows,
      now: FixedClock.today(),
    );
    expect(s.otherShare, lessThan(0.05));
    expect(s.otherFault, isFalse);
  });
}
