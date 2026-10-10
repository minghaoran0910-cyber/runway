import 'package:drift/drift.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/ui/theme/motion_spec.dart';

// SB-008 · 成就解锁单测（合成数据，纯 Dart + DAO；≥12 条）.

void main() {
  test('SB-008 达成判定：可换算>=目标即解锁，目标<=0永不解锁', () {
    expect(isGoalUnlocked(convertibleFen: 5000, targetFen: 5000), isTrue);
    expect(isGoalUnlocked(convertibleFen: 6000, targetFen: 5000), isTrue);
    expect(isGoalUnlocked(convertibleFen: 4999, targetFen: 5000), isFalse);
    expect(isGoalUnlocked(convertibleFen: 0, targetFen: 0), isFalse);
    expect(isGoalUnlocked(convertibleFen: 100, targetFen: -5), isFalse);
  });

  test('SB-008 检出：已达成未庆祝才入列', () {
    const AchievementPending c = AchievementPending(
      goalId: 1,
      goalName: '攒手机',
      targetFen: 399900,
      convertibleFen: 400000,
      tier: '手机',
    );
    final List<AchievementPending> out = detectUnlocks(
      candidates: <AchievementPending>[c],
      celebratedGoalIds: <int>{},
    );
    expect(out.length, 1);
    expect(out.first.goalId, 1);
  });

  test('SB-008 检出：已庆祝的不重复弹', () {
    const AchievementPending c = AchievementPending(
      goalId: 1,
      goalName: '攒手机',
      targetFen: 399900,
      convertibleFen: 400000,
      tier: '手机',
    );
    final List<AchievementPending> out = detectUnlocks(
      candidates: <AchievementPending>[c],
      celebratedGoalIds: <int>{1},
    );
    expect(out, isEmpty);
  });

  test('SB-008 检出：未达成的排除，多目标只收达成者', () {
    const AchievementPending done = AchievementPending(
      goalId: 1,
      goalName: '攒手机',
      targetFen: 1000,
      convertibleFen: 2000,
      tier: '奶茶',
    );
    const AchievementPending todo = AchievementPending(
      goalId: 2,
      goalName: '攒5090',
      targetFen: 1649900,
      convertibleFen: 100,
      tier: '5090',
    );
    final List<AchievementPending> out = detectUnlocks(
      candidates: <AchievementPending>[done, todo],
      celebratedGoalIds: <int>{},
    );
    expect(out.length, 1);
    expect(out.first.goalId, 1);
  });

  test('SB-008 会话：同 goal 只认领一次（本会话即弹语义）', () {
    final AchievementSession s = AchievementSession();
    expect(s.claim(7), isTrue);
    expect(s.claim(7), isFalse);
    expect(s.claim(8), isTrue);
  });

  test('SB-008 文案：标题/正文/分享零禁词（得到框架）', () {
    final String title = achievementTitle(goalName: '攒手机', tier: '手机');
    final String body = achievementBody(
      convertibleFen: 400000,
      targetFen: 399900,
    );
    final String share = shareCaption(goalName: '攒手机');
    for (final String bad in achievementBannedWords) {
      expect(title.contains(bad), isFalse, reason: '标题含禁词 $bad');
      expect(body.contains(bad), isFalse, reason: '正文含禁词 $bad');
      expect(share.contains(bad), isFalse, reason: '分享含禁词 $bad');
    }
    expect(title.contains('已攒够'), isTrue);
    expect(title.contains('得到'), isTrue);
  });

  test('SB-008 文案：标题含目标名与阶梯赠语', () {
    expect(achievementTitle(goalName: '攒手机', tier: '手机'), contains('攒手机'));
    expect(achievementTitle(goalName: '攒手机', tier: ''), contains('底气'));
  });

  test('SB-008 文案：正文大额只陈述（无行动召唤）', () {
    final String body = achievementBody(
      convertibleFen: 399900 + 1800,
      targetFen: 399900,
    );
    for (final String bad in <String>['别买', '不该', '忍住', '建议']) {
      expect(body.contains(bad), isFalse);
    }
  });

  test('SB-008 动效规格：成就时长 900–1200ms，粒子≤12', () {
    expect(MotionSpec.achievement.inMilliseconds, greaterThanOrEqualTo(900));
    expect(MotionSpec.achievement.inMilliseconds, lessThanOrEqualTo(1200));
    expect(MotionSpec.particlesMax, lessThanOrEqualTo(12));
  });

  test('SB-008 金额格式化与阶梯推导一致', () {
    expect(formatAmount(399900), '3999');
    expect(formatAmount(1800), '18');
  });

  test('SB-008 DAO：成就插入/列表倒序/删除', () async {
    final AppDb db = AppDb.memoryForTest();
    final int id1 = await db.insertAchievement(
      AchievementsCompanion(
        goalId: const Value(1),
        goalName: const Value('攒手机'),
        targetFen: const Value(399900),
        convertibleFen: const Value(400000),
        tier: const Value('手机'),
        unlockedAt: Value(DateTime(2026, 10, 1, 12)),
      ),
    );
    await db.insertAchievement(
      AchievementsCompanion(
        goalId: const Value(2),
        goalName: const Value('攒键盘'),
        targetFen: const Value(29900),
        convertibleFen: const Value(30000),
        tier: const Value('键盘'),
        unlockedAt: Value(DateTime(2026, 10, 2, 12)),
      ),
    );
    final List<Achievement> rows = await db.listAchievements();
    expect(rows.length, 2);
    expect(rows.first.goalId, 2);
    await db.deleteAchievement(id1);
    final List<Achievement> rows2 = await db.listAchievements();
    expect(rows2.length, 1);
  });

  test('SB-008 schema v3：回滚删表即回 v2 形状', () async {
    final AppDb db = AppDb.memoryForTest();
    await db.insertAchievement(
      AchievementsCompanion(
        goalId: const Value(9),
        goalName: const Value('回滚卡'),
        targetFen: const Value(100),
        convertibleFen: const Value(200),
        tier: const Value('奶茶'),
      ),
    );
    expect((await db.listAchievements()).length, 1);
    await db.rollbackAchievementsToV2();
    bool threw = false;
    try {
      await db.listAchievements();
    } catch (_) {
      threw = true;
    }
    expect(threw, isTrue);
  });
}
