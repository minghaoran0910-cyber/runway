import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/experiment.dart';

// SB-018 · 月度小实验引擎单测（纯函数；合成数据，真实账目=0）.

void main() {
  test('周期=7 天', () {
    expect(experimentDays, 7);
  });

  test('建议库≥8 且 id 唯一、日省额>0', () {
    final libs = experimentLibrary();
    expect(libs.length, greaterThanOrEqualTo(8));
    final ids = libs.map((t) => t.id).toSet();
    expect(ids.length, libs.length);
    for (final t in libs) {
      expect(t.dailySaveFen, greaterThan(0), reason: t.id);
      expect(t.name.trim(), isNotEmpty);
    }
  });

  test('建议库含三示例（无奶茶/自带午饭/走路通勤）', () {
    final ids = experimentLibrary().map((t) => t.id).toSet();
    expect(ids, contains('no-milk-tea'));
    expect(ids, contains('homemade-lunch'));
    expect(ids, contains('walk-commute'));
  });

  test('resolveExperimentPlan 模板走库值', () {
    final plan = resolveExperimentPlan(templateId: 'no-milk-tea');
    expect(plan.name, '无奶茶周');
    expect(plan.dailySaveFen, 1800);
  });

  test('resolveExperimentPlan 自设走 custom', () {
    final plan = resolveExperimentPlan(
      templateId: 'custom',
      customName: '晚饭自己做',
      customDailySaveFen: 2500,
    );
    expect(plan.name, '晚饭自己做');
    expect(plan.dailySaveFen, 2500);
  });

  test('dayIndexFor 0..6，周期外 -1', () {
    final start = DateTime(2026, 10, 1);
    expect(dayIndexFor(date: DateTime(2026, 10, 1), startDate: start), 0);
    expect(dayIndexFor(date: DateTime(2026, 10, 7), startDate: start), 6);
    expect(dayIndexFor(date: DateTime(2026, 10, 8), startDate: start), -1);
    expect(dayIndexFor(date: DateTime(2026, 9, 30), startDate: start), -1);
  });

  test('checkInDays 同天幂等、越界忽略', () {
    var days = <int>{};
    days = checkInDays(days, 0);
    days = checkInDays(days, 0);
    expect(days, {0});
    days = checkInDays(days, 7);
    days = checkInDays(days, -1);
    expect(days, {0});
  });

  test('isExperimentFinished 第 8 天起结束', () {
    final start = DateTime(2026, 10, 1);
    expect(
      isExperimentFinished(startDate: start, now: DateTime(2026, 10, 7)),
      isFalse,
    );
    expect(
      isExperimentFinished(startDate: start, now: DateTime(2026, 10, 8)),
      isTrue,
    );
  });

  test('elapsedDays 日历口径 0..7', () {
    final start = DateTime(2026, 10, 1);
    expect(elapsedDays(startDate: start, now: DateTime(2026, 9, 30)), 0);
    expect(elapsedDays(startDate: start, now: DateTime(2026, 10, 1)), 1);
    expect(elapsedDays(startDate: start, now: DateTime(2026, 10, 7)), 7);
    expect(elapsedDays(startDate: start, now: DateTime(2026, 10, 20)), 7);
  });

  test('experimentSavedFen 打卡天×日省额（缺席即 0）', () {
    expect(experimentSavedFen(dailySaveFen: 1800, checkedCount: 5), 9000);
    expect(experimentSavedFen(dailySaveFen: 1800, checkedCount: 0), 0);
    expect(experimentSavedFen(dailySaveFen: 0, checkedCount: 7), 0);
  });

  test('进度文案如实显示（断卡只记缺席天）', () {
    final t = experimentProgressText(checked: 5, elapsed: 7);
    expect(t, contains('5/7'));
    expect(t, contains('缺席 2 天'));
  });

  test('结果文案得到框架（省出+换算）', () {
    final t = experimentResultText(savedFen: 9000);
    expect(t, contains('省出 ¥90'));
    expect(t, isNotEmpty);
  });

  test('结果文案零省出持平态', () {
    expect(experimentResultText(savedFen: 0), contains('持平'));
  });

  test('实验成就名口径', () {
    expect(experimentAchievementName('无奶茶周'), contains('无奶茶周'));
  });

  test('实验成就 goalId 防撞段（900000+）', () {
    expect(experimentGoalId(3), 900003);
  });

  test('validateExperimentCustom 口径', () {
    expect(validateExperimentCustom(name: '晚饭自己做', dailySaveFen: 1000), isNull);
    expect(validateExperimentCustom(name: '', dailySaveFen: 1000), isNotNull);
    expect(validateExperimentCustom(name: '晚饭自己做', dailySaveFen: 0), isNotNull);
    expect(
      validateExperimentCustom(name: '晚饭自己做', dailySaveFen: null),
      isNotNull,
    );
  });

  test('文案零禁词（进度/结果/成就名）', () {
    final texts = <String>[
      experimentProgressText(checked: 3, elapsed: 7),
      experimentResultText(savedFen: 9000),
      experimentResultText(savedFen: 0),
      experimentAchievementName('无奶茶周'),
    ];
    for (final t in texts) {
      for (final w in achievementBannedWords) {
        expect(t.contains(w), isFalse, reason: '文案命中禁词 $w：$t');
      }
    }
  });

  test('文案零说教零恐吓抽查', () {
    const preachy = <String>[
      '说教',
      '惩罚',
      '冲动',
      '剁手',
      '警告',
      '克制',
      '自律',
      '后悔',
      '罪恶',
      '浪费',
      '失败',
      '放弃',
    ];
    final texts = <String>[
      experimentProgressText(checked: 3, elapsed: 7),
      experimentResultText(savedFen: 9000),
      experimentResultText(savedFen: 0),
    ];
    for (final t in texts) {
      for (final w in preachy) {
        expect(t.contains(w), isFalse, reason: '文案命中说教词 $w：$t');
      }
    }
  });
}
