import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/cooloff_dao.dart';
import 'package:runway/logic/cooloff.dart';
import 'package:runway/ui/cooloff_card.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

import 'fixed_clock.dart';

// SB-017 widget + Golden：冷静两组（提出/忍住）× Light/Dark.
// 基线 golden/sb017/；生成：cd app && flutter test --update-goldens test/golden_cooloff_test.dart

class CooloffBoard extends StatelessWidget {
  const CooloffBoard({super.key, required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    );
  }
}

CooloffCard _askCard() {
  return CooloffCard(
    amountFen: 20000,
    held: false,
    onBuy: () {},
    onHold: () {},
  );
}

CooloffCard _heldCard() {
  return const CooloffCard(
    amountFen: 20000,
    held: true,
    savedFen: 20000,
    targetFen: 1649900,
  );
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  // SB-025 · 相对种子经夹具（行为与直调一致）.
  final DateTime now = FixedClock.today();
  for (int i = 1; i <= 5; i++) {
    await db.insertOne(
      TransactionsCompanion(
        amountFen: Value(1000),
        occurredAt: Value(now.subtract(Duration(days: i))),
        category: const Value('餐饮'),
        source: const Value('manual'),
      ),
    );
  }
  return db;
}

void main() {
  testWidgets('SB-017 widget 提出态：仍要买+忍住双钮', (WidgetTester tester) async {
    await tester.pumpWidget(CooloffBoard(isDark: false, child: _askCard()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cooloffAsk')), findsOneWidget);
    expect(find.byKey(const Key('cooloffBuy')), findsOneWidget);
    expect(find.byKey(const Key('cooloffHold')), findsOneWidget);
    expect(find.text('仍要买'), findsOneWidget);
    expect(find.text('忍住'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-017 widget 忍住态：省额+梗行', (WidgetTester tester) async {
    await tester.pumpWidget(CooloffBoard(isDark: false, child: _heldCard()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cooloffDone')), findsOneWidget);
    expect(find.byKey(const Key('cooloffJoke')), findsOneWidget);
    expect(find.byKey(const Key('cooloffBuy')), findsNothing);
    expect(find.textContaining('省出'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-017 widget 仍要买无摩擦：点后即回调', (WidgetTester tester) async {
    bool bought = false;
    await tester.pumpWidget(
      CooloffBoard(
        isDark: false,
        child: CooloffCard(
          amountFen: 20000,
          held: false,
          onBuy: () => bought = true,
          onHold: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cooloffBuy')));
    await tester.pumpAndSettle();
    expect(bought, isTrue);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-017 widget 我的页集成（SB-038搬家后）：冷静区挂载+开关', (
    WidgetTester tester,
  ) async {
    final AppDb db = await _seedDb();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: GoalPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('cooloffSwitch')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cooloffSwitch')), findsOneWidget);
    expect(find.text('大额冷静'), findsOneWidget);
    await _unmountAndFlush(tester);
    await db.close();
  });

  testWidgets('SB-017 widget DAO：开关默认开+建单幂等+决策+回滚', (
    WidgetTester tester,
  ) async {
    final AppDb db = AppDb.memoryForTest();
    expect(await db.cooloffEnabled(), isTrue);
    await db.setCooloffEnabled(false);
    expect(await db.cooloffEnabled(), isFalse);
    await db.setCooloffEnabled(true);
    expect(await db.cooloffCustomFen(), 0);
    final int id1 = await db.proposeCooloff(txId: 7, amountFen: 20000);
    final int id2 = await db.proposeCooloff(txId: 7, amountFen: 20000);
    expect(id1, id2);
    expect((await db.cooloffOfTx(7))?.status, 'pending');
    await db.decideCooloff(id: id1, status: 'held');
    expect((await db.cooloffOfTx(7))?.status, 'held');
    expect(
      shouldExpireCooloff(
        // SB-025 · 相对种子经夹具（行为与直调一致）.
        proposedAt: FixedClock.today().subtract(const Duration(hours: 25)),
        now: FixedClock.today(),
      ),
      isTrue,
    );
    await db.rollbackCooloffToV8();
    await db.close();
  });

  testWidgets('SB-017 golden 提出 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CooloffBoard(isDark: false, child: _askCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CooloffBoard),
      matchesGoldenFile('../../golden/sb017/cooloff_light_ask.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-017 golden 提出 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CooloffBoard(isDark: true, child: _askCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CooloffBoard),
      matchesGoldenFile('../../golden/sb017/cooloff_dark_ask.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-017 golden 忍住 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CooloffBoard(isDark: false, child: _heldCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CooloffBoard),
      matchesGoldenFile('../../golden/sb017/cooloff_light_held.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-017 golden 忍住 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(CooloffBoard(isDark: true, child: _heldCard()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CooloffBoard),
      matchesGoldenFile('../../golden/sb017/cooloff_dark_held.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-017 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/cooloff_card.dart',
      'lib/ui/home_page.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-017 对比度闸门（冷静文案组合）', () {
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
