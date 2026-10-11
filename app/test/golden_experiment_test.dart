import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/experiment_dao.dart';
import 'package:runway/logic/experiment.dart';
import 'package:runway/ui/experiment_card.dart';
import 'package:runway/ui/home_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-018 widget + Golden：实验两组（选/进行中）× Light/Dark.
// 基线 golden/sb018/；生成：cd app && flutter test --update-goldens test/golden_experiment_test.dart

class ExperimentBoard extends StatelessWidget {
  const ExperimentBoard({super.key, required this.isDark, required this.child});

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

ExperimentSelectCard _selectCard() {
  return ExperimentSelectCard(
    templates: experimentLibrary(),
    selectedId: 'no-milk-tea',
    onSelect: (_) {},
    onStart: () {},
  );
}

ExperimentActiveCard _activeCard() {
  return const ExperimentActiveCard(
    name: '无奶茶周',
    checked: 5,
    elapsed: 7,
    savedFen: 9000,
    finished: false,
    onCheckIn: null,
  );
}

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

void main() {
  testWidgets('SB-018 widget 选择态：8 模板+开始钮', (WidgetTester tester) async {
    await tester.pumpWidget(
      ExperimentBoard(isDark: false, child: _selectCard()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('experimentTitle')), findsOneWidget);
    expect(find.byKey(const Key('experimentStart')), findsOneWidget);
    expect(find.textContaining('无奶茶周'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-018 widget 进行态：进度+打卡钮', (WidgetTester tester) async {
    await tester.pumpWidget(
      ExperimentBoard(isDark: false, child: _activeCard()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('experimentProgress')), findsOneWidget);
    expect(find.byKey(const Key('experimentCheckIn')), findsOneWidget);
    expect(find.textContaining('已打卡'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-018 widget 打卡回调：点后即回调', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      ExperimentBoard(
        isDark: false,
        child: ExperimentActiveCard(
          name: '无奶茶周',
          checked: 1,
          elapsed: 2,
          savedFen: 1800,
          finished: false,
          onCheckIn: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('experimentCheckIn')));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-018 widget 首页集成：实验区挂载+开关', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: HomePage(db: db),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('experimentSwitch')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('experimentSwitch')), findsOneWidget);
    expect(find.text('月度小实验'), findsOneWidget);
    await _unmountAndFlush(tester);
    await db.close();
  });

  testWidgets('SB-018 widget DAO：开关默认开+建单+打卡幂等+完结+回滚', (
    WidgetTester tester,
  ) async {
    final AppDb db = AppDb.memoryForTest();
    expect(await db.experimentEnabled(), isTrue);
    await db.setExperimentEnabled(false);
    expect(await db.experimentEnabled(), isFalse);
    await db.setExperimentEnabled(true);
    final int id = await db.startExperiment(
      templateId: 'no-milk-tea',
      name: '无奶茶周',
      dailySaveFen: 1800,
      startDate: DateTime(2026, 10, 1),
    );
    expect((await db.activeExperiment())?.id, id);
    expect(await db.checkInExperiment(id: id, dayIndex: 0), isTrue);
    expect(await db.checkInExperiment(id: id, dayIndex: 0), isFalse);
    expect(await db.checkInExperiment(id: id, dayIndex: 9), isFalse);
    expect(decodeCheckIns((await db.activeExperiment())!.checkIns), {0});
    await db.finishExperiment(id);
    expect(await db.activeExperiment(), isNull);
    await db.rollbackExperimentToV9();
    await db.close();
  });

  testWidgets('SB-018 golden 选择 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ExperimentBoard(isDark: false, child: _selectCard()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ExperimentBoard),
      matchesGoldenFile('../../golden/sb018/experiment_light_select.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-018 golden 选择 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ExperimentBoard(isDark: true, child: _selectCard()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ExperimentBoard),
      matchesGoldenFile('../../golden/sb018/experiment_dark_select.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-018 golden 进行 light', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ExperimentBoard(isDark: false, child: _activeCard()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ExperimentBoard),
      matchesGoldenFile('../../golden/sb018/experiment_light_active.png'),
    );
    await _unmountAndFlush(tester);
  });

  testWidgets('SB-018 golden 进行 dark', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ExperimentBoard(isDark: true, child: _activeCard()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ExperimentBoard),
      matchesGoldenFile('../../golden/sb018/experiment_dark_active.png'),
    );
    await _unmountAndFlush(tester);
  });

  test('SB-018 动效零裸量：新 UI 文件无裸 Duration/Curves/Cubic', () {
    for (final String p in <String>[
      'lib/ui/experiment_card.dart',
      'lib/ui/home_page.dart',
      'lib/ui/weekly_page.dart',
    ]) {
      final String src = File(p).readAsStringSync();
      expect(src.contains('Duration('), isFalse, reason: '$p 含裸 Duration');
      expect(src.contains('Curves.'), isFalse, reason: '$p 含裸 Curves');
      expect(src.contains('Cubic('), isFalse, reason: '$p 含裸 Cubic');
    }
  });

  test('SB-018 对比度闸门（实验文案组合）', () {
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
