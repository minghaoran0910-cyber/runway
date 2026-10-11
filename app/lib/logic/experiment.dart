// SB-018 · 月度小实验引擎（PRD §2 改变层；DESIGN §7 得到框架，纯 Dart）.
// 口径：
//   每月一个 7 天实验（建议库≥8 + 自设）；每日 3 秒打卡（同天幂等）.
//   断卡不惩罚只如实显示（缺席天只记 0，不扣不罚，文案零负罪词）.
//   省出 = 打卡天数 × 日省额（checked-only；缺席即 0，无第二套公式）.
//   换算复用 SB-007 价格表（equivalentOf/describeSaving），禁第二套换算.
//   完成即一张实验成就（调用方落 achievements 表，goalId=900000+实验 id 防撞）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'achievement.dart';
import 'entry.dart';
import 'goal_ladder.dart';

/// 实验周期（7 天；第 8 天起即结束）.
const int experimentDays = 7;

/// 建议库 id（自设走 'custom'）.
class ExperimentTemplate {
  const ExperimentTemplate({
    required this.id,
    required this.name,
    required this.dailySaveFen,
    required this.desc,
  });

  final String id;
  final String name;
  final int dailySaveFen;
  final String desc;
}

/// 建议库（≥8；日省额为合成缺省值，用户可在 UI 按实改）.
List<ExperimentTemplate> experimentLibrary() {
  return const <ExperimentTemplate>[
    ExperimentTemplate(
      id: 'no-milk-tea',
      name: '无奶茶周',
      dailySaveFen: 1800,
      desc: '每天少 1 杯奶茶',
    ),
    ExperimentTemplate(
      id: 'homemade-lunch',
      name: '自带午饭',
      dailySaveFen: 2000,
      desc: '每天自带 1 顿午饭',
    ),
    ExperimentTemplate(
      id: 'walk-commute',
      name: '走路通勤',
      dailySaveFen: 600,
      desc: '能走就不打车',
    ),
    ExperimentTemplate(
      id: 'no-takeout',
      name: '不点外卖周',
      dailySaveFen: 1500,
      desc: '外卖换自己做',
    ),
    ExperimentTemplate(
      id: 'no-snack',
      name: '零食暂停',
      dailySaveFen: 800,
      desc: '零食先放 7 天',
    ),
    ExperimentTemplate(
      id: 'home-coffee',
      name: '手冲代外带',
      dailySaveFen: 1500,
      desc: '外带咖啡换手冲',
    ),
    ExperimentTemplate(
      id: 'bus-first',
      name: '公交优先',
      dailySaveFen: 1000,
      desc: '打车换公交地铁',
    ),
    ExperimentTemplate(
      id: 'cook-dinner',
      name: '自己做晚饭',
      dailySaveFen: 2500,
      desc: '下馆子换自己做',
    ),
  ];
}

/// 落库计划（UI 由模板/自设转换；logic 不 import drift）.
class ExperimentPlan {
  const ExperimentPlan({
    required this.templateId,
    required this.name,
    required this.dailySaveFen,
    required this.startDate,
  });

  final String templateId;
  final String name;
  final int dailySaveFen;
  final DateTime startDate;
}

/// 模板/自设解析（custom 用自设名+日省额；模板用库值）.
ExperimentPlan resolveExperimentPlan({
  required String templateId,
  String customName = '',
  int customDailySaveFen = 0,
  DateTime? startDate,
}) {
  final DateTime start = startDate ?? DateTime.now();
  if (templateId == 'custom') {
    return ExperimentPlan(
      templateId: 'custom',
      name: customName.trim(),
      dailySaveFen: customDailySaveFen,
      startDate: start,
    );
  }
  for (final ExperimentTemplate t in experimentLibrary()) {
    if (t.id == templateId) {
      return ExperimentPlan(
        templateId: t.id,
        name: t.name,
        dailySaveFen: t.dailySaveFen,
        startDate: start,
      );
    }
  }
  return ExperimentPlan(
    templateId: templateId,
    name: templateId,
    dailySaveFen: 0,
    startDate: start,
  );
}

/// 日期 → 第几天（0..6；周期外 -1）.
int dayIndexFor({required DateTime date, required DateTime startDate}) {
  final DateTime d = DateTime(date.year, date.month, date.day);
  final DateTime s = DateTime(startDate.year, startDate.month, startDate.day);
  final int diff = d.difference(s).inDays;
  if (diff < 0 || diff >= experimentDays) return -1;
  return diff;
}

/// 打卡（同天幂等；越界忽略；返回新集合）.
Set<int> checkInDays(Set<int> days, int dayIndex) {
  if (dayIndex < 0 || dayIndex >= experimentDays) return Set<int>.from(days);
  final Set<int> next = Set<int>.from(days);
  next.add(dayIndex);
  return next;
}

/// 是否结束（start+7 天起）.
bool isExperimentFinished({
  required DateTime startDate,
  required DateTime now,
}) {
  final DateTime s = DateTime(startDate.year, startDate.month, startDate.day);
  final DateTime n = DateTime(now.year, now.month, now.day);
  return n.difference(s).inDays >= experimentDays;
}

/// 已过天数（0..7；只看日历，不看打卡）.
int elapsedDays({required DateTime startDate, required DateTime now}) {
  final int idx = dayIndexFor(date: now, startDate: startDate);
  if (idx >= 0) return idx + 1;
  final DateTime s = DateTime(startDate.year, startDate.month, startDate.day);
  final DateTime n = DateTime(now.year, now.month, now.day);
  if (n.isBefore(s)) return 0;
  return experimentDays;
}

/// 省出（打卡天 × 日省额；缺席即 0，不惩罚）.
int experimentSavedFen({required int dailySaveFen, required int checkedCount}) {
  if (dailySaveFen <= 0 || checkedCount <= 0) return 0;
  return dailySaveFen * checkedCount;
}

/// 进度文案（只如实显示；零惩罚零负罪）.
String experimentProgressText({required int checked, required int elapsed}) {
  final int e = elapsed < 0
      ? 0
      : (elapsed > experimentDays ? experimentDays : elapsed);
  final int missed = e - checked > 0 ? e - checked : 0;
  return '已打卡 $checked/$experimentDays 天 · 缺席 $missed 天如实记录';
}

/// 结果文案（得到框架；换算复用 SB-007，禁第二套公式）.
String experimentResultText({required int savedFen}) {
  if (savedFen <= 0) return '这次实验持平 · 记下一笔继续稳步积累';
  return '这次实验省出 ¥${formatFen(savedFen)} · ${equivalentOf(savedFen)}';
}

/// 实验成就名（落 achievements 表 goalName 用）.
String experimentAchievementName(String planName) => '实验 · $planName';

/// 实验成就 goalId（900000+实验 id；与真实目标 id 段防撞）.
int experimentGoalId(int experimentId) => 900000 + experimentId;

/// 领域校验：自设实验（名 1–16 字，日省额 >0）.
String? validateExperimentCustom({required String name, int? dailySaveFen}) {
  if (name.trim().isEmpty || name.trim().length > 16) return '实验名 1–16 字';
  if (dailySaveFen == null || dailySaveFen <= 0) return '日省额须大于 0';
  if (dailySaveFen > 10000000) return '日省额过大';
  return null;
}

/// 本卡禁词复用成就表（不另建第二套；实验文案零命中）.
List<String> get experimentBannedWords => achievementBannedWords;
