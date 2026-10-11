import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/experiment_dao.dart';
import '../logic/entry.dart';
import '../logic/experiment.dart';
import 'theme/tokens.dart';

// SB-018 · 月度小实验卡（PRD §2 改变层；DESIGN §1 地面+浮起 / §7 得到框架）.
// 每月一个 7 天实验（建议库 8 + 自设走模板名输入）；每日 3 秒打卡（同天幂等）.
// 断卡不惩罚只如实显示；完成省出经 SB-007 价格表换算 + 落一张实验成就.
// 开关默认开可关；形状只用 r16（内容卡）；颜色只用 tokens.
// 本文件零裸时长/曲线（无动画，纯展示 + 落库）；成就复用 SB-008（禁新造动效）.

class ExperimentSelectCard extends StatelessWidget {
  const ExperimentSelectCard({
    super.key,
    required this.templates,
    required this.selectedId,
    required this.onSelect,
    required this.onStart,
  });

  final List<ExperimentTemplate> templates;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback? onStart;

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
              '月度小实验 · 选一个',
              style: theme.textTheme.titleMedium,
              key: const Key('experimentTitle'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final ExperimentTemplate t in templates)
                  ChoiceChip(
                    label: Text('${t.name} · ¥${formatFen(t.dailySaveFen)}/天'),
                    selected: selectedId == t.id,
                    key: Key('experimentTpl-${t.id}'),
                    onSelected: (_) => onSelect(t.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onStart,
              key: const Key('experimentStart'),
              child: const Text('开始 7 天实验'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExperimentActiveCard extends StatelessWidget {
  const ExperimentActiveCard({
    super.key,
    required this.name,
    required this.checked,
    required this.elapsed,
    required this.savedFen,
    required this.finished,
    this.onCheckIn,
  });

  final String name;
  final int checked;
  final int elapsed;
  final int savedFen;
  final bool finished;
  final VoidCallback? onCheckIn;

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
              finished ? '小实验 · 已完成' : '小实验 · $name',
              style: theme.textTheme.titleMedium,
              key: const Key('experimentTitle'),
            ),
            const SizedBox(height: 8),
            Text(
              experimentProgressText(checked: checked, elapsed: elapsed),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              key: const Key('experimentProgress'),
            ),
            const SizedBox(height: 4),
            Text(
              experimentResultText(savedFen: savedFen),
              style: theme.textTheme.bodySmall,
              key: finished
                  ? const Key('experimentResult')
                  : const Key('experimentHint'),
            ),
            if (!finished) ...<Widget>[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onCheckIn,
                key: const Key('experimentCheckIn'),
                child: const Text('今日打卡（3 秒）'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 实验同区（首页大额冷静之后；数据源 experiments + achievements）.
class ExperimentZone extends StatefulWidget {
  const ExperimentZone({super.key, required this.db});

  final AppDb db;

  @override
  State<ExperimentZone> createState() => _ExperimentZoneState();
}

class _ExperimentZoneState extends State<ExperimentZone> {
  String _selectedId = 'no-milk-tea';
  final Set<int> _finishingIds = <int>{};

  Future<void> _start(ExperimentPlan plan) async {
    await widget.db.startExperiment(
      templateId: plan.templateId,
      name: plan.name,
      dailySaveFen: plan.dailySaveFen,
      startDate: plan.startDate,
    );
  }

  Future<void> _checkIn(Experiment row, int dayIndex) async {
    await widget.db.checkInExperiment(id: row.id, dayIndex: dayIndex);
  }

  /// 完结：落 done + 一张实验成就（省出>0 才落；幂等防重）.
  Future<void> _finish(Experiment row, int savedFen) async {
    await widget.db.finishExperiment(row.id);
    final int goalId = experimentGoalId(row.id);
    final List<Achievement> has = await widget.db.listAchievements();
    for (final Achievement a in has) {
      if (a.goalId == goalId) return;
    }
    if (savedFen <= 0) return;
    await widget.db.insertAchievement(
      AchievementsCompanion(
        goalId: Value(goalId),
        goalName: Value(experimentAchievementName(row.name)),
        targetFen: Value(savedFen),
        convertibleFen: Value(savedFen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.db.watchExperimentEnabled(),
      builder: (ectx, esnap) {
        final bool enabled = esnap.data ?? true;
        return StreamBuilder<List<Experiment>>(
          stream: widget.db.watchExperiments(),
          builder: (ctx, snap) {
            final List<Experiment> rows = snap.data ?? <Experiment>[];
            Experiment? active;
            for (final Experiment e in rows) {
              if (e.status == 'active') {
                active = e;
                break;
              }
            }
            final DateTime now = DateTime.now();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '月度小实验',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Switch(
                      value: enabled,
                      key: const Key('experimentSwitch'),
                      onChanged: (bool v) => widget.db.setExperimentEnabled(v),
                    ),
                  ],
                ),
                if (!enabled)
                  const SizedBox.shrink()
                else if (active == null)
                  ExperimentSelectCard(
                    templates: experimentLibrary(),
                    selectedId: _selectedId,
                    onSelect: (String id) => setState(() => _selectedId = id),
                    onStart: () {
                      final ExperimentPlan plan = resolveExperimentPlan(
                        templateId: _selectedId,
                        startDate: now,
                      );
                      _start(plan);
                    },
                  )
                else ...<Widget>[
                  Builder(
                    builder: (BuildContext bctx) {
                      final Experiment row = active!;
                      final Set<int> days = decodeCheckIns(row.checkIns);
                      final int idx = dayIndexFor(
                        date: now,
                        startDate: row.startDate,
                      );
                      final int elapsed = elapsedDays(
                        startDate: row.startDate,
                        now: now,
                      );
                      final int saved = experimentSavedFen(
                        dailySaveFen: row.dailySaveFen,
                        checkedCount: days.length,
                      );
                      final bool finished = isExperimentFinished(
                        startDate: row.startDate,
                        now: now,
                      );
                      if (finished && !_finishingIds.contains(row.id)) {
                        _finishingIds.add(row.id);
                        _finish(row, saved);
                      }
                      return ExperimentActiveCard(
                        name: row.name,
                        checked: days.length,
                        elapsed: elapsed,
                        savedFen: saved,
                        finished: finished,
                        onCheckIn: idx < 0 || days.contains(idx)
                            ? null
                            : () => _checkIn(row, idx),
                      );
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
