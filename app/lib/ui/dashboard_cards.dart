import 'package:flutter/material.dart';

import '../logic/dashboard_stats.dart';
import '../logic/entry.dart';
import '../logic/goal_ladder.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'widgets/progress_ring.dart';

// SB-006 · 看板四区组件（Hero 支出主卡 / 今日 / 类目 Top5 / 目标进度）.
// 形状只用 r22（Hero）/ r16（内容卡）/ r10（进度条裁剪）；分隔仅 hairline；
// 数字 tabular（§1.4）；颜色只用 tokens；字号收敛阶梯（Hero 沿 RunwayHero）.
// SB-029 · Hero 升级为 demo 同构可视化主卡（demos/shots/home-light.png）：
// 环形进度（环内跑道月数大数字+单位）+ 右上琥珀对比行（比上月 ±N 个月）+
// 得到框架金句 + "可动用 ÷ 刚性"公式行；"（示例数据）"移出 hero，
// 改页底水印（home_page.dart 底）；homeTotal 键保留在环内大数字上（SB-004 回归）.

/// Hero：跑道主卡（目标名/环形月数/琥珀对比/金句/公式/分类健康）.
class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key, required this.summary, this.goalName});

  final DashboardSummary summary;

  /// 首个目标名（null=未设目标，标题回落"本月支出"）.
  final String? goalName;

  @override
  Widget build(BuildContext context) {
    final String shareText =
        '${(summary.otherShare * 100).toStringAsFixed(1)}%';
    final bool hasCompare = summary.lastMonthFen > 0;
    // 金句（得到框架；大额只陈述复用 equivalentOf，无行动召唤）.
    final String verdict;
    if (goalName != null && summary.goalFen != null && summary.goalFen! > 0) {
      verdict = nextLadderHint(
        convertibleFen: summary.convertibleFen,
        targetFen: summary.goalFen!,
      );
    } else if (summary.convertibleFen > 0) {
      verdict = equivalentOf(summary.convertibleFen);
    } else {
      verdict = '记下第一笔，开始攒跑道';
    }
    return Container(
      decoration: AppTheme.heroCard(),
      padding: const EdgeInsets.all(RunwaySpacing.cardInner),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  goalName ?? '本月支出',
                  style: const TextStyle(
                    fontSize: RunwayHero.titleSize,
                    color: RunwayHero.title,
                  ),
                  key: const Key('heroTitle'),
                ),
              ),
              Text(
                !hasCompare
                    ? '首月记账中'
                    : summary.runwayDeltaMonths.abs() < 0.05
                    ? '与上月持平'
                    : '比上月 ${formatRunwayDelta(summary.runwayDeltaMonths)} 个月',
                style: const TextStyle(
                  fontSize: RunwayHero.subSize,
                  color: RunwayHero.goldAccent,
                  fontWeight: FontWeight.w600,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
                key: const Key('heroCompare'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ProgressRing(
                key: const Key('heroRing'),
                fraction: runwayFraction(summary.runwayMonths),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CountUpMonths(
                      months: summary.runwayMonths,
                      style: const TextStyle(
                        fontSize: RunwayHero.numberSize,
                        color: RunwayHero.number,
                        fontWeight: FontWeight.w700,
                        fontFeatures: <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const Text(
                      '个月',
                      style: TextStyle(
                        fontSize: RunwayHero.subSize,
                        color: RunwayHero.sub,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      verdict,
                      style: const TextStyle(
                        fontSize: 17,
                        color: RunwayHero.number,
                        fontWeight: FontWeight.w700,
                        fontFeatures: <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                      key: const Key('heroVerdict'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '可动用 ¥${formatFen(summary.convertibleFen)}'
                      ' ÷ 刚性 ¥${formatFen(summary.rigidPerMonthFen)}/月',
                      style: const TextStyle(
                        fontSize: RunwayHero.subSize,
                        color: RunwayHero.sub,
                        fontFeatures: <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                      key: const Key('heroFormula'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // SB-045 ① · 其他占比零值降噪：share*100<0.05（取整即 0.0%）时
          // 整段不显示该字段；故障态（>5%）恒显示.
          if (summary.otherShare * 100 >= 0.05)
            Text(
              '今日 ${summary.todayCount} 笔 · ${formatFenYuan(summary.todayFen)}'
              ' · 其他占比 $shareText',
              style: const TextStyle(
                fontSize: RunwayHero.subSize,
                color: RunwayHero.sub,
              ),
              key: const Key('dashOtherShare'),
            ),
          if (summary.otherShare * 100 >= 0.05) const SizedBox(height: 4),
          Text(
            // SB-045 ② · 「分类健康」悬空标签→自解释短句；故障态文案不动.
            summary.otherFault ? '分类故障：其他占比超 5%' : '分类都在轨',
            style: TextStyle(
              fontSize: RunwayHero.subSize,
              color: summary.otherFault
                  ? RunwayHero.goldAccent
                  : RunwayHero.sub,
            ),
            key: Key(
              summary.otherFault ? 'dashOtherFault' : 'dashOtherHealthy',
            ),
          ),
        ],
      ),
    );
  }
}

/// 今日卡：今日笔数金额（内容卡 r16）.
class DashboardTodayCard extends StatelessWidget {
  const DashboardTodayCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('今日', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.todayCount} 笔 · ${formatFenYuan(summary.todayFen)}',
                    style: theme.textTheme.headlineSmall,
                    key: const Key('dashToday'),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '本周 ${formatFenYuan(summary.weekFen)}',
                  style: theme.textTheme.bodySmall,
                  key: const Key('dashWeek'),
                ),
                const SizedBox(height: 4),
                Text(
                  '本月 ${summary.monthCount} 笔',
                  style: theme.textTheme.bodySmall,
                  key: const Key('dashMonthCount'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Top5 卡：类目分布前五（横条为 Container 比例条，无新图表库）.
class DashboardTop5Card extends StatelessWidget {
  const DashboardTop5Card({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color barBg = isDark ? RunwayDark.surface2 : RunwayLight.surface2;
    final Color barFg = isDark ? RunwayDark.accent : RunwayLight.accentStrong;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('类目分布 Top5', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (summary.top5.isEmpty)
              Text(
                '暂无分布',
                style: theme.textTheme.bodyMedium,
                key: const Key('dashTop5Empty'),
              )
            else
              for (final TopEntry e in summary.top5)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 44,
                        child: Text(
                          e.category,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: barBg,
                            borderRadius: BorderRadius.circular(
                              RunwayRadius.control,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: e.share.clamp(0.02, 1.0).toDouble(),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: barFg,
                                borderRadius: BorderRadius.circular(
                                  RunwayRadius.control,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 72,
                        child: Text(
                          formatFenYuan(e.fen),
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.right,
                          key: Key('dashTop5-${e.category}'),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// 目标卡：月度目标进度（未设目标显示引导位）.
class DashboardGoalCard extends StatelessWidget {
  const DashboardGoalCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    if (summary.goalFen == null || summary.goalFen! <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(RunwaySpacing.cardInner),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('本月攒出', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '还没有设定目标，设一个试试',
                style: theme.textTheme.bodyMedium,
                key: const Key('dashGoalEmpty'),
              ),
            ],
          ),
        ),
      );
    }
    final int goal = summary.goalFen!;
    final String pct = (summary.goalProgress * 100).toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('本月攒出', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${formatFenYuan(summary.monthFen)} / ${formatFenYuan(goal)} · $pct%',
              style: theme.textTheme.headlineSmall,
              key: const Key('dashGoal'),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(RunwayRadius.control),
              child: LinearProgressIndicator(
                value: summary.goalProgress,
                minHeight: 8,
                backgroundColor: isDark
                    ? RunwayDark.surface2
                    : RunwayLight.surface2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  summary.goalOver
                      ? (isDark ? RunwayDark.danger : RunwayLight.danger)
                      : (isDark ? RunwayDark.accent : RunwayLight.accentStrong),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              summary.goalOver ? '已超目标' : '进行中',
              style: theme.textTheme.bodySmall,
              key: Key(summary.goalOver ? 'dashGoalOver' : 'dashGoalDoing'),
            ),
          ],
        ),
      ),
    );
  }
}
