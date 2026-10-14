import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/goal_ladder.dart';
import 'theme/tokens.dart';

// SB-007 · 实物换算进度组件（可叠加 SB-006 看板之下；得到框架文案）.
// 形状只用 r16（内容卡）/ r10（进度条裁剪）；数字 tabular（§1.4）；
// 颜色只用 tokens；文案全量"得到"框架（§7），零亏欠表述.

/// 当月/上月支出汇总（自然月；纯函数便于测试）.
({int monthSpendFen, int lastMonthSpendFen}) sumMonthSpend(
  List<Transaction> rows,
  DateTime now,
) {
  int month = 0;
  int last = 0;
  final int lastMonth = now.month == 1 ? 12 : now.month - 1;
  final int lastYear = now.month == 1 ? now.year - 1 : now.year;
  for (final Transaction r in rows) {
    if (r.occurredAt.year == now.year && r.occurredAt.month == now.month) {
      month += r.amountFen;
    } else if (r.occurredAt.year == lastYear &&
        r.occurredAt.month == lastMonth) {
      last += r.amountFen;
    }
  }
  return (monthSpendFen: month, lastMonthSpendFen: last);
}

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.targetFen,
    required this.price,
    required this.monthSpendFen,
    required this.lastMonthSpendFen,
  });

  final int targetFen;
  final PriceRef price;
  final int monthSpendFen;
  final int lastMonthSpendFen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final GoalView view = computeGoal(
      monthSpendFen: monthSpendFen,
      lastMonthSpendFen: lastMonthSpendFen,
      targetFen: targetFen,
    );
    final String pct = (view.progress * 100).toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('本周换算', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              describeSaving(convertibleFen: view.convertibleFen, price: price),
              style: theme.textTheme.headlineSmall,
              key: const Key('goalConvert'),
            ),
            const SizedBox(height: 4),
            Text(
              equivalentOf(view.convertibleFen),
              style: theme.textTheme.bodySmall,
              key: const Key('goalEquiv'),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(RunwayRadius.control),
              child: LinearProgressIndicator(
                value: view.progress,
                minHeight: 8,
                backgroundColor: isDark
                    ? RunwayDark.surface2
                    : RunwayLight.surface2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  view.done
                      ? (isDark ? RunwayDark.goldHi : RunwayLight.gold)
                      : (isDark ? RunwayDark.accent : RunwayLight.accentStrong),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // SB-037③：去重（旧文"已攒 0% · 下一站 奶茶 · 已攒 0%"双已攒+双行复述；
            // 进度行只留一份已攒+站名，下一站详情由时间线承载，本卡不再复述第二行）.
            Text(
              view.done
                  ? '已攒够 · 得到阶段性底气'
                  : () {
                      final String? next = nextLadderName(
                        convertibleFen: view.convertibleFen,
                      );
                      return next == null
                          ? '已攒 $pct% · 已越过全部阶梯'
                          : '已攒 $pct% · 下一站 $next';
                    }(),
              style: theme.textTheme.bodySmall,
              key: Key(view.done ? 'goalDone' : 'goalProgress'),
            ),
          ],
        ),
      ),
    );
  }
}
