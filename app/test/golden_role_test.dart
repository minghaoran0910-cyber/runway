import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/category_role_dao.dart';
import 'package:runway/logic/category_feedback.dart';
import 'package:runway/ui/category_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

import 'fixed_clock.dart';

// SB-019 Golden：类目管理-角色选择（选/未选必提示）Light/Dark，基线 golden/sb019/.
// 生成：cd app && flutter test --update-goldens test/golden_role_test.dart
// 注意：本页用 db.watchAll()/watchCategoryRoles()，测后不调 close（见 category_page_test.dart 头注）.

class RoleBoard extends StatelessWidget {
  const RoleBoard({super.key, required this.isDark, required this.db});

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

DateTime _mday(int day) {
  // SB-025 · 相对种子经夹具（行为与直调一致）.
  final DateTime now = FixedClock.today();
  final int d = day <= 28 ? day : 28;
  return DateTime(now.year, now.month, d, 12);
}

Future<AppDb> _seedDb() async {
  final AppDb db = AppDb.memoryForTest();
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(7000),
      occurredAt: Value(_mday(10)),
      category: const Value('食'),
      note: const Value('外卖午餐'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(3000),
      occurredAt: Value(_mday(10)),
      category: const Value('玩'),
      note: const Value('电影'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(1000),
      occurredAt: Value(_mday(11)),
      category: const Value('自建类'),
      note: const Value('手作市集'),
      source: const Value('manual'),
    ),
  );
  await db.insertOne(
    TransactionsCompanion(
      amountFen: const Value(5000),
      occurredAt: Value(_mday(11)),
      category: const Value('食'),
      note: const Value('周五聚餐火锅'),
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
  testWidgets('SB-019 弹性占比头行（首页不放，类目页有）', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();

    await tester.pumpWidget(RoleBoard(isDark: false, db: db));
    await tester.pumpAndSettle();

    // 总额 16000，弹性=玩3000+自建类1000（计算侧兜底弹性，提示仅 UI 层）→ 25.0%.
    // SB-039 ② · 头行人话化（key 不变）.
    expect(find.byKey(const Key('elasticShare')), findsOneWidget);
    expect(find.textContaining('本月能省的占比 25.0%'), findsOneWidget);
    expect(find.byKey(const Key('elasticHint')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-019 未选必提示：自建类无覆盖即提示，选中后消失', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();

    await tester.pumpWidget(RoleBoard(isDark: false, db: db));
    await tester.pumpAndSettle();

    // 默认类有选中态（食=必要）.
    // SB-047 · 角色墙默认折叠：先展开.
    await tester.tap(find.byKey(const Key('roleWall')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('role-食-必要')), findsOneWidget);
    // 自建类无默认无覆盖 → 必提示.
    expect(find.byKey(const Key('rolePrompt-自建类')), findsOneWidget);

    await tester.tap(find.byKey(const Key('role-自建类-必要')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rolePrompt-自建类')), findsNothing);
    final Map<String, String> m = await db.roleOverrideMap();
    expect(m['自建类'], '必要');

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-019 聚餐引导卡（只引导不强制）', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();

    await tester.pumpWidget(RoleBoard(isDark: false, db: db));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('diningGuide')), findsOneWidget);
    expect(find.byKey(const Key('diningCount')), findsOneWidget);
    // 不强制：食仍解析为必要.
    // SB-047 · 角色墙默认折叠：先展开.
    await tester.tap(find.byKey(const Key('roleWall')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('role-食-必要')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-019 golden role light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(RoleBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RoleBoard),
      matchesGoldenFile('../../golden/sb019/role_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-019 golden role dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = await _seedDb();
    await tester.pumpWidget(RoleBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RoleBoard),
      matchesGoldenFile('../../golden/sb019/role_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-019 对比度闸门（角色页文字组合）', () {
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
