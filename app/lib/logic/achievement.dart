// SB-008 · 成就解锁检测（PRD §2 成就卡；DESIGN §7 得到框架，纯 Dart）.
// 口径：目标达成 = 可换算省出 >= 目标额（复用 goal_ladder.computeGoal 口径）.
// 触发语义：本会话内达成即弹；错过（已达成但无成就行）在下次打开补弹一次；
// 庆祝即落库（achievements 表一行），落库后不再弹.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'entry.dart';
import 'goal_ladder.dart';

/// 禁词表（得到框架；与 SB-007 一致，成就文案零命中）.
const List<String> achievementBannedWords = <String>[
  '又花掉',
  '只剩',
  '还差',
  '超支',
  '别买',
  '不该',
];

/// 待庆祝的解锁（纯值对象，便于单测）.
class AchievementPending {
  const AchievementPending({
    required this.goalId,
    required this.goalName,
    required this.targetFen,
    required this.convertibleFen,
    required this.tier,
  });

  final int goalId;
  final String goalName;
  final int targetFen;
  final int convertibleFen;
  final String tier;
}

/// 单目标是否达成（目标额须 >0）.
bool isGoalUnlocked({required int convertibleFen, required int targetFen}) {
  if (targetFen <= 0) return false;
  return convertibleFen >= targetFen;
}

/// 从多目标中挑出"已达成但尚未庆祝"的（celebratedGoalIds 为 achievements 表已有 goalId 集合）.
List<AchievementPending> detectUnlocks({
  required List<AchievementPending> candidates,
  required Set<int> celebratedGoalIds,
}) {
  final List<AchievementPending> out = <AchievementPending>[];
  for (final AchievementPending c in candidates) {
    if (celebratedGoalIds.contains(c.goalId)) continue;
    if (!isGoalUnlocked(
      convertibleFen: c.convertibleFen,
      targetFen: c.targetFen,
    )) {
      continue;
    }
    out.add(c);
  }
  return out;
}

/// 会话内去重（本会话同 goal 只弹一次；进程常驻即会话）.
class AchievementSession {
  final Set<int> _shown = <int>{};

  /// 未弹过 → true（并标记）；已弹过 → false.
  bool claim(int goalId) {
    if (_shown.contains(goalId)) return false;
    _shown.add(goalId);
    return true;
  }

  bool shown(int goalId) => _shown.contains(goalId);

  /// 测试复位（单测隔离用；生产不调用）.
  void resetForTest() => _shown.clear();

  /// 进程级单例（GoalPage 常驻复用）.
  static final AchievementSession global = AchievementSession();
}

/// 成就标题（得到框架：只报得到，无行动召唤）.
String achievementTitle({required String goalName, required String tier}) {
  return '已攒够 $goalName · 得到${zoneWord(tier)}';
}

/// 阶梯赠语（得到框架；tier 为空回到底气）.
String zoneWord(String tier) {
  if (tier.trim().isEmpty) return '阶段性底气';
  return '$tier底气';
}

/// 成就正文（得到框架；大额只陈述）.
String achievementBody({required int convertibleFen, required int targetFen}) {
  final String equiv = equivalentOf(convertibleFen);
  return '攒出 ${formatAmount(targetFen)} · $equiv';
}

/// 金额分 → 元串（复用 goal_ladder.formatFen 口径，避免 logic 重复实现）.
String formatAmount(int fen) => formatFen(fen);

/// 分享配文（得到框架；截图导出时配文用）.
String shareCaption({required String goalName}) {
  return '用攒够攒出 $goalName · 稳步积累的证明';
}
