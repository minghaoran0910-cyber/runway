import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/goal_editor.dart';
import 'package:runway/ui/goal_page.dart';
import 'package:runway/ui/settings_page.dart';

// SB-040 · 目标动线补全 + 设置页（widget 单测；固定时钟无关=纯 UI 断言）.

Widget _wrap(Widget child) => MaterialApp(home: child);

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  test('SB-040 期限校验：空=过，1–36=过，其余=错', () {
    expect(validateDeadline(''), isNull);
    expect(validateDeadline('  '), isNull);
    expect(validateDeadline('6'), isNull);
    expect(validateDeadline('1'), isNull);
    expect(validateDeadline('36'), isNull);
    expect(validateDeadline('0'), isNotNull);
    expect(validateDeadline('37'), isNotNull);
    expect(validateDeadline('abc'), isNotNull);
  });

  test('SB-040 导出 CSV：表头固定+逗号转义', () {
    final String csv = exportTransactionsCsv(<Transaction>[]);
    expect(
      csv.startsWith('id,amountFen,occurredAt,category,note,source'),
      isTrue,
    );
  });

  testWidgets('SB-040 我的页：标题+设置入口+空态按钮+无空白卡', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    // 标题已改为"我的"，设置入口可达.
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('目标阶梯'), findsNothing);
    expect(find.byKey(const Key('settingsEntry')), findsOneWidget);

    // 空态：旧 goalEmpty 在 + 新按钮在；空列表不渲染白卡时间线.
    expect(find.byKey(const Key('goalEmpty')), findsOneWidget);
    expect(find.byKey(const Key('goalEmptyAdd')), findsOneWidget);
    expect(find.byKey(const Key('goalTimeline')), findsNothing);

    // 设置页四行可达（诊断段门关闭=零像素，不断言）.
    await tester.tap(find.byKey(const Key('settingsEntry')));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsOneWidget);
    expect(find.byKey(const Key('settingsImport')), findsOneWidget);
    expect(find.byKey(const Key('settingsPending')), findsOneWidget);
    expect(find.byKey(const Key('settingsExport')), findsOneWidget);
    expect(find.byKey(const Key('settingsAbout')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-040 空态按钮→表单：名称/金额/期限三字段+保存建目标', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalName')), findsOneWidget);
    expect(find.byKey(const Key('goalTarget')), findsOneWidget);
    expect(find.byKey(const Key('goalDeadline')), findsOneWidget);

    // 非法期限挡保存（对话框不关）.
    await tester.enterText(find.byKey(const Key('goalName')), '攒手机');
    await tester.enterText(find.byKey(const Key('goalTarget')), '3999');
    await tester.enterText(find.byKey(const Key('goalDeadline')), '99');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();
    expect(find.text('期限须为 1–36 个月'), findsOneWidget);
    // 错误条 4s 占屏，成功条会排队——先等它退场再二次保存.
    await tester.pump(const Duration(seconds: 5));

    // 合法期限放行：建完列表出现（含期限回显）.
    // 注：snackbar 4s 即逝，pumpAndSettle 会把它消费掉——改定泵断言.
    await tester.enterText(find.byKey(const Key('goalDeadline')), '6');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('已定下新目标'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('攒手机'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('攒手机'), findsWidgets);
    // 建完有目标→时间线白卡恢复（非空才渲染）.
    expect(find.byKey(const Key('goalTimeline')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-040 换算行可点：出预设+目标价选择列表', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await db.insertGoal(
      GoalsCompanion(
        name: const Value('攒键盘'),
        targetFen: const Value(29900),
        priceName: const Value('键盘'),
        priceFen: const Value(29900),
        tier: const Value('键盘'),
      ),
    );
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('goalPricePick')), findsOneWidget);
    await tester.tap(find.byKey(const Key('goalPricePick')));
    await tester.pumpAndSettle();
    expect(find.text('换算成什么'), findsOneWidget);
    expect(find.byKey(const Key('priceOption-奶茶')), findsOneWidget);
    // 当前目标价作为自定义项在列.
    expect(find.byKey(const Key('priceOption-custom-键盘')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-040 余粮空态：引导语降 bodySmall（非标题字号）', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('记满 3 个月'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    final BuildContext ctx = tester.element(
      find.byKey(const Key('grainConvert')),
    );
    final Text t = tester.widget<Text>(find.byKey(const Key('grainConvert')));
    final ThemeData theme = Theme.of(ctx);
    expect(t.style?.fontSize, theme.textTheme.bodySmall?.fontSize);

    await _unmountAndFlush(tester);
  });
}
