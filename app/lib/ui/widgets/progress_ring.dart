import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/motion_spec.dart';
import '../theme/tokens.dart';

// SB-029 · 环形进度图（DESIGN §5：96px 外框 / r40 / 线宽 9 / 圆头 /
// 渐变描边亮灰蓝→深；环扫过与数字共用同一进度函数，动画走 MotionSpec.state +
// emphasizedDecelerate，禁散落时长）. Hero 深青卡与目标页复用同一组件
// （SB-030 依赖）；圆心数字由调用方以 child 传入（tabular 由调用方保证）.
// 自检：外沿 40+9/2=44.5 < 48 半框，零贴边裁切（§8 走查项）.

/// 环形进度（fraction 0..1，溢出由调用方钳，数字照实显示）.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.fraction,
    required this.center,
    this.size = 96,
  });

  /// 0..1（>1 调用方自钳；<0 归 0）.
  final double fraction;

  /// 圆心内容（大数字+单位列）.
  final Widget center;

  /// 外框边长（§5 默认 96）.
  final double size;

  @override
  Widget build(BuildContext context) {
    final double f = fraction.clamp(0.0, 1.0).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: f),
        duration: MotionSpec.state,
        curve: MotionSpec.emphasizedDecelerate,
        builder: (BuildContext ctx, double v, Widget? child) {
          return CustomPaint(
            painter: _RingPainter(fraction: v),
            child: Center(child: child),
          );
        },
        child: center,
      ),
    );
  }
}

// SB-033 · 环扫数字滚动（DESIGN §5+§6：环扫与数字共用同一进度函数
// MotionSpec.state + emphasizedDecelerate；reduce-motion 直接显示终值）.
// 与 ProgressRing 同帧起播，中间帧≠终值即同步证据（监工实拍验收）.
class CountUpMonths extends StatelessWidget {
  const CountUpMonths({super.key, required this.months, required this.style});

  final double months;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      return Text(_fmt(months), style: style, key: const Key('homeTotal'));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: months),
      duration: MotionSpec.state,
      curve: MotionSpec.emphasizedDecelerate,
      builder: (BuildContext ctx, double v, Widget? child) {
        return Text(_fmt(v), style: style, key: const Key('homeTotal'));
      },
    );
  }

  static String _fmt(double m) => m.toStringAsFixed(1);
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    // §5：r40、线宽 9、圆头.
    const double radius = 40;
    const double stroke = 9;
    // 轨道：hero 内高光冷白蓝（token glow，18% ≥8% 装饰下限 §1.6）.
    final Paint track = Paint()
      ..color = RunwayHero.glow
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, radius, track);
    if (fraction <= 0) return;
    // 进度弧：渐变描边（亮白→亮灰蓝，深青卡上可读；均为现行 token）.
    final Rect rect = Rect.fromCircle(center: c, radius: radius);
    final Paint arc = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 3 / 2,
        colors: <Color>[RunwayHero.number, RunwayDark.accent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, fraction * math.pi * 2, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
