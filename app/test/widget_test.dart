import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/home_page.dart';

// SB-004 返工（REVIEW 第 1 轮问题 1）：旧计数器测试已退役，改为主屏真实冒烟.
// 另覆盖问题 2：编辑→改类目→保存（合成数据，内存库）.
//
// 测试环境说明（drift watch + flutter_tester 实测结论）：
// - HomePage 用 db.watchAll() 做 StreamBuilder；unmount 卸载订阅时 drift
//   StreamQueryStore.markAsClosed 会排一个零时长 Timer，须在 unmount 后多
//   pump 几帧让 FakeAsync 消化，否则 test 结束 invariant 报 pending timer.
// - 同环境下 `await db.close()` 在 watch 订阅过后会挂起不返回（实测），故
//   本文件 widget 测试不调 close（内存库随测试进程退出释放）.

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

void main() {
  testWidgets('SB-004 主屏空态冒烟', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byKey(const Key('emptyHint')), findsOneWidget);
    expect(find.byKey(const Key('homeTotal')), findsOneWidget);
    expect(find.text('攒够'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-004 编辑→改类目→保存落库', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(1234),
        occurredAt: Value(DateTime(2026, 10, 10, 12)),
        category: const Value('餐饮'),
        note: const Value('午餐'),
        source: const Value('manual'),
      ),
    );

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // 列表出现该记录.
    expect(find.textContaining('餐饮'), findsOneWidget);

    // 打开编辑框.
    await tester.tap(find.byTooltip('编辑'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('编辑记录'), findsOneWidget);

    // 切换类目到交通，选中态即时回显.
    final Finder chipJiaoTong = find.widgetWithText(ChoiceChip, '交通');
    expect(chipJiaoTong, findsOneWidget);
    await tester.tap(chipJiaoTong);
    await tester.pump();
    final ChoiceChip chip = tester.widget<ChoiceChip>(chipJiaoTong);
    expect(chip.selected, isTrue);

    // 保存（updateOne 后等 watch 流重建回放）.
    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    final List<Transaction> rows = await db.listAll();
    expect(rows.length, 1);
    expect(rows.first.category, '交通');
    expect(find.textContaining('交通'), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
