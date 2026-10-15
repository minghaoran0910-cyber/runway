import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import '../logic/goal_deadline.dart';
import 'theme/tokens.dart';

// SB-030 · 目标纵向时间线（demo 清单④：图标方块竖线串联；
// SB-031 · 达成态去重：瓦片 check 图标保留，文案去 ✓ 留「已攒够 · N 周」；
// 未达成"¥现攒 / ¥目标" tabular 对齐 §1.4；编辑/删除键并入状态行右侧 trailing；
// 形状只用 r16 外卡 / r10 图标瓦片 §1.2；图标 34px 瓦片+19px 图标 §4；
// 达标瓦片 gold，未达标中性瓦片；分隔竖线仅 hairline §1.3；
// N 周=自建目标起整周数（(now-createdAt)/7+1，最小 1），如实口径不编造）.
// SB-041 · 期限行（goals.deadline 可空；有值即"预计 M月d日攒到"，空则零像素）.

/// 目标时间线（goals 为全部目标，convertibleFen 为全局可换算省出）.
class GoalTimeline extends StatelessWidget {
  const GoalTimeline({
    super.key,
    required this.goals,
    required this.convertibleFen,
    required this.now,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Goal> goals;
  final int convertibleFen;
  final DateTime now;
  final void Function(Goal goal) onEdit;
  final void Function(Goal goal) onDelete;

  /// 自建起整周数（最小 1）.
  static int weeksSince(DateTime createdAt, DateTime now) {
    final int days = now.difference(createdAt).inDays;
    if (days < 0) return 1;
    return days ~/ 7 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color lineColor = isDark ? RunwayDark.hairline : RunwayLight.hairline;
    final Color tileBg = isDark ? RunwayDark.surface2 : RunwayLight.surface1;
    final Color goldTile = isDark ? RunwayDark.goldHi : RunwayLight.gold;
    return Column(
      key: const Key('goalTimeline'),
      children: <Widget>[
        for (int i = 0; i < goals.length; i++)
          Builder(
            builder: (BuildContext ctx) {
              final Goal g = goals[i];
              final bool done = convertibleFen >= g.targetFen;
              final int weeks = weeksSince(g.createdAt, now);
              final bool last = i == goals.length - 1;
              final String deadlineLine = formatDeadlineLine(g.deadline);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 左轨：图标方块 + 竖线.
                  Column(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: done
                              ? goldTile.withValues(alpha: 0.18)
                              : tileBg,
                          borderRadius: BorderRadius.circular(
                            RunwayRadius.control,
                          ),
                          border: Border.all(color: lineColor),
                        ),
                        child: Icon(
                          done ? Icons.check : Icons.flag_outlined,
                          size: 19,
                          color: done
                              ? (isDark ? RunwayDark.goldHi : RunwayLight.gold)
                              : (isDark
                                    ? RunwayDark.accent
                                    : RunwayLight.accentStrong),
                        ),
                      ),
                      if (!last)
                        Container(width: 2, height: 28, color: lineColor),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // 右侧：标题 + 状态行（编辑/删除并入状态行右侧 trailing）.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${g.name} · ${formatFen(g.targetFen)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                          key: Key('goalItem-${g.id}'),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                done
                                    ? '已攒够 · $weeks 周'
                                    : '${formatFen(convertibleFen)} / ${formatFen(g.targetFen)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: done
                                      ? (isDark
                                            ? RunwayDark.goldHi
                                            : RunwayLight.gold)
                                      : theme.textTheme.bodySmall?.color,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                                key: Key(
                                  done
                                      ? 'goalTimelineDone-${g.id}'
                                      : 'goalTimelineProgress-${g.id}',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: '编辑',
                              key: Key('goalEdit-${g.id}'),
                              onPressed: () => onEdit(g),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: '删除',
                              key: Key('goalDelete-${g.id}'),
                              onPressed: () => onDelete(g),
                            ),
                          ],
                        ),
                        if (deadlineLine.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              deadlineLine,
                              style: theme.textTheme.bodySmall,
                              key: Key('goalDeadline-${g.id}'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
