import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/dashboard_stats.dart';
import '../logic/entry.dart';
import '../logic/goal_ladder.dart';
import 'achievement_gate.dart';
import 'achievements_page.dart';
import 'dashboard_cards.dart';
import 'goal_card.dart';
import 'goal_price_follow.dart';
import 'grain_card.dart';
import 'weekly_page.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-007 · 目标设定页（PRD §2 攒到层入口；进度组件见 goal_card.dart）.
// SB-009 · 余粮同区展示（GrainReserveCard 复用目标区视觉语言，不另造轮子）+ 周报入口.
// 形状只用 r16（内容卡）；分隔仅 hairline；数字 tabular（§1.4）；
// 颜色只用 tokens；文案全量"得到"框架（§7），零亏欠表述.
// 进度数据源为 SB-004 transactions（watchAll 实时联动）；目标持久化于 goals 表.
// SB-006 看板叠加：顶部复用 DashboardGoalCard（传真实 goalFen，闭环 SB-006 D1）.

class GoalPage extends StatelessWidget {
  const GoalPage({super.key, required this.db, this.showFab = true});

  final AppDb db;
  final bool showFab;

  Future<void> _openEditor(BuildContext context, {Goal? goal}) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => _GoalDialog(
        goal: goal,
        db: db,
        onSave: (BuildContext dctx, _GoalForm form) async {
          await _saveDialog(dctx, form, goal);
          if (dctx.mounted) Navigator.of(dctx).pop(true);
        },
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(goal == null ? '已定下新目标' : '目标已更新')),
      );
    }
  }

  Future<void> _saveDialog(
    BuildContext context,
    _GoalForm form,
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
      return;
    }
    if (goal == null) {
      await db.insertGoal(
        GoalsCompanion(
          name: Value(form.name.trim()),
          targetFen: Value(form.targetFen!),
          priceName: Value(form.priceName.trim()),
          priceFen: Value(form.priceFen!),
          tier: Value(ladderNameFor(form.targetFen!)),
        ),
      );
    } else {
      await db.updateGoal(
        GoalsCompanion(
          id: Value(goal.id),
          name: Value(form.name.trim()),
          targetFen: Value(form.targetFen!),
          priceName: Value(form.priceName.trim()),
          priceFen: Value(form.priceFen!),
          tier: Value(ladderNameFor(form.targetFen!)),
          doneAt: Value(goal.doneAt),
          createdAt: Value(goal.createdAt),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('目标阶梯')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Goal>>(
          stream: db.watchGoals(),
          builder: (BuildContext ctx, AsyncSnapshot<List<Goal>> gsnap) {
            final List<Goal> goals = gsnap.data ?? <Goal>[];
            final Goal? active = goals.isEmpty ? null : goals.first;
            return StreamBuilder<List<Transaction>>(
              stream: db.watchAll(),
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
                    return ListView(
                      padding: const EdgeInsets.all(RunwaySpacing.page),
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
                                ],
                              ),
                            ),
                          )
                        else
                          GoalProgressCard(
                            targetFen: active.targetFen,
                            price: PriceRef(
                              name: active.priceName,
                              fen: active.priceFen,
                            ),
                            monthSpendFen: sums.monthSpendFen,
                            lastMonthSpendFen: sums.lastMonthSpendFen,
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
                                builder: (_) => AchievementsPage(db: db),
                              ),
                            ),
                            key: const Key('goalToAchievements'),
                            child: const Text('查看成就收藏'),
                          ),
                        AchievementGate(db: db),
                        const SizedBox(height: RunwaySpacing.section),
                        GrainZone(db: db, rows: rows),
                        TextButton(
                          onPressed: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => WeeklyPage(db: db),
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
                        for (final Goal g in goals)
                          Card(
                            child: ListTile(
                              title: Text(
                                '${g.name} · ${formatFen(g.targetFen)}',
                                style: theme.textTheme.titleMedium,
                                key: Key('goalItem-${g.id}'),
                              ),
                              subtitle: Text(
                                '单价 ${g.priceName} ${formatFen(g.priceFen)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: '编辑',
                                    key: Key('goalEdit-${g.id}'),
                                    onPressed: () =>
                                        _openEditor(context, goal: g),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: '删除',
                                    key: Key('goalDelete-${g.id}'),
                                    onPressed: () => db.deleteGoal(g.id),
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
      floatingActionButton: showFab
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

class _GoalForm {
  String name = '';
  int? targetFen;
  String priceName = '奶茶';
  int? priceFen = 1800;
  String followKey = '';
}

/// 目标设定对话框（名称/目标额/参考单价；内置单价 chips 一键填入，可自定义改）.
/// SB-020 · 常买跟随（可选）：填"类目｜备注"键取中位数填入单价；
/// 填入后仍可手改，手改即锁定优先；换算引擎零改动（复用 SB-007）.
class _GoalDialog extends StatefulWidget {
  const _GoalDialog({this.goal, this.db, this.onSave});

  final Goal? goal;
  final AppDb? db;
  final Future<void> Function(BuildContext ctx, _GoalForm form)? onSave;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _priceName;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.goal?.name ?? '');
    _target = TextEditingController(
      text: widget.goal == null ? '' : formatFen(widget.goal!.targetFen),
    );
    _priceName = TextEditingController(text: widget.goal?.priceName ?? '奶茶');
    _price = TextEditingController(
      text: widget.goal == null ? '18' : formatFen(widget.goal!.priceFen),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _priceName.dispose();
    _price.dispose();
    super.dispose();
  }

  void _pickPrice(PriceRef p) {
    setState(() {
      _priceName.text = p.name;
      _price.text = formatFen(p.fen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? '定一个目标' : '编辑目标'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: '目标名（如攒手机）'),
              maxLength: 32,
              key: const Key('goalName'),
            ),
            TextField(
              controller: _target,
              decoration: const InputDecoration(labelText: '目标金额（元）'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              key: const Key('goalTarget'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final PriceRef p in defaultPrices)
                  ChoiceChip(
                    label: Text('${p.name}${formatFen(p.fen)}'),
                    selected: _priceName.text == p.name,
                    onSelected: (_) => _pickPrice(p),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceName,
              decoration: const InputDecoration(labelText: '参考单价名（可自定义）'),
              maxLength: 16,
              key: const Key('goalPriceName'),
            ),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: '参考单价（元）'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              key: const Key('goalPrice'),
            ),
            const SizedBox(height: 8),
            GoalFollowField(
              db: widget.db,
              onPick: (int medianFen, String noteName) {
                setState(() {
                  _price.text = formatFen(medianFen);
                  _priceName.text = noteName;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final _GoalForm form = _GoalForm()
              ..name = _name.text
              ..targetFen = parseAmountToFen(_target.text)
              ..priceName = _priceName.text
              ..priceFen = parseAmountToFen(_price.text);
            if (widget.onSave != null) {
              await widget.onSave!(context, form);
            } else {
              Navigator.of(context).pop(false);
            }
          },
          key: const Key('goalSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
