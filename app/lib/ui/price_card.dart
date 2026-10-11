import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import '../logic/price_watch.dart';
import 'theme/tokens.dart';

// SB-020 · 常买价格眼卡（PRD §2 看见层；DESIGN §1 地面+浮起 / §5 sparkline≤56px）.
// ≥3 条同键才现身；<3 条不显示不猜（PriceZone 直接零高度，旧 golden 零像素改动）.
// 形状只用 r16（内容卡）/ r10（走势裁剪）；分隔仅 hairline；数字 tabular；颜色只用 tokens.
// 文案只陈述（较均价 ±X），无说教、无禁词；换算引擎零改动（复用 SB-007 价格表在 goal 侧）.
// 本文件零裸时长/曲线（纯展示，无动画）.

/// 最近 ≤10 价迷你走势（自绘 CustomPainter，不新增图表库）.
class PriceSparkline extends StatelessWidget {
  const PriceSparkline({super.key, required this.values, required this.isDark});

  final List<int> values;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RunwayRadius.control),
      child: CustomPaint(
        size: const Size(double.infinity, 48),
        painter: _SparkPainter(values: values, isDark: isDark),
        key: const Key('priceSpark'),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.values, required this.isDark});

  final List<int> values;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    int min = values.first;
    int max = values.first;
    for (final int v in values) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final int span = (max - min) == 0 ? 1 : (max - min);
    const double pad = 8;
    final double w = size.width;
    final double h = size.height;
    final List<Offset> pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final double x = values.length == 1
          ? w / 2
          : pad + (w - pad * 2) * i / (values.length - 1);
      final double y = h - pad - (h - pad * 2) * (values[i] - min) / span;
      pts.add(Offset(x, y));
    }
    final Color line = isDark ? RunwayDark.accent : RunwayLight.accentStrong;
    final Paint fill = Paint()
      ..color = line.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final Path area = Path()..moveTo(pts.first.dx, h);
    for (final Offset p in pts) {
      area.lineTo(p.dx, p.dy);
    }
    area.lineTo(pts.last.dx, h);
    area.close();
    canvas.drawPath(area, fill);
    final Paint stroke = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, stroke);
    final Paint halo = Paint()..color = line;
    canvas.drawCircle(pts.last, 4, halo);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.values != values || old.isDark != isDark;
}

/// 常买价格卡（有历史态；无历史不建本卡，由 PriceZone 守门）.
class PriceCard extends StatelessWidget {
  const PriceCard({super.key, required this.stats});

  final PriceStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final String vs = describeVsAvg(
      currentFen: stats.latestFen,
      avgFen: stats.avgFen,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              stats.key,
              style: theme.textTheme.titleMedium,
              key: const Key('priceTitle'),
            ),
            const SizedBox(height: 8),
            PriceSparkline(values: stats.recentFen, isDark: isDark),
            const SizedBox(height: 8),
            Text(
              '均价 ${formatFen(stats.avgFen)} · 最低 ${formatFen(stats.minFen)}'
              ' · 最近 ${formatFen(stats.latestFen)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              key: const Key('priceAvg'),
            ),
            const SizedBox(height: 4),
            Text(
              '共 ${stats.count} 笔 · 这次$vs',
              style: theme.textTheme.bodySmall,
              key: const Key('priceVs'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 常买价格同区（类目页底部；无 ≥3 条同键即零高度，旧 golden 零改动）.
class PriceZone extends StatelessWidget {
  const PriceZone({super.key, required this.db});

  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: db.watchAll(),
      builder: (BuildContext ctx, AsyncSnapshot<List<Transaction>> snap) {
        final List<Transaction> rows = snap.data ?? <Transaction>[];
        final Map<String, PriceStats> all = summarizeAll(
          rows
              .map(
                (Transaction r) => (
                  category: r.category,
                  note: r.note,
                  amountFen: r.amountFen,
                ),
              )
              .toList(),
        );
        if (all.isEmpty) return const SizedBox.shrink();
        final List<PriceStats> top = all.values.toList()
          ..sort((a, b) => b.count.compareTo(a.count));
        final List<PriceStats> show = top.take(2).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 24),
            Text(
              '常买价格眼',
              style: Theme.of(context).textTheme.titleMedium,
              key: const Key('priceZoneTitle'),
            ),
            const SizedBox(height: 8),
            for (final PriceStats s in show) ...<Widget>[
              PriceCard(stats: s),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
