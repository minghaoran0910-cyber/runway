// SB-034 · 诊断回传开关行（得到系文案；形状只用 r16 内容卡；颜色只用 tokens）.
// 挂载门：kDebugMode + 注入配齐 + 未过期，三者缺一即 SizedBox（默认环境零像素，golden 不动）.
// 文案禁词复用成就表扫描，本文件零命中.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ui/theme/tokens.dart';
import '../diagnostics/diag_config.dart';
import '../diagnostics/diag_reporter.dart';

/// 编译期挂载门（设置页用；测试环境未注入即 false）.
bool diagSectionVisible() {
  if (!kDebugMode) return false;
  if (!diagIsConfigured(endpoint: DiagEnv.endpoint, token: DiagEnv.token)) {
    return false;
  }
  return !diagIsExpired(expiryMs: DiagEnv.expiryMs, now: DateTime.now());
}

/// 设置页挂载段（门关闭即零像素）.
class DiagnosticsSection extends StatefulWidget {
  const DiagnosticsSection({super.key});

  @override
  State<DiagnosticsSection> createState() => _DiagnosticsSectionState();
}

class _DiagnosticsSectionState extends State<DiagnosticsSection> {
  @override
  Widget build(BuildContext context) {
    if (!diagSectionVisible()) return const SizedBox.shrink();
    return DiagnosticsCard(
      enabled: DiagRuntime.instance.reporter.userEnabled,
      onChanged: (bool v) {
        setState(() {
          DiagRuntime.instance.reporter.userEnabled = v;
        });
      },
    );
  }
}

/// 开关卡本体（常渲染；供单测直泵）.
class DiagnosticsCard extends StatelessWidget {
  const DiagnosticsCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '体验改进计划',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '帮你攒得更稳：卡顿或闪退时自动带上技术日志，修得更快',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              key: const Key('diagSwitch'),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// SB-039 ③ · "关于·诊断"常驻行（"我的"页尾；与调试门控的 DiagnosticsSection
/// 不同，本卡常显——内部实现细节有处可查，又不占类目页标题位；
/// 文案一律 bodySmall，禁词复用成就表扫描零命中）.
class AboutDiagnosticsCard extends StatelessWidget {
  const AboutDiagnosticsCard({
    super.key,
    required this.ruleCount,
    required this.categoryCount,
    required this.otherShare,
    required this.otherFault,
  });

  final int ruleCount;
  final int categoryCount;
  final double otherShare;
  final bool otherFault;

  @override
  Widget build(BuildContext context) {
    final String pct = (otherShare * 100).toStringAsFixed(1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '关于 · 诊断信息',
              style: Theme.of(context).textTheme.bodySmall,
              key: const Key('aboutDiagTitle'),
            ),
            const SizedBox(height: 4),
            Text(
              '内置规则 $ruleCount 条 · $categoryCount 类目',
              style: Theme.of(context).textTheme.bodySmall,
              key: const Key('aboutDiagRules'),
            ),
            Text(
              otherFault ? '其他占比 $pct% · 分类故障：占比超 5%，待修复' : '其他占比 $pct% · 分类健康',
              style: Theme.of(context).textTheme.bodySmall,
              key: Key(otherFault ? 'aboutDiagFault' : 'aboutDiagHealthy'),
            ),
          ],
        ),
      ),
    );
  }
}
