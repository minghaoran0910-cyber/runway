// SB-006 · 首页看板聚合统计（PRD §2 三十秒日报 / §6 其他占比；纯 Dart）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）；日期边界全部以传入 now 为准，便于测试.
import 'category_feedback.dart';
import 'category_rules.dart';

/// 看板输入流（UI 层由 Transaction 转换而来；logic 不 import drift）.
class DashboardFlow {
  const DashboardFlow({
    required this.amountFen,
    required this.category,
    required this.occurredAt,
  });

  final int amountFen;
  final String category;
  final DateTime occurredAt;
}

/// Top5 单项（金额分 + 占总支出份额）.
class TopEntry {
  const TopEntry({
    required this.category,
    required this.fen,
    required this.share,
  });

  final String category;
  final int fen;
  final double share;
}

/// 看板汇总（Hero/今日/Top5/目标四区供数）.
class DashboardSummary {
  const DashboardSummary({
    required this.todayCount,
    required this.todayFen,
    required this.weekFen,
    required this.monthFen,
    required this.monthCount,
    required this.totalFen,
    required this.fenByCategory,
    required this.top5,
    required this.otherShare,
    required this.otherFault,
    required this.goalFen,
    required this.goalProgress,
    required this.goalOver,
  });

  final int todayCount;
  final int todayFen;
  final int weekFen;
  final int monthFen;
  final int monthCount;
  final int totalFen;
  final Map<String, int> fenByCategory;
  final List<TopEntry> top5;
  final double otherShare;
  final bool otherFault;

  /// 月度目标（分，null=未设 → UI 显示引导位，不做进度）.
  final int? goalFen;

  /// 0..1（目标未设或目标<=0 时为 0）.
  final double goalProgress;

  /// 本月已超目标.
  final bool goalOver;

  static const DashboardSummary empty = DashboardSummary(
    todayCount: 0,
    todayFen: 0,
    weekFen: 0,
    monthFen: 0,
    monthCount: 0,
    totalFen: 0,
    fenByCategory: <String, int>{},
    top5: <TopEntry>[],
    otherShare: 0,
    otherFault: false,
    goalFen: null,
    goalProgress: 0,
    goalOver: false,
  );
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 聚合：今日（自然日）/ 本周（滚动 7 天含今）/ 本月（自然月）/ Top5 / 其他占比 / 目标进度.
/// 空输入返回零汇总（otherShare=0，不误报故障；目标位仍按 goalFen 计算引导/进度）.
DashboardSummary computeDashboard({
  required List<DashboardFlow> flows,
  required DateTime now,
  int? goalFen,
}) {
  int todayCount = 0;
  int todayFen = 0;
  int weekFen = 0;
  int monthFen = 0;
  int monthCount = 0;
  int totalFen = 0;
  final Map<String, int> byCat = <String, int>{};
  final DateTime weekStart = now.subtract(const Duration(days: 7));

  for (final DashboardFlow f in flows) {
    final String c = canonicalCategory(f.category);
    totalFen += f.amountFen;
    byCat.update(c, (int v) => v + f.amountFen, ifAbsent: () => f.amountFen);
    if (_sameDay(f.occurredAt, now)) {
      todayCount += 1;
      todayFen += f.amountFen;
    }
    if (!f.occurredAt.isBefore(weekStart) &&
        !f.occurredAt.isAfter(now.add(const Duration(seconds: 1)))) {
      weekFen += f.amountFen;
    }
    if (f.occurredAt.year == now.year && f.occurredAt.month == now.month) {
      monthFen += f.amountFen;
      monthCount += 1;
    }
  }

  final List<TopEntry> top5 =
      byCat.entries
          .map(
            (MapEntry<String, int> e) => TopEntry(
              category: e.key,
              fen: e.value,
              share: totalFen <= 0 ? 0 : e.value / totalFen,
            ),
          )
          .toList()
        ..sort((TopEntry a, TopEntry b) => b.fen.compareTo(a.fen));
  final List<TopEntry> top = top5.length <= 5 ? top5 : top5.sublist(0, 5);

  // 复用 SB-005 口径：其他占比>5% 即故障（CategorySummary.otherFault 同值）.
  final CategorySummary check = summarizeFlows(
    flows.map(
      (DashboardFlow f) => (amountFen: f.amountFen, category: f.category),
    ),
  );

  double progress = 0;
  bool over = false;
  if (goalFen != null && goalFen > 0) {
    progress = (monthFen / goalFen).clamp(0.0, 1.0).toDouble();
    over = monthFen > goalFen;
  }

  return DashboardSummary(
    todayCount: todayCount,
    todayFen: todayFen,
    weekFen: weekFen,
    monthFen: monthFen,
    monthCount: monthCount,
    totalFen: totalFen,
    fenByCategory: byCat,
    top5: top,
    otherShare: check.otherShare,
    otherFault: check.otherFault,
    goalFen: goalFen,
    goalProgress: progress,
    goalOver: over,
  );
}
