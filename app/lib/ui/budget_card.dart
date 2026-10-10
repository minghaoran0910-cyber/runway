import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/budget_dao.dart';
import '../logic/budget.dart';
import '../logic/entry.dart';
import 'theme/tokens.dart';

// SB-015 · 预算卡（PRD §2 改变层 / §3 比预算基线多省；DESIGN §1 地面+浮起 / §7 得到框架）.
// 自动给（同月>中位数>观察期）+ 一键改（改后省出按新基线重算，历史行保留）；
// 形状只用 r16（内容卡）/ r10（进度条裁剪）；分隔仅 hairline；数字 tabular（§1.4）；
// 颜色只用 tokens；文案全量"得到"框架，零亏欠表述.
// 本文件零裸时长/曲线（无动画，纯展示 + 落库）.

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.budgetFen,
    required this.savedFen,
    required this.monthSpendFen,
    required this.observing,
    required this.basisText,
    required this.historyCount,
    this.onEdit,
  });

  final int budgetFen;
  final int savedFen;
  final int monthSpendFen;
  final bool observing;
  final String basisText;
  final int historyCount;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double progress = budgetFen > 0
        ? (savedFen / budgetFen).clamp(0.0, 1.0).toDouble()
        : 0;
    final String pct = (progress * 100).toStringAsFixed(0);
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
                    budgetTitle(observing: observing),
                    style: theme.textTheme.titleMedium,
                    key: const Key('budgetTitle'),
                  ),
                ),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    key: const Key('budgetEdit'),
                    child: const Text('调预算'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              budgetBody(budgetFen: budgetFen, savedFen: savedFen),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              key: const Key('budgetConvert'),
            ),
            const SizedBox(height: 4),
            Text(
              basisText,
              style: theme.textTheme.bodySmall,
              key: const Key('budgetBasis'),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(RunwayRadius.control),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark
                    ? RunwayDark.surface2
                    : RunwayLight.surface2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? RunwayDark.accent : RunwayLight.accentStrong,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              observing
                  ? '记满 3 个月即自动生效 · 当前第 ${historyCount + 1} 次设定'
                  : '已省出 $pct% 预算 · ${budgetHint(budgetFen: budgetFen, monthSpendFen: monthSpendFen, savedFen: savedFen)}',
              style: theme.textTheme.bodySmall,
              key: const Key('budgetProgress'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 预算编辑框（金额空=自动建议；收紧 0–15；校验走 validateBudgetFen/validateTighten）.
class BudgetEditDialog extends StatefulWidget {
  const BudgetEditDialog({
    super.key,
    required this.initialBudget,
    required this.initialTighten,
  });

  final int initialBudget;
  final int initialTighten;

  @override
  State<BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<BudgetEditDialog> {
  late final TextEditingController _budget;
  late final TextEditingController _tighten;

  @override
  void initState() {
    super.initState();
    _budget = TextEditingController(
      text: widget.initialBudget > 0 ? formatFen(widget.initialBudget) : '',
    );
    _tighten = TextEditingController(text: '${widget.initialTighten}');
  }

  @override
  void dispose() {
    _budget.dispose();
    _tighten.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('本月预算'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _budget,
            decoration: const InputDecoration(labelText: '预算金额（元，空=自动建议）'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            key: const Key('budgetAmountInput'),
          ),
          TextField(
            controller: _tighten,
            decoration: const InputDecoration(labelText: '收紧比例（0–15，默认 5）'),
            keyboardType: TextInputType.number,
            key: const Key('budgetTightenInput'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final String raw = _budget.text.trim();
            final int? pct = int.tryParse(_tighten.text.trim());
            final String? err = validateTighten(pct);
            if (err != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(err)));
              return;
            }
            int? fen;
            if (raw.isNotEmpty) {
              fen = parseAmountToFen(raw);
              final String? err2 = validateBudgetFen(fen);
              if (err2 != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(err2)));
                return;
              }
            }
            Navigator.of(context).pop<({int? budgetFen, int tightenPct})>((
              budgetFen: fen,
              tightenPct: pct!,
            ));
          },
          key: const Key('budgetSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 预算编辑入口（GoalPage/WeeklyPage 复用：空金额=按建议口径自动，填金额=手动；一律插新行留历史）.
Future<bool> editBudget(
  BuildContext context,
  AppDb db,
  String monthKey, {
  required int m0Fen,
  required int m1Fen,
  required int m2Fen,
  required int dataMonths,
  int? sameMonthFen,
  required int currentBudgetFen,
  required int currentTighten,
}) async {
  final ({int? budgetFen, int tightenPct})? res =
      await showDialog<({int? budgetFen, int tightenPct})>(
        context: context,
        builder: (BuildContext ctx) => BudgetEditDialog(
          initialBudget: currentBudgetFen,
          initialTighten: currentTighten,
        ),
      );
  if (res == null) return false;
  if (res.budgetFen != null && res.budgetFen! > 0) {
    await db.upsertBudget(
      monthKey: monthKey,
      budgetFen: res.budgetFen!,
      tightenPct: res.tightenPct,
      basis: 'manual',
    );
    return true;
  }
  final BudgetQuote quote = suggestBudget(
    sameMonthFen: sameMonthFen,
    m0Fen: m0Fen,
    m1Fen: m1Fen,
    m2Fen: m2Fen,
    dataMonths: dataMonths,
    tightenPct: res.tightenPct,
  );
  if (quote.observing) return false;
  await db.upsertBudget(
    monthKey: monthKey,
    budgetFen: quote.budgetFen,
    basisFen: quote.basisFen,
    tightenPct: quote.tightenPct,
    basis: quote.basis.name,
  );
  return true;
}

/// 预算同区（GoalPage 目标区之上；数据源 transactions + budgets 表）.
class BudgetZone extends StatelessWidget {
  const BudgetZone({super.key, required this.db, required this.rows});

  final AppDb db;
  final List<Transaction> rows;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String key = monthKeyFor(now);
    int m0 = 0;
    int m1 = 0;
    int m2 = 0;
    int sameYear = 0;
    final DateTime d1 = DateTime(now.year, now.month - 1, 1);
    final DateTime d2 = DateTime(now.year, now.month - 2, 1);
    for (final Transaction r in rows) {
      if (r.occurredAt.year == now.year && r.occurredAt.month == now.month) {
        m0 += r.amountFen;
      } else if (r.occurredAt.year == d1.year &&
          r.occurredAt.month == d1.month) {
        m1 += r.amountFen;
      } else if (r.occurredAt.year == d2.year &&
          r.occurredAt.month == d2.month) {
        m2 += r.amountFen;
      } else if (r.occurredAt.year == now.year - 1 &&
          r.occurredAt.month == now.month) {
        sameYear += r.amountFen;
      }
    }
    final int dataMonths =
        (m0 > 0 ? 1 : 0) + (m1 > 0 ? 1 : 0) + (m2 > 0 ? 1 : 0);
    final BudgetQuote quote = suggestBudget(
      sameMonthFen: sameYear > 0 ? sameYear : null,
      m0Fen: m0,
      m1Fen: m1,
      m2Fen: m2,
      dataMonths: dataMonths,
    );
    return StreamBuilder<List<Budget>>(
      stream: db.watchBudgetHistory(key),
      builder: (ctx, snap) {
        final List<Budget> hist = snap.data ?? <Budget>[];
        final int budgetFen = hist.isNotEmpty
            ? hist.first.budgetFen
            : quote.budgetFen;
        final bool observing = hist.isEmpty && quote.observing;
        final String basis = hist.isNotEmpty
            ? '已设定 ${formatFen(budgetFen)} · 共调整 ${hist.length} 次'
            : budgetBasisText(quote: quote);
        final BudgetSaved saved = computeBudgetSaved(
          budgetFen: budgetFen,
          monthSpendFen: m0,
          lastMonthSpendFen: m1,
        );
        return BudgetCard(
          budgetFen: budgetFen,
          savedFen: saved.convertibleFen,
          monthSpendFen: m0,
          observing: observing,
          basisText: basis,
          historyCount: hist.length,
          onEdit: () => editBudget(
            context,
            db,
            key,
            m0Fen: m0,
            m1Fen: m1,
            m2Fen: m2,
            dataMonths: dataMonths,
            sameMonthFen: sameYear > 0 ? sameYear : null,
            currentBudgetFen: budgetFen,
            currentTighten: hist.isNotEmpty
                ? hist.first.tightenPct
                : quote.tightenPct,
          ),
        );
      },
    );
  }
}
