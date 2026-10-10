import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/pending_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-010 widget + Golden：待确认列表（空/有数 × Light/Dark）+ 权限流 + 入账.
// 基线 golden/sb010/；生成：cd app && flutter test --update-goldens test/golden_pending_test.dart

class FakePendingSource implements PendingSource {
  FakePendingSource({this.enabled = false});

  bool enabled;
  int settingsOpened = 0;
  void Function(PendingPush)? handler;

  @override
  Future<bool> isListenerEnabled() async => enabled;

  @override
  Future<void> openListenerSettings() async {
    settingsOpened++;
  }

  @override
  void setPendingHandler(void Function(PendingPush) onPush) {
    handler = onPush;
  }
}

class PendingBoard extends StatelessWidget {
  const PendingBoard({
    super.key,
    required this.isDark,
    required this.db,
    required this.source,
  });

  final bool isDark;
  final AppDb db;
  final FakePendingSource source;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: PendingListPage(db: db, source: source),
    );
  }
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  await db.insertPendingDedup(
    PendingRecordsCompanion(
      amountFen: const Value(2550),
      occurredAt: Value(DateTime(2026, 10, 10, 9, 31)),
      category: const Value('食'),
      merchant: const Value('瑞幸咖啡'),
      sourcePkg: const Value('com.tencent.mm'),
      notifyKey: const Value('g-1'),
    ),
  );
  await db.insertPendingDedup(
    PendingRecordsCompanion(
      amountFen: const Value(12000),
      occurredAt: Value(DateTime(2026, 10, 10, 8, 5)),
      category: const Value('用'),
      merchant: const Value('支付宝'),
      sourcePkg: const Value('com.eg.android.AlipayGphone'),
      notifyKey: const Value('g-2'),
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
  testWidgets('SB-010 widget 空态：权限引导卡 + 去设置', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final FakePendingSource src = FakePendingSource(enabled: false);
    await tester.pumpWidget(PendingBoard(isDark: false, db: db, source: src));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('permOff')), findsOneWidget);
    expect(find.byKey(const Key('pendingEmpty')), findsOneWidget);
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pump();
    expect(src.settingsOpened, 1);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 widget 有数：逐条确认入账', (WidgetTester tester) async {
    final AppDb db = await _seedDb();
    addTearDown(db.close);
    final FakePendingSource src = FakePendingSource(enabled: true);
    await tester.pumpWidget(PendingBoard(isDark: false, db: db, source: src));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('permOn')), findsOneWidget);
    expect(find.textContaining('瑞幸咖啡'), findsOneWidget);
    // 批量开关默认关（卡验收 3）.
    final Switch sw = tester.widget(find.byKey(const Key('batchSwitch')));
    expect(sw.value, isFalse);
    final int id = (await db.listPending()).first.id;
    await tester.tap(find.byKey(Key('pendingConfirm-$id')));
    await tester.pumpAndSettle();
    expect((await db.listPending()).length, 1);
    final List<Transaction> txs = await db.listAll();
    expect(txs.length, 1);
    expect(txs.single.source, 'notify');
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 widget 批量：开开关→勾选→确认所选', (WidgetTester tester) async {
    final AppDb db = await _seedDb();
    addTearDown(db.close);
    final FakePendingSource src = FakePendingSource(enabled: true);
    await tester.pumpWidget(PendingBoard(isDark: false, db: db, source: src));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('batchSwitch')));
    await tester.pumpAndSettle();
    final int id = (await db.listPending()).first.id;
    await tester.tap(find.byKey(Key('pick-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmPicked')));
    await tester.pumpAndSettle();
    expect((await db.listPending()).length, 1);
    expect((await db.listAll()).length, 1);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 widget 原生推送：同键重复只落一条', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final FakePendingSource src = FakePendingSource(enabled: true);
    await tester.pumpWidget(PendingBoard(isDark: false, db: db, source: src));
    await tester.pumpAndSettle();
    PendingPush push() => PendingPush(
      packageName: 'com.tencent.mm',
      title: '瑞幸咖啡',
      amountFen: 2550,
      merchant: '瑞幸咖啡',
      notifyKey: 'push-dedup-1',
      occurredAt: DateTime(2026, 10, 10, 9, 31),
    );
    src.handler!(push());
    await tester.pumpAndSettle();
    src.handler!(push());
    await tester.pumpAndSettle();
    expect((await db.listPending()).length, 1);
    expect(find.textContaining('瑞幸咖啡'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 golden 待确认有数 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    addTearDown(db.close);
    await tester.pumpWidget(
      PendingBoard(
        isDark: false,
        db: db,
        source: FakePendingSource(enabled: true),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PendingBoard),
      matchesGoldenFile('../../golden/sb010/pending_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 golden 待确认空态 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(
      PendingBoard(
        isDark: false,
        db: db,
        source: FakePendingSource(enabled: false),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PendingBoard),
      matchesGoldenFile('../../golden/sb010/pending_light_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 golden 待确认有数 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    addTearDown(db.close);
    await tester.pumpWidget(
      PendingBoard(
        isDark: true,
        db: db,
        source: FakePendingSource(enabled: true),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PendingBoard),
      matchesGoldenFile('../../golden/sb010/pending_dark_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-010 golden 待确认空态 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(
      PendingBoard(
        isDark: true,
        db: db,
        source: FakePendingSource(enabled: false),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PendingBoard),
      matchesGoldenFile('../../golden/sb010/pending_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-010 对比度闸门（待确认文字组合）', () {
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
