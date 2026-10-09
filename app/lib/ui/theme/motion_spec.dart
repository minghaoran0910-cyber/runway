import 'package:flutter/material.dart';

// SB-003 · DESIGN_SYSTEM §6 动效体系（MotionSpec 统一封装，禁散落参数）.
// UI 侧不得出现裸时长/曲线字面量，一律引用此处常量.

/// 六类动效 + 全局默认（§6 表格逐条映射）.
abstract final class MotionSpec {
  // 1. 按压反馈：120–160ms，scale .96，pointer-down 即响应.
  static const Duration pressMin = Duration(milliseconds: 120);
  static const Duration pressMax = Duration(milliseconds: 160);
  static const Duration press = Duration(milliseconds: 140);
  static const double pressScale = 0.96;

  // 2. 状态变化/数字滚动：220–320ms（滚动≤600），emphasized-decelerate.
  static const Duration stateMin = Duration(milliseconds: 220);
  static const Duration stateMax = Duration(milliseconds: 320);
  static const Duration state = Duration(milliseconds: 260);
  static const Duration scrollMax = Duration(milliseconds: 600);
  static const Cubic emphasizedDecelerate = Cubic(0.2, 0, 0.1, 1);

  // 3. 页面转场：320–400ms，shared-axis Z + 轻视差，四端同一语言.
  static const Duration transitionMin = Duration(milliseconds: 320);
  static const Duration transitionMax = Duration(milliseconds: 400);
  static const Duration transition = Duration(milliseconds: 360);

  // 4. Sheet/弹层：进 280 / 出 220ms，spring damping .8 / response .3，跟手拖拽.
  static const Duration sheetIn = Duration(milliseconds: 280);
  static const Duration sheetOut = Duration(milliseconds: 220);
  static const double sheetDamping = 0.8;
  static const double sheetResponse = 0.3;

  // 5. 列表入场：stagger 80ms/行，上浮 14–16px，仅首屏.
  static const Duration stagger = Duration(milliseconds: 80);
  static const double listRiseMin = 14;
  static const double listRiseMax = 16;
  static const double listRise = 15;

  // 6. FAB/成就卡：easeOutBack c1=1.70158，唯一允许过冲；
  //    成就 900–1200ms + 粒子 ≤12 颗.
  static const double easeOutBackC1 = 1.70158;
  static const Curve fabCurve = Curves.easeOutBack;
  static const Duration achievementMin = Duration(milliseconds: 900);
  static const Duration achievementMax = Duration(milliseconds: 1200);
  static const Duration achievement = Duration(milliseconds: 1000);
  static const int particlesMax = 12;

  // 全局：spring 默认临界阻尼 1.0（不过冲）；可从当前呈现值打断重定向.
  static const double springDampingDefault = 1.0;

  // reduce-motion 开启：全部转场降级 80ms fade.
  static const Duration reducedMotion = Duration(milliseconds: 80);

  // 骨架 shimmer ≤300ms 后出现；动效不得阻塞输入（实现侧以此断言）.
  static const Duration shimmerDelayMax = Duration(milliseconds: 300);
}
