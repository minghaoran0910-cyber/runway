import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/price_watch.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/price_card.dart';
import 'package:runway/ui/quick_add_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

import 'fixed_clock.dart';

// SB-020 widget + Golden：常买价格眼（有历史/无历史卡片）Light/Dark + 接线.
// 基线 golden/sb020/；生成：cd app && flutter test --update-goldens test/golden_price_test.dart

class PriceBoard extends StatelessWidget {
  const PriceBoard({super.key, required this.isDark, required this.stats});

  final bool isDark;
  final PriceStats stats;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: PriceCard(stats: stats)),
    );
  }
}

PriceStats _demoStats() {
  return summarizePrices(key: '食｜牛肉面', amounts: <int>[2500, 2800, 3000, 2600])!;
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  // SB-025 · 相对种子经夹具（行为与直调一致）.
  final DateTime now = FixedClock.today();
  DateTime day(int d) => DateTime(now.year, now.month, d <= 28 ? d : 28, 12);
  final List<({int fen, int d})> noodles = <({int fen, int d})>[
    (fen: 2500, d: 3),
    (fen: 2800, d: 5),
    (fen: 3000, d: 8),
  ];
  for (final e in noodles) {
    await db.insertOne(
      TransactionsCompanion(
        amountFen: Value(e.fen),
        occurredAt: Value(day(e.d)),
        category: const Value('食'),
        note: const Value('牛肉面'),
        source: const Value('manual'),
      ),
    );
  }
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(5000),
      occurredAt: Value(day(9)),
      category: const Value('玩'),
      note: const Value('电影'),
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

void main() {
  testWidgets('SB-020 有历史卡片（均价/最低/最近+走势）', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(PriceBoard(isDark: false, stats: _demoStats()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('priceTitle')), findsOneWidget);
    expect(find.byKey(const Key('priceAvg')), findsOneWidget);
    expect(find.textContaining('最低'), findsOneWidget);
    expect(find.byKey(const Key('priceVs')), findsOneWidget);
    expect(find.byKey(const Key('priceSpark')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-020 无历史零高度（<3 条不猜）', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: PriceZone(db: db)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('priceZoneTitle')), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-020 记一笔命中同类历史显示较均价', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: QuickAddPage(db: db, categories: const <String>['食', '玩']),
      ),
    );
    await tester.pumpAndSettle();

    // 默认已选中食：填备注即命中同键（食｜牛肉面，3 笔）.
    await tester.enterText(find.byType(TextField), '牛肉面');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('priceHint')), findsOneWidget);
    expect(find.textContaining('常买均价'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-020 目标单价跟随常买中位数（手改优先）', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: GoalPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('goalAdd')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('goalFollowKey')), '食｜牛肉面');
    await tester.tap(find.byKey(const Key('goalFollowFetch')));
    await tester.pumpAndSettle();

    // 中位数 2800 → 28 元填入单价框；手改后仍可覆盖.
    expect(find.text('28'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-020 golden price light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(PriceBoard(isDark: false, stats: _demoStats()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PriceBoard),
      matchesGoldenFile('../../golden/sb020/price_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-020 golden price dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(PriceBoard(isDark: true, stats: _demoStats()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PriceBoard),
      matchesGoldenFile('../../golden/sb020/price_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-020 对比度闸门（价格卡文字组合）', () {
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
