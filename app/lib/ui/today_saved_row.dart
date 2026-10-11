import 'package:flutter/material.dart';

import '../logic/estimate.dart';
import '../logic/role_resolver.dart';
import '../logic/week_warm.dart';

// SB-016 · 今日攒出行（收口浮层「已记」态固定反馈行；DESIGN §1 地面+浮起 / §7 得到框架）.
// SB-022 · 零日温度线：saved<=0 时该行仍显示（覆盖 SB-016 验收5 隐藏条款），两档——
//   恰零：首行动作可见 + 得到式鼓励 + 本周角色归组；负结余：承认+点名/退档+犒劳前瞻+去向行
//   （「今天攒 0」负结余禁用）；saved>0 行为与 SB-016 完全一致，一字不动.
// 形状无新增（纯文本行/列）；颜色只用 tokens；数字 tabular；本文件零裸时长/曲线.

class TodaySavedRow extends StatelessWidget {
  const TodaySavedRow({
    super.key,
    required this.savedFen,
    this.todayCount = 0,
    this.necessaryFen = 0,
    this.flexibleFen = 0,
    this.fixedFen = 0,
    this.joyRows = const <JoyRow>[],
    this.roleOverrides = const <String, CategoryRole>{},
  });

  final int savedFen;

  /// 今日已记笔数（零日首行用；非零日忽略）.
  final int todayCount;

  /// 本周角色归组（零日去向行用；非零日忽略）.
  final int necessaryFen;
  final int flexibleFen;
  final int fixedFen;

  /// 当日行（负结余点名用；调用方已按自然日过滤；默认空=走退档链）.
  final List<JoyRow> joyRows;

  /// 角色覆盖（点名判定用；默认空）.
  final Map<String, CategoryRole> roleOverrides;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? text = todaySavedText(savedFen: savedFen);
    if (text != null) {
      return Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
        key: const Key('todaySaved'),
      );
    }
    // 换算不出但 saved>0（不足最小单价）：沿 SB-016 整行不出现，非零日行为不变.
    if (!isZeroDay(savedFen: savedFen)) {
      return const SizedBox.shrink(key: Key('todaySavedEmpty'));
    }
    final WeekRoleSums sums = WeekRoleSums(
      necessaryFen: necessaryFen,
      flexibleFen: flexibleFen,
      fixedFen: fixedFen,
    );
    // 负结余档：承认 + 点名/退档 + 犒劳前瞻 + 去向行（「今天攒 0」禁用）.
    if (savedFen < 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            overspendHeadline(savedFen: savedFen),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
            key: const Key('overspendHeadline'),
          ),
          const SizedBox(height: 2),
          Text(
            overspendSecondLine(today: joyRows, overrides: roleOverrides),
            style: theme.textTheme.bodySmall,
            key: const Key('joyLine'),
          ),
          const SizedBox(height: 2),
          Text(
            overspendComfort(),
            style: theme.textTheme.bodySmall,
            key: const Key('overspendComfort'),
          ),
          const SizedBox(height: 2),
          Text(
            weekRoleLine(sums: sums),
            style: theme.textTheme.bodySmall?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
            key: const Key('weekRoleLine'),
          ),
        ],
      );
    }
    // 恰零档：首行 + 鼓励 + 去向行.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          zeroDayHeadline(todayCount: todayCount),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          key: const Key('todaySavedZero'),
        ),
        const SizedBox(height: 2),
        Text(
          zeroDayEncourage(),
          style: theme.textTheme.bodySmall,
          key: const Key('zeroDayEncourage'),
        ),
        const SizedBox(height: 2),
        Text(
          weekRoleLine(sums: sums),
          style: theme.textTheme.bodySmall?.copyWith(
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          key: const Key('weekRoleLine'),
        ),
      ],
    );
  }
}
