import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/ui/theme/motion_spec.dart';
import 'package:runway/ui/theme/tokens.dart';

void main() {
  group('SB-003 tokens 与文档逐字一致（DESIGN_SYSTEM §2）', () {
    test('Light 色板 12 组命名与值齐全', () {
      expect(RunwayLight.groundStart, const Color(0xFFF3F6F7));
      expect(RunwayLight.groundEnd, const Color(0xFFE8EEF1));
      expect(RunwayLight.surface, const Color(0xFFFFFFFF));
      expect(RunwayLight.surface1, const Color(0xFFF7F8F8));
      expect(RunwayLight.surface2, const Color(0xFFEDEFEF));
      expect(RunwayLight.ink, const Color(0xFF383D3D));
      expect(RunwayLight.inkSecondaryText, const Color(0xFF647576));
      expect(RunwayLight.inkSecondary, const Color(0xFF95A5A6));
      expect(RunwayLight.accent, const Color(0xFF5D8AA8));
      expect(RunwayLight.accentStrong, const Color(0xFF3E6B86));
      expect(RunwayLight.gold, const Color(0xFFC08A3E));
      expect(RunwayLight.danger, const Color(0xFFB4552F));
      expect(RunwayLight.groundAngleDeg, 168);
    });

    test('Dark 色板 12 组命名与值齐全', () {
      expect(RunwayDark.groundStart, const Color(0xFF141616));
      expect(RunwayDark.groundEnd, const Color(0xFF101213));
      expect(RunwayDark.surface, const Color(0xFF141616));
      expect(RunwayDark.surface1, const Color(0xFF1C1F1F));
      expect(RunwayDark.surface2, const Color(0xFF262A2A));
      expect(RunwayDark.ink, const Color(0xFFECEEEF));
      expect(RunwayDark.inkSecondaryText, const Color(0xFFA6B2B4));
      expect(RunwayDark.inkSecondary, const Color(0xFF8B9698));
      expect(RunwayDark.accent, const Color(0xFF7FA6C4));
      expect(RunwayDark.accentStrong, const Color(0xFF8FB4D0));
      expect(RunwayDark.gold, const Color(0xFFD8B27E));
      expect(RunwayDark.goldHi, const Color(0xFFEAD9B4));
      expect(RunwayDark.danger, const Color(0xFFD2704A));
    });

    test('字号阶梯/字重/间距/圆角收敛到规范', () {
      expect(RunwayType.scale, const <double>[
        9.5,
        11,
        12,
        13,
        15,
        17,
        20,
        26,
        28,
        34,
      ]);
      expect(RunwayType.weights, const <int>[400, 500, 600, 700, 800]);
      expect(RunwaySpacing.page, 16);
      expect(RunwaySpacing.cardInner, 16);
      expect(RunwaySpacing.section, 24);
      expect(RunwayRadius.hero, 22);
      expect(RunwayRadius.card, 16);
      expect(RunwayRadius.control, 10);
      expect(RunwayRadius.capsule, 13);
    });

    test('Hero 主卡三段渐变与文字层级', () {
      expect(RunwayHero.stop0, const Color(0xFF25404F));
      expect(RunwayHero.stop1, const Color(0xFF3E6B86));
      expect(RunwayHero.stop1Position, 0.58);
      expect(RunwayHero.stop2, const Color(0xFF557F99));
      expect(RunwayHero.goldAccent, const Color(0xFFEAD9B4));
    });
  });

  group('SB-003 对比度闸门（§2.3/§8 代码内计算）', () {
    test('Light 小字组合 ≥4.5:1', () {
      expect(
        RunwayContrast.ratio(RunwayLight.ink, RunwayLight.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
      expect(
        RunwayContrast.ratio(RunwayLight.inkSecondaryText, RunwayLight.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
      expect(
        RunwayContrast.ratio(RunwayLight.accentStrong, RunwayLight.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
      expect(
        RunwayContrast.ratio(RunwayLight.danger, RunwayLight.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
    });

    test('Light 大字/图形组合 ≥3:1', () {
      expect(
        RunwayContrast.ratio(RunwayLight.accent, RunwayLight.surface),
        greaterThanOrEqualTo(RunwayContrast.largeMin),
      );
      expect(
        RunwayContrast.ratio(RunwayLight.gold, RunwayLight.surface),
        greaterThanOrEqualTo(RunwayContrast.largeMin),
      );
    });

    test('Dark 小字组合 ≥4.5:1', () {
      expect(
        RunwayContrast.ratio(RunwayDark.ink, RunwayDark.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
      expect(
        RunwayContrast.ratio(RunwayDark.inkSecondaryText, RunwayDark.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
      expect(
        RunwayContrast.ratio(RunwayDark.accentStrong, RunwayDark.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
      expect(
        RunwayContrast.ratio(RunwayDark.danger, RunwayDark.surface),
        greaterThanOrEqualTo(RunwayContrast.textMin),
      );
    });

    test('Dark 大字/图形组合 ≥3:1', () {
      expect(
        RunwayContrast.ratio(RunwayDark.accent, RunwayDark.surface),
        greaterThanOrEqualTo(RunwayContrast.largeMin),
      );
      expect(
        RunwayContrast.ratio(RunwayDark.gold, RunwayDark.surface),
        greaterThanOrEqualTo(RunwayContrast.largeMin),
      );
    });
  });

  group('SB-003 MotionSpec 六类封装（§6）', () {
    test('时长区间与常量齐全', () {
      expect(MotionSpec.press.inMilliseconds, inInclusiveRange(120, 160));
      expect(MotionSpec.state.inMilliseconds, inInclusiveRange(220, 320));
      expect(MotionSpec.transition.inMilliseconds, inInclusiveRange(320, 400));
      expect(MotionSpec.sheetIn, const Duration(milliseconds: 280));
      expect(MotionSpec.sheetOut, const Duration(milliseconds: 220));
      expect(MotionSpec.stagger, const Duration(milliseconds: 80));
      expect(
        MotionSpec.achievement.inMilliseconds,
        inInclusiveRange(900, 1200),
      );
      expect(MotionSpec.particlesMax, lessThanOrEqualTo(12));
      expect(MotionSpec.pressScale, 0.96);
      expect(MotionSpec.easeOutBackC1, 1.70158);
    });
  });
}
