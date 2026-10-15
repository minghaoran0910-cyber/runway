import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/estimate_dao.dart';
import 'package:runway/logic/estimate.dart';
import 'package:runway/ui/daily_close_sheet.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

import 'fixed_clock.dart';

// SB-016 widget + Golden：收口三组（问句/已记/已记含今日攒出行）× Light/Dark.
// 基线 golden/sb016/；生成：cd app && flutter test --update-goldens test/golden_daily_close_test.dart

class CloseBoard extends StatelessWidget {
  const CloseBoard({super.key, required this.isDark, required this.child});

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

DailyCloseCard _askCard() {
  return DailyCloseCard(
    estimateFen: 5750,
    todaySpendFen: 0,
    closed: false,
    savedFen: 4250,
    onConfirm: () {},
    onAdjust: () {},
    onSkip: () {},
  );
}

DailyCloseCard _doneCard() {
  return const DailyCloseCard(
    estimateFen: 5750,
    todaySpendFen: 3000,
    closed: true,
    savedFen: 0,
  );
}

DailyCloseCard _doneSavedCard() {
  return const DailyCloseCard(
    estimateFen: 5750,
    todaySpendFen: 3000,
    closed: true,
    savedFen: 7000,
  );
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  // SB-023 · 相对种子经夹具封装（首页集成仅断言键，行为与直调一致）.
  final DateTime now = FixedClock.today();
  for (int i = 1; i <= 5; i++) {
    await db.insertOne(
      TransactionsCompanion(
        amountFen: Value(3000 + i * 100),
        occurredAt: Value(now.subtract(Duration(days: i))),
        category: const Value('餐饮'),
        source: const Value('manual'),
      ),
    );
  }
  return db;
}

void main() {
  testWidgets('SB-016 widget 问句态：三钮全程可点', (WidgetTester tester) async {
    await tester.pumpWidget(CloseBoard(isDark: false, child: _askCard()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dailyCloseAsk')), findsOneWidget);
    expect(find.byKey(const Key('dailyCloseConfirm')), findsOneWidget);
    expect(find.byKey(const Key('dailyCloseAdjust')), findsOneWidget);
    expect(find.byKey(const Key('dailyCloseSkip')), findsOneWidget);
    expect(find.textContaining('不用每笔记'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 widget 已记态：今日支出行', (WidgetTester tester) async {
    await tester.pumpWidget(CloseBoard(isDark: false, child: _doneCard()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dailyCloseDone')), findsOneWidget);
    expect(find.byKey(const Key('dailyCloseConfirm')), findsNothing);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 widget 已记含攒出：今日攒出行出现', (WidgetTester tester) async {
    await tester.pumpWidget(CloseBoard(isDark: false, child: _doneSavedCard()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dailyCloseDone')), findsOneWidget);
    expect(find.byKey(const Key('todaySaved')), findsOneWidget);
    expect(find.textContaining('今天攒出'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 widget 我的页集成（SB-038搬家后）：收口区挂载+开关', (
    WidgetTester tester,
  ) async {
    final AppDb db = await _seedDb();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: GoalPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('dailyCloseSwitch')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dailyCloseSwitch')), findsOneWidget);
    expect(find.text('每日收口'), findsOneWidget);
    await _unmountAndFlush(tester);
    await db.close();
  });

  testWidgets('SB-016 widget DAO：开关默认开+收口落库', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    expect(await db.closeEnabled(), isTrue);
    await db.setCloseEnabled(false);
    expect(await db.closeEnabled(), isFalse);
    await db.setCloseEnabled(true);
    final String key = dateKeyFor(FixedClock.today());
    expect(await db.closeOfDate(key), isNull);
    await db.markClosed(dateKey: key, estimateFen: 5000);
    expect((await db.closeOfDate(key))?.estimateFen, 5000);
    await db.rollbackEstimateToV7();
    await db.close();
  });

  testWidgets('SB-016 golden 问句 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CloseBoard(isDark: false, child: _askCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CloseBoard),
      matchesGoldenFile('../../golden/sb016/close_light_ask.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 golden 问句 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CloseBoard(isDark: true, child: _askCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CloseBoard),
      matchesGoldenFile('../../golden/sb016/close_dark_ask.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 golden 已记 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CloseBoard(isDark: false, child: _doneCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CloseBoard),
      matchesGoldenFile('../../golden/sb016/close_light_done.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 golden 已记 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CloseBoard(isDark: true, child: _doneCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CloseBoard),
      matchesGoldenFile('../../golden/sb016/close_dark_done.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 golden 已记含攒出 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CloseBoard(isDark: false, child: _doneSavedCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CloseBoard),
      matchesGoldenFile('../../golden/sb016/close_light_saved.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-016 golden 已记含攒出 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CloseBoard(isDark: true, child: _doneSavedCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CloseBoard),
      matchesGoldenFile('../../golden/sb016/close_dark_saved.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-016 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/daily_close_sheet.dart',
      'lib/ui/today_saved_row.dart',
      'lib/ui/home_page.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-016 对比度闸门（收口文案组合）', () {
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
