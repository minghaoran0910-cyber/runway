import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/main.dart'
    show runwayLocalizationsDelegates, runwaySupportedLocales;
import 'package:runway/ui/goal_page.dart';

// SB-048 · 设目标表单控件修复（widget 单测）.
// 覆盖：核心三项常显/进阶折叠/目标预设 chips/期限日历入口/自定义单价卡/
// 换算提示/人话标签/截断修复（短标签）/全链路建目标/日历中文弹层（票262问题①）.

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: runwayLocalizationsDelegates,
  supportedLocales: runwaySupportedLocales,
  home: child,
);

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-048 核心三项常显，进阶默认折叠', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('goalName')), findsOneWidget);
    expect(find.byKey(const Key('goalTarget')), findsOneWidget);
    expect(find.byKey(const Key('goalDeadline')), findsOneWidget);
    expect(find.byKey(const Key('goalAdvanced')), findsOneWidget);
    // 进阶折叠：单价 chips 与跟随字段收起不可见.
    expect(find.byKey(const Key('priceOption-奶茶')), findsNothing);
    expect(find.byKey(const Key('goalFollowKey')), findsNothing);

    // 展开进阶后可见.
    await tester.scrollUntilVisible(
      find.byKey(const Key('goalAdvanced')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('goalAdvanced')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('priceOption-奶茶')), findsOneWidget);
    expect(find.byKey(const Key('goalFollowKey')), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-048 目标预设 chip 一点即填金额', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalTargetPreset-手机')));
    await tester.pumpAndSettle();
    // 手机档 399900 分 → 回填 "3,999".
    final TextField target = tester.widget<TextField>(
      find.byKey(const Key('goalTarget')),
    );
    expect(target.controller?.text, '3,999');

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-048 期限日历入口与短标签防截断', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('goalDeadlinePick')), findsOneWidget);
    // 短标签：无长括号截断源.
    final TextField deadline = tester.widget<TextField>(
      find.byKey(const Key('goalDeadline')),
    );
    expect(deadline.decoration?.labelText, '期限（可选）');
    // 手输仍兼容（旧链路），非法仍挡保存.
    await tester.enterText(find.byKey(const Key('goalDeadline')), '99');
    await tester.enterText(find.byKey(const Key('goalName')), '攒手机');
    await tester.enterText(find.byKey(const Key('goalTarget')), '3999');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pumpAndSettle();
    expect(find.text('期限须为 yyyy-MM-dd 日期'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-048 日历弹层中文（票262问题①回归：非英文 picker）', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('goalDeadlinePick')));
    await tester.pumpAndSettle();

    // 中文弹层锚点（限 Dialog 内：表单本体自带「清除」等非弹层文案）；
    // 英文残留（Select date/OK/Cancel）必须零命中.
    final Finder dialog = find.ancestor(
      of: find.text('选择日期'),
      matching: find.byType(Dialog),
    );
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('确定')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('取消')),
      findsOneWidget,
    );
    expect(find.text('OK'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
    expect(find.text('Select date'), findsNothing);

    // 点确定回填 yyyy-MM-dd，零数字键入路径成立.
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    final TextField deadline = tester.widget<TextField>(
      find.byKey(const Key('goalDeadline')),
    );
    expect(deadline.controller?.text, matches(r'^\d{4}-\d{2}-\d{2}$'));

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-048 自定义单价卡展开行内输入 + 换算提示 + 人话标签', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('goalAdvanced')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('goalAdvanced')));
    await tester.pumpAndSettle();

    // 自定义卡存在，默认收起（预设奶茶命中）.
    expect(find.byKey(const Key('priceOption-custom')), findsOneWidget);
    expect(find.byKey(const Key('goalPriceName')), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const Key('priceOption-custom')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('priceOption-custom')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalPriceName')), findsOneWidget);
    expect(find.byKey(const Key('goalPrice')), findsOneWidget);

    // 人话标签：无"常买键"黑话.
    final TextField follow = tester.widget<TextField>(
      find.byKey(const Key('goalFollowKey')),
    );
    expect(follow.decoration?.labelText, contains('常买价'));
    expect(find.textContaining('常买键'), findsNothing);

    // 换算提示：目标 3999 + 单价奶茶 18 → 攒够 222 杯奶茶.
    await tester.enterText(find.byKey(const Key('goalName')), '攒手机');
    await tester.enterText(find.byKey(const Key('goalTarget')), '3999');
    await tester.pumpAndSettle();
    // 切回预设奶茶以便换算（自定义展开中点奶茶收起自定义）.
    await tester.tap(find.byKey(const Key('priceOption-奶茶')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goalConvertHint')), findsOneWidget);
    expect(find.textContaining('攒够'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('SB-048 全链路：预设金额 + 手输日期建目标', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(_wrap(GoalPage(db: db)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goalEmptyAdd')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('goalName')), '攒键盘');
    await tester.tap(find.byKey(const Key('goalTargetPreset-键盘')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goalDeadline')), '2026-12-31');
    await tester.tap(find.byKey(const Key('goalSave')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已定下新目标'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('攒键盘'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('攒键盘'), findsWidgets);
    expect(find.text('预计 12月31日攒到'), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
