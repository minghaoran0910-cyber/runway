import 'dart:math' as math;

import 'package:flutter/material.dart';

// SB-003 · DESIGN_SYSTEM §2 Tokens 落地（Light/Dark 双份，与文档逐字一致）.
// 真相链：DESIGN_SYSTEM §2 → 本文件（demos/tokens.css 缺失时以 §2 表格为准）.
// 禁止编造或近似；新增 token 须走 design: 型 commit + 浩然批准.

/// Light 色板（DESIGN_SYSTEM §2.1 表格 Light 列）.
abstract final class RunwayLight {
  // 地面：渐变 168° #F3F6F7 → #E8EEF1（禁纯白）.
  static const double groundAngleDeg = 168;
  static const Color groundStart = Color(0xFFF3F6F7);
  static const Color groundEnd = Color(0xFFE8EEF1);

  // 卡片三层材质.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface1 = Color(0xFFF7F8F8);
  static const Color surface2 = Color(0xFFEDEFEF);

  // 文字.
  static const Color ink = Color(0xFF383D3D);
  static const Color inkSecondaryText = Color(0xFF647576);
  // 仅装饰图形，禁做小字.
  static const Color inkSecondary = Color(0xFF95A5A6);

  // 强调：accent 供色块/进度/大选中（≥22pt 或图形）；accentStrong 供小字/链接.
  static const Color accent = Color(0xFF5D8AA8);
  static const Color accentStrong = Color(0xFF3E6B86);

  // 成就/达标/家庭贡献.
  static const Color gold = Color(0xFFC08A3E);
  // gold-hi 文档 Light 列记"—"（无独立值）：复用 gold，保证不断言编造值.
  static const Color goldHi = Color(0xFFC08A3E);

  static const Color danger = Color(0xFFB4552F);

  // 行分隔：rgba(56,61,61,.08).
  static const Color hairline = Color(0x14383D3D);
}

/// Dark 色板（DESIGN_SYSTEM §2.1 表格 Dark 列）.
abstract final class RunwayDark {
  static const double groundAngleDeg = 168;
  static const Color groundStart = Color(0xFF141616);
  static const Color groundEnd = Color(0xFF101213);

  static const Color surface = Color(0xFF141616);
  static const Color surface1 = Color(0xFF1C1F1F);
  static const Color surface2 = Color(0xFF262A2A);

  static const Color ink = Color(0xFFECEEEF);
  static const Color inkSecondaryText = Color(0xFFA6B2B4);
  static const Color inkSecondary = Color(0xFF8B9698);

  static const Color accent = Color(0xFF7FA6C4);
  static const Color accentStrong = Color(0xFF8FB4D0);

  static const Color gold = Color(0xFFD8B27E);
  // 深色主卡内唯一暖强调.
  static const Color goldHi = Color(0xFFEAD9B4);

  static const Color danger = Color(0xFFD2704A);

  // 行分隔：rgba(255,255,255,.09).
  static const Color hairline = Color(0x17FFFFFF);
}

/// 字号阶梯（§2.2）：9.5/11/12/13/15/17/20/26/28/34；demo 过渡值一律收敛到此.
abstract final class RunwayType {
  static const List<double> scale = <double>[
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
  ];
  static const double lineHeightMin = 1.4;
  static const double lineHeightMax = 1.6;
  // 字重只用 400/500/600/700/800.
  static const List<int> weights = <int>[400, 500, 600, 700, 800];
  // 中文正文不加字距；26pt 以上负字距 -0.4~-0.6px，取中值 -0.5.
  static const double letterSpacingBody = 0;
  static const double letterSpacingDisplay = -0.5;
}

/// 间距 4/8 网格（§2.2）：页边距 16、卡内 16、区块间 24、分区头 24上/12下.
abstract final class RunwaySpacing {
  static const double page = 16;
  static const double cardInner = 16;
  static const double section = 24;
  static const double sectionHeaderTop = 24;
  static const double sectionHeaderBottom = 12;
  // 负 margin 压卡（浮层感）18–40.
  static const double overlapMin = 18;
  static const double overlapMax = 40;
}

/// 形状三档（§1.2）：主卡 r22 / 内容卡 r16 / 控件 r10、胶囊 r13；第四种=违规.
abstract final class RunwayRadius {
  static const double hero = 22;
  static const double card = 16;
  static const double control = 10;
  static const double capsule = 13;
}

/// 阴影 3 档（§2.1）.
abstract final class RunwayShadow {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000)),
    BoxShadow(offset: Offset(0, 10), blurRadius: 28, color: Color(0x17000000)),
  ];
  static const List<BoxShadow> overlay = <BoxShadow>[
    BoxShadow(offset: Offset(0, 4), blurRadius: 16, color: Color(0x1F000000)),
  ];
  // 深色主卡彩色柔影（禁彩色硬影）：0 10 26 rgba(43,73,93,.26).
  static const List<BoxShadow> heroDark = <BoxShadow>[
    BoxShadow(offset: Offset(0, 10), blurRadius: 26, color: Color(0x422B495D)),
  ];
}

/// Hero 主卡（§3）：渐变 142° #25404F → #3E6B86 58% → #557F99.
abstract final class RunwayHero {
  static const double gradientAngleDeg = 142;
  static const Color stop0 = Color(0xFF25404F);
  static const Color stop1 = Color(0xFF3E6B86);
  static const double stop1Position = 0.58;
  static const Color stop2 = Color(0xFF557F99);
  static const double radius = 22;
  // border-top 1px rgba(255,255,255,.16) 内高光.
  static const Color topHighlight = Color(0x29FFFFFF);
  // 右上 230px 径向光晕，18% 冷白蓝.
  static const double glowSize = 230;
  static const Color glow = Color(0x2EE8F1FA);
  // 内部四层文字：12.5px/74%白 → 28px/100%白 → 12px/62%白 → 暖金一处.
  static const double titleSize = 12.5;
  static const Color title = Color(0xBDFFFFFF);
  static const double numberSize = 28;
  static const Color number = Color(0xFFFFFFFF);
  static const double subSize = 12;
  static const Color sub = Color(0x9EFFFFFF);
  static const Color goldAccent = Color(0xFFEAD9B4);
}

/// 对比度闸门（§2.3/§8，CI 强制）：文字级 ≥4.5:1；≥22pt 大字 ≥3:1.
abstract final class RunwayContrast {
  static const double textMin = 4.5;
  static const double largeMin = 3.0;

  static double _linearize(double c) {
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4) as double;
  }

  static double ratio(Color fg, Color bg) {
    double r(double v) => _linearize(v);
    final double l1 = 0.2126 * r(fg.r) + 0.7152 * r(fg.g) + 0.0722 * r(fg.b);
    final double l2 = 0.2126 * r(bg.r) + 0.7152 * r(bg.g) + 0.0722 * r(bg.b);
    final double hi = l1 > l2 ? l1 : l2;
    final double lo = l1 > l2 ? l2 : l1;
    return (hi + 0.05) / (lo + 0.05);
  }
}
