import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/safety_report.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/safety_card.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';
import 'package:runway/ui/weekly_page.dart';

// SB-009 widget + Golden：安全垫卡/周报页四组 + 同区集成.
// 基线 golden/sb009/；生成：cd app && flutter test --update-goldens test/golden_safety_test.dart

class SafetyBoard extends StatelessWidget {
  const SafetyBoard({super.key, required this.isDark, required this.child});

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

SafetyPadView _dataView() {
  return computeSafetyPad(
    avgMonthlySpendFen: 10000,
    fundFen: 30000,
    targetMonths: 6,
  );
}

SafetyPadView _emptyView() {
  return computeSafetyPad(avgMonthlySpendFen: 0, fundFen: 0, targetMonths: 6);
}

Future<AppDb> _seedWeeklyDb() async {
  final AppDb db = AppDb.memoryForTest();
  final DateTime now = DateTime.now();
  final DateTime monday = weekStartFor(now);
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
  return db;
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-009 widget 安全垫卡有数：标题/进度/设月数入口', (WidgetTester tester) async {
    await tester.pumpWidget(
      SafetyBoard(isDark: false, child: SafetyPadCard(view: _dataView())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('safetyTitle')), findsOneWidget);
    expect(find.byKey(const Key('safetyConvert')), findsOneWidget);
    expect(find.byKey(const Key('safetyTarget')), findsOneWidget);
    expect(find.byKey(const Key('safetyProgress')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 widget 安全垫卡空态：引导语无崩', (WidgetTester tester) async {
    await tester.pumpWidget(
      SafetyBoard(
        isDark: true,
        child: SafetyPadCard(view: _emptyView(), onEdit: () {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('safetyTitle')), findsOneWidget);
    expect(find.byKey(const Key('safetyEdit')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 widget 周报页：本周实时 + 历史 + 生成幂等', (
    WidgetTester tester,
  ) async {
    final AppDb db = await _seedWeeklyDb();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WeeklyPage(db: db),
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

  testWidgets('SB-009 widget 周报空态：空库引导语', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WeeklyPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weeklyEmpty')), findsOneWidget);
    expect(find.byKey(const Key('weeklyCount')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 widget 同区：目标页含安全垫区 + 周报入口', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: GoalPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('safetyTitle')), findsOneWidget);
    expect(find.byKey(const Key('goalToWeekly')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 golden 安全垫卡 light 有数', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      SafetyBoard(isDark: false, child: SafetyPadCard(view: _dataView())),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SafetyBoard),
      matchesGoldenFile('../../golden/sb009/safety_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 golden 安全垫卡 dark 空态', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      SafetyBoard(isDark: true, child: SafetyPadCard(view: _emptyView())),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SafetyBoard),
      matchesGoldenFile('../../golden/sb009/safety_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 golden 周报页 light 有数', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedWeeklyDb();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: WeeklyPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WeeklyPage),
      matchesGoldenFile('../../golden/sb009/weekly_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-009 golden 周报页 dark 空态', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: WeeklyPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WeeklyPage),
      matchesGoldenFile('../../golden/sb009/weekly_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-009 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/safety_card.dart',
      'lib/ui/weekly_page.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-009 对比度闸门（安全垫/周报文案组合）', () {
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
