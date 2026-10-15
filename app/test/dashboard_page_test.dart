import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/budget_dao.dart';
import 'package:runway/logic/budget.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/home_page.dart';

import 'fixed_clock.dart';

// SB-006 · 看板 widget 测试（合成数据，内存库）.
// SB-038 · 首页大扫除后：首页=Hero+今日卡+最近3笔；Top5/目标/收口/冷静/
//   实验/预算已搬去"我的"(GoalPage)/账本页，首页断言同步改写.
// SB-038-RC1追补 · 裁A硬约束：「今天攒出」日载体行常驻首页（_HomeTodaySaved 卡）.
// drift watch 流说明见 widget_test.dart 文件头：unmount 后多 pump 消化零时长
// Timer；本文件 widget 测试同样不调 db.close.

Widget _wrap(AppDb db) {
  return MaterialApp(home: HomePage(db: db));
}

void _largeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

Future<void> _seed(AppDb db) async {
  // SB-025 · 相对种子经夹具（行为与直调一致）.
  final DateTime now = FixedClock.today();
  // SB-038-RC1追补 · 大月预算种子：日预算（310万/当月天数≈10万）−今日支出
  // 5.5万＝攒出正数，首页日载体行走 todaySaved 键（裁A常驻行可断言）.
  await db.upsertBudget(monthKey: monthKeyFor(now), budgetFen: 3100000);
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(5000),
      occurredAt: Value(now),
      category: const Value('食'),
      note: const Value('午餐'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(50000),
      occurredAt: Value(now),
      category: const Value('其他'),
      note: const Value('未知事项'),
      source: const Value('manual'),
    ),
  );
}

void main() {
  testWidgets('SB-038 首页=Hero+今日卡+最近3笔（搬家后契约）', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    await _seed(db);

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // 留存：Hero 环 + 今日卡 + 最近3笔标题.
    expect(find.byKey(const Key('heroRing')), findsOneWidget);
    expect(find.byKey(const Key('dashToday')), findsOneWidget);
    expect(find.byKey(const Key('recentTitle')), findsOneWidget);
    // SB-038-RC1追补 · 裁A日载体行常驻首页（大预算种子→攒出正数→todaySaved）.
    expect(find.byKey(const Key('todaySaved')), findsOneWidget);
    // 搬走：Top5/目标卡/预算区不在首页.
    expect(find.textContaining('Top5'), findsNothing);
    expect(find.byKey(const Key('dashGoalEmpty')), findsNothing);
    expect(find.byKey(const Key('budgetTitle')), findsNothing);
    // Hero 内分类故障态仍在（随 Hero 保留）.
    expect(find.byKey(const Key('dashOtherFault')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-038 首页空态：引导位 + 最近3笔标题', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byKey(const Key('emptyHint')), findsOneWidget);
    expect(find.byKey(const Key('dashOtherHealthy')), findsOneWidget);
    // SB-045 ① · 零值降噪：空库 share=0 → 占比字段整段不显示.
    expect(find.byKey(const Key('dashOtherShare')), findsNothing);
    expect(find.byKey(const Key('recentTitle')), findsOneWidget);
    expect(find.textContaining('Top5'), findsNothing);
    // SB-038-RC1追补 · 空库零日档：攒出 0→todaySavedZero+去向行仍常驻（不断线）.
    expect(find.byKey(const Key('todaySavedZero')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-038 我的页含搬家四区（功能零丢失）', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(MaterialApp(home: GoalPage(db: db)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    Future<void> scrollTo(Finder f) async {
      await tester.scrollUntilVisible(
        f,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
    }

    // 每日收口（开关行常在）/大额冷静/月度小实验/预算观察四区均在"我的"页.
    expect(find.byKey(const Key('dailyCloseSwitch')), findsOneWidget);
    await scrollTo(find.byKey(const Key('cooloffSwitch')));
    expect(find.byKey(const Key('cooloffSwitch')), findsOneWidget);
    await scrollTo(find.byKey(const Key('experimentTitle')));
    expect(find.byKey(const Key('experimentTitle')), findsOneWidget);
    await scrollTo(find.byKey(const Key('budgetTitle')));
    expect(find.byKey(const Key('budgetTitle')), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
