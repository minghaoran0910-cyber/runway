import 'package:flutter/material.dart';

import '../logic/dashboard_stats.dart';
import '../logic/entry.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-006 · 看板四区组件（Hero 支出主卡 / 今日 / 类目 Top5 / 目标进度）.
// 形状只用 r22（Hero）/ r16（内容卡）/ r10（进度条裁剪）；分隔仅 hairline；
// 数字 tabular（§1.4）；颜色只用 tokens；字号收敛阶梯（Hero 沿 RunwayHero）.

/// Hero：本月支出主数字（复用 homeTotal 键，保 SB-004 回归）+ 今日副数据 + 其他占比故障态.
class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final String shareText =
        '${(summary.otherShare * 100).toStringAsFixed(1)}%';
    return Container(
      decoration: AppTheme.heroCard(),
      padding: const EdgeInsets.all(RunwaySpacing.cardInner),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '本月支出（示例数据）',
            style: TextStyle(
              fontSize: RunwayHero.titleSize,
              color: RunwayHero.title,
            ),
          ),
          Text(
            formatFen(summary.monthFen),
            style: const TextStyle(
              fontSize: RunwayHero.numberSize,
              color: RunwayHero.number,
              fontWeight: FontWeight.w700,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
            key: const Key('homeTotal'),
          ),
          Text(
            '今日 ${summary.todayCount} 笔 · ${formatFen(summary.todayFen)}'
            ' · 其他占比 $shareText',
            style: const TextStyle(
              fontSize: RunwayHero.subSize,
              color: RunwayHero.sub,
            ),
            key: const Key('dashOtherShare'),
          ),
          const SizedBox(height: 4),
          Text(
            summary.otherFault ? '分类故障：其他占比超 5%' : '分类健康',
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
                    '${summary.todayCount} 笔 · ${formatFen(summary.todayFen)}',
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
                  '本周 ${formatFen(summary.weekFen)}',
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
                          formatFen(e.fen),
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
              Text('本月目标', style: theme.textTheme.titleMedium),
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
            Text('本月目标', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${formatFen(summary.monthFen)} / ${formatFen(goal)} · $pct%',
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
