import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import '../logic/goal_ladder.dart';
import '../logic/grain_report.dart';
import 'goal_card.dart';
import 'theme/tokens.dart';

// SB-009 · 余粮卡（PRD §2 余粮/自由基金；DESIGN §1 地面+浮起 / §7 得到框架）.
// SB-014 · 旧词正名余粮（标识符同步改 Grain*；DB 表保持不动，行为零变化）.
// 与目标阶梯同区展示（GoalPage 内 GoalProgressCard 之下），不重复造轮子：
// 进度条/排版复用 GoalProgressCard 视觉语言，数据源走 grain_report 引擎.
// 形状只用 r16（内容卡）/ r10（进度条裁剪）；分隔仅 hairline；数字 tabular（§1.4）；
// 颜色只用 tokens；文案全量"得到"框架，零亏欠表述.
// 本文件零裸时长/曲线（无动画，纯展示）.

class GrainReserveCard extends StatelessWidget {
  const GrainReserveCard({
    super.key,
    required this.view,
    this.onEdit,
    this.onOpenWeekly,
  });

  final GrainReserveView view;
  final VoidCallback? onEdit;
  final VoidCallback? onOpenWeekly;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final String monthTitle = grainMonthsTitle(
      fundFen: view.fundFen,
      targetFen: view.targetFen,
      targetMonths: view.targetMonths,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    grainTitle(targetMonths: view.targetMonths),
                    style: theme.textTheme.titleMedium,
                    key: const Key('grainTitle'),
                  ),
                ),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    key: const Key('grainEdit'),
                    child: const Text('设月数'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // SB-040 · 空目标态（targetFen<=0，文案="记满 3 个月…"引导语）降
            // bodySmall：标题级字号只留给真实数字（DESIGN §1.4 数字一等公民）.
            Text(
              grainBody(fundFen: view.fundFen, targetFen: view.targetFen),
              style: view.targetFen <= 0
                  ? theme.textTheme.bodySmall?.copyWith(
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    )
                  : theme.textTheme.headlineSmall?.copyWith(
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
              key: const Key('grainConvert'),
            ),
            const SizedBox(height: 4),
            Text(
              '月均支出 ${formatFenHead(view.avgMonthlySpendFen)} · 目标 ${formatFenHead(view.targetFen)}',
              style: theme.textTheme.bodySmall,
              key: const Key('grainTarget'),
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
            Text(
              view.done
                  ? '已攒够余粮 · 仓满 · ${grainJokeFor('仓满')}'
                  : '$monthTitle · ${grainHint(fundFen: view.fundFen, targetFen: view.targetFen)}',
              style: theme.textTheme.bodySmall,
              key: Key(view.done ? 'grainDone' : 'grainProgress'),
            ),
            if (onOpenWeekly != null) ...<Widget>[
              const SizedBox(height: 4),
              TextButton(
                onPressed: onOpenWeekly,
                key: const Key('grainToWeekly'),
                child: const Text('看本周周报'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 余粮月数编辑框（1–36，默认 6；校验走 validateGrainMonths）.
class GrainMonthsDialog extends StatefulWidget {
  const GrainMonthsDialog({super.key, required this.initialMonths});

  final int initialMonths;

  @override
  State<GrainMonthsDialog> createState() => _GrainMonthsDialogState();
}

class _GrainMonthsDialogState extends State<GrainMonthsDialog> {
  late final TextEditingController _months;

  @override
  void initState() {
    super.initState();
    _months = TextEditingController(text: '${widget.initialMonths}');
  }

  @override
  void dispose() {
    _months.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('余粮目标'),
      content: TextField(
        controller: _months,
        decoration: const InputDecoration(labelText: '目标月数（1–36，默认 6）'),
        keyboardType: TextInputType.number,
        key: const Key('grainMonthsInput'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop<int?>(null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final int? v = int.tryParse(_months.text.trim());
            final String? err = validateGrainMonths(v);
            if (err != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(err)));
              return;
            }
            Navigator.of(context).pop<int>(v!);
          },
          key: const Key('grainMonthsSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 余粮编辑入口（GoalPage 复用：弹框 → upsert 落库，返回 true=已保存）.
Future<bool> editGrainMonths(
  BuildContext context,
  AppDb db,
  int current,
) async {
  final int? months = await showDialog<int>(
    context: context,
    builder: (BuildContext ctx) => GrainMonthsDialog(initialMonths: current),
  );
  if (months == null) return false;
  await db.upsertSafetyMonths(months);
  return true;
}

/// 余粮同区（GoalPage 目标区之下；数据源 transactions + safety_pad 配置）.
class GrainZone extends StatelessWidget {
  const GrainZone({super.key, required this.db, required this.rows});

  final AppDb db;
  final List<Transaction> rows;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final sums = sumMonthSpend(rows, now);
    int last2 = 0;
    final DateTime m2 = DateTime(now.year, now.month - 2, 1);
    for (final Transaction r in rows) {
      if (r.occurredAt.year == m2.year && r.occurredAt.month == m2.month) {
        last2 += r.amountFen;
      }
    }
    final int avg = avg3MonthSpend(
      monthSpendFen: sums.monthSpendFen,
      lastMonthSpendFen: sums.lastMonthSpendFen,
      last2MonthSpendFen: last2,
    );
    final int fund = computeGoal(
      monthSpendFen: sums.monthSpendFen,
      lastMonthSpendFen: sums.lastMonthSpendFen,
    ).convertibleFen;
    return FutureBuilder<SafetyPadData?>(
      future: db.currentSafetyPad(),
      builder: (ctx, snap) {
        final int months = snap.data?.targetMonths ?? defaultGrainMonths;
        final GrainReserveView view = computeGrainReserve(
          avgMonthlySpendFen: avg,
          fundFen: fund,
          targetMonths: months,
        );
        return GrainReserveCard(
          view: view,
          onEdit: () => editGrainMonths(context, db, months),
        );
      },
    );
  }
}
