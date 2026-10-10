import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/ui/quick_add_page.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-004 Golden：记一笔页 Light/Dark 各一，基线 golden/sb004/.
// 生成：cd app && flutter test --update-goldens test/golden_quick_add_test.dart

class QuickAddBoard extends StatelessWidget {
  const QuickAddBoard({super.key, required this.isDark, required this.db});

  final bool isDark;
  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: QuickAddPage(db: db),
    );
  }
}

void main() {
  testWidgets('SB-004 golden quick-add light', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(QuickAddBoard(isDark: false, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(QuickAddBoard),
      matchesGoldenFile('../../golden/sb004/quick_add_light.png'),
    );
  });

  testWidgets('SB-004 golden quick-add dark', (WidgetTester tester) async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await tester.pumpWidget(QuickAddBoard(isDark: true, db: db));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(QuickAddBoard),
      matchesGoldenFile('../../golden/sb004/quick_add_dark.png'),
    );
  });

  test('SB-004 对比度闸门（记账页文字组合）', () {
    // 记一笔页文字全部走主题 textTheme（ink/次要 ≥4.5:1），此处断言源 token.
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
