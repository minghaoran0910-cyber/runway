import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/dashboard_stats.dart';
import '../logic/entry.dart';
import 'budget_card.dart';
import 'category_page.dart';
import 'cooloff_card.dart';
import 'daily_close_sheet.dart';
import 'dashboard_cards.dart';
import 'experiment_card.dart';
import 'goal_page.dart';
import 'pending_page.dart';
import 'quick_add_page.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-004 · 主屏（记录列表可查/可改/可删；重开 App 数据仍在，文件库持久化）.
// SB-006 · 首页看板四区（Hero/今日/Top5/目标）+ 原记录列表保留.
// SB-007 · 目标入口 + goals 表真实 goalFen 供数（闭环 SB-006 D1 目标未持久化）.
// SB-010 · 待确认入口（图标按钮进 PendingListPage；零像素改动，既有 golden 不受影响）.
// Hero 主卡沿 §3（AppTheme.heroCard）；列表行分隔仅用 hairline（§1.3）.

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.db});

  final AppDb db;

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => QuickAddPage(db: db)));
  }

  Future<void> _edit(BuildContext context, Transaction row) async {
    final TextEditingController note = TextEditingController(text: row.note);
    String category = row.category;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext dctx, StateSetter setDialogState) => AlertDialog(
          title: const Text('编辑记录'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final String c in defaultCategories)
                    ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setDialogState(() => category = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: '备注'),
                maxLength: 200,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dctx).pop(true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    try {
      if (ok == true) {
        await db.updateOne(
          TransactionsCompanion(
            id: Value(row.id),
            amountFen: Value(row.amountFen),
            occurredAt: Value(row.occurredAt),
            category: Value(category),
            note: Value(note.text),
            source: Value(row.source),
          ),
        );
      }
    } finally {
      note.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('攒够'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.markunread_mailbox),
            tooltip: '待确认',
            key: const Key('pendingEntry'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => PendingListPage(
                  db: db,
                  source: AndroidNotificationCollector(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: '类目管理',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => CategoryPage(db: db)),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Goal>>(
          stream: db.watchGoals(),
          builder: (BuildContext gctx, AsyncSnapshot<List<Goal>> gsnap) {
            final List<Goal> goals = gsnap.data ?? <Goal>[];
            final int? goalFen = goals.isEmpty ? null : goals.first.targetFen;
            return StreamBuilder<List<Transaction>>(
              stream: db.watchAll(),
              builder:
                  (BuildContext ctx, AsyncSnapshot<List<Transaction>> snap) {
                    final List<Transaction> rows = snap.data ?? <Transaction>[];
                    final DashboardSummary summary = computeDashboard(
                      flows: rows
                          .map(
                            (Transaction r) => DashboardFlow(
                              amountFen: r.amountFen,
                              category: r.category,
                              occurredAt: r.occurredAt,
                            ),
                          )
                          .toList(),
                      now: DateTime.now(),
                      goalFen: goalFen,
                    );
                    return ListView(
                      padding: const EdgeInsets.all(RunwaySpacing.page),
                      children: <Widget>[
                        DashboardHero(summary: summary),
                        const SizedBox(height: RunwaySpacing.section),
                        DashboardTodayCard(summary: summary),
                        const SizedBox(height: RunwaySpacing.section),
                        DashboardTop5Card(summary: summary),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-007 · 目标卡即入口（点击进目标阶梯页；零像素改动，
                        // SB-006 golden 基线不受影响）.
                        GestureDetector(
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => GoalPage(db: db),
                            ),
                          ),
                          child: DashboardGoalCard(summary: summary),
                        ),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-016 · 每日收口同区（目标卡之后；确认/微调/跳过三选，估算 source=estimate）.
                        DailyCloseZone(db: db, rows: rows),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-017 · 大额冷静同区（收口之后；只手动大额，仍要买无摩擦）.
                        CooloffZone(db: db),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-018 · 月度小实验同区（冷静之后；7 天打卡，断卡不罚）.
                        ExperimentZone(db: db),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-012 · 预算卡上首页（周报页 BudgetZone 保留；
                        // 口径/禁词/换算零改，仅换宿主位，复用同一 BudgetZone）.
                        BudgetZone(db: db, rows: rows),
                        const SizedBox(height: RunwaySpacing.section),
                        if (rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              '还没有记录，点右下角记第一笔',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              key: const Key('emptyHint'),
                            ),
                          ),
                        for (final Transaction r in rows)
                          Card(
                            child: ListTile(
                              title: Text(
                                '${r.category} · ${formatFen(r.amountFen)}',
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                r.note.isEmpty ? '无备注' : r.note,
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: '编辑',
                                    onPressed: () => _edit(context, r),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: '删除',
                                    onPressed: () => db.deleteOne(r.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        tooltip: '记一笔',
        child: const Icon(Icons.add),
      ),
    );
  }
}
