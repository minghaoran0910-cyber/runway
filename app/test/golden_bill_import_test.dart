import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/bill_import_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-011 widget + Golden：导入向导（选文件→预览→结果 × Light/Dark）+ 撤销 + 对比度闸门.
// 基线 golden/sb011/；生成：cd app && flutter test --update-goldens test/golden_bill_import_test.dart
// 测试一律合成数据.

const String _fixtureCsv =
    '交易时间,交易分类,交易对方,对方账号,商品说明,收/支,金额,收/付款方式,交易状态,交易订单号\n'
    '2026-09-01 12:34:56,餐饮美食,测试小吃店,acc1,午餐,支出,25.50,余额宝,交易成功,ALI001\n'
    '2026-09-01 18:20:00,交通出行,测试地铁,acc2,地铁,支出,4.00,余额宝,交易成功,ALI002\n'
    '2026-09-02 09:00:00,餐饮美食,测试包子铺,acc3,早餐,支出,,余额宝,交易成功,ALI003\n';

class ImportBoard extends StatelessWidget {
  const ImportBoard({super.key, required this.isDark, required this.db});

  final bool isDark;
  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: BillImportPage(db: db),
    );
  }
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

Future<void> _toPreview(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('csvField')), _fixtureCsv);
  await tester.tap(find.byKey(const Key('parseBtn')));
  await tester.pumpAndSettle();
}

Future<void> _toResult(WidgetTester tester) async {
  await _toPreview(tester);
  await tester.tap(find.byKey(const Key('confirmBtn')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('SB-011 widget 预览：计数+失败行+返回修改', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('importStep')), findsOneWidget);
    await _toPreview(tester);
    expect(find.byKey(const Key('previewCount')), findsOneWidget);
    expect(find.textContaining('可入账 2 笔'), findsOneWidget);
    expect(find.textContaining('失败 1 行'), findsOneWidget);
    expect(find.byKey(const Key('failRow-4')), findsOneWidget);
    expect(find.textContaining('测试小吃店'), findsOneWidget);
    await tester.tap(find.byKey(const Key('backBtn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('csvField')), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-011 widget 确认入账→结果→撤销本批', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await _toPreview(tester);
    await tester.tap(find.byKey(const Key('confirmBtn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('resultSummary')), findsOneWidget);
    expect(find.textContaining('入账 2 笔'), findsOneWidget);
    expect((await db.listAll()).length, 2);
    await tester.tap(find.byKey(const Key('revokeBtn')));
    await tester.pumpAndSettle();
    expect(find.textContaining('本批已撤销'), findsOneWidget);
    expect(await db.listAll(), isEmpty);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-011 widget 空粘贴与坏路径给提示', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parseBtn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('importNotice')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('fileField')),
      '/no/such/bill.csv',
    );
    await tester.ensureVisible(find.byKey(const Key('fileBtn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fileBtn')));
    await tester.pumpAndSettle();
    expect(find.textContaining('文件不存在'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-011 golden 预览 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await _toPreview(tester);
    await expectLater(
      find.byType(ImportBoard),
      matchesGoldenFile('../../golden/sb011/preview_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-011 golden 结果 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await _toResult(tester);
    await expectLater(
      find.byType(ImportBoard),
      matchesGoldenFile('../../golden/sb011/result_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-011 golden 预览 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await _toPreview(tester);
    await expectLater(
      find.byType(ImportBoard),
      matchesGoldenFile('../../golden/sb011/preview_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-011 golden 结果 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(ImportBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await _toResult(tester);
    await expectLater(
      find.byType(ImportBoard),
      matchesGoldenFile('../../golden/sb011/result_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-011 对比度闸门（导入向导文字组合）', () {
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
