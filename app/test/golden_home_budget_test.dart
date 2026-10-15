import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/theme/app_theme.dart';

import 'fixed_clock.dart';

// SB-012 · 预算卡上首页：同一 BudgetZone 换宿主（周报页保留，口径零改）.
// SB-038 · 预算观察搬去"我的"页：本文件改泵 GoalPage，基线原位重生成
//   （路径沿用 golden/sb012/budget_home_*，内容=我的页预算区；周报页另有
//   golden_budget_test 覆盖，不受影响）.
// 生成：cd app && flutter test --update-goldens test/golden_home_budget_test.dart
// 注意：GoalPage 用 db.watchGoals/watchAll，测后不调 close.

class HomeBudgetBoard extends StatelessWidget {
  const HomeBudgetBoard({super.key, required this.isDark, required this.db});

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
  // SB-025 · 相对种子经夹具（行为与直调一致）.
  final DateTime now = FixedClock.today();
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
      amountFen: const Value(3000),
      occurredAt: Value(now),
      category: const Value('行'),
      note: const Value('地铁'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(2000),
      occurredAt: Value(now),
      category: const Value('其他'),
      note: const Value('未知事项'),
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

Future<void> _scrollToBudget(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('budgetTitle')),
    500,
    scrollable: find.byType(Scrollable).first,
  );
  // SB-038 · 我的页含常动组件（环扫/count-up），pumpAndSettle 永不收敛；
  // 用定泵代替（dashboard_page_test 同口径）.
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

void main() {
  testWidgets('SB-038 widget 我的页含预算区：标题/基线/进度', (WidgetTester tester) async {
    final AppDb db = await _seedDb();
    await tester.pumpWidget(HomeBudgetBoard(isDark: false, db: db));
    await _settle(tester);
    await _scrollToBudget(tester);
    expect(find.byKey(const Key('budgetTitle')), findsOneWidget);
    expect(find.byKey(const Key('budgetBasis')), findsOneWidget);
    expect(find.byKey(const Key('budgetProgress')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-038 golden 我的页预算区 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(HomeBudgetBoard(isDark: false, db: db));
    await _settle(tester);
    await _scrollToBudget(tester);
    await expectLater(
      find.byType(HomeBudgetBoard),
      matchesGoldenFile('../../golden/sb012/budget_home_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-038 golden 我的页预算区 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(HomeBudgetBoard(isDark: true, db: db));
    await _settle(tester);
    await _scrollToBudget(tester);
    await expectLater(
      find.byType(HomeBudgetBoard),
      matchesGoldenFile('../../golden/sb012/budget_home_dark.png'),
    );
    await _unmountAndFlush(tester);
  });
}
