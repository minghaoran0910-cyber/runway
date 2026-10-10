import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/budget.dart';
import 'package:runway/ui/budget_card.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';
import 'package:runway/ui/weekly_page.dart';

// SB-015 widget + Golden：预算卡两组（观察/生效）× Light/Dark + 周报页集成.
// 基线 golden/sb015/；生成：cd app && flutter test --update-goldens test/golden_budget_test.dart

class BudgetBoard extends StatelessWidget {
  const BudgetBoard({super.key, required this.isDark, required this.child});

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

BudgetCard _activeCard() {
  final BudgetQuote quote = suggestBudget(
    m0Fen: 80000,
    m1Fen: 90000,
    m2Fen: 100000,
    dataMonths: 3,
  );
  final BudgetSaved saved = computeBudgetSaved(
    budgetFen: quote.budgetFen,
    monthSpendFen: 80000,
    lastMonthSpendFen: 90000,
  );
  return BudgetCard(
    budgetFen: quote.budgetFen,
    savedFen: saved.convertibleFen,
    monthSpendFen: 80000,
    observing: false,
    basisText: budgetBasisText(quote: quote),
    historyCount: 1,
  );
}

BudgetCard _observingCard() {
  return const BudgetCard(
    budgetFen: 0,
    savedFen: 0,
    monthSpendFen: 5000,
    observing: true,
    basisText: '数据不足 3 个月 · 可手动设定预算',
    historyCount: 0,
  );
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-015 widget 预算卡生效态：标题/换算/基线/进度', (WidgetTester tester) async {
    await tester.pumpWidget(BudgetBoard(isDark: false, child: _activeCard()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('budgetTitle')), findsOneWidget);
    expect(find.byKey(const Key('budgetConvert')), findsOneWidget);
    expect(find.byKey(const Key('budgetBasis')), findsOneWidget);
    expect(find.byKey(const Key('budgetProgress')), findsOneWidget);
    expect(find.textContaining('中位数'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-015 widget 预算卡观察态：引导语 + 调预算入口', (WidgetTester tester) async {
    await tester.pumpWidget(
      BudgetBoard(
        isDark: false,
        child: BudgetCard(
          budgetFen: 0,
          savedFen: 0,
          monthSpendFen: 5000,
          observing: true,
          basisText: '数据不足 3 个月 · 可手动设定预算',
          historyCount: 0,
          onEdit: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('budgetTitle')), findsOneWidget);
    expect(find.byKey(const Key('budgetEdit')), findsOneWidget);
    expect(find.textContaining('记满 3 个月'), findsWidgets);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-015 widget 周报页集成：滚到底含预算区', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: WeeklyPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('budgetTitle')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('budgetTitle')), findsOneWidget);
    expect(find.byKey(const Key('budgetBasis')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-015 golden 预算卡 light 生效', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(BudgetBoard(isDark: false, child: _activeCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BudgetBoard),
      matchesGoldenFile('../../golden/sb015/budget_light_active.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-015 golden 预算卡 dark 生效', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(BudgetBoard(isDark: true, child: _activeCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BudgetBoard),
      matchesGoldenFile('../../golden/sb015/budget_dark_active.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-015 golden 预算卡 light 观察', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      BudgetBoard(isDark: false, child: _observingCard()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BudgetBoard),
      matchesGoldenFile('../../golden/sb015/budget_light_observing.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-015 golden 预算卡 dark 观察', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(BudgetBoard(isDark: true, child: _observingCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(BudgetBoard),
      matchesGoldenFile('../../golden/sb015/budget_dark_observing.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-015 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/budget_card.dart',
      'lib/ui/weekly_page.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-015 对比度闸门（预算文案组合）', () {
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
