import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

import 'fixed_clock.dart';

// SB-007 widget + Golden：目标设定页 CRUD 联动 + Light/Dark × 空/有四组.
// 基线 golden/sb007/；生成：cd app && flutter test --update-goldens test/golden_goal_test.dart
// 注意：GoalPage 用 db.watchGoals/watchAll，测后不调 close（见 widget_test.dart 头注）.

class GoalBoard extends StatelessWidget {
  const GoalBoard({super.key, required this.isDark, required this.db});

  final bool isDark;
  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: GoalPage(db: db),
    );
  }
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  // SB-023 · 相对种子经夹具封装（保本月/上月关系，月界稳定；页渲染仅数字无日期串）.
  final DateTime now = FixedClock.today();
  final DateTime lastMonth = DateTime(now.year, now.month - 1, 15, 12);
  await db.insertGoal(
    GoalsCompanion(
      name: const Value('攒手机'),
      targetFen: const Value(399900),
      priceName: const Value('奶茶'),
      priceFen: const Value(1800),
    ),
  );
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
      amountFen: const Value(100000),
      occurredAt: Value(lastMonth),
      category: const Value('居'),
      note: const Value('房租'),
      source: const Value('manual'),
    ),
  );
  return db;
}

Future<AppDb> _seedDoneDb() async {
  // SB-031 · 达成态合成夹具：目标 100 元（10000 分），上月支出 6000 分、
  // 本月 0 → convertible=12000 ≥ 目标，达成态（禁真实账目）.
  // SB-032 · 达成已庆祝预置：门闩视作已弹过，golden 只收稳定达成页；
  // 庆祝弹层禁入镜，浅/深两帧底板对齐（static 会话跨测泄漏一并隔离）.
  final AppDb db = AppDb.memoryForTest();
  final DateTime now = FixedClock.today();
  final DateTime lastMonth = DateTime(now.year, now.month - 1, 15, 12);
  final int goalId = await db.insertGoal(
    GoalsCompanion(
      name: const Value('攒键盘'),
      targetFen: const Value(10000),
      priceName: const Value('奶茶'),
      priceFen: const Value(1800),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(6000),
      occurredAt: Value(lastMonth),
      category: const Value('食'),
      note: const Value('合成上月'),
      source: const Value('manual'),
    ),
  );
  await db.insertAchievement(
    AchievementsCompanion(
      goalId: Value(goalId),
      goalName: const Value('攒键盘'),
      targetFen: const Value(10000),
      convertibleFen: const Value(12000),
      tier: const Value(''),
      unlockedAt: Value(now),
    ),
  );
  return db;
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-007 widget 目标 CRUD：定目标后列表出现', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(GoalBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalEmpty')), findsOneWidget);
    await tester.tap(find.byKey(const Key('goalAdd')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goalName')), '攒手机');
    await tester.enterText(find.byKey(const Key('goalTarget')), '3999');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();
    // SB-009 起目标列表在安全垫区之下，首屏视口外（ListView 懒加载），滚到可见再断言.
    await tester.scrollUntilVisible(
      find.textContaining('攒手机'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('攒手机'), findsWidgets);
    expect(find.byKey(const Key('goalConvert')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-007 widget 进度随记一笔实时联动', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒手机'),
        targetFen: const Value(399900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
      ),
    );
    await tester.pumpWidget(GoalBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalProgress')), findsOneWidget);
    final DateTime now = FixedClock.today();
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(2000),
        occurredAt: Value(now),
        category: const Value('食'),
        note: const Value('联动笔'),
        source: const Value('manual'),
      ),
    );
    await tester.pumpAndSettle();
    // 记一笔后换算文案仍在（流已联动重算，未抛异常即联动通路正常）.
    expect(find.byKey(const Key('goalConvert')), findsOneWidget);
    expect(find.byKey(const Key('goalLadder')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-007 golden 目标页有数据 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(GoalBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GoalBoard),
      matchesGoldenFile('../../golden/sb007/goal_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-007 golden 目标页有数据 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(GoalBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GoalBoard),
      matchesGoldenFile('../../golden/sb007/goal_dark_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-007 golden 目标页空态 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(GoalBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GoalBoard),
      matchesGoldenFile('../../golden/sb007/goal_light_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-007 golden 目标页空态 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(GoalBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GoalBoard),
      matchesGoldenFile('../../golden/sb007/goal_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-031 golden 目标页达成态 light', (WidgetTester tester) async {
    // SB-032 · static 会话跨测隔离（light 先跑 claim 后 dark 不弹，两帧错位）.
    AchievementSession.global.resetForTest();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDoneDb();
    await tester.pumpWidget(GoalBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    // 达成态像素证据：时间线达成行在位（文案去 ✓，瓦片图标唯一 ✓）.
    expect(find.byKey(const Key('goalTimeline')), findsOneWidget);
    expect(find.byKey(const Key('goalTimelineDone-1')), findsOneWidget);
    expect(find.textContaining('已攒够'), findsWidgets);
    expect(find.textContaining('✓'), findsNothing);
    // SB-032 · 弹层禁入镜（两帧底板对齐回归闸）.
    expect(find.byKey(const Key('achievementCard')), findsNothing);
    await expectLater(
      find.byType(GoalBoard),
      matchesGoldenFile('../../golden/sb007/goal_light_done.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-031 golden 目标页达成态 dark', (WidgetTester tester) async {
    // SB-032 · static 会话跨测隔离（同上）.
    AchievementSession.global.resetForTest();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDoneDb();
    await tester.pumpWidget(GoalBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalTimeline')), findsOneWidget);
    expect(find.byKey(const Key('goalTimelineDone-1')), findsOneWidget);
    expect(find.textContaining('已攒够'), findsWidgets);
    expect(find.textContaining('✓'), findsNothing);
    // SB-032 · 弹层禁入镜（两帧底板对齐回归闸）.
    expect(find.byKey(const Key('achievementCard')), findsNothing);
    await expectLater(
      find.byType(GoalBoard),
      matchesGoldenFile('../../golden/sb007/goal_dark_done.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-007 对比度闸门（目标页文字组合）', () {
    expect(
      RunwayContrast.ratio(RunwayLight.ink, RunwayLight.surface),
      greaterThanOrEqualTo(RunwayContrast.textMin),
    );
    expect(
      RunwayContrast.ratio(RunwayLight.inkSecondaryText, RunwayLight.surface),
      greaterThanOrEqualTo(RunwayContrast.textMin),
    );
    expect(
      RunwayContrast.ratio(RunwayDark.ink, RunwayDark.surface),
      greaterThanOrEqualTo(RunwayContrast.textMin),
    );
    expect(
      RunwayContrast.ratio(RunwayDark.inkSecondaryText, RunwayDark.surface),
      greaterThanOrEqualTo(RunwayContrast.textMin),
    );
  });
}
