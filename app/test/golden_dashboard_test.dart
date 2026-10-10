import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/home_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-006 Golden：首页看板 Light/Dark × 空态/有数据，共四组，基线 golden/sb006/.
// 生成：cd app && flutter test --update-goldens test/golden_dashboard_test.dart
// 注意：HomePage 用 db.watchAll()，测后不调 close（见 widget_test.dart 头注）.

class DashboardBoard extends StatelessWidget {
  const DashboardBoard({super.key, required this.isDark, required this.db});

  final bool isDark;
  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(db: db),
    );
  }
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  final DateTime now = DateTime.now();
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
      amountFen: const Value(3000),
      occurredAt: Value(now),
      category: const Value('行'),
      note: const Value('地铁'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(2000),
      occurredAt: Value(now),
      category: const Value('其他'),
      note: const Value('未知事项'),
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
  testWidgets('SB-006 golden 看板有数据 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(DashboardBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DashboardBoard),
      matchesGoldenFile('../../golden/sb006/dashboard_light_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-006 golden 看板有数据 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(DashboardBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DashboardBoard),
      matchesGoldenFile('../../golden/sb006/dashboard_dark_data.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-006 golden 看板空态 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(DashboardBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DashboardBoard),
      matchesGoldenFile('../../golden/sb006/dashboard_light_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-006 golden 看板空态 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(DashboardBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DashboardBoard),
      matchesGoldenFile('../../golden/sb006/dashboard_dark_empty.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-006 对比度闸门（看板文字组合）', () {
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
