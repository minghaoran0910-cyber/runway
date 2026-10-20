import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/category_feedback.dart';
import 'package:runway/ui/category_page.dart';

// SB-005 · 类目管理页 widget 测试（合成数据，内存库）.
// drift watch 流说明见 widget_test.dart 文件头：unmount 后多 pump 消化零时长
// Timer；本文件 widget 测试同样不调 db.close（内存库随进程退出释放）.

Widget _wrap(AppDb db, CategoryCorrections corrections) {
  return MaterialApp(
    home: CategoryPage(db: db, corrections: corrections),
  );
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

void main() {
  testWidgets('SB-005 类目页空态：零占比不误报', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    final CategoryCorrections corrections = CategoryCorrections();

    await tester.pumpWidget(_wrap(db, corrections));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // SB-039 ③ · 其他占比块已搬"我的"关于诊断区：本页无占比无故障行.
    expect(find.byKey(const Key('otherShare')), findsNothing);
    expect(find.byKey(const Key('otherHealthy')), findsNothing);
    expect(find.byKey(const Key('otherFault')), findsNothing);
    expect(find.byKey(const Key('emptyCatHint')), findsOneWidget);
    // SB-039 ③ · 其他占比/规则行已搬"我的"关于诊断区，本页零内部细节.
    expect(find.byKey(const Key('otherShare')), findsNothing);
    expect(find.textContaining('条 ·'), findsNothing);
    // SB-047 · 空态只出引导卡：角色墙隐藏，无类目行.
    expect(find.byKey(const Key('roleWall')), findsNothing);
    expect(find.text('餐饮'), findsNothing);
    expect(find.byKey(const Key('elasticRing')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-005 其他超 5% 显示故障 + 分项合计', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    final CategoryCorrections corrections = CategoryCorrections();
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(9000),
        occurredAt: Value(DateTime(2026, 10, 10, 12)),
        category: const Value('食'),
        note: const Value('外卖午餐'),
        source: const Value('manual'),
      ),
    );
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(1000),
        occurredAt: Value(DateTime(2026, 10, 10, 13)),
        category: const Value('其他'),
        note: const Value('未知事项'),
        source: const Value('manual'),
      ),
    );

    await tester.pumpWidget(_wrap(db, corrections));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // SB-047 · 角色墙默认折叠：先展开再断言墙内分项.
    expect(find.byKey(const Key('roleWall')), findsOneWidget);
    await tester.tap(find.byKey(const Key('roleWall')));
    await tester.pumpAndSettle();

    // SB-039 ③ · 故障行随其他占比块搬"我的"页；本页看分项合计（全称）.
    expect(find.byKey(const Key('otherFault')), findsNothing);
    expect(find.byKey(const Key('catTotal-食')), findsOneWidget);
    expect(find.text('餐饮'), findsWidgets);
    expect(find.text('¥90'), findsOneWidget);
    expect(find.text('¥10'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-005 纠正回写：改类目落库且下次命中', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    final CategoryCorrections corrections = CategoryCorrections();
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(1000),
        occurredAt: Value(DateTime(2026, 10, 10, 13)),
        category: const Value('其他'),
        note: const Value('未知事项'),
        source: const Value('manual'),
      ),
    );

    await tester.pumpWidget(_wrap(db, corrections));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    await tester.tap(find.byTooltip('纠正'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('fix-食')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    final List<Transaction> rows = await db.listAll();
    expect(rows.length, 1);
    // SB-039 ① · 存储仍引擎短名（零迁移），提示条显全称.
    expect(rows.first.category, '食');
    expect(corrections.lookup(merchant: '', note: '未知事项'), '食');
    expect(find.textContaining('已纠正为 餐饮'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-047 角色墙默认折叠+人话解释+未选红点+占比环', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();
    final CategoryCorrections corrections = CategoryCorrections();
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(9000),
        occurredAt: Value(DateTime(2026, 10, 10, 12)),
        category: const Value('食'),
        note: const Value('外卖午餐'),
        source: const Value('manual'),
      ),
    );
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(1000),
        occurredAt: Value(DateTime(2026, 10, 10, 13)),
        category: const Value('自建类'),
        note: const Value('手作市集'),
        source: const Value('manual'),
      ),
    );

    await tester.pumpWidget(_wrap(db, corrections));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // 页首占比环在位（复用首页 ring 组件）.
    expect(find.byKey(const Key('elasticRing')), findsOneWidget);
    expect(find.byKey(const Key('elasticShare')), findsOneWidget);
    // 默认折叠：墙内 chips 不可见.
    expect(find.byKey(const Key('roleWall')), findsOneWidget);
    expect(find.byKey(const Key('role-食-必要')), findsNothing);
    // 未选类 → 墙头红点 + 待选计数.
    expect(find.byKey(const Key('roleRedDot')), findsOneWidget);
    expect(find.textContaining('类待选'), findsOneWidget);

    await tester.tap(find.byKey(const Key('roleWall')));
    await tester.pumpAndSettle();

    // 人话解释三行在位.
    expect(find.byKey(const Key('roleExplain-必要')), findsOneWidget);
    expect(find.byKey(const Key('roleExplain-弹性')), findsOneWidget);
    expect(find.byKey(const Key('roleExplain-固定')), findsOneWidget);
    // 未选行红点 + 提示在位.
    expect(find.byKey(const Key('roleDot-自建类')), findsOneWidget);
    expect(find.byKey(const Key('rolePrompt-自建类')), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
