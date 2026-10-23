import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/budget_dao.dart';
import 'package:runway/logic/budget.dart';
import 'package:runway/ui/home_page.dart';
import 'package:runway/ui/today_saved_row.dart';

import 'fixed_clock.dart';

// SB-053 · 首页「今日攒」空白卡（空壳 Card 泄漏）回归.
// 缺陷：saved>0 但不足最小单价（<1800）时 TodaySavedRow 返回 shrink，
// 外层 Card 仍无条件渲染 → 首页出现零文字空白卡.
// 修复：hasTodaySavedContent 判据 + home_page 调用侧整卡不渲染.

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
}

Future<void> _pumpHome(WidgetTester tester, AppDb db) async {
  await tester.pumpWidget(_wrap(db));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

void main() {
  test('SB-053 hasTodaySavedContent 口径：零日/可换算有内容，换算不出无内容', () {
    // 零日档（含恰零与负结余）仍有内容.
    expect(hasTodaySavedContent(savedFen: 0), isTrue);
    expect(hasTodaySavedContent(savedFen: -100), isTrue);
    // saved>0 但不足最小单价 1800 → 空壳，无内容.
    expect(hasTodaySavedContent(savedFen: 1), isFalse);
    expect(hasTodaySavedContent(savedFen: 100), isFalse);
    expect(hasTodaySavedContent(savedFen: 1799), isFalse);
    // 可换算档有内容.
    expect(hasTodaySavedContent(savedFen: 1800), isTrue);
    expect(hasTodaySavedContent(savedFen: 5000), isTrue);
  });

  testWidgets('SB-053 缺陷场景 saved>0 不足最小单价 → 整卡不存在', (
    WidgetTester tester,
  ) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    final DateTime now = FixedClock.today();
    // 月预算 31000 → 日预算约 1000（28~31 天均落在 1000~1107）；
    // 今日支出 900 → saved 约 100~207，>0 且 <1800，必走空壳分支.
    await db.upsertBudget(monthKey: monthKeyFor(now), budgetFen: 31000);
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(900),
        occurredAt: Value(now),
        category: const Value('食'),
        note: const Value('早餐'),
        source: const Value('manual'),
      ),
    );

    await _pumpHome(tester, db);

    // 整卡不渲染：外层 Card（todaySavedCard）与行内所有键均不存在.
    expect(find.byKey(const Key('todaySavedCard')), findsNothing);
    expect(find.byKey(const Key('todaySavedCardEmpty')), findsOneWidget);
    expect(find.byKey(const Key('todaySaved')), findsNothing);
    expect(find.byKey(const Key('todaySavedZero')), findsNothing);
    expect(find.byKey(const Key('todaySavedEmpty')), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-053 零日档仍常驻：空库 → todaySavedCard + todaySavedZero', (
    WidgetTester tester,
  ) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await _pumpHome(tester, db);

    expect(find.byKey(const Key('todaySavedCard')), findsOneWidget);
    expect(find.byKey(const Key('todaySavedZero')), findsOneWidget);
    expect(find.byKey(const Key('todaySavedCardEmpty')), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-053 可换算档行为不变：大预算 → todaySavedCard + todaySaved', (
    WidgetTester tester,
  ) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    final DateTime now = FixedClock.today();
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

    await _pumpHome(tester, db);

    expect(find.byKey(const Key('todaySavedCard')), findsOneWidget);
    expect(find.byKey(const Key('todaySaved')), findsOneWidget);
    expect(find.byKey(const Key('todaySavedCardEmpty')), findsNothing);

    await _unmountAndFlush(tester);
  });
}
