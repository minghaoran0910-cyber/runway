import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/dashboard_stats.dart';

// SB-006 · 看板聚合单测（合成数据，纯 Dart）.

List<DashboardFlow> _flows() {
  final DateTime now = DateTime(2026, 10, 10, 12);
  return <DashboardFlow>[
    DashboardFlow(amountFen: 5000, category: '食', occurredAt: now),
    DashboardFlow(
      amountFen: 3000,
      category: '行',
      occurredAt: now.subtract(const Duration(hours: 1)),
    ),
    DashboardFlow(
      amountFen: 2000,
      category: '其他',
      occurredAt: now.subtract(const Duration(days: 1)),
    ),
    DashboardFlow(
      amountFen: 90000,
      category: '居',
      occurredAt: DateTime(2026, 10, 1, 9),
    ),
    DashboardFlow(
      amountFen: 1000,
      category: '餐饮',
      occurredAt: DateTime(2026, 9, 20, 9),
    ),
  ];
}

void main() {
  test('SB-006 今日/本周/本月聚合', () {
    final DateTime now = DateTime(2026, 10, 10, 12);
    final DashboardSummary s = computeDashboard(flows: _flows(), now: now);
    expect(s.todayCount, 2);
    expect(s.todayFen, 8000);
    expect(s.monthFen, 5000 + 3000 + 2000 + 90000);
    expect(s.monthCount, 4);
    expect(s.weekFen, 5000 + 3000 + 2000);
    expect(s.totalFen, 5000 + 3000 + 2000 + 90000 + 1000);
  });

  test('SB-006 旧类目名归一 + Top5 排序', () {
    final DateTime now = DateTime(2026, 10, 10, 12);
    final DashboardSummary s = computeDashboard(flows: _flows(), now: now);
    // 餐饮(1000) 应归一为 食，与 5000 合并为 6000.
    expect(s.fenByCategory['食'], 6000);
    expect(s.fenByCategory.containsKey('餐饮'), isFalse);
    expect(s.top5.first.category, '居');
    expect(s.top5.length, lessThanOrEqualTo(5));
  });

  test('SB-006 其他占比>5%即故障；空库不误报', () {
    final DateTime now = DateTime(2026, 10, 10, 12);
    final DashboardSummary s = computeDashboard(
      flows: <DashboardFlow>[
        DashboardFlow(amountFen: 9000, category: '食', occurredAt: now),
        DashboardFlow(amountFen: 1000, category: '其他', occurredAt: now),
      ],
      now: now,
    );
    expect(s.otherShare, closeTo(0.1, 1e-9));
    expect(s.otherFault, isTrue);
    final DashboardSummary e = computeDashboard(
      flows: <DashboardFlow>[],
      now: now,
    );
    expect(e.otherShare, 0);
    expect(e.otherFault, isFalse);
    expect(e.top5, isEmpty);
  });

  test('SB-006 目标进度：未设为引导，设后算进度/超标', () {
    final DateTime now = DateTime(2026, 10, 10, 12);
    final DashboardSummary e = computeDashboard(flows: _flows(), now: now);
    expect(e.goalFen, isNull);
    expect(e.goalProgress, 0);
    final DashboardSummary g = computeDashboard(
      flows: _flows(),
      now: now,
      goalFen: 200000,
    );
    expect(
      g.goalProgress,
      closeTo((5000 + 3000 + 2000 + 90000) / 200000, 1e-9),
    );
    expect(g.goalOver, isFalse);
    final DashboardSummary o = computeDashboard(
      flows: _flows(),
      now: now,
      goalFen: 10000,
    );
    expect(o.goalProgress, 1.0);
    expect(o.goalOver, isTrue);
  });

  test('SB-006 性能：1 万条聚合 <1s', () {
    final DateTime now = DateTime(2026, 10, 10, 12);
    final List<DashboardFlow> big = List<DashboardFlow>.generate(
      10000,
      (int i) => DashboardFlow(
        amountFen: 100 + (i % 900),
        category: <String>['食', '行', '居', '玩', '用', '其他'][i % 6],
        occurredAt: now.subtract(Duration(minutes: i % 5000)),
      ),
    );
    final Stopwatch sw = Stopwatch()..start();
    final DashboardSummary s = computeDashboard(flows: big, now: now);
    sw.stop();
    expect(s.totalFen, greaterThan(0));
    expect(sw.elapsedMilliseconds, lessThan(1000));
  });
}
