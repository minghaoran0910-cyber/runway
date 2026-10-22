import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_db.dart';
import '../logic/dashboard_stats.dart';
import '../logic/goal_deadline.dart';
import '../logic/goal_ladder.dart';
import 'achievement_gate.dart';
import 'achievements_page.dart';
import 'budget_card.dart';
import 'cooloff_card.dart';
import 'daily_close_sheet.dart';
import 'dashboard_cards.dart';
import 'diagnostics_card.dart';
import 'experiment_card.dart';
import 'goal_card.dart';
import 'goal_editor.dart';
import 'goal_timeline.dart';
import 'grain_card.dart';
import 'runway_icons.dart';
import 'settings_page.dart';
import 'weekly_page.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-007 · 目标设定页（PRD §2 攒到层入口；进度组件见 goal_card.dart）.
// SB-009 · 余粮同区展示（GrainReserveCard 复用目标区视觉语言，不另造轮子）+ 周报入口.
// SB-040 · 页标题改为"我的"（设置的家不再挂目标的牌）+ 设置入口；空态加
// "设一个试试"按钮（点即表单）；换算行可点选单价（预设+目标价）；空列表不渲
// 染白卡（修空白卡 bug）；编辑器拆至 goal_editor.dart（保单文件 ≤400）.
// SB-041 · 编辑器拆至 goal_editor.dart（保单文件 ≤400）；期限直存 goals.deadline
// （v12，浩然裁 C 解冻）；目标卡期限行见 goal_timeline.dart.
// 形状只用 r16（内容卡）；分隔仅 hairline；数字 tabular（§1.4）；
// 颜色只用 tokens；文案全量"得到"框架（§7），零亏欠表述.
// 进度数据源为 SB-004 transactions（watchAll 实时联动）；目标持久化于 goals 表.

class GoalPage extends StatefulWidget {
  const GoalPage({super.key, required this.db, this.showFab = true});

  final AppDb db;
  final bool showFab;

  @override
  State<GoalPage> createState() => GoalPageState();
}

class GoalPageState extends State<GoalPage> {
  /// 换算单价覆盖（SB-040：点换算行选单价；null=用当前目标价）.
  PriceRef? priceOverride;

  Future<void> _openEditor(BuildContext context, {Goal? goal}) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => GoalDialog(
        goal: goal,
        db: widget.db,
        onSave: (BuildContext dctx, GoalForm form) async {
          // SB-042 · 仅真实落库才关对话框；校验失败/异常保持打开.
          final bool ok = await _saveDialog(dctx, form, goal);
          if (ok && dctx.mounted) Navigator.of(dctx).pop(true);
        },
      ),
    );
    if (saved == true && context.mounted) {
      // SB-044 · 保存成功触觉（§6：记一笔/存目标 .light）.
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(goal == null ? '已定下新目标' : '目标已更新')),
      );
    }
  }

  /// SB-042 · true=真实落库（含期限直存），false=校验失败/异常（对话框保持打开）.
  Future<bool> _saveDialog(
    BuildContext context,
    GoalForm form,
    Goal? goal,
  ) async {
    final String? err = validateGoal(
      name: form.name,
      targetFen: form.targetFen,
      priceName: form.priceName,
      priceFen: form.priceFen,
    );
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return false;
    }
    final String? dErr = validateDeadlineDate(form.deadline ?? '');
    if (dErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dErr)));
      return false;
    }
    try {
      if (goal == null) {
        await widget.db.insertGoal(
          GoalsCompanion(
            name: Value(form.name.trim()),
            targetFen: Value(form.targetFen!),
            priceName: Value(form.priceName.trim()),
            priceFen: Value(form.priceFen!),
            tier: Value(ladderNameFor(form.targetFen!)),
            deadline: Value(form.deadline),
          ),
        );
      } else {
        await widget.db.updateGoal(
          GoalsCompanion(
            id: Value(goal.id),
            name: Value(form.name.trim()),
            targetFen: Value(form.targetFen!),
            priceName: Value(form.priceName.trim()),
            priceFen: Value(form.priceFen!),
            tier: Value(ladderNameFor(form.targetFen!)),
            doneAt: Value(goal.doneAt),
            deadline: Value(form.deadline),
            createdAt: Value(goal.createdAt),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
      }
      return false;
    }
    return true;
  }

  Future<void> _pickPrice(BuildContext context, PriceRef current) async {
    final List<Goal> goals = await widget.db.listGoals();
    if (!context.mounted) return;
    final PriceRef? sel = await pickConvertPrice(
      context,
      current: current,
      goals: goals,
    );
    if (sel != null && context.mounted) {
      setState(() => priceOverride = sel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: <Widget>[
          IconButton(
            icon: const RunwayIcon(RunwayIconKind.settings),
            tooltip: '设置',
            key: const Key('settingsEntry'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => SettingsPage(db: widget.db),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Goal>>(
          stream: widget.db.watchGoals(),
          builder: (BuildContext ctx, AsyncSnapshot<List<Goal>> gsnap) {
            final List<Goal> goals = gsnap.data ?? <Goal>[];
            final Goal? active = goals.isEmpty ? null : goals.first;
            return StreamBuilder<List<Transaction>>(
              stream: widget.db.watchAll(),
              builder:
                  (BuildContext ctx2, AsyncSnapshot<List<Transaction>> tsnap) {
                    final List<Transaction> rows =
                        tsnap.data ?? <Transaction>[];
                    final DateTime now = DateTime.now();
                    final ({int lastMonthSpendFen, int monthSpendFen}) sums =
                        sumMonthSpend(rows, now);
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
                      now: now,
                      goalFen: active?.targetFen,
                    );
                    final PriceRef price =
                        priceOverride ??
                        (active == null
                            ? const PriceRef(name: '奶茶', fen: 1800)
                            : PriceRef(
                                name: active.priceName,
                                fen: active.priceFen,
                              ));
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        RunwaySpacing.page,
                        RunwaySpacing.page,
                        RunwaySpacing.page,
                        96,
                      ), // SB-044 · 底部 96 避开 FAB 遮挡
                      children: <Widget>[
                        DashboardGoalCard(summary: summary),
                        const SizedBox(height: RunwaySpacing.section),
                        if (active == null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                RunwaySpacing.cardInner,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '实物换算',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '定第一个目标，开始攒出奶茶',
                                    style: theme.textTheme.bodyMedium,
                                    key: const Key('goalEmpty'),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: () => _openEditor(context),
                                    key: const Key('goalEmptyAdd'),
                                    child: const Text('设一个试试'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            key: const Key('goalPricePick'),
                            onTap: () => _pickPrice(context, price),
                            child: GoalProgressCard(
                              targetFen: active.targetFen,
                              price: price,
                              monthSpendFen: sums.monthSpendFen,
                              lastMonthSpendFen: sums.lastMonthSpendFen,
                            ),
                          ),
                        // SB-008 · 达成态才出现的收藏入口（非达成零像素改动，
                        // SB-007 golden 基线不受影响）.
                        if (active != null &&
                            computeGoal(
                              monthSpendFen: sums.monthSpendFen,
                              lastMonthSpendFen: sums.lastMonthSpendFen,
                              targetFen: active.targetFen,
                            ).done)
                          TextButton(
                            onPressed: () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => AchievementsPage(db: widget.db),
                              ),
                            ),
                            key: const Key('goalToAchievements'),
                            child: const Text('查看成就收藏'),
                          ),
                        AchievementGate(db: widget.db),
                        const SizedBox(height: RunwaySpacing.section),
                        GrainZone(db: widget.db, rows: rows),
                        TextButton(
                          onPressed: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => WeeklyPage(db: widget.db),
                            ),
                          ),
                          key: const Key('goalToWeekly'),
                          child: const Text('看本周周报'),
                        ),
                        const SizedBox(height: RunwaySpacing.section),
                        Text(
                          '全部目标 ${goals.length} 个 · 首个为当前目标',
                          style: theme.textTheme.bodySmall,
                          key: const Key('goalCount'),
                        ),
                        const SizedBox(height: 8),
                        // SB-030 · 目标纵向时间线（demo 清单④；未达成 tabular
                        // "¥现攒/¥目标"，达成琥珀"✓ 已攒够·N周"；N=自建起整周）.
                        // SB-040 · 空列表不渲染白卡（修"全部目标 0 个"下方
                        // 空白卡 bug；空态已有上方设目标卡承接）.
                        if (goals.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                RunwaySpacing.cardInner,
                              ),
                              child: GoalTimeline(
                                goals: goals,
                                convertibleFen: computeGoal(
                                  monthSpendFen: sums.monthSpendFen,
                                  lastMonthSpendFen: sums.lastMonthSpendFen,
                                ).convertibleFen,
                                now: now,
                                onEdit: (Goal g) =>
                                    _openEditor(context, goal: g),
                                onDelete: (Goal g) =>
                                    widget.db.deleteGoal(g.id),
                              ),
                            ),
                          ),
                        // SB-034 · 诊断回传开关行（仅 debug + 已配置可见；
                        // 默认未注入 = 零像素，golden 不动）.
                        const SizedBox(height: RunwaySpacing.section),
                        // SB-038 · 首页搬家区（只搬家不删除：每日收口/大额冷静/
                        // 月度小实验/预算观察；口径零改，复用同一 Zone；
                        // 040 合入轮随 StatefulWidget 改挂 widget.db）.
                        DailyCloseZone(db: widget.db, rows: rows),
                        const SizedBox(height: RunwaySpacing.section),
                        CooloffZone(db: widget.db),
                        const SizedBox(height: RunwaySpacing.section),
                        ExperimentZone(db: widget.db),
                        const SizedBox(height: RunwaySpacing.section),
                        BudgetZone(db: widget.db, rows: rows),
                        const DiagnosticsSection(),
                      ],
                    );
                  },
            );
          },
        ),
      ),
      floatingActionButton: widget.showFab
          ? FloatingActionButton(
              onPressed: () => _openEditor(context),
              tooltip: '定目标',
              key: const Key('goalAdd'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
