import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/root_shell.dart';

// SB-027 · 底部导航三 tab 可达性：首页/账本/我的均可达，FAB 口径如卡.

Widget _wrap(AppDb db) {
  return MaterialApp(home: RootShell(db: db));
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
  testWidgets('SB-027 三 tab 可达 + FAB 口径', (WidgetTester tester) async {
    _largeViewport(tester);
    final AppDb db = AppDb.memoryForTest();

    await tester.pumpWidget(_wrap(db));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // 首页（默认）：攒够标题 + 统一记一笔 FAB.
    expect(find.text('攒够'), findsOneWidget);
    expect(find.byKey(const Key('shellAdd')), findsOneWidget);

    // 账本：类目管理页可达 + 统一 FAB 仍在.
    await tester.tap(find.text('账本'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('账本')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('shellAdd')), findsOneWidget);

    // 我的：我的页（SB-040 起标题=我的，不再叫目标阶梯）可达；
    // 该页保留定目标 FAB，外层记一笔隐藏.
    // SB-027 续做修：FAB 跨 Scaffold 有 hero 过渡（~300ms），定泵
    // 300ms+1 帧恰卡在过渡中导致旧 shellAdd 仍在 overlay——改 settle 等过渡走完.
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    // Tab 文案"我的"+AppBar 标题"我的"=2 处.
    expect(find.text('我的'), findsNWidgets(2));
    expect(find.text('目标阶梯'), findsNothing);
    expect(find.byKey(const Key('goalAdd')), findsOneWidget);
    expect(find.byKey(const Key('shellAdd')), findsNothing);

    // 回首页：统一 FAB 恢复.
    await tester.tap(find.text('首页'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('攒够'), findsOneWidget);
    expect(find.byKey(const Key('shellAdd')), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
