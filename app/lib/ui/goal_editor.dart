import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import '../logic/goal_ladder.dart';
import 'goal_price_follow.dart';

// SB-040 · 目标编辑器（自 goal_page.dart 拆出，DEV §2 单文件 ≤400）.
// 新增期限字段（月，1–36，可空）：schema 冻结（DEV §2.3 禁区）暂不入库，
// 仅收集+校验，随保存回显；持久化待后续 schema 卡. 口径零改，复用 SB-007.

class GoalForm {
  String name = '';
  int? targetFen;
  String priceName = '奶茶';
  int? priceFen = 1800;
  String followKey = '';

  /// 期望期限（月）；null=未填. 暂不持久化（见文件头注记）.
  int? deadlineMonths;
}

/// 期限合法性（可空；填了须 1–36）.
String? validateDeadline(String raw) {
  final String t = raw.trim();
  if (t.isEmpty) return null;
  final int? v = int.tryParse(t);
  if (v == null || v < 1 || v > 36) return '期限须为 1–36 个月';
  return null;
}

/// 目标设定对话框（名称/目标额/期限/参考单价；内置单价 chips 一键填入，可自定义改）.
/// SB-020 · 常买跟随（可选）：填"类目｜备注"键取中位数填入单价；
/// 填入后仍可手改，手改即锁定优先；换算引擎零改动（复用 SB-007）.
class GoalDialog extends StatefulWidget {
  const GoalDialog({super.key, this.goal, this.db, this.onSave});

  final Goal? goal;
  final AppDb? db;
  final Future<void> Function(BuildContext ctx, GoalForm form)? onSave;

  @override
  State<GoalDialog> createState() => GoalDialogState();
}

class GoalDialogState extends State<GoalDialog> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _deadline;
  late final TextEditingController _priceName;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.goal?.name ?? '');
    _target = TextEditingController(
      text: widget.goal == null ? '' : formatFen(widget.goal!.targetFen),
    );
    _deadline = TextEditingController();
    _priceName = TextEditingController(text: widget.goal?.priceName ?? '奶茶');
    _price = TextEditingController(
      text: widget.goal == null ? '18' : formatFen(widget.goal!.priceFen),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _deadline.dispose();
    _priceName.dispose();
    _price.dispose();
    super.dispose();
  }

  void _pickPrice(PriceRef p) {
    setState(() {
      _priceName.text = p.name;
      _price.text = formatFen(p.fen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? '定一个目标' : '编辑目标'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: '目标名（如攒手机）'),
              maxLength: 32,
              key: const Key('goalName'),
            ),
            TextField(
              controller: _target,
              decoration: const InputDecoration(labelText: '目标金额（元）'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              key: const Key('goalTarget'),
            ),
            TextField(
              controller: _deadline,
              decoration: const InputDecoration(labelText: '期限（月，1–36，可空）'),
              keyboardType: TextInputType.number,
              key: const Key('goalDeadline'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final PriceRef p in defaultPrices)
                  ChoiceChip(
                    // SB-042 P3 · 补分隔（5090 ¥16,499），金额口径仍走 formatFen.
                    label: Text('${p.name} ¥${formatFen(p.fen)}'),
                    selected: _priceName.text == p.name,
                    onSelected: (_) => _pickPrice(p),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceName,
              decoration: const InputDecoration(labelText: '参考单价名（可自定义）'),
              maxLength: 16,
              key: const Key('goalPriceName'),
            ),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: '参考单价（元）'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              key: const Key('goalPrice'),
            ),
            const SizedBox(height: 8),
            GoalFollowField(
              db: widget.db,
              onPick: (int medianFen, String noteName) {
                setState(() {
                  _price.text = formatFen(medianFen);
                  _priceName.text = noteName;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final String? dErr = validateDeadline(_deadline.text);
            if (dErr != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(dErr)));
              return;
            }
            final String dt = _deadline.text.trim();
            final GoalForm form = GoalForm()
              ..name = _name.text
              ..targetFen = parseAmountToFen(_target.text)
              ..priceName = _priceName.text
              ..priceFen = parseAmountToFen(_price.text)
              ..deadlineMonths = dt.isEmpty ? null : int.parse(dt);
            if (widget.onSave != null) {
              await widget.onSave!(context, form);
            } else {
              Navigator.of(context).pop();
            }
          },
          key: const Key('goalSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 实物换算选择（预设 defaultPrices + 当前目标价自定义项；纯选择器，零口径改动）.
Future<PriceRef?> pickConvertPrice(
  BuildContext context, {
  required PriceRef current,
  List<Goal> goals = const <Goal>[],
}) async {
  final List<PriceRef> customs = <PriceRef>[
    for (final Goal g in goals) PriceRef(name: g.priceName, fen: g.priceFen),
  ];
  return showDialog<PriceRef>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: const Text('换算成什么'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final PriceRef p in defaultPrices)
              ListTile(
                title: Text('${p.name} · ${formatFen(p.fen)}'),
                trailing: p.name == current.name && p.fen == current.fen
                    ? const Icon(Icons.check)
                    : null,
                key: Key('priceOption-${p.name}'),
                onTap: () => Navigator.of(ctx).pop(p),
              ),
            if (customs.isNotEmpty) const Divider(height: 16),
            for (final PriceRef p in customs)
              ListTile(
                title: Text('${p.name} · ${formatFen(p.fen)}（目标价）'),
                trailing: p.name == current.name && p.fen == current.fen
                    ? const Icon(Icons.check)
                    : null,
                key: Key('priceOption-custom-${p.name}'),
                onTap: () => Navigator.of(ctx).pop(p),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('取消'),
        ),
      ],
    ),
  );
}
