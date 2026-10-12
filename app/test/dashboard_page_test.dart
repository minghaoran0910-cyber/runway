import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/home_page.dart';

import 'fixed_clock.dart';

// SB-006 · 看板 widget 测试（合成数据，内存库）.
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
  testWidgets('SB-006 看板四区渲染 + 其他故障态', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    await _seed(db);

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byKey(const Key('homeTotal')), findsOneWidget);
    expect(find.byKey(const Key('dashToday')), findsOneWidget);
    expect(find.textContaining('Top5'), findsOneWidget);
    expect(find.byKey(const Key('dashGoalEmpty')), findsOneWidget);
    expect(find.byKey(const Key('dashOtherFault')), findsOneWidget);
    expect(find.byKey(const Key('dashTop5-食')), findsOneWidget);
    expect(find.byKey(const Key('dashTop5-其他')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-006 空态：零占比健康 + 引导位', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byKey(const Key('emptyHint')), findsOneWidget);
    expect(find.byKey(const Key('dashOtherHealthy')), findsOneWidget);
    expect(find.byKey(const Key('dashTop5Empty')), findsOneWidget);
    expect(find.byKey(const Key('dashGoalEmpty')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-007 目标卡点击进目标阶梯页', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    await tester.tap(find.byKey(const Key('dashGoalEmpty')));
    await tester.pumpAndSettle();
    expect(find.byType(GoalPage), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
