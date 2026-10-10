import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/budget_dao.dart';
import '../data/estimate_dao.dart';
import '../logic/budget.dart';
import '../logic/entry.dart';
import '../logic/estimate.dart';
import 'theme/tokens.dart';
import 'today_saved_row.dart';

// SB-016 · 每日收口浮层（PRD §1 记账是手段；DESIGN §1 地面+浮起 / §7 得到框架）.
// 确认/微调/跳过三选全程 ≤10 秒（一屏三钮，无多步）；跳过零打扰零负罪.
// 估算记录 source=estimate，看板/周报天然合计（transactions 通道）；有真实记录估算自动让位.
// 开关默认开可关；形状只用 r16（内容卡）/ r10（进度位保留）；颜色只用 tokens.
// 本文件零裸时长/曲线（无动画，纯展示 + 落库）；成就复用 SB-008（禁新造动效，本文件不弹新动效）.

class DailyCloseCard extends StatelessWidget {
  const DailyCloseCard({
    super.key,
    required this.estimateFen,
    required this.todaySpendFen,
    required this.closed,
    required this.savedFen,
    this.onConfirm,
    this.onAdjust,
    this.onSkip,
  });

  final int estimateFen;
  final int todaySpendFen;
  final bool closed;
  final int savedFen;
  final VoidCallback? onConfirm;
  final VoidCallback? onAdjust;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              closed ? '今日收口 · 已记' : '今日收口 · 一键',
              style: theme.textTheme.titleMedium,
              key: const Key('dailyCloseTitle'),
            ),
            const SizedBox(height: 8),
            Text(
              closed
                  ? closeDoneText(todaySpendFen: todaySpendFen)
                  : closeAskText(estimateFen: estimateFen),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              key: closed
                  ? const Key('dailyCloseDone')
                  : const Key('dailyCloseAsk'),
            ),
            if (closed) ...<Widget>[
              const SizedBox(height: 4),
              TodaySavedRow(savedFen: savedFen),
            ],
            if (!closed) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '不用每笔记 · 大件手动，细节留给采集',
                style: theme.textTheme.bodySmall,
                key: const Key('dailyCloseHint'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  FilledButton(
                    onPressed: onConfirm,
                    key: const Key('dailyCloseConfirm'),
                    child: const Text('记'),
                  ),
                  OutlinedButton(
                    onPressed: onAdjust,
                    key: const Key('dailyCloseAdjust'),
                    child: const Text('微调'),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    key: const Key('dailyCloseSkip'),
                    child: Text(closeSkipText()),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 收口微调框（金额空=按估算；校验走 validateEstimateFen）.
class DailyCloseAdjustDialog extends StatefulWidget {
  const DailyCloseAdjustDialog({super.key, required this.estimateFen});

  final int estimateFen;

  @override
  State<DailyCloseAdjustDialog> createState() => _DailyCloseAdjustDialogState();
}

class _DailyCloseAdjustDialogState extends State<DailyCloseAdjustDialog> {
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('微调今日零碎'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '估算 ¥${formatFen(widget.estimateFen)} · 空=按估算记',
            key: const Key('dailyCloseAdjustHint'),
          ),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: '金额（元，空=按估算）'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            key: const Key('dailyCloseAmountInput'),
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
            final String raw = _amount.text.trim();
            if (raw.isEmpty) {
              Navigator.of(context).pop<int>(widget.estimateFen);
              return;
            }
            final int? fen = parseAmountToFen(raw);
            final String? err = validateEstimateFen(fen);
            if (err != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(err)));
              return;
            }
            Navigator.of(context).pop<int>(fen);
          },
          key: const Key('dailyCloseAdjustSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 收口同区（首页目标卡之后；数据源 transactions + budgets + 收口两表）.
class DailyCloseZone extends StatelessWidget {
  const DailyCloseZone({super.key, required this.db, required this.rows});

  final AppDb db;
  final List<Transaction> rows;

  Future<void> _confirm(
    BuildContext context,
    int estimateFen,
    String key,
  ) async {
    final DateTime now = DateTime.now();
    await db.insertOne(
      TransactionsCompanion(
        amountFen: Value(estimateFen),
        occurredAt: Value(now),
        category: const Value('其他'),
        note: const Value('每日收口估算'),
        source: const Value('estimate'),
      ),
    );
    await db.markClosed(dateKey: key, estimateFen: estimateFen);
  }

  Future<void> _adjust(
    BuildContext context,
    int estimateFen,
    String key,
  ) async {
    final int? fen = await showDialog<int>(
      context: context,
      builder: (BuildContext ctx) =>
          DailyCloseAdjustDialog(estimateFen: estimateFen),
    );
    if (fen == null || fen <= 0) return;
    if (!context.mounted) return;
    await _confirm(context, fen, key);
  }

  Future<void> _skip(String key) async {
    await db.markClosed(dateKey: key, status: 'skipped');
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String key = dateKeyFor(now);
    final List<CloseFlow> flows = rows
        .map(
          (r) => CloseFlow(
            amountFen: r.amountFen,
            occurredAt: r.occurredAt,
            source: r.source,
          ),
        )
        .toList();
    final int avg = dailyAverage(flows: flows, now: now);
    final int estimate = estimateToday(dailyAvgFen: avg, today: now);
    final List<CloseFlow> today = todayFlowsOf(flows, now);
    final int todaySpend = todaySpendOf(today);
    return StreamBuilder<bool>(
      stream: db.watchCloseEnabled(),
      builder: (ectx, esnap) {
        final bool enabled = esnap.data ?? true;
        return StreamBuilder<List<DailyClose>>(
          stream: db.watchClosesForDate(key),
          builder: (cctx, csnap) {
            final List<DailyClose> closes = csnap.data ?? <DailyClose>[];
            final bool closedToday = closes.isNotEmpty;
            final bool ask =
                enabled &&
                shouldAskClose(todayFlows: today, closedToday: closedToday);
            return StreamBuilder<List<Budget>>(
              stream: db.watchBudgetHistory(monthKeyFor(now)),
              builder: (bctx, bsnap) {
                final List<Budget> hist = bsnap.data ?? <Budget>[];
                final int monthBudget = hist.isEmpty ? 0 : hist.first.budgetFen;
                final int dailyBudget = dailyBudgetFor(
                  monthBudgetFen: monthBudget,
                  now: now,
                  dailyAvgFen: avg,
                );
                final int spendForSaved = ask ? estimate : todaySpend;
                final int saved = computeTodaySaved(
                  dailyBudgetFen: dailyBudget,
                  todaySpendFen: ask ? 0 : spendForSaved,
                );
                // 问句态攒出按"记下估算之后"预估：预算−估算（仅展示用，不落库）.
                final int askSaved = computeTodaySaved(
                  dailyBudgetFen: dailyBudget,
                  todaySpendFen: estimate,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '每日收口',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Switch(
                          value: enabled,
                          key: const Key('dailyCloseSwitch'),
                          onChanged: (bool v) => db.setCloseEnabled(v),
                        ),
                      ],
                    ),
                    if (!enabled)
                      const SizedBox.shrink()
                    else if (ask && estimate <= 0)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            RunwaySpacing.cardInner,
                          ),
                          child: Text(
                            '先记账，收口自然来',
                            style: Theme.of(context).textTheme.bodyMedium,
                            key: const Key('dailyCloseEmpty'),
                          ),
                        ),
                      )
                    else if (ask)
                      DailyCloseCard(
                        estimateFen: estimate,
                        todaySpendFen: 0,
                        closed: false,
                        savedFen: askSaved,
                        onConfirm: () => _confirm(context, estimate, key),
                        onAdjust: () => _adjust(context, estimate, key),
                        onSkip: () => _skip(key),
                      )
                    else
                      DailyCloseCard(
                        estimateFen: estimate,
                        todaySpendFen: todaySpend,
                        closed: true,
                        savedFen: saved,
                        onConfirm: null,
                        onAdjust: null,
                        onSkip: null,
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
