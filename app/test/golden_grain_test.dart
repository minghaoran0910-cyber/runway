import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/grain_report.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/grain_card.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';
import 'package:runway/ui/weekly_page.dart';

import 'fixed_clock.dart';

// SB-014 widget + Golden：余粮卡/周报页四组 + 同区集成.
// 基线 golden/sb014/；生成：cd app && flutter test --update-goldens test/golden_grain_test.dart

class GrainBoard extends StatelessWidget {
  const GrainBoard({super.key, required this.isDark, required this.child});

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

GrainReserveView _dataView() {
  return computeGrainReserve(
    avgMonthlySpendFen: 10000,
    fundFen: 30000,
    targetMonths: 6,
  );
}

GrainReserveView _emptyView() {
  return computeGrainReserve(
    avgMonthlySpendFen: 0,
    fundFen: 0,
    targetMonths: 6,
  );
}

Future<AppDb> _seedWeeklyDb() async {
  final AppDb db = AppDb.memoryForTest();
  // SB-023 · 绝对钉：种子与页时钟同源（FixedClock.fixedMonday），渲染全年确定.
  // 本周历史预置一条（周一 auto-generate 被幂等抑止，任意真实日期结构恒定 2 期）.
  final DateTime monday = weekStartFor(FixedClock.fixedMonday);
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(5000),
      occurredAt: Value(monday.add(const Duration(hours: 10))),
      category: const Value('餐饮'),
      note: const Value('本周午餐'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(3000),
      occurredAt: Value(monday.add(const Duration(days: 1, hours: 10))),
      category: const Value('交通'),
      note: const Value('地铁'),
      source: const Value('manual'),
    ),
  );
  await db.insertWeeklyReport(
    WeeklyReportsCompanion(
      weekStart: Value(monday.subtract(const Duration(days: 7))),
      spendFen: const Value(12000),
      savedFen: const Value(2000),
      topJson: const Value('食:8000,行:4000'),
      momDeltaFen: const Value(2000),
    ),
  );
  await db.insertWeeklyReport(
    WeeklyReportsCompanion(
      weekStart: Value(monday),
      spendFen: const Value(8000),
      savedFen: const Value(0),
      topJson: const Value('食:5000,交通:3000'),
      momDeltaFen: const Value(-8000),
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
  testWidgets('SB-014 widget 余粮卡有数：标题/进度/设月数入口', (WidgetTester tester) async {
    await tester.pumpWidget(
      GrainBoard(isDark: false, child: GrainReserveCard(view: _dataView())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('grainTitle')), findsOneWidget);
    expect(find.byKey(const Key('grainConvert')), findsOneWidget);
    expect(find.byKey(const Key('grainTarget')), findsOneWidget);
    expect(find.byKey(const Key('grainProgress')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 widget 余粮卡空态：引导语无崩', (WidgetTester tester) async {
    await tester.pumpWidget(
      GrainBoard(
        isDark: true,
        child: GrainReserveCard(view: _emptyView(), onEdit: () {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('grainTitle')), findsOneWidget);
    expect(find.byKey(const Key('grainEdit')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 widget 余粮卡称号行：地主家可见', (WidgetTester tester) async {
    await tester.pumpWidget(
      GrainBoard(isDark: false, child: GrainReserveCard(view: _dataView())),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('地主家'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 widget 周报页：本周实时 + 历史 + 生成幂等', (
    WidgetTester tester,
  ) async {
    final AppDb db = await _seedWeeklyDb();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WeeklyPage(db: db, nowOverride: FixedClock.fixedMonday),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weeklyTitle')), findsOneWidget);
    expect(find.byKey(const Key('weeklyBody')), findsOneWidget);
    expect(find.byKey(const Key('weeklyMom')), findsOneWidget);
    expect(find.byKey(const Key('weeklyTop')), findsOneWidget);
    expect(find.byKey(const Key('weeklyGenerate')), findsOneWidget);
    await tester.tap(find.byKey(const Key('weeklyGenerate')));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weeklyGenResult')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 widget 周报空态：空库引导语', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WeeklyPage(db: db, nowOverride: FixedClock.fixedMonday),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weeklyEmpty')), findsOneWidget);
    expect(find.byKey(const Key('weeklyCount')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 widget 同区：目标页含余粮区 + 周报入口', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: GoalPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('grainTitle')), findsOneWidget);
    expect(find.byKey(const Key('goalToWeekly')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 golden 余粮卡 light 有数', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      GrainBoard(isDark: false, child: GrainReserveCard(view: _dataView())),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GrainBoard),
      matchesGoldenFile('../../golden/sb014/grain_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 golden 余粮卡 dark 空态', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      GrainBoard(isDark: true, child: GrainReserveCard(view: _emptyView())),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GrainBoard),
      matchesGoldenFile('../../golden/sb014/grain_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 golden 周报页 light 有数', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedWeeklyDb();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: WeeklyPage(db: db, nowOverride: FixedClock.fixedMonday),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WeeklyPage),
      matchesGoldenFile('../../golden/sb014/weekly_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-014 golden 周报页 dark 空态', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: WeeklyPage(db: db, nowOverride: FixedClock.fixedMonday),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WeeklyPage),
      matchesGoldenFile('../../golden/sb014/weekly_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-014 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/grain_card.dart',
      'lib/ui/weekly_page.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-014 对比度闸门（余粮/周报文案组合）', () {
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
      RunwayContrast.ratio(RunwayLight.accentStrong, RunwayLight.surface),
      greaterThanOrEqualTo(RunwayContrast.textMin),
    );
    expect(
      RunwayContrast.ratio(RunwayDark.accent, RunwayDark.surface),
      greaterThanOrEqualTo(RunwayContrast.largeMin),
    );
  });
}
