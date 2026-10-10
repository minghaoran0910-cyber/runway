import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import '../logic/goal_ladder.dart';
import '../logic/safety_report.dart';
import 'goal_card.dart';
import 'theme/tokens.dart';

// SB-009 · 安全垫卡（PRD §2 安全垫/自由基金；DESIGN §1 地面+浮起 / §7 得到框架）.
// 与目标阶梯同区展示（GoalPage 内 GoalProgressCard 之下），不重复造轮子：
// 进度条/排版复用 GoalProgressCard 视觉语言，数据源走 safety_report 引擎.
// 形状只用 r16（内容卡）/ r10（进度条裁剪）；分隔仅 hairline；数字 tabular（§1.4）；
// 颜色只用 tokens；文案全量"得到"框架，零亏欠表述.
// 本文件零裸时长/曲线（无动画，纯展示）.

class SafetyPadCard extends StatelessWidget {
  const SafetyPadCard({
    super.key,
    required this.view,
    this.onEdit,
    this.onOpenWeekly,
  });

  final SafetyPadView view;
  final VoidCallback? onEdit;
  final VoidCallback? onOpenWeekly;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final String pct = (view.progress * 100).toStringAsFixed(0);
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
                    safetyTitle(targetMonths: view.targetMonths),
                    style: theme.textTheme.titleMedium,
                    key: const Key('safetyTitle'),
                  ),
                ),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    key: const Key('safetyEdit'),
                    child: const Text('设月数'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              safetyBody(fundFen: view.fundFen, targetFen: view.targetFen),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              key: const Key('safetyConvert'),
            ),
            const SizedBox(height: 4),
            Text(
              '月均支出 ${formatFen(view.avgMonthlySpendFen)} · 目标 ${formatFen(view.targetFen)}',
              style: theme.textTheme.bodySmall,
              key: const Key('safetyTarget'),
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
                  ? '已攒够安全垫 · 得到阶段性底气'
                  : '已攒 $pct% · ${safetyHint(fundFen: view.fundFen, targetFen: view.targetFen)}',
              style: theme.textTheme.bodySmall,
              key: Key(view.done ? 'safetyDone' : 'safetyProgress'),
            ),
            if (onOpenWeekly != null) ...<Widget>[
              const SizedBox(height: 4),
              TextButton(
                onPressed: onOpenWeekly,
                key: const Key('safetyToWeekly'),
                child: const Text('看本周周报'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 安全垫月数编辑框（1–36，默认 6；校验走 validateSafetyMonths）.
class SafetyMonthsDialog extends StatefulWidget {
  const SafetyMonthsDialog({super.key, required this.initialMonths});

  final int initialMonths;

  @override
  State<SafetyMonthsDialog> createState() => _SafetyMonthsDialogState();
}

class _SafetyMonthsDialogState extends State<SafetyMonthsDialog> {
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
      title: const Text('安全垫目标'),
      content: TextField(
        controller: _months,
        decoration: const InputDecoration(labelText: '目标月数（1–36，默认 6）'),
        keyboardType: TextInputType.number,
        key: const Key('safetyMonthsInput'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop<int?>(null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final int? v = int.tryParse(_months.text.trim());
            final String? err = validateSafetyMonths(v);
            if (err != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(err)));
              return;
            }
            Navigator.of(context).pop<int>(v!);
          },
          key: const Key('safetyMonthsSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 安全垫编辑入口（GoalPage 复用：弹框 → upsert 落库，返回 true=已保存）.
Future<bool> editSafetyMonths(
  BuildContext context,
  AppDb db,
  int current,
) async {
  final int? months = await showDialog<int>(
    context: context,
    builder: (BuildContext ctx) => SafetyMonthsDialog(initialMonths: current),
  );
  if (months == null) return false;
  await db.upsertSafetyMonths(months);
  return true;
}

/// 安全垫同区（GoalPage 目标区之下；数据源 transactions + safety_pad 配置）.
class SafetyZone extends StatelessWidget {
  const SafetyZone({super.key, required this.db, required this.rows});

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
        final int months = snap.data?.targetMonths ?? defaultSafetyMonths;
        final SafetyPadView view = computeSafetyPad(
          avgMonthlySpendFen: avg,
          fundFen: fund,
          targetMonths: months,
        );
        return SafetyPadCard(
          view: view,
          onEdit: () => editSafetyMonths(context, db, months),
        );
      },
    );
  }
}
