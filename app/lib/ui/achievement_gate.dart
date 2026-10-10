import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/achievement.dart';
import '../logic/goal_ladder.dart';
import 'achievement_card.dart';
import 'goal_card.dart';

// SB-008 · 解锁即弹门（本会话内达成即弹；错过下次打开补弹一次）.
// 零像素（SizedBox.shrink）；落库即庆祝，落库后不再弹；会话内同 goal 只弹一次.
// 达成同时回写 goals.doneAt（闭环 SB-007 D4）+ 落 achievements 一行.

class AchievementGate extends StatefulWidget {
  const AchievementGate({super.key, required this.db});

  final AppDb db;

  @override
  State<AchievementGate> createState() => _AchievementGateState();
}

class _AchievementGateState extends State<AchievementGate> {
  final Set<int> _handling = <int>{};

  Future<void> _celebrate(AchievementPending p) async {
    if (!AchievementSession.global.claim(p.goalId)) return;
    final DateTime now = DateTime.now();
    final List<Goal> goals = await widget.db.listGoals();
    Goal? goal;
    for (final Goal g in goals) {
      if (g.id == p.goalId) goal = g;
    }
    await widget.db.insertAchievement(
      AchievementsCompanion(
        goalId: Value(p.goalId),
        goalName: Value(p.goalName),
        targetFen: Value(p.targetFen),
        convertibleFen: Value(p.convertibleFen),
        tier: Value(p.tier),
        unlockedAt: Value(now),
      ),
    );
    if (goal != null) {
      await widget.db.updateGoal(
        GoalsCompanion(
          id: Value(goal.id),
          name: Value(goal.name),
          targetFen: Value(goal.targetFen),
          priceName: Value(goal.priceName),
          priceFen: Value(goal.priceFen),
          tier: Value(p.tier),
          doneAt: Value(now),
          createdAt: Value(goal.createdAt),
        ),
      );
    }
    if (!mounted) return;
    await showAchievementDialog(
      context,
      goalName: p.goalName,
      targetFen: p.targetFen,
      convertibleFen: p.convertibleFen,
      tier: p.tier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Goal>>(
      stream: widget.db.watchGoals(),
      builder: (BuildContext c, AsyncSnapshot<List<Goal>> gsnap) {
        final List<Goal> goals = gsnap.data ?? <Goal>[];
        return StreamBuilder<List<Transaction>>(
          stream: widget.db.watchAll(),
          builder: (BuildContext c2, AsyncSnapshot<List<Transaction>> tsnap) {
            final List<Transaction> rows = tsnap.data ?? <Transaction>[];
            final ({int lastMonthSpendFen, int monthSpendFen}) sums =
                sumMonthSpend(rows, DateTime.now());
            return StreamBuilder<List<Achievement>>(
              stream: widget.db.watchAchievements(),
              builder:
                  (BuildContext c3, AsyncSnapshot<List<Achievement>> asnap) {
                    final Set<int> celebrated = <int>{
                      for (final Achievement a
                          in (asnap.data ?? <Achievement>[]))
                        a.goalId,
                    };
                    final List<AchievementPending> candidates =
                        <AchievementPending>[
                          for (final Goal g in goals)
                            AchievementPending(
                              goalId: g.id,
                              goalName: g.name,
                              targetFen: g.targetFen,
                              convertibleFen: computeGoal(
                                monthSpendFen: sums.monthSpendFen,
                                lastMonthSpendFen: sums.lastMonthSpendFen,
                                targetFen: g.targetFen,
                              ).convertibleFen,
                              tier: ladderNameFor(g.targetFen),
                            ),
                        ];
                    final List<AchievementPending> pending = detectUnlocks(
                      candidates: candidates,
                      celebratedGoalIds: celebrated,
                    );
                    for (final AchievementPending p in pending) {
                      if (_handling.contains(p.goalId)) continue;
                      if (AchievementSession.global.shown(p.goalId)) continue;
                      _handling.add(p.goalId);
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        try {
                          await _celebrate(p);
                        } finally {
                          _handling.remove(p.goalId);
                        }
                      });
                    }
                    return const SizedBox.shrink(key: Key('achGate'));
                  },
            );
          },
        );
      },
    );
  }
}
