import 'package:flutter/material.dart';

import 'tokens.dart';

// SB-003 · ThemeData 装配（DESIGN_SYSTEM §2+§3）：light+dark 双主题.
// 地面渐变与 Hero 卡以 decoration helper 提供（ThemeData 不承载渐变）.

abstract final class AppTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.light(
      primary: RunwayLight.accentStrong,
      onPrimary: RunwayLight.surface,
      secondary: RunwayLight.accent,
      surface: RunwayLight.surface,
      onSurface: RunwayLight.ink,
      error: RunwayLight.danger,
      onError: RunwayLight.surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: RunwayLight.surface1,
      cardTheme: const CardThemeData(
        color: RunwayLight.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(RunwayRadius.card)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RunwayLight.surface,
        foregroundColor: RunwayLight.ink,
        elevation: 0,
      ),
      dividerColor: RunwayLight.hairline,
      textTheme: _textTheme(RunwayLight.ink, RunwayLight.inkSecondaryText),
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.dark(
      primary: RunwayDark.accentStrong,
      onPrimary: RunwayDark.surface,
      secondary: RunwayDark.accent,
      surface: RunwayDark.surface,
      onSurface: RunwayDark.ink,
      error: RunwayDark.danger,
      onError: RunwayDark.surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: RunwayDark.surface1,
      cardTheme: const CardThemeData(
        color: RunwayDark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(RunwayRadius.card)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RunwayDark.surface,
        foregroundColor: RunwayDark.ink,
        elevation: 0,
      ),
      dividerColor: RunwayDark.hairline,
      textTheme: _textTheme(RunwayDark.ink, RunwayDark.inkSecondaryText),
    );
  }

  /// 数字一等公民（§1.4）：全局 tabular-nums；主数字与其下副文案差 ≥12pt.
  static TextTheme _textTheme(Color ink, Color secondary) {
    TextStyle body(double size, FontWeight w, Color c) => TextStyle(
      fontSize: size,
      fontWeight: w,
      height: 1.5,
      letterSpacing: RunwayType.letterSpacingBody,
      color: c,
    );
    TextStyle number(double size, FontWeight w, Color c) => TextStyle(
      fontSize: size,
      fontWeight: w,
      height: 1.4,
      letterSpacing: size >= 26 ? RunwayType.letterSpacingDisplay : 0,
      color: c,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    return TextTheme(
      bodyMedium: body(13, FontWeight.w400, ink),
      bodySmall: body(12, FontWeight.w400, secondary),
      titleMedium: body(15, FontWeight.w500, ink),
      titleLarge: body(17, FontWeight.w600, ink),
      headlineSmall: number(20, FontWeight.w600, ink),
      headlineMedium: number(28, FontWeight.w700, ink),
      headlineLarge: number(34, FontWeight.w800, ink),
    );
  }

  /// 页面地面渐变 decoration（§2.1 ground，禁纯白）.
  static BoxDecoration ground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const <Color>[RunwayDark.groundStart, RunwayDark.groundEnd]
            : const <Color>[RunwayLight.groundStart, RunwayLight.groundEnd],
      ),
    );
  }

  /// Hero 主卡渐变 decoration（§3：142° 三段 + 内高光由边框实现）.
  static BoxDecoration heroCard() {
    return const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(RunwayHero.radius)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: <double>[0, RunwayHero.stop1Position, 1],
        colors: <Color>[RunwayHero.stop0, RunwayHero.stop1, RunwayHero.stop2],
      ),
    );
  }
}
