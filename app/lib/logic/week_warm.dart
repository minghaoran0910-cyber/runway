// SB-022 · 零日温度线（PRD §2 每日载体恒可见 / SB-019 角色轴，纯 Dart）.
// 口径：结余<=0 的日子该行仍显示，两档——
//   恰零（saved==0）：①「今天攒 0 · 已记 N 笔」②得到式鼓励 ③本周去向行.
//   负结余（saved<0）：①诚实承认「虽然今天多花了 ¥X」②点名今日之乐/退档链
//   ③犒劳前瞻；本周去向行保留.「今天攒 0」负结余禁用（浩然 21:47）.
// 归组调 resolveRole（SB-019，不新建第二套判定）；周区间调 weekStartFor（SB-009，只读复用）.
// guilt 句式（超支/浪费类）=违规，本文件文案零命中；「多花」系诚实事实词可用（v3）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'achievement.dart';
import 'entry.dart';
import 'grain_report.dart';
import 'role_resolver.dart';

/// 本周角色归组汇总（分）.
class WeekRoleSums {
  const WeekRoleSums({
    required this.necessaryFen,
    required this.flexibleFen,
    required this.fixedFen,
  });

  final int necessaryFen;
  final int flexibleFen;
  final int fixedFen;

  static const WeekRoleSums empty = WeekRoleSums(
    necessaryFen: 0,
    flexibleFen: 0,
    fixedFen: 0,
  );
}

/// 本周角色归组聚合（周一起止；空输入=全零，零编造）.
WeekRoleSums summarizeWeekRoles({
  required Iterable<({int amountFen, String category, DateTime occurredAt})>
  flows,
  required DateTime now,
  Map<String, CategoryRole>? overrides,
}) {
  final DateTime start = weekStartFor(now);
  final DateTime endEx = start.add(const Duration(days: 7));
  int necessary = 0;
  int flexible = 0;
  int fixed = 0;
  for (final ({int amountFen, String category, DateTime occurredAt}) f
      in flows) {
    if (f.occurredAt.isBefore(start) || !f.occurredAt.isBefore(endEx)) {
      continue;
    }
    switch (resolveRole(f.category, overrides)) {
      case CategoryRole.necessary:
        necessary += f.amountFen;
      case CategoryRole.flexible:
        flexible += f.amountFen;
      case CategoryRole.fixed:
        fixed += f.amountFen;
    }
  }
  return WeekRoleSums(
    necessaryFen: necessary,
    flexibleFen: flexible,
    fixedFen: fixed,
  );
}

/// 是否零日（结余<=0 即零日，含持平）.
bool isZeroDay({required int savedFen}) => savedFen <= 0;

/// 零日首行（动作可见：攒 0 照样说话 + 已记笔数）.
String zeroDayHeadline({required int todayCount}) {
  return '今天攒 0 · 已记 $todayCount 笔';
}

/// 零日鼓励（得到框架；单句无感叹号，禁假热情堆叠）.
String zeroDayEncourage() => '奶茶自由又近了一小步的势头还在';

/// 本周去向行（只报归组金额，零评判词）.
String weekRoleLine({required WeekRoleSums sums}) {
  return '本周必要 ¥${formatFen(sums.necessaryFen)}'
      ' · 弹性 ¥${formatFen(sums.flexibleFen)}'
      ' · 固定 ¥${formatFen(sums.fixedFen)}';
}

/// 负结余首行（诚实承认；X=|saved|，走 formatFen；「多花」可用，v3）.
String overspendHeadline({required int savedFen}) {
  return '虽然今天多花了 ¥${formatFen(savedFen.abs())}';
}

/// 点名输入行（调用方已按自然日过滤；logic 不 import drift）.
class JoyRow {
  const JoyRow(this.amountFen, this.category, this.note, this.source);

  final int amountFen;
  final String category;
  final String note;
  final String source;
}

/// 点名今日之乐：当日弹性角色 + source≠estimate + note 非空，按金额倒序取≤2 笔
/// 原样返回 note（禁换算禁编造；note 空=无名可点，走退档链，D1 按卡判）.
List<String> pickJoyNotes({
  required Iterable<JoyRow> today,
  Map<String, CategoryRole>? overrides,
}) {
  final List<JoyRow> cands = today
      .where(
        (JoyRow r) =>
            resolveRole(r.category, overrides) == CategoryRole.flexible &&
            r.source != 'estimate' &&
            r.note.trim().isNotEmpty,
      )
      .toList();
  cands.sort((JoyRow a, JoyRow b) => b.amountFen.compareTo(a.amountFen));
  return cands.take(2).map((JoyRow r) => r.note.trim()).toList();
}

/// 负结余第二段（三级退档链；只读账上已有行，零编造）：
/// 有名可点→点名句；否则当日有固定/必要行→通用交代句（禁点名不存在物件）；
/// 再退→记账动作句.
String overspendSecondLine({
  required Iterable<JoyRow> today,
  Map<String, CategoryRole>? overrides,
}) {
  final List<JoyRow> rows = today.toList();
  final List<String> notes = pickJoyNotes(today: rows, overrides: overrides);
  if (notes.isNotEmpty) {
    return '但买了${notes.join('、')}，取悦自己不叫乱花';
  }
  final bool hasSturdy = rows.any(
    (JoyRow r) => resolveRole(r.category, overrides) != CategoryRole.flexible,
  );
  if (hasSturdy) {
    return '但该交的都交上了，日子在稳稳过';
  }
  return '但账记明白了';
}

/// 负结余第三段（犒劳+前瞻；零感叹号；金标准句=语气参照非复读模板）.
String overspendComfort() => '周中了犒劳犒劳自己吧。工作辛苦了。明天努力💪';

/// 本卡禁词复用成就表（不另建第二套）.
List<String> get warmBannedWords => achievementBannedWords;

/// 验收扩展扫描集（成就表 + 卡文点名的浪费；仅测试扫描用，不落新表；
/// 「多花」系诚实事实词已移出，v3）.
List<String> get warmExtendedBannedWords => <String>[
  ...achievementBannedWords,
  '浪费',
];
