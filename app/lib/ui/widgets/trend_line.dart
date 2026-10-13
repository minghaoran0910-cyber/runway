import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

// SB-030 · 周报折线趋势图（DESIGN §5：Catmull-Rom→三次贝塞尔平滑，禁硬折；
// 面积填充 accent 22%→0 渐变；末端点 halo；端点 marker 距 svg 边界 ≥8px——
// 本组件四周 pad=12，path 起点 x=12≥2、终点 x=宽-12≤宽-r-4（r=4），零贴边裁切；
// sparkline 高 ≤56px，默认高 56；静态展示零裸时长/曲线）.

/// 折线趋势（values 为 7 天每日支出分；空/全零画中线）.
class TrendLine extends StatelessWidget {
  const TrendLine({super.key, required this.values, this.height = 56});

  final List<int> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color line = isDark ? RunwayDark.accent : RunwayLight.accentStrong;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(values: values, line: line),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.values, required this.line});

  final List<int> values;
  final Color line;

  static const double _pad = 12;
  static const double _r = 4;

  List<double> _norm() {
    if (values.isEmpty) return <double>[];
    int min = values.first;
    int max = values.first;
    for (final int v in values) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    if (max == min) return List<double>.filled(values.length, 0.5);
    final int span = max - min;
    return values.map((int v) => (v - min) / span).toList();
  }

  List<Offset> _points(Size size) {
    final int n = values.length;
    if (n == 0) return <Offset>[];
    final List<double> norm = _norm();
    final double w = size.width - _pad * 2;
    final double h = size.height - _pad * 2;
    if (n == 1) {
      return <Offset>[Offset(_pad + w / 2, _pad + (1 - norm[0]) * h)];
    }
    return List<Offset>.generate(
      n,
      (int i) => Offset(_pad + i * w / (n - 1), _pad + (1 - norm[i]) * h),
    );
  }

  /// Catmull-Rom 转三次贝塞尔（禁硬折 §5）.
  Path _smooth(List<Offset> pts) {
    final Path path = Path();
    if (pts.isEmpty) return path;
    if (pts.length == 1) {
      path.moveTo(pts.first.dx, pts.first.dy);
      path.lineTo(pts.first.dx + 1, pts.first.dy);
      return path;
    }
    if (pts.length == 2) {
      path.moveTo(pts[0].dx, pts[0].dy);
      path.lineTo(pts[1].dx, pts[1].dy);
      return path;
    }
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final Offset p0 = i == 0 ? pts[0] : pts[i - 1];
      final Offset p1 = pts[i];
      final Offset p2 = pts[i + 1];
      final Offset p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      final Offset c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final Offset c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> pts = _points(size);
    if (pts.isEmpty) return;
    final Path linePath = _smooth(pts);
    // 面积填充：accent 22%→0 纵向渐变（§5）.
    final Path fill = Path.from(linePath)
      ..lineTo(pts.last.dx, size.height - _pad)
      ..lineTo(pts.first.dx, size.height - _pad)
      ..close();
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          line.withValues(alpha: 0.22),
          line.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fill, fillPaint);
    final Paint linePaint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);
    // 端点圆点 r=4（pad=12 保证距边 ≥8 §5）.
    final Paint dot = Paint()
      ..color = line
      ..style = PaintingStyle.fill;
    for (final Offset p in pts) {
      canvas.drawCircle(p, _r, dot);
    }
    // 末端 halo（§5 末端点 halo）.
    final Paint halo = Paint()
      ..color = line.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pts.last, _r + 4, halo);
    canvas.drawCircle(pts.last, _r, dot);
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.line != line || !listEquals(old.values, values);
}
