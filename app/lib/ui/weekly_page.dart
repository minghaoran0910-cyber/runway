import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/budget_dao.dart';
import '../logic/budget.dart';
import '../logic/dashboard_stats.dart';
import 'budget_card.dart';
import '../logic/entry.dart';
import '../logic/grain_report.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-009 · 周报页（PRD §2 攒到层周交付 / §6 周报互动率；DESIGN §1 地面+浮起 / §7 得到框架）.
// 历史留存走 weekly_reports 表（每周一生成，weekStart 去重，纯本地无网络）；
// 本周实时区由 transactions 推导（computeWeekly），换算复用 SB-007 引擎.
// 形状只用 r16（内容卡）；分隔仅 hairline；数字 tabular；颜色只用 tokens.
// 本文件零裸时长/曲线（无动画，纯展示 + 落库）.

/// Top3 序列化（"类目:分,…"；空为 ''，解析失败即空列表）.
String encodeTop3(List<WeeklyTop> top3) {
  return top3.map((t) => '${t.category}:${t.fen}').join(',');
}

List<WeeklyTop> decodeTop3(String raw) {
  if (raw.trim().isEmpty) return <WeeklyTop>[];
  final List<WeeklyTop> out = <WeeklyTop>[];
  for (final String part in raw.split(',')) {
    final List<String> kv = part.split(':');
    if (kv.length != 2) continue;
    final int? fen = int.tryParse(kv[1]);
    if (fen == null) continue;
    out.add(WeeklyTop(category: kv[0], fen: fen));
  }
  return out;
}

String _dateOf(DateTime t) {
  final String m = t.month.toString().padLeft(2, '0');
  final String d = t.day.toString().padLeft(2, '0');
  return '${t.year}-$m-$d';
}

/// 本周落库（幂等：同 weekStart 已存在即跳过，返回 false=跳过）.
Future<bool> ensureWeeklyReport(AppDb db, WeeklyReportView view) async {
  if (await db.weeklyExists(view.weekStart)) return false;
  await db.insertWeeklyReport(
    WeeklyReportsCompanion(
      weekStart: Value(view.weekStart),
      spendFen: Value(view.spendFen),
      incomeFen: Value(view.incomeFen),
      savedFen: Value(view.savedFen),
      topJson: Value(encodeTop3(view.top3)),
      momDeltaFen: Value(view.momDeltaFen),
    ),
  );
  return true;
}

/// SB-015 · 当月支出合计（预算口径省出用）.
int _monthSpendOf(List<Transaction> rows) {
  final DateTime now = DateTime.now();
  int sum = 0;
  for (final Transaction r in rows) {
    if (r.occurredAt.year == now.year && r.occurredAt.month == now.month) {
      sum += r.amountFen;
    }
  }
  return sum;
}

/// SB-015 · 上月支出合计（预算口径环比增量用）.
int _lastMonthSpendOf(List<Transaction> rows) {
  final DateTime now = DateTime.now();
  final DateTime d1 = DateTime(now.year, now.month - 1, 1);
  int sum = 0;
  for (final Transaction r in rows) {
    if (r.occurredAt.year == d1.year && r.occurredAt.month == d1.month) {
      sum += r.amountFen;
    }
  }
  return sum;
}

class WeeklyPage extends StatefulWidget {
  const WeeklyPage({super.key, required this.db});

  final AppDb db;

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  bool _autoTried = false;

  List<DashboardFlow> _flowsOf(List<Transaction> rows) {
    return rows
        .map(
          (r) => DashboardFlow(
            amountFen: r.amountFen,
            category: r.category,
            occurredAt: r.occurredAt,
          ),
        )
        .toList();
  }

  Future<void> _maybeAutoGenerate(
    List<Transaction> rows,
    List<WeeklyReport> history,
  ) async {
    if (_autoTried) return;
    _autoTried = true;
    final DateTime now = DateTime.now();
    final DateTime? last = history.isEmpty ? null : history.first.weekStart;
    if (!shouldGenerateWeekly(now: now, lastGenerated: last)) return;
    final List<DashboardFlow> flows = _flowsOf(rows);
    final int prev = sumPrevWeekSpend(flows: flows, now: now);
    final WeeklyReportView view = computeWeekly(
      flows: flows,
      now: now,
      prevWeekSpendFen: prev,
    );
    await ensureWeeklyReport(widget.db, view);
  }

  Future<void> _manualGenerate(List<Transaction> rows) async {
    final DateTime now = DateTime.now();
    final List<DashboardFlow> flows = _flowsOf(rows);
    final int prev = sumPrevWeekSpend(flows: flows, now: now);
    final WeeklyReportView view = computeWeekly(
      flows: flows,
      now: now,
      prevWeekSpendFen: prev,
    );
    final bool inserted = await ensureWeeklyReport(widget.db, view);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(inserted ? '本周周报已留存' : '本周周报已存在，无需重复生成'),
        key: const Key('weeklyGenResult'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('周报')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Transaction>>(
          stream: widget.db.watchAll(),
          builder: (ctx, tsnap) {
            final List<Transaction> rows = tsnap.data ?? <Transaction>[];
            return StreamBuilder<List<WeeklyReport>>(
              stream: widget.db.watchWeeklyReports(),
              builder: (ctx2, wsnap) {
                final List<WeeklyReport> history =
                    wsnap.data ?? <WeeklyReport>[];
                if (history.isNotEmpty || rows.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _maybeAutoGenerate(rows, history);
                  });
                }
                final DateTime now = DateTime.now();
                final List<DashboardFlow> flows = _flowsOf(rows);
                final int prev = sumPrevWeekSpend(flows: flows, now: now);
                final WeeklyReportView cur = computeWeekly(
                  flows: flows,
                  now: now,
                  prevWeekSpendFen: prev,
                );
                return ListView(
                  padding: const EdgeInsets.all(RunwaySpacing.page),
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              weeklyTitle(weekStart: cur.weekStart),
                              style: theme.textTheme.titleMedium,
                              key: const Key('weeklyTitle'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weeklyBody(
                                savedFen: cur.savedFen,
                                spendFen: cur.spendFen,
                              ),
                              style: theme.textTheme.headlineSmall,
                              key: const Key('weeklyBody'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              // SB-014 · 本周攒出物理换算（复用 SB-007 价格表，禁止编造）.
                              weeklySavingConvert(savedFen: cur.savedFen),
                              style: theme.textTheme.bodySmall,
                              key: const Key('weeklyConvert'),
                            ),
                            // SB-015 · 周报换算改接预算基线（预算周折算对照 + 环比增量）.
                            StreamBuilder<List<Budget>>(
                              stream: widget.db.watchBudgetHistory(
                                monthKeyFor(DateTime.now()),
                              ),
                              builder: (bctx, bsnap) {
                                final List<Budget> hist =
                                    bsnap.data ?? <Budget>[];
                                if (hist.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final int mSpend = _monthSpendOf(rows);
                                final int mLast = _lastMonthSpendOf(rows);
                                final BudgetSaved bs = computeBudgetSaved(
                                  budgetFen: hist.first.budgetFen,
                                  monthSpendFen: mSpend,
                                  lastMonthSpendFen: mLast,
                                );
                                return Text(
                                  '相对预算省出 ${formatFen(bs.convertibleFen)}',
                                  style: theme.textTheme.bodySmall,
                                  key: const Key('weeklyBudgetSaved'),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weeklyMomText(momDeltaFen: cur.momDeltaFen),
                              style: theme.textTheme.bodySmall,
                              key: const Key('weeklyMom'),
                            ),
                            Text(
                              weeklyTopText(cur.top3),
                              style: theme.textTheme.bodySmall,
                              key: const Key('weeklyTop'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _manualGenerate(rows),
                              key: const Key('weeklyGenerate'),
                              child: const Text('生成本周周报'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: RunwaySpacing.section),
                    Text(
                      '历史周报 ${history.length} 期',
                      style: theme.textTheme.bodySmall,
                      key: const Key('weeklyCount'),
                    ),
                    const SizedBox(height: 8),
                    if (history.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            RunwaySpacing.cardInner,
                          ),
                          child: Text(
                            '还没有历史周报 · 每周一自动留存',
                            style: theme.textTheme.bodyMedium,
                            key: const Key('weeklyEmpty'),
                          ),
                        ),
                      )
                    else
                      for (final WeeklyReport w in history)
                        Card(
                          child: ListTile(
                            title: Text(
                              '${_dateOf(w.weekStart)} · 省出 ${formatFen(w.savedFen)}',
                              style: theme.textTheme.titleMedium,
                              key: Key('weeklyItem-${w.id}'),
                            ),
                            subtitle: Text(
                              '支出 ${formatFen(w.spendFen)} · ${weeklyMomText(momDeltaFen: w.momDeltaFen)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                    // SB-015 · 预算同区（历史之后；上方周报区相对位置不变，
                    // 旧 widget 断言零影响；自动给+一键改，改后省出按新基线重算）.
                    const SizedBox(height: RunwaySpacing.section),
                    BudgetZone(db: widget.db, rows: rows),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
