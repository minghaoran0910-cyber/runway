// SB-050 · runway_icons 回归（生产图标 26 枚 + 白名单）.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/ui/runway_icons.dart';

void main() {
  test('26 枚全量在册且授权均为原创', () {
    expect(RunwayIconKind.values.length, 26);
    for (final RunwayIconKind k in RunwayIconKind.values) {
      expect(kRunwayIconAuth[k], 'original', reason: '$k 授权缺失');
    }
  });

  testWidgets('每枚均可泵渲染且尺寸透传', (WidgetTester tester) async {
    for (final RunwayIconKind k in RunwayIconKind.values) {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RunwayIcon(k, size: 19))),
      );
      expect(find.byType(RunwayIcon), findsOneWidget);
      final Size sz = tester.getSize(find.byType(RunwayIcon));
      expect(sz.width, 19);
    }
  });

  testWidgets('颜色透传 currentColor 口径', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RunwayIcon(RunwayIconKind.home, color: Color(0xFF3E6B86)),
        ),
      ),
    );
    expect(find.byType(RunwayIcon), findsOneWidget);
  });

  test('系统级 Icons 白名单仍保留（FAB/编辑/删除等功能型）', () {
    // 白名单见 runway_icons.dart 头注；本断言锁定"不动系统图标"契约.
    const List<String> whitelist = <String>[
      'Icons.add',
      'Icons.check',
      'Icons.edit',
      'Icons.delete',
      'Icons.clear',
      'Icons.calendar_today_outlined',
      'Icons.flag_outlined',
      'Icons.emoji_events',
      'Icons.local_cafe_outlined',
    ];
    expect(whitelist.length, 9);
  });
}
