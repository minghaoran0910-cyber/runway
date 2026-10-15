import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/dashboard_stats.dart';
import 'package:runway/ui/dashboard_cards.dart';
import 'package:runway/ui/home_page.dart';
import 'package:runway/ui/widgets/progress_ring.dart';

import 'fixed_clock.dart';

// SB-029 · 环形进度 + 跑道口径测试（合成数据；日期一律经 FixedClock 派生，
// 禁直调 DateTime.now/new Date；db 用内存库，测后不 close 见 widget_test 头注）.

/// 三桶种子（m0 本月 / m1 上月 / m2 上上月；类目均为刚性：食=必要/居=固定）.
/// m0=5000，m1=12000，m2=10000 → 可动用=2×(12000−5000)=14000，
/// 分母=上月刚性 12000 → 跑道 1.1667，增量同值（上上轮可动用=0）.
List<DashboardFlow> _seedThreeMonths(DateTime now) {
  DateTime m1(int day) => DateTime(now.year, now.month - 1, day);
  DateTime m2(int day) => DateTime(now.year, now.month - 2, day);
  return <DashboardFlow>[
    DashboardFlow(amountFen: 5000, category: '食', occurredAt: now),
    DashboardFlow(amountFen: 8000, category: '食', occurredAt: m1(10)),
    DashboardFlow(amountFen: 4000, category: '居', occurredAt: m1(20)),
    DashboardFlow(amountFen: 10000, category: '食', occurredAt: m2(10)),
  ];
}

void main() {
  test('SB-029 环形换算四态：0%/50%/100%/溢出', () {
    expect(runwayFraction(0), 0);
    expect(runwayFraction(-3), 0);
    expect(runwayFraction(6), 0.5);
    expect(runwayFraction(12), 1);
    // 溢出钳满环（数字照实显示，见 formatRunway）.
    expect(runwayFraction(24), 1);
    expect(runwayFraction(8.6), closeTo(8.6 / 12, 1e-9));
  });

  test('SB-029 跑道显示与增量符号', () {
    expect(formatRunway(8.625), '8.6');
    expect(formatRunway(0), '0.0');
    expect(formatRunwayDelta(0.42), '+0.4');
    expect(formatRunwayDelta(-0.32), '-0.3');
    expect(formatRunwayDelta(0), '+0.0');
  });

  test('SB-029 跑道口径：三桶月数据', () {
    final DateTime now = FixedClock.today();
    final DashboardSummary s = computeDashboard(
      flows: _seedThreeMonths(now),
      now: now,
    );
    expect(s.lastMonthFen, 12000);
    expect(s.monthRigidFen, 5000);
    expect(s.rigidPerMonthFen, 12000);
    expect(s.convertibleFen, 14000);
    expect(s.runwayMonths, moreOrLessEquals(14000 / 12000));
    expect(s.runwayDeltaMonths, moreOrLessEquals(14000 / 12000));
    expect(formatRunway(s.runwayMonths), '1.2');
  });

  test('SB-029 空态：跑道全零不误报', () {
    final DateTime now = FixedClock.today();
    final DashboardSummary s = computeDashboard(flows: const [], now: now);
    expect(s.runwayMonths, 0);
    expect(s.runwayDeltaMonths, 0);
    expect(s.convertibleFen, 0);
    expect(s.rigidPerMonthFen, 0);
    expect(runwayFraction(s.runwayMonths), 0);
  });

  testWidgets('SB-029 hero 渲染：环+琥珀行+金句+公式', (WidgetTester tester) async {
    final DateTime now = FixedClock.today();
    final DashboardSummary s = computeDashboard(
      flows: _seedThreeMonths(now),
      now: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardHero(summary: s, goalName: '家庭安全垫'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('heroRing')), findsOneWidget);
    expect(find.byKey(const Key('homeTotal')), findsOneWidget);
    expect(find.text('1.2'), findsOneWidget);
    expect(find.byKey(const Key('heroTitle')), findsOneWidget);
    expect(find.text('家庭安全垫'), findsOneWidget);
    expect(find.byKey(const Key('heroCompare')), findsOneWidget);
    expect(find.textContaining('比上月'), findsOneWidget);
    expect(find.byKey(const Key('heroVerdict')), findsOneWidget);
    expect(find.byKey(const Key('heroFormula')), findsOneWidget);
    expect(find.textContaining('可动用'), findsOneWidget);
    expect(find.textContaining('刚性'), findsOneWidget);
    // hero 内无"（示例数据）".
    expect(find.textContaining('示例数据'), findsNothing);
  });

  testWidgets('SB-029 hero 空态：标题回落+水印在页底', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(MaterialApp(home: HomePage(db: db)));
    await tester.pumpAndSettle();
    expect(find.text('本月支出'), findsOneWidget);
    expect(find.byKey(const Key('homeWatermark')), findsOneWidget);
    expect(find.text('示例数据'), findsOneWidget);
    // drift watch 流 unmount 后多 pump 消化零时长 Timer（见 dashboard_page_test 头注）.
    await tester.pumpWidget(Container());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  });

  testWidgets('SB-029 hero 深色模式同验', (WidgetTester tester) async {
    final DateTime now = FixedClock.today();
    final DashboardSummary s = computeDashboard(
      flows: _seedThreeMonths(now),
      now: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: DashboardHero(summary: s, goalName: '家庭安全垫'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('heroRing')), findsOneWidget);
    expect(find.byKey(const Key('heroCompare')), findsOneWidget);
    expect(find.byKey(const Key('heroFormula')), findsOneWidget);
  });

  testWidgets('SB-029 ProgressRing 溢出：弧满数字照实', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressRing(
            fraction: 2.5,
            center: Text('30.0', key: Key('ringNum')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ringNum')), findsOneWidget);
  });

  testWidgets('SB-033 环扫数字滚动：中间帧≠终值+终值收敛', (WidgetTester tester) async {
    final DateTime now = FixedClock.today();
    final DashboardSummary s = computeDashboard(
      flows: _seedThreeMonths(now),
      now: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardHero(summary: s, goalName: '家庭安全垫'),
        ),
      ),
    );
    // 首帧：从 0 起播，中间态≠终值（同步证据，监工实拍同口径）.
    await tester.pump(const Duration(milliseconds: 130));
    final Text mid = tester.widget<Text>(find.byKey(const Key('homeTotal')));
    expect(mid.data, isNot('1.2'));
    await tester.pumpAndSettle();
    expect(find.text('1.2'), findsOneWidget);
  });

  testWidgets('SB-046 起步文案数据态：有笔零攒出不再喊第一笔', (WidgetTester tester) async {
    const DashboardSummary s = DashboardSummary(
      todayCount: 2,
      todayFen: 5000,
      weekFen: 5000,
      monthFen: 5000,
      monthCount: 2,
      totalFen: 5000,
      fenByCategory: <String, int>{'食': 5000},
      top5: <TopEntry>[],
      otherShare: 0,
      otherFault: false,
      goalFen: null,
      goalProgress: 0,
      goalOver: false,
      convertibleFen: 0,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DashboardHero(summary: s)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('已记下、攒出在路上'), findsOneWidget);
    expect(find.text('记下第一笔，开始攒跑道'), findsNothing);
  });

  testWidgets('SB-046 起步文案数据态：零笔零攒出仍引导第一笔', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DashboardHero(summary: DashboardSummary.empty)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('记下第一笔，开始攒跑道'), findsOneWidget);
  });
}
