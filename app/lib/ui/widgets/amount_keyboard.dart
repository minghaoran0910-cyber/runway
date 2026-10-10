import 'package:flutter/material.dart';

import '../theme/motion_spec.dart';
import '../theme/tokens.dart';

// SB-004 · 数字键盘（记一笔直输金额）. 纯展示+回调，金额拼装走 applyKey（可单测）.
// 样式：控件圆角 r10（§1.2 三档内），字号阶梯内 20，高饱和强调 ≤1 处.

/// 金额拼装纯逻辑：current 为显示串（"0" 起），key 为 '0'-'9'/'.'/'00'.
String applyKey(String current, String key) {
  String cur = current.isEmpty ? '0' : current;
  if (key == 'back') {
    if (cur.length <= 1) return '0';
    final String next = cur.substring(0, cur.length - 1);
    return next.isEmpty ? '0' : next;
  }
  if (key == '.') {
    if (cur.contains('.')) return cur;
    return '$cur.';
  }
  final String add = key == '00' ? '00' : key;
  String next = cur == '0' && !cur.contains('.') ? add : '$cur$add';
  // 小数最多 2 位，整数最多 6 位（上限内防误触）.
  if (next.contains('.')) {
    final List<String> parts = next.split('.');
    if (parts[1].length > 2) return cur;
    if (parts[0].length > 6) return cur;
  } else if (next.length > 6) {
    return cur;
  }
  // 去前导零（"00"→"0"，小数点前保留一位）.
  if (!next.contains('.')) {
    next = next.replaceFirst(RegExp(r'^0+'), '');
    if (next.isEmpty) next = '0';
  }
  return next;
}

class AmountKeyboard extends StatelessWidget {
  const AmountKeyboard({
    super.key,
    required this.onKey,
    required this.onBackspace,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  static const List<String> _keys = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '.',
    '0',
    '00',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: <Widget>[
        for (final String k in _keys)
          _Key(label: k, onTap: () => onKey(k), theme: theme),
        _Key(label: '⌫', onTap: onBackspace, theme: theme, isAction: true),
      ],
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({
    required this.label,
    required this.onTap,
    required this.theme,
    this.isAction = false,
  });

  final String label;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isAction;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  double _scale = 1;

  void _down(TapDownDetails _) =>
      setState(() => _scale = MotionSpec.pressScale);
  void _up() => setState(() => _scale = 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: MotionSpec.press,
        curve: MotionSpec.emphasizedDecelerate,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isAction
                ? widget.theme.colorScheme.primary.withValues(alpha: 0.12)
                : widget.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(RunwayRadius.control),
            border: Border.all(color: widget.theme.dividerColor),
          ),
          child: Text(
            widget.label,
            style: widget.theme.textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
