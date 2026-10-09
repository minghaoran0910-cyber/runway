import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/ui/theme/app_theme.dart';
import 'package:runway/ui/theme/tokens.dart';

// SB-003 Golden：色板 + 字例示意卡（Light/Dark 各一），基线入库 golden/sb003/.
// 生成：cd app && flutter test --update-goldens test/golden_tokens_test.dart

class TokenBoard extends StatelessWidget {
  const TokenBoard({super.key, required this.isDark});

  final bool isDark;

  List<_Swatch> _swatches() {
    if (isDark) {
      return const <_Swatch>[
        _Swatch('surface', RunwayDark.surface),
        _Swatch('surface-1', RunwayDark.surface1),
        _Swatch('surface-2', RunwayDark.surface2),
        _Swatch('ink', RunwayDark.ink),
        _Swatch('ink-sec-text', RunwayDark.inkSecondaryText),
        _Swatch('accent', RunwayDark.accent),
        _Swatch('accent-strong', RunwayDark.accentStrong),
        _Swatch('gold', RunwayDark.gold),
        _Swatch('gold-hi', RunwayDark.goldHi),
        _Swatch('danger', RunwayDark.danger),
      ];
    }
    return const <_Swatch>[
      _Swatch('surface', RunwayLight.surface),
      _Swatch('surface-1', RunwayLight.surface1),
      _Swatch('surface-2', RunwayLight.surface2),
      _Swatch('ink', RunwayLight.ink),
      _Swatch('ink-sec-text', RunwayLight.inkSecondaryText),
      _Swatch('accent', RunwayLight.accent),
      _Swatch('accent-strong', RunwayLight.accentStrong),
      _Swatch('gold', RunwayLight.gold),
      _Swatch('gold-hi', RunwayLight.goldHi),
      _Swatch('danger', RunwayLight.danger),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = isDark ? AppTheme.dark() : AppTheme.light();
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Container(
          decoration: AppTheme.ground(isDark),
          padding: const EdgeInsets.all(RunwaySpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: AppTheme.heroCard(),
                padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                child: const Text(
                  '28 主数字示例数据',
                  style: TextStyle(
                    fontSize: RunwayHero.numberSize,
                    color: RunwayHero.number,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: RunwaySpacing.section),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final _Swatch s in _swatches())
                    Container(
                      width: 100,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(
                          RunwayRadius.control,
                        ),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Text(
                        s.name,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: RunwaySpacing.section),
              Text('17 标题示例数据', style: theme.textTheme.titleLarge),
              Text('13 正文示例数据', style: theme.textTheme.bodyMedium),
              Text('12 次要示例数据', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch {
  const _Swatch(this.name, this.color);
  final String name;
  final Color color;
}

void main() {
  testWidgets('SB-003 golden light board', (WidgetTester tester) async {
    await tester.pumpWidget(const TokenBoard(isDark: false));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TokenBoard),
      matchesGoldenFile('../../golden/sb003/tokens_light.png'),
    );
  });

  testWidgets('SB-003 golden dark board', (WidgetTester tester) async {
    await tester.pumpWidget(const TokenBoard(isDark: true));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TokenBoard),
      matchesGoldenFile('../../golden/sb003/tokens_dark.png'),
    );
  });
}
