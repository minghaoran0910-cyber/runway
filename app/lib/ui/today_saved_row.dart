import 'package:flutter/material.dart';

import '../logic/estimate.dart';

// SB-016 · 今日攒出行（收口浮层「已记」态固定反馈行；DESIGN §1 地面+浮起 / §7 得到框架）.
// saved<=0 或换算不出时整行不出现（零失败暴露、无安慰话术）；文案复用 SB-007 价格表.
// 形状无新增（纯文本行）；颜色只用 tokens；数字 tabular；本文件零裸时长/曲线.

class TodaySavedRow extends StatelessWidget {
  const TodaySavedRow({super.key, required this.savedFen});

  final int savedFen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? text = todaySavedText(savedFen: savedFen);
    if (text == null) return const SizedBox.shrink(key: Key('todaySavedEmpty'));
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      key: const Key('todaySaved'),
    );
  }
}
