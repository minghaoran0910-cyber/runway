import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/category_feedback.dart';
import 'package:runway/ui/category_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-005 Golden：类目管理页 Light/Dark 各一，基线 golden/sb005/.
// 生成：cd app && flutter test --update-goldens test/golden_category_test.dart
// 注意：本页用 db.watchAll()，测后不调 close（见 category_page_test.dart 头注）.

class CategoryBoard extends StatelessWidget {
  const CategoryBoard({super.key, required this.isDark, required this.db});

  final bool isDark;
  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: CategoryPage(db: db, corrections: CategoryCorrections()),
    );
  }
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
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
  return db;
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-005 golden category light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(CategoryBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CategoryBoard),
      matchesGoldenFile('../../golden/sb005/category_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-005 golden category dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(CategoryBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CategoryBoard),
      matchesGoldenFile('../../golden/sb005/category_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-005 对比度闸门（类目页文字组合）', () {
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
