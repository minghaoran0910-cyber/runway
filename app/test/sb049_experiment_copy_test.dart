import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/experiment.dart';
import 'package:runway/ui/experiment_card.dart';
import 'package:runway/ui/theme/app_theme.dart';

// SB-049 · 月度小实验语义收口回归（选择页：解释句/建议值提示/推荐置顶+折叠/打卡预览条）.

Widget _board(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );
}

ExperimentSelectCard _card({String selectedId = 'no-milk-tea'}) {
  return ExperimentSelectCard(
    templates: experimentLibrary(),
    selectedId: selectedId,
    onSelect: (_) {},
    onStart: () {},
  );
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(Container());
  await tester.pump();
}

void main() {
  testWidgets('SB-049 页首一句话解释在位（7天/3秒/断卡不罚/按实算）', (WidgetTester tester) async {
    await tester.pumpWidget(_board(_card()));
    await tester.pumpAndSettle();
    final Finder intro = find.byKey(const Key('experimentIntro'));
    expect(intro, findsOneWidget);
    final String text = tester.widget<Text>(intro).data ?? '';
    for (final String k in <String>['7 天', '3 秒', '断卡不罚', '实际打卡天数']) {
      expect(text, contains(k), reason: '解释句缺关键词：$k');
    }
    await _unmount(tester);
  });

  testWidgets('SB-049 日省额建议值微提示在位', (WidgetTester tester) async {
    await tester.pumpWidget(_board(_card()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('experimentDailyHint')), findsOneWidget);
    expect(find.textContaining('建议值'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('SB-049 默认推荐3项+折叠按钮，点开展示全部8个', (WidgetTester tester) async {
    await tester.pumpWidget(_board(_card()));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(find.byKey(const Key('experimentShowAll')), findsOneWidget);
    expect(find.textContaining('看全部 8 个'), findsOneWidget);
    await tester.tap(find.byKey(const Key('experimentShowAll')));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(8));
    expect(find.text('收起推荐'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('SB-049 选中折叠区模板时自动展开', (WidgetTester tester) async {
    await tester.pumpWidget(_board(_card(selectedId: 'walk-commute')));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(8));
    expect(find.textContaining('走路通勤'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('SB-049 7天打卡预览条：7段·首段高亮', (WidgetTester tester) async {
    await tester.pumpWidget(_board(_card()));
    await tester.pumpAndSettle();
    final Finder bar = find.byKey(const Key('experimentPreview'));
    expect(bar, findsOneWidget);
    expect(find.byKey(const Key('experimentPreviewLabel')), findsOneWidget);
    final List<Expanded> segs = tester
        .widgetList<Expanded>(
          find.descendant(of: bar, matching: find.byType(Expanded)),
        )
        .toList();
    expect(segs.length, experimentDays);
    await _unmount(tester);
  });

  testWidgets('SB-049 开始按钮仍在预览条下方', (WidgetTester tester) async {
    await tester.pumpWidget(_board(_card()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('experimentStart')), findsOneWidget);
    expect(find.text('开始 7 天实验'), findsOneWidget);
    await _unmount(tester);
  });

  test('SB-049 新增文案零禁词零说教', () {
    const List<String> texts = <String>[
      '选一个 7 天小实验，每天 3 秒打个卡，断卡不罚——省多少到时候按你实际打卡天数算给你看',
      '日省额是建议值，可改',
      '7 天打卡预览',
    ];
    const List<String> preachy = <String>[
      '说教',
      '惩罚',
      '冲动',
      '剁手',
      '警告',
      '克制',
      '自律',
      '后悔',
      '罪恶',
      '浪费',
      '失败',
      '放弃',
    ];
    for (final String t in texts) {
      for (final String w in achievementBannedWords) {
        expect(t.contains(w), isFalse, reason: '命中禁词 $w：$t');
      }
      for (final String w in preachy) {
        expect(t.contains(w), isFalse, reason: '命中说教词 $w：$t');
      }
    }
  });
}
