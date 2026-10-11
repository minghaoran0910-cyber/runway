import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/week_warm.dart';
import 'package:runway/ui/daily_close_sheet.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';
import 'package:runway/ui/today_saved_row.dart';

// SB-022 widget + Golden：零日温度线 1 组（Light/Dark）.
// 基线 golden/sb022/；生成：cd app && flutter test --update-goldens test/golden_zero_day_test.dart

class WarmBoard extends StatelessWidget {
  const WarmBoard({super.key, required this.isDark, required this.child});

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

TodaySavedRow _zeroRow() {
  return const TodaySavedRow(
    savedFen: 0,
    todayCount: 3,
    necessaryFen: 10000,
    flexibleFen: 20000,
    fixedFen: 5000,
  );
}

TodaySavedRow _overspendRow() {
  return const TodaySavedRow(
    savedFen: -2700,
    todayCount: 2,
    necessaryFen: 10000,
    flexibleFen: 20000,
    fixedFen: 5000,
    joyRows: <JoyRow>[
      JoyRow(2700, '玩', '霸王茶姬', 'manual'),
      JoyRow(9900, '其他', '每日收口估算', 'estimate'),
    ],
  );
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-022 widget 零日三段全现身', (WidgetTester tester) async {
    await tester.pumpWidget(
      const WarmBoard(isDark: false, child: TodaySavedRow(savedFen: 0)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('todaySavedZero')), findsOneWidget);
    expect(find.byKey(const Key('zeroDayEncourage')), findsOneWidget);
    expect(find.byKey(const Key('weekRoleLine')), findsOneWidget);
    expect(find.textContaining('今天攒 0'), findsOneWidget);
    expect(find.textContaining('已记 0 笔'), findsOneWidget);
    expect(find.textContaining('本周必要'), findsOneWidget);
    expect(find.byKey(const Key('todaySaved')), findsNothing);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 widget 非零日行为不变（攒出行）', (WidgetTester tester) async {
    await tester.pumpWidget(
      const WarmBoard(isDark: false, child: TodaySavedRow(savedFen: 5000)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('todaySaved')), findsOneWidget);
    expect(find.textContaining('今天攒出'), findsOneWidget);
    expect(find.byKey(const Key('todaySavedZero')), findsNothing);
    expect(find.byKey(const Key('weekRoleLine')), findsNothing);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 widget 收口卡已记零结余透传', (WidgetTester tester) async {
    await tester.pumpWidget(
      WarmBoard(
        isDark: false,
        child: DailyCloseCard(
          estimateFen: 5750,
          todaySpendFen: 8000,
          closed: true,
          savedFen: 0,
          todayCount: 2,
          necessaryFen: 3000,
          flexibleFen: 4000,
          fixedFen: 1000,
          onConfirm: () {},
          onAdjust: () {},
          onSkip: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dailyCloseDone')), findsOneWidget);
    expect(find.byKey(const Key('todaySavedZero')), findsOneWidget);
    expect(find.textContaining('已记 2 笔'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 widget 负结余三段+去向行（今天攒0禁用）', (WidgetTester tester) async {
    await tester.pumpWidget(WarmBoard(isDark: false, child: _overspendRow()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overspendHeadline')), findsOneWidget);
    expect(find.textContaining('虽然今天多花了'), findsOneWidget);
    expect(find.textContaining('今天攒 0'), findsNothing);
    expect(find.byKey(const Key('joyLine')), findsOneWidget);
    expect(find.textContaining('霸王茶姬'), findsOneWidget);
    expect(find.byKey(const Key('overspendComfort')), findsOneWidget);
    expect(find.byKey(const Key('weekRoleLine')), findsOneWidget);
    expect(find.byKey(const Key('todaySavedZero')), findsNothing);
    expect(find.byKey(const Key('todaySaved')), findsNothing);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 widget 负结余无名可点走退档链', (WidgetTester tester) async {
    await tester.pumpWidget(
      const WarmBoard(
        isDark: false,
        child: TodaySavedRow(
          savedFen: -100,
          todayCount: 1,
          joyRows: <JoyRow>[JoyRow(500000, '居住', '', 'manual')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('虽然今天多花了'), findsOneWidget);
    expect(find.textContaining('该交的'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 golden 零日 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(WarmBoard(isDark: false, child: _zeroRow()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WarmBoard),
      matchesGoldenFile('../../golden/sb022/zero_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 golden 零日 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(WarmBoard(isDark: true, child: _zeroRow()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WarmBoard),
      matchesGoldenFile('../../golden/sb022/zero_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 golden 负结余 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(WarmBoard(isDark: false, child: _overspendRow()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WarmBoard),
      matchesGoldenFile('../../golden/sb022/overspend_light.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-022 golden 负结余 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(WarmBoard(isDark: true, child: _overspendRow()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WarmBoard),
      matchesGoldenFile('../../golden/sb022/overspend_dark.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-022 动效零裸量：新/改 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/today_saved_row.dart',
      'lib/ui/daily_close_sheet.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-022 对比度闸门（零日文案组合）', () {
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

  test('SB-022 零日全量文案扩展禁词零命中', () {
    final List<String> texts = <String>[
      zeroDayHeadline(todayCount: 3),
      zeroDayEncourage(),
      weekRoleLine(
        sums: const WeekRoleSums(
          necessaryFen: 10000,
          flexibleFen: 20000,
          fixedFen: 5000,
        ),
      ),
      overspendHeadline(savedFen: -2700),
      overspendSecondLine(
        today: const <JoyRow>[JoyRow(2700, '玩', '霸王茶姬', 'manual')],
      ),
      overspendComfort(),
    ];
    for (final String t in texts) {
      for (final String wd in warmExtendedBannedWords) {
        expect(t.contains(wd), isFalse, reason: '零日文案命中禁词 $wd：$t');
      }
    }
  });
}
