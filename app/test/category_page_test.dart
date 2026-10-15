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
    // SB-039 ① · 类目行标题取全称（key 沿用引擎短名）.
    expect(find.text('餐饮'), findsWidgets);

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
}
