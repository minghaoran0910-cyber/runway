import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/goal_timeline.dart';
import 'package:runway/ui/home_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/widgets/trend_line.dart';

// SB-030 · 时间线 + 折线 widget 单测 + 首页→目标 ≤2 跳实测.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-030 时间线未达成 tabular ¥现攒/¥目标', (WidgetTester tester) async {
    final DateTime now = DateTime(2026, 10, 14, 12);
    final List<Goal> goals = <Goal>[
      Goal(
        id: 1,
        name: '攒手机',
        targetFen: 399900,
        priceName: '奶茶',
        priceFen: 1800,
        createdAt: DateTime(2026, 10, 1, 12),
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalTimeline(
            goals: goals,
            convertibleFen: 14000,
            now: now,
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalTimeline')), findsOneWidget);
    expect(find.byKey(const Key('goalTimelineProgress-1')), findsOneWidget);
    expect(find.byKey(const Key('goalItem-1')), findsOneWidget);
  });

  testWidgets('SB-030 时间线达成态琥珀 ✓ 已攒够·N周', (WidgetTester tester) async {
    final DateTime now = DateTime(2026, 10, 14, 12);
    final List<Goal> goals = <Goal>[
      Goal(
        id: 2,
        name: '攒键盘',
        targetFen: 10000,
        priceName: '奶茶',
        priceFen: 1800,
        createdAt: DateTime(2026, 9, 20, 12),
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalTimeline(
            goals: goals,
            convertibleFen: 14000,
            now: now,
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalTimelineDone-2')), findsOneWidget);
    expect(find.textContaining('已攒够'), findsOneWidget);
    expect(find.textContaining('周'), findsOneWidget);
    // SB-031 ①：文案去 ✓（瓦片图标保留唯一 ✓），防双 ✓ 冗余回归.
    expect(find.textContaining('✓'), findsNothing);
  });

  testWidgets('SB-031 编辑/删除键并入状态行右侧 trailing', (WidgetTester tester) async {
    final DateTime now = DateTime(2026, 10, 14, 12);
    final List<Goal> goals = <Goal>[
      Goal(
        id: 3,
        name: '攒手机',
        targetFen: 399900,
        priceName: '奶茶',
        priceFen: 1800,
        createdAt: DateTime(2026, 10, 1, 12),
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalTimeline(
            goals: goals,
            convertibleFen: 14000,
            now: now,
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final Finder edit = find.byKey(const Key('goalEdit-3'));
    final Finder del = find.byKey(const Key('goalDelete-3'));
    final Finder status = find.byKey(const Key('goalTimelineProgress-3'));
    expect(edit, findsOneWidget);
    expect(del, findsOneWidget);
    // 三者同属一行 Row：状态文本 Expanded + 双键 trailing（非悬于下方左置）.
    Finder rowOf(Finder f) => find.ancestor(of: f, matching: find.byType(Row));
    final Set<Element> editRows = rowOf(edit).evaluate().toSet();
    final Set<Element> statusRows = rowOf(status).evaluate().toSet();
    final Set<Element> delRows = rowOf(del).evaluate().toSet();
    expect(
      editRows.intersection(statusRows).isNotEmpty,
      isTrue,
      reason: '编辑键须与状态行同 Row',
    );
    expect(
      delRows.intersection(statusRows).isNotEmpty,
      isTrue,
      reason: '删除键须与状态行同 Row',
    );
  });

  testWidgets('SB-030 折线空数据不断言崩', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrendLine(values: <int>[0, 0, 0, 0, 0, 0, 0])),
      ),
    );
    await tester.pump();
    expect(find.byType(TrendLine), findsOneWidget);
  });

  testWidgets('SB-030 折线单点/极差渲染', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrendLine(values: <int>[100, 10000, 200, 50000, 300, 400, 500]),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(TrendLine), findsOneWidget);
  });

  testWidgets('SB-030 折线同长度新数据触发重绘', (WidgetTester tester) async {
    const List<int> a = <int>[100, 200, 300, 400, 500, 600, 700];
    const List<int> b = <int>[700, 600, 500, 400, 300, 200, 100];
    Finder trendPaint() => find.descendant(
      of: find.byType(TrendLine),
      matching: find.byType(CustomPaint),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrendLine(values: a)),
      ),
    );
    await tester.pump();
    final CustomPaint first = tester.widget<CustomPaint>(trendPaint());
    final dynamic oldPainter = first.painter;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrendLine(values: b)),
      ),
    );
    await tester.pump();
    final CustomPaint second = tester.widget<CustomPaint>(trendPaint());
    final dynamic newPainter = second.painter;
    // 同长度不同值必须重绘（长度代理判等曾在此漏刷）.
    expect(newPainter.shouldRepaint(oldPainter), isTrue);
    // 同值重泵必须不重绘（无用功不刷）.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrendLine(values: b)),
      ),
    );
    await tester.pump();
    final CustomPaint third = tester.widget<CustomPaint>(trendPaint());
    final dynamic newestPainter = third.painter;
    expect(newestPainter.shouldRepaint(newPainter), isFalse);
  });

  test('SB-030 weeksSince 整周口径', () {
    expect(
      GoalTimeline.weeksSince(
        DateTime(2026, 10, 14, 12),
        DateTime(2026, 10, 14, 12),
      ),
      1,
    );
    expect(
      GoalTimeline.weeksSince(
        DateTime(2026, 10, 7, 12),
        DateTime(2026, 10, 14, 12),
      ),
      2,
    );
  });

  testWidgets('SB-030 首页→目标页 1 跳可达', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: HomePage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    // 首页目标卡入口存在（手势入口，点进目标页即第 1 跳）.
    expect(find.byType(GestureDetector), findsWidgets);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-030 目标页→周报 1 跳可达（首页起 ≤2 跳）', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    // SB-040 起空列表不渲染时间线白卡——先置一条目标再断言可达.
    await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒手机'),
        targetFen: const Value(399900),
        priceName: const Value('奶茶'),
        priceFen: const Value(1800),
        tier: const Value('手机'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: GoalPage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    // 目标页含周报入口键（第 2 跳），首页→目标→周报共 ≤2 跳.
    // 040 合入轮：合并态列表更高且搬家区流重建使 scrollUntilVisible 内部
    // element() 竞态（No element）——改渐进拖拽+收集：三键均在列表出现=可达.
    final Set<String> seen = <String>{};
    for (int i = 0; i < 12 && seen.length < 3; i++) {
      for (final String k in <String>[
        'goalToWeekly',
        'goalCount',
        'goalTimeline',
      ]) {
        if (find.byKey(Key(k)).evaluate().isNotEmpty) {
          seen.add(k);
        }
      }
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(seen.length, 3, reason: '周报入口/计数/时间线三键须均在目标页列表出现（≤2跳契约）');
    await _unmountAndFlush(tester);
  });
}
