import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/budget_dao.dart';
import '../data/category_role_dao.dart';
import '../logic/budget.dart';
import '../logic/dashboard_stats.dart';
import '../logic/entry.dart';
import '../logic/estimate.dart';
import '../logic/role_resolver.dart';
import '../logic/week_warm.dart';
import 'dashboard_cards.dart';
import 'pending_page.dart';
import 'quick_add_page.dart';
import 'runway_icons.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'today_saved_row.dart';

// SB-004 · 主屏（记录列表可查/可改/可删；重开 App 数据仍在，文件库持久化）.
// SB-006 · 首页看板四区（Hero/今日/Top5/目标）+ 原记录列表保留.
// SB-007 · 目标入口 + goals 表真实 goalFen 供数（闭环 SB-006 D1 目标未持久化）.
// SB-010 · 待确认入口（图标按钮进 PendingListPage；零像素改动，既有 golden 不受影响）.
// Hero 主卡沿 §3（AppTheme.heroCard）；列表行分隔仅用 hairline（§1.3）.
// SB-038 · 首页大扫除定稿：只留 Hero 跑道环 + 今日/月卡 + 最近 3 笔 + 记一笔 FAB；
// 每日收口/大额冷静/月度小实验/预算观察已搬去 GoalPage（我的），类目 Top5/目标卡
// 信息分别由账本页/我的页承载（功能只搬家不删除）；顶栏只留通知导入.

class HomePage extends StatelessWidget {
  // SB-027 · showFab=false 供 RootShell 嵌入时隐藏内层记一笔 FAB
  //（外层统一 FAB，避免双 FAB 重叠；独立泵测默认 true，golden 零影响）.
  const HomePage({super.key, required this.db, this.showFab = true});

  final AppDb db;
  final bool showFab;

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
            icon: const RunwayIcon(RunwayIconKind.inbox),
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
          // SB-038 · 类目管理入口下线：账本 Tab 即类目管理页，不再占顶栏.
        ],
      ),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Goal>>(
          stream: db.watchGoals(),
          builder: (BuildContext gctx, AsyncSnapshot<List<Goal>> gsnap) {
            final List<Goal> goals = gsnap.data ?? <Goal>[];
            final int? goalFen = goals.isEmpty ? null : goals.first.targetFen;
            // SB-029 · hero 标题用首个目标名（无目标回落"本月支出"）.
            final String? goalName = goals.isEmpty ? null : goals.first.name;
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
                        DashboardHero(summary: summary, goalName: goalName),
                        const SizedBox(height: RunwaySpacing.section),
                        DashboardTodayCard(summary: summary),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-038-RC1追补 · 裁A硬约束（2026-10-14 21:34）：「今天攒出」
                        // 日载体行必须常驻首页，不得并入月累计环.口径复用 SB-016，
                        // 零日温度线（SB-022）一并透传；收口问句仍留我的页.
                        _HomeTodaySaved(db: db, rows: rows),
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-038 · 最近 3 笔（全量列表搬去账本页；首页只答"我攒到哪了"）.
                        Text(
                          '最近 3 笔',
                          style: theme.textTheme.titleMedium,
                          key: const Key('recentTitle'),
                        ),
                        const SizedBox(height: 8),
                        if (rows.isEmpty)
                          Padding(
                            // SB-045 ④ · 裸 24 收 token（section=24 同值）.
                            padding: const EdgeInsets.only(
                              top: RunwaySpacing.section,
                            ),
                            child: Text(
                              '还没有记录，点右下角记第一笔',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              key: const Key('emptyHint'),
                            ),
                          ),
                        for (final Transaction r in rows.take(3))
                          Card(
                            child: ListTile(
                              title: Text(
                                '${r.category} · ${formatFenYuan(r.amountFen)}',
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
                        // SB-029 · "示例数据"页底浅灰水印（演示物料标注 §8.4；
                        // 装饰文本不承载信息：文字级 token 降淡（§2.3 装饰不设限），
                        // 不用 inkSecondary（§2.1 禁做小字）.
                        Padding(
                          // SB-045 ④ · 裸 24 收 token（sectionHeaderTop=24 同值）.
                          padding: const EdgeInsets.only(
                            top: RunwaySpacing.sectionHeaderTop,
                            bottom: 96,
                          ), // SB-044 · 底部 96 完全避开 FAB
                          child: Text(
                            '示例数据',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  (isDark
                                          ? RunwayDark.inkSecondaryText
                                          : RunwayLight.inkSecondaryText)
                                      .withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
                            key: const Key('homeWatermark'),
                          ),
                        ),
                      ],
                    );
                  },
            );
          },
        ),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => _openAdd(context),
              tooltip: '记一笔',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// SB-038-RC1追补 · 首页日载体（裁A常驻行；数据源 budgets+transactions+roles）.
class _HomeTodaySaved extends StatelessWidget {
  const _HomeTodaySaved({required this.db, required this.rows});

  final AppDb db;
  final List<Transaction> rows;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String key = dateKeyFor(now);
    final List<CloseFlow> flows = <CloseFlow>[
      for (final Transaction r in rows)
        CloseFlow(
          amountFen: r.amountFen,
          occurredAt: r.occurredAt,
          source: r.source,
        ),
    ];
    final int avg = dailyAverage(flows: flows, now: now);
    final List<CloseFlow> today = todayFlowsOf(flows, now);
    final int todaySpend = todaySpendOf(today);
    final List<JoyRow> joy = <JoyRow>[
      for (final Transaction t in rows)
        if (dateKeyFor(t.occurredAt) == key)
          JoyRow(t.amountFen, t.category, t.note, t.source),
    ];
    return StreamBuilder<List<Budget>>(
      stream: db.watchBudgetHistory(monthKeyFor(now)),
      builder: (BuildContext bctx, AsyncSnapshot<List<Budget>> bsnap) {
        final List<Budget> hist = bsnap.data ?? <Budget>[];
        final int monthBudget = hist.isEmpty ? 0 : hist.first.budgetFen;
        final int dailyBudget = dailyBudgetFor(
          monthBudgetFen: monthBudget,
          now: now,
          dailyAvgFen: avg,
        );
        final int saved = computeTodaySaved(
          dailyBudgetFen: dailyBudget,
          todaySpendFen: todaySpend,
        );
        return StreamBuilder<List<RoleOverride>>(
          stream: db.watchCategoryRoles(),
          builder:
              (BuildContext rctx, AsyncSnapshot<List<RoleOverride>> rsnap) {
                final Map<String, CategoryRole> overrides =
                    <String, CategoryRole>{};
                for (final RoleOverride o in rsnap.data ?? <RoleOverride>[]) {
                  final CategoryRole? r = parseRole(o.role);
                  if (r != null) overrides[o.category] = r;
                }
                final WeekRoleSums week = summarizeWeekRoles(
                  flows: rows.map(
                    (Transaction t) => (
                      amountFen: t.amountFen,
                      category: t.category,
                      occurredAt: t.occurredAt,
                    ),
                  ),
                  now: now,
                  overrides: overrides,
                );
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                    child: TodaySavedRow(
                      savedFen: saved,
                      todayCount: today.length,
                      necessaryFen: week.necessaryFen,
                      flexibleFen: week.flexibleFen,
                      fixedFen: week.fixedFen,
                      joyRows: joy,
                      roleOverrides: overrides,
                    ),
                  ),
                );
              },
        );
      },
    );
  }
}
