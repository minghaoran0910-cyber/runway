import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/ui/achievement_card.dart';
import 'package:runway/ui/achievements_page.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

import 'fixed_clock.dart';

// SB-008 widget + Golden：解锁即弹/补弹一次 + 成就卡/收藏页四组.
// 基线 golden/sb008/；生成：cd app && flutter test --update-goldens test/golden_achievement_test.dart
// 注意：GoalPage 内 streams 测后不调 close（沿 SB-007 先例，unmount 即弃）.

class AchBoard extends StatelessWidget {
  const AchBoard({super.key, required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    );
  }
}

class GoalWrap extends StatelessWidget {
  const GoalWrap({super.key, required this.isDark, required this.db});

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

Future<AppDb> _seedDoneDb() async {
  final AppDb db = AppDb.memoryForTest();
  // SB-025 · 相对种子经夹具（行为与直调一致）.
  final DateTime now = FixedClock.today();
  final DateTime lastMonth = DateTime(now.year, now.month - 1, 15, 12);
  await db.insertGoal(
    GoalsCompanion(
      name: const Value('攒手机'),
      targetFen: const Value(100),
      priceName: const Value('奶茶'),
      priceFen: const Value(1800),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(100000),
      occurredAt: Value(lastMonth),
      category: const Value('居'),
      note: const Value('上月房租'),
      source: const Value('manual'),
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
  testWidgets('SB-008 widget 解锁即弹：达成后弹成就卡并落库', (WidgetTester tester) async {
    AchievementSession.global.resetForTest();
    final AppDb db = await _seedDoneDb();
    await tester.pumpWidget(GoalWrap(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievementCard')), findsOneWidget);
    expect(find.byKey(const Key('achievementTitle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('achievementClose')));
    await tester.pumpAndSettle();
    final List<Achievement> rows = await db.listAchievements();
    expect(rows.length, 1);
    expect(rows.first.goalName, '攒手机');
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 widget 补弹一次：落库后重开不再弹', (WidgetTester tester) async {
    AchievementSession.global.resetForTest();
    final AppDb db = await _seedDoneDb();
    await tester.pumpWidget(GoalWrap(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievementCard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('achievementClose')));
    await tester.pumpAndSettle();
    await _unmountAndFlush(tester);
    AchievementSession.global.resetForTest();
    await tester.pumpWidget(GoalWrap(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievementCard')), findsNothing);
    expect(find.byKey(const Key('goalToAchievements')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 widget 未达成不弹', (WidgetTester tester) async {
    AchievementSession.global.resetForTest();
    final AppDb db = AppDb.memoryForTest();
    await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒5090'),
        targetFen: const Value(1649900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
      ),
    );
    await tester.pumpWidget(GoalWrap(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievementCard')), findsNothing);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 widget 收藏页空态 + 有数序列 + 分享导出', (WidgetTester tester) async {
    final AppDb empty = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AchievementsPage(db: empty),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achEmpty')), findsOneWidget);
    await _unmountAndFlush(tester);

    final AppDb db = AppDb.memoryForTest();
    await db.insertAchievement(
      AchievementsCompanion(
        goalId: const Value(1),
        goalName: const Value('攒手机'),
        targetFen: const Value(399900),
        convertibleFen: const Value(400000),
        tier: const Value('手机'),
        unlockedAt: Value(DateTime(2026, 10, 1, 12)),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AchievementsPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achievementCard')), findsOneWidget);
    final List<Achievement> rows = await db.listAchievements();
    final int id = rows.first.id;
    expect(find.byKey(Key('achItem-$id')), findsOneWidget);
    expect(find.byKey(Key('achShare-$id')), findsOneWidget);
    await tester.tap(find.byKey(Key('achShare-$id')));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('achShareResult')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 截图导出：RepaintBoundary 可产 PNG 字节（无新依赖）', (
    WidgetTester tester,
  ) async {
    final GlobalKey key = GlobalKey(debugLabel: 'achShot-test');
    await tester.pumpWidget(
      AchBoard(
        isDark: false,
        child: RepaintBoundary(
          key: key,
          child: const AchievementCard(
            goalName: '攒手机',
            targetFen: 399900,
            convertibleFen: 400000,
            tier: '手机',
            frame: AchievementFrame.still,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final Uint8List? bytes = await tester.runAsync<Uint8List?>(() async {
      return captureAchievementPng(key);
    });
    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(100));
    // PNG 魔数 89 50 4E 47.
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 golden 成就卡 light 弹出帧', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const AchBoard(
        isDark: false,
        child: AchievementCard(
          goalName: '攒手机',
          targetFen: 399900,
          convertibleFen: 400000,
          tier: '手机',
          frame: AchievementFrame.popup,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AchBoard),
      matchesGoldenFile('../../golden/sb008/achievement_light_popup.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 golden 成就卡 dark 静帧', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const AchBoard(
        isDark: true,
        child: AchievementCard(
          goalName: '攒手机',
          targetFen: 399900,
          convertibleFen: 400000,
          tier: '手机',
          frame: AchievementFrame.still,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AchBoard),
      matchesGoldenFile('../../golden/sb008/achievement_dark_still.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 golden 收藏页 light 有数', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await db.insertAchievement(
      AchievementsCompanion(
        goalId: const Value(1),
        goalName: const Value('攒手机'),
        targetFen: const Value(399900),
        convertibleFen: const Value(400000),
        tier: const Value('手机'),
        unlockedAt: Value(DateTime(2026, 10, 1, 12)),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: AchievementsPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AchievementsPage),
      matchesGoldenFile('../../golden/sb008/collection_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-008 golden 收藏页 dark 空态', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: AchievementsPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AchievementsPage),
      matchesGoldenFile('../../golden/sb008/collection_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-008 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/achievement_card.dart',
      'lib/ui/achievements_page.dart',
      'lib/ui/achievement_gate.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-008 对比度闸门（成就页文字组合）', () {
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
    expect(
      RunwayContrast.ratio(RunwayLight.gold, RunwayLight.surface),
      greaterThanOrEqualTo(RunwayContrast.largeMin),
    );
    expect(
      RunwayContrast.ratio(RunwayDark.gold, RunwayDark.surface),
      greaterThanOrEqualTo(RunwayContrast.largeMin),
    );
  });
}
