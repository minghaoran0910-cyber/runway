import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/quick_add_page.dart';
import 'package:runway/ui/widgets/amount_keyboard.dart';

// SB-004 · widget 测试：键盘输入→保存流（内存库合成数据）.
// drift watch 流说明见 widget_test.dart 文件头：SB-020 起 QuickAdd 含 PriceHint
// 流订阅（有备注时），故本文件遵循全仓统一口径——不调 db.close（内存库随进程
// 退出释放），测末 unmount + 多 pump 消化零时长 Timer；断言语义零改动.

Widget _wrap(AppDb db) {
  return MaterialApp(home: QuickAddPage(db: db));
}

Future<void> _tapKeys(WidgetTester tester, List<String> keys) async {
  for (final String k in keys) {
    // 只点键盘内的键，避免与金额预览文本重名误触（如 '1' 同时是预览）.
    final Finder f = find.descendant(
      of: find.byType(AmountKeyboard),
      matching: find.text(k),
    );
    await tester.tap(f.first);
    await tester.pump();
  }
}

Future<void> _tapSave(WidgetTester tester) async {
  final Finder f = find.byKey(const Key('saveEntry'));
  await tester.tap(f);
  await tester.pump();
}

void _largeViewport(WidgetTester tester) {
  // 记一笔页含键盘+表单，高视口一次全显，避免滚动/懒构建导致键找不到.
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
  testWidgets('SB-004 键盘输入 12.34 并保存落库', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    // 默认类目首项已选中（餐饮）.
    expect(find.text('餐饮'), findsWidgets);

    await _tapKeys(tester, <String>['1', '2', '.', '3', '4']);
    expect(find.text('12.34'), findsOneWidget);

    await _tapSave(tester);
    await tester.pumpAndSettle();

    final List<Transaction> rows = await db.listAll();
    expect(rows.length, 1);
    expect(rows.first.amountFen, 1234);
    expect(rows.first.category, '餐饮');

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-004 金额为 0 时拦截并提示', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsWidgets);
    await _tapSave(tester);
    await tester.pump();

    expect(find.byKey(const Key('amountError')), findsOneWidget);
    expect(await db.listAll(), isEmpty);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-004 切换类目后保存带新类目', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    await _tapKeys(tester, <String>['5', '0']);
    await tester.tap(find.text('交通').first);
    await tester.pump();
    await _tapSave(tester);
    await tester.pumpAndSettle();

    final List<Transaction> rows = await db.listAll();
    expect(rows.length, 1);
    expect(rows.first.amountFen, 5000);
    expect(rows.first.category, '交通');

    await _unmountAndFlush(tester);
  });
}
