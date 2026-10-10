import 'package:flutter/material.dart';

import '../logic/achievement.dart';
import '../logic/entry.dart';
import 'theme/app_theme.dart';
import 'theme/motion_spec.dart';
import 'theme/tokens.dart';

// SB-008 · 成就卡（PRD §2 成就卡；DESIGN §5 成就时刻唯一允许表演 + §6 动效规格）.
// 动效一律走 MotionSpec 常量（成就 1200ms 规格内）；本文件零裸时长/曲线.
// 形状只用 r22（主卡）/ r10（内层）；颜色只用 tokens（hero 渐变 + 暖金一处）；
// 文案全量"得到"框架（§7），零亏欠表述；数字 tabular（§1.4）.

/// 成就卡帧（golden 用）：popup=弹出帧（粒子可见）/ still=静帧（沉稳态）.
enum AchievementFrame { popup, still }

/// 静态成就卡（golden/收藏页复用；无动画，帧确定）.
class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.goalName,
    required this.targetFen,
    required this.convertibleFen,
    required this.tier,
    this.frame = AchievementFrame.still,
  });

  final String goalName;
  final int targetFen;
  final int convertibleFen;
  final String tier;
  final AchievementFrame frame;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = achievementTitle(goalName: goalName, tier: tier);
    final String body = achievementBody(
      convertibleFen: convertibleFen,
      targetFen: targetFen,
    );
    return RepaintBoundary(
      child: Container(
        key: const Key('achievementCard'),
        decoration: AppTheme.heroCard(),
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(RunwayRadius.control),
                    color: RunwayHero.goldAccent.withValues(alpha: 0.18),
                    border: Border.all(
                      color: RunwayHero.goldAccent.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 19,
                    color: RunwayHero.goldAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: RunwayHero.goldAccent,
                    ),
                    key: const Key('achievementTitle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '攒出 ${formatFen(targetFen)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: RunwayHero.number,
              ),
              key: const Key('achievementAmount'),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: RunwayHero.sub,
              ),
              key: const Key('achievementBody'),
            ),
            if (frame == AchievementFrame.popup) ...<Widget>[
              const SizedBox(height: 8),
              _ParticlesRow(count: MotionSpec.particlesMax - 4),
            ],
          ],
        ),
      ),
    );
  }
}

/// 粒子行（≤12 颗；数量走 MotionSpec.particlesMax 派生，唯一允许过冲的点缀）.
class _ParticlesRow extends StatelessWidget {
  const _ParticlesRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final int n = count > MotionSpec.particlesMax
        ? MotionSpec.particlesMax
        : count;
    return Row(
      key: const Key('achievementParticles'),
      children: <Widget>[
        for (int i = 0; i < n; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: RunwayHero.goldAccent,
              ),
            ),
          ),
      ],
    );
  }
}

/// 弹出动效（1200ms 规格内 + easeOutBack 唯一允许过冲；可打断重定向）.
class AchievementPop extends StatefulWidget {
  const AchievementPop({
    super.key,
    required this.goalName,
    required this.targetFen,
    required this.convertibleFen,
    required this.tier,
  });

  final String goalName;
  final int targetFen;
  final int convertibleFen;
  final String tier;

  @override
  State<AchievementPop> createState() => _AchievementPopState();
}

class _AchievementPopState extends State<AchievementPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final bool reduce = MediaQuery.of(context).disableAnimations;
    _ctrl = AnimationController(
      vsync: this,
      duration: reduce ? MotionSpec.reducedMotion : MotionSpec.achievement,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: MotionSpec.fabCurve);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.7, end: 1).animate(_scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AchievementCard(
            goalName: widget.goalName,
            targetFen: widget.targetFen,
            convertibleFen: widget.convertibleFen,
            tier: widget.tier,
            frame: AchievementFrame.popup,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            key: const Key('achievementClose'),
            child: const Text('收下这份底气'),
          ),
        ],
      ),
    );
  }
}

/// 本会话即弹（含补弹）：调用方保证一 goal 一次；返回 true=已庆祝.
Future<bool> showAchievementDialog(
  BuildContext context, {
  required String goalName,
  required int targetFen,
  required int convertibleFen,
  required String tier,
}) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AchievementPop(
        goalName: goalName,
        targetFen: targetFen,
        convertibleFen: convertibleFen,
        tier: tier,
      ),
    ),
  );
  return ok ?? true;
}
