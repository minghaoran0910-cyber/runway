// SB-006 · 首页看板聚合统计（PRD §2 三十秒日报 / §6 其他占比；纯 Dart）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）；日期边界全部以传入 now 为准，便于测试.
import 'category_feedback.dart';
import 'category_rules.dart';
import 'goal_ladder.dart';
import 'role_resolver.dart';

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
    this.lastMonthFen = 0,
    this.monthRigidFen = 0,
    this.rigidPerMonthFen = 0,
    this.convertibleFen = 0,
    this.runwayMonths = 0,
    this.runwayDeltaMonths = 0,
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

  // SB-029 · 跑道口径（hero 环形图供数；全部由 computeDashboard 填充，默认 0）.
  // 口径（复用既有公式，禁第二套）：
  //   可动用 convertible = computeGoal(monthSpend=m0, lastMonth=m1).convertible
  //     （= 2×max(0, 上月−本月），SB-007 原公式）；
  //   刚性 rigidPerMonth = 上月刚性（必要+固定）>0 ? 上月刚性 : 本月刚性；
  //   跑道 runwayMonths = rigid>0 ? convertible/rigid : 0；
  //   增量 delta = runway − prevRunway（prev 按 m1/m2 同口径，缺数据即 0）.
  // 角色映射用默认表（用户覆盖未接入 hero，见 SB-029 偏差声明）.
  /// 上月总支出（分）.
  final int lastMonthFen;

  /// 本月刚性支出（必要+固定，分）.
  final int monthRigidFen;

  /// 跑道分母：月均刚性（分）.
  final int rigidPerMonthFen;

  /// 可动用（分，goal_ladder 口径）.
  final int convertibleFen;

  /// 跑道（月，保留全精度，显示走 formatRunway）.
  final double runwayMonths;

  /// 跑道环比增量（月，可负）.
  final double runwayDeltaMonths;

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
    lastMonthFen: 0,
    monthRigidFen: 0,
    rigidPerMonthFen: 0,
    convertibleFen: 0,
    runwayMonths: 0,
    runwayDeltaMonths: 0,
  );
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 自然月偏移（back=0 本月，1 上月，2 上上月；跨年进位）.
({int year, int month}) _calendarMonth(DateTime now, int back) {
  int m = now.month - back;
  int y = now.year;
  while (m <= 0) {
    m += 12;
    y -= 1;
  }
  return (year: y, month: m);
}

/// 是否落在指定自然月.
bool _inMonth(DateTime t, ({int year, int month}) m) {
  return t.year == m.year && t.month == m.month;
}

/// 刚性判定（必要+固定；默认映射，覆盖未接入见字段注释）.
bool _isRigid(String category) {
  final CategoryRole r = resolveRole(category);
  return r == CategoryRole.necessary || r == CategoryRole.fixed;
}

/// 环形进度换算（SB-029 · DESIGN §5 环径 96 供数）：12 个月跑道=满环；
/// 溢出钳 1（弧满，数字照实显示），空/负归 0.
double runwayFraction(double months) {
  if (months <= 0) return 0;
  if (months >= 12) return 1;
  return months / 12;
}

/// 跑道显示（1 位小数，tabular 对齐由 UI 保证）.
String formatRunway(double months) {
  return months.toStringAsFixed(1);
}

/// 增量显示（带符号，1 位小数；+0.4 / -0.3 式）.
String formatRunwayDelta(double delta) {
  final String v = delta.abs().toStringAsFixed(1);
  if (delta > 0) return '+$v';
  if (delta < 0) return '-$v';
  return '+0.0';
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
  // SB-029 · 自然月三桶（m0 本月 / m1 上月 / m2 上上月）+ 月刚性.
  final ({int year, int month}) m0 = _calendarMonth(now, 0);
  final ({int year, int month}) m1 = _calendarMonth(now, 1);
  final ({int year, int month}) m2 = _calendarMonth(now, 2);
  int m0Fen = 0;
  int m1Fen = 0;
  int m2Fen = 0;
  int rigid0 = 0;
  int rigid1 = 0;
  int rigid2 = 0;

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
    // SB-029 · 月桶（以归一类目计刚性）.
    if (_inMonth(f.occurredAt, m0)) {
      m0Fen += f.amountFen;
      if (_isRigid(c)) rigid0 += f.amountFen;
    } else if (_inMonth(f.occurredAt, m1)) {
      m1Fen += f.amountFen;
      if (_isRigid(c)) rigid1 += f.amountFen;
    } else if (_inMonth(f.occurredAt, m2)) {
      m2Fen += f.amountFen;
      if (_isRigid(c)) rigid2 += f.amountFen;
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

  // SB-029 · 跑道（goal_ladder 原公式复用；分母取上月刚性，无则本月）.
  final GoalView goal0 = computeGoal(
    monthSpendFen: m0Fen,
    lastMonthSpendFen: m1Fen,
  );
  final GoalView goal1 = computeGoal(
    monthSpendFen: m1Fen,
    lastMonthSpendFen: m2Fen,
  );
  final int rigidBase = rigid1 > 0 ? rigid1 : rigid0;
  final int rigidBasePrev = rigid2 > 0 ? rigid2 : rigid1;
  final double runway = rigidBase > 0 ? goal0.convertibleFen / rigidBase : 0;
  final double prevRunway = rigidBasePrev > 0
      ? goal1.convertibleFen / rigidBasePrev
      : 0;

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
    lastMonthFen: m1Fen,
    monthRigidFen: rigid0,
    rigidPerMonthFen: rigidBase,
    convertibleFen: goal0.convertibleFen,
    runwayMonths: runway,
    runwayDeltaMonths: runway - prevRunway,
  );
}
