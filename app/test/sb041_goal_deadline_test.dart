import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/goal_deadline_dao.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/goal_deadline.dart';
import 'package:runway/ui/goal_page.dart';

// SB-041 · 目标期限落库（浩然 18:54 裁 C：schema v11→v12 真存下来）.
// 迁移三件套（升/降/幂等）+ 存-重启-读回 roundtrip + 期限文案/禁词 + 表单 widget 全链路.
// 合成夹具，无真实账目.

Widget _wrap(Widget child) => MaterialApp(home: child);

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  test('SB-041 期限校验：空=过，yyyy-MM-dd 合法=过，其余=错', () {
    expect(validateDeadlineDate(''), isNull);
    expect(validateDeadlineDate('  '), isNull);
    expect(validateDeadlineDate('2026-12-31'), isNull);
    expect(validateDeadlineDate('2026-02-28'), isNull);
    expect(validateDeadlineDate('2026-13-01'), isNotNull);
    expect(validateDeadlineDate('2026-02-30'), isNotNull);
    expect(validateDeadlineDate('2026-2-3'), isNotNull);
    expect(validateDeadlineDate('6'), isNotNull);
    expect(validateDeadlineDate('6 个月'), isNotNull);
    expect(validateDeadlineDate('abc'), isNotNull);
  });

  test('SB-041 归一化/解析/文案：空→无行，合法→预计 M月d日', () {
    expect(normalizeDeadline('  '), isNull);
    expect(normalizeDeadline('2026-12-31'), '2026-12-31');
    expect(normalizeDeadline(' 2026-01-05 '), '2026-01-05');
    expect(normalizeDeadline('99'), isNull);
    expect(parseDeadline(null), isNull);
    expect(parseDeadline(''), isNull);
    expect(parseDeadline('2026-02-30'), isNull);
    expect(parseDeadline('2026-12-31'), DateTime(2026, 12, 31));
    expect(formatDeadlineLine(null), '');
    expect(formatDeadlineLine(''), '');
    expect(formatDeadlineLine('2026-02-30'), '');
    expect(formatDeadlineLine('2026-12-31'), '预计 12月31日攒到');
    expect(formatDeadlineLine('2026-01-05'), '预计 1月5日攒到');
  });

  test('SB-041 文案零禁词命中', () {
    final List<String> copies = <String>[
      formatDeadlineLine('2026-12-31'),
      formatDeadlineLine('2026-01-05'),
      validateDeadlineDate('abc')!,
    ];
    expect(copies.every((String c) => c.isNotEmpty), isTrue);
    for (final String c in copies) {
      for (final String w in achievementBannedWords) {
        expect(c.contains(w), isFalse, reason: '文案命中禁词 $w：$c');
      }
    }
  });

  test('SB-041 迁移幂等：新鲜库已含列→false，删列后补列→true，再调→false', () async {
    final AppDb db = AppDb.memoryForTest();
    expect(await db.ensureGoalDeadlineColumn(), isFalse);
    await db.rollbackGoalDeadlineToV11();
    expect(await db.ensureGoalDeadlineColumn(), isTrue);
    expect(await db.ensureGoalDeadlineColumn(), isFalse);
    await db.close();
  });

  test('SB-041 回滚：删列后 goals 读写 deadline 即抛，补列即恢复', () async {
    final AppDb db = AppDb.memoryForTest();
    await db.rollbackGoalDeadlineToV11();
    expect(
      () async => db.insertGoal(
        GoalsCompanion(
          name: const Value('攒平板'),
          targetFen: const Value(199900),
          priceName: const Value('奶茶'),
          priceFen: const Value(1800),
          deadline: const Value('2026-12-31'),
        ),
      ),
      throwsA(isA<Exception>()),
    );
    expect(await db.ensureGoalDeadlineColumn(), isTrue);
    final int id = await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒平板'),
        targetFen: const Value(199900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
        deadline: const Value('2026-12-31'),
      ),
    );
    expect(
      (await db.listGoals()).firstWhere((Goal g) => g.id == id).deadline,
      '2026-12-31',
    );
    await db.close();
  });

  test('SB-041 存-重启-读回 roundtrip（文件库关后重开）', () async {
    final Directory tmp = await Directory.systemTemp.createTemp('sb041-');
    final File file = File('${tmp.path}/runway.db');
    AppDb db = await AppDb.openFile(file);
    final int id = await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒耳机'),
        targetFen: const Value(129900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
        deadline: const Value('2026-11-11'),
      ),
    );
    await db.close();
    db = await AppDb.openFile(file);
    Goal goal = (await db.listGoals()).firstWhere((Goal g) => g.id == id);
    expect(goal.deadline, '2026-11-11');
    await db.updateGoal(
      GoalsCompanion(
        id: Value(id),
        name: const Value('攒耳机'),
        targetFen: const Value(129900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
        tier: Value(goal.tier),
        doneAt: Value(goal.doneAt),
        deadline: const Value('2026-12-25'),
        createdAt: Value(goal.createdAt),
      ),
    );
    await db.close();
    db = await AppDb.openFile(file);
    goal = (await db.listGoals()).firstWhere((Goal g) => g.id == id);
    expect(goal.deadline, '2026-12-25');
    await db.close();
    await tmp.delete(recursive: true);
  });

  testWidgets('SB-041 表单→存库→目标卡显示期限行', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalAdd')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalDeadline')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('goalName')), '攒平板');
    await tester.enterText(find.byKey(const Key('goalTarget')), '1999');
    await tester.enterText(find.byKey(const Key('goalDeadline')), '99');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();
    expect(find.text('期限须为 yyyy-MM-dd 日期'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));

    await tester.enterText(find.byKey(const Key('goalDeadline')), '2026-12-31');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已定下新目标'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('攒平板'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('预计 12月31日攒到'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-041 编辑可改期限，清空即无期限行', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    final int id = await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒耳机'),
        targetFen: const Value(129900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
        deadline: const Value('2026-11-11'),
      ),
    );
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('预计 11月11日攒到'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('预计 11月11日攒到'), findsOneWidget);

    // 041 合入轮：合并态页面更高，scrollUntilVisible 停点钮藏 AppBar 底——
    // 先 ensureVisible 居中再 tap（Scrollable.ensureVisible 支持 alignment）.
    await Scrollable.ensureVisible(
      tester.element(find.byKey(Key('goalEdit-$id'))),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('goalEdit-$id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goalDeadline')), '2026-12-25');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('预计 12月25日攒到'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('预计 12月25日攒到'), findsOneWidget);
    expect((await db.listGoals()).first.deadline, '2026-12-25');

    await Scrollable.ensureVisible(
      tester.element(find.byKey(Key('goalEdit-$id'))),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('goalEdit-$id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goalDeadline')), '');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('goalDeadline-$id')), findsNothing);
    expect((await db.listGoals()).first.deadline, isNull);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-041 无期限目标不渲染期限行', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    final int id = await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒键盘'),
        targetFen: const Value(29900),
        priceName: const Value('键盘'),
        priceFen: const Value(29900),
      ),
    );
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('攒键盘'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(Key('goalDeadline-$id')), findsNothing);

    await _unmountAndFlush(tester);
  });
}
