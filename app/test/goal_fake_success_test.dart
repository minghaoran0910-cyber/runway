// SB-042 · 假成功回归：非法金额零落库时无成功条且对话框保持打开.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/theme/app_theme.dart';

Widget _wrap(AppDb db) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: GoalPage(db: db),
  );
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('goalAdd')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.text('定一个目标'), findsOneWidget);
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  // 先放行 SnackBar 定时器（4s 自动消失），再卸载树，防 pending timer 误杀.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-042 非法金额：错误条+对话框存活+无成功条+零落库', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _openDialog(tester);
    // SB-042 P3 · chip 文案含分隔（5090 ¥16,499），非 509016,499 粘连.
    expect(find.textContaining('5090 ¥'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('goalName')), '攒手机');
    // 卡面指定污染串：parseAmountToFen -> null -> 校验拒绝.
    await tester.enterText(
      find.byKey(const Key('goalTarget')),
      '3002027-04-30',
    );
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 错误条为失败路径唯一 toast.
    expect(find.text('目标金额须大于 0'), findsOneWidget);
    // 成功条绝不出现.
    expect(find.text('已定下新目标'), findsNothing);
    // 对话框保持打开（用户可改后重存）.
    expect(find.byKey(const Key('goalSave')), findsOneWidget);
    expect(find.text('定一个目标'), findsOneWidget);
    // DB 行数不变.
    final goals = await db.listGoals();
    expect(goals, isEmpty);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-042 合法金额：真实落库后才弹成功条', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _openDialog(tester);

    await tester.enterText(find.byKey(const Key('goalName')), '攒手机');
    await tester.enterText(find.byKey(const Key('goalTarget')), '3999');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('已定下新目标'), findsOneWidget);
    final goals = await db.listGoals();
    expect(goals.length, 1);
    expect(goals.first.name, '攒手机');
    await _unmountAndFlush(tester);
  });
}
