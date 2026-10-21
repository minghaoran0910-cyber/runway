import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import '../logic/goal_deadline.dart';
import '../logic/goal_ladder.dart';
import 'goal_price_follow.dart';
import 'theme/tokens.dart';

// SB-041 · 目标编辑器（自 goal_page.dart 拆出，DEV §2 单文件 ≤400；与 SB-040 分支
// goal_editor.dart 同名不同命：该分支未合入且用"月数"口径，本卡按卡面"ISO 日期串"
// 口径实现，合入时以本文件为准核对，见提审单偏差声明）.
// SB-048 · 表单修复：核心三项常显（名/额/期限）+「进阶（换算单价）」折叠；
// 期限改 showDatePicker 日历选择（默认建议月末）；目标金额增阶梯预设 chips
// （键盘/手机/5090/余粮，零数字键入路径）；单价保留卡片 +「自定义」卡展开行内输入；
// 预设 chips 仅进阶区；间距按 token；label 短化防截断；"常买键"改人话见
// goal_price_follow.dart；换算区附"攒够 X 件 Y"上下文.

class GoalForm {
  String name = '';
  int? targetFen;
  String priceName = '奶茶';
  int? priceFen = 1800;

  /// 期限 ISO 日期串；null=无期限，直存 goals.deadline.
  String? deadline;
}

/// 目标金额快捷档（SB-048 · 阶梯语境，零数字键入路径；取自 defaultLadder）.
const List<LadderRung> goalTargetPresets = <LadderRung>[
  LadderRung(name: '键盘', thresholdFen: 29900),
  LadderRung(name: '手机', thresholdFen: 399900),
  LadderRung(name: '5090', thresholdFen: 1649900),
  LadderRung(name: '余粮', thresholdFen: 6000000),
];

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
  late bool _customPriceExpanded;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.goal?.name ?? '');
    _target = TextEditingController(
      text: widget.goal == null ? '' : formatFen(widget.goal!.targetFen),
    );
    _deadline = TextEditingController(text: widget.goal?.deadline ?? '');
    _priceName = TextEditingController(text: widget.goal?.priceName ?? '奶茶');
    _price = TextEditingController(
      text: widget.goal == null ? '18' : formatFen(widget.goal!.priceFen),
    );
    // 已存自定义单价（非预设）→ 默认展开自定义行内输入.
    final String pn = widget.goal?.priceName ?? '奶茶';
    final int pf = widget.goal?.priceFen ?? 1800;
    _customPriceExpanded = !defaultPrices.any(
      (PriceRef p) => p.name == pn && p.fen == pf,
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
      _customPriceExpanded = false;
    });
  }

  void _pickTargetPreset(LadderRung rung) {
    setState(() {
      _target.text = formatFen(rung.thresholdFen);
    });
  }

  /// SB-048 · 日历选择期限（默认建议月末；空=无期限）.
  Future<void> _pickDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime? parsed = parseDeadline(
      _deadline.text.trim().isEmpty ? null : _deadline.text,
    );
    // 默认建议：当月月末.
    final DateTime monthEnd = DateTime(now.year, now.month + 1, 0);
    final DateTime first = DateTime(now.year - 1);
    final DateTime last = DateTime(now.year + 5);
    // 票262问题③：手输早于 firstDate/晚于 lastDate 的日期一律钳进区间，
    // 防 showDatePicker initialDate 越界 assert（debug 崩路径）。
    final DateTime raw =
        parsed ?? (_deadline.text.trim().isEmpty ? monthEnd : now);
    final DateTime initial = raw.isBefore(first)
        ? first
        : (raw.isAfter(last) ? last : raw);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && mounted) {
      setState(() {
        _deadline.text =
            '${picked.year.toString().padLeft(4, '0')}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  /// SB-048 · 换算上下文：攒够 N 件/杯 X（目标额 ÷ 单价）.
  String _convertHint() {
    final int? targetFen = parseAmountToFen(_target.text);
    final int? priceFen = parseAmountToFen(_price.text);
    final String priceName = _priceName.text.trim().isEmpty
        ? '单价'
        : _priceName.text.trim();
    if (targetFen == null || targetFen <= 0) return '定个金额，看看能攒够多少件';
    if (priceFen == null || priceFen <= 0) return '选个单价，看看能攒够多少件';
    final int count = targetFen ~/ priceFen;
    if (count <= 0) {
      return '攒够 1 $priceName · 先从第一件开始';
    }
    final String unit = cupUnit(priceName);
    return '攒够 $count $unit$priceName';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? '定一个目标' : '编辑目标'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // —— 核心三项常显 ——
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: '目标名',
                helperText: '如攒手机，1–32字',
              ),
              maxLength: 32,
              key: const Key('goalName'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
            TextField(
              controller: _target,
              decoration: const InputDecoration(
                labelText: '目标金额（元）',
                helperText: '点下方快捷档可免输入',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              key: const Key('goalTarget'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final LadderRung rung in goalTargetPresets)
                  ChoiceChip(
                    label: Text(
                      '${rung.name} ¥${formatFen(rung.thresholdFen)}',
                    ),
                    selected:
                        parseAmountToFen(_target.text) == rung.thresholdFen,
                    onSelected: (_) => _pickTargetPreset(rung),
                    key: Key('goalTargetPreset-${rung.name}'),
                  ),
              ],
            ),
            const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
            TextField(
              controller: _deadline,
              decoration: InputDecoration(
                labelText: '期限（可选）',
                helperText: '日历选择，空=无期限',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_deadline.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: '清除期限',
                        key: const Key('goalDeadlineClear'),
                        onPressed: () => setState(() => _deadline.text = ''),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      tooltip: '日历选择期限',
                      key: const Key('goalDeadlinePick'),
                      onPressed: _pickDeadline,
                    ),
                  ],
                ),
              ),
              keyboardType: TextInputType.datetime,
              key: const Key('goalDeadline'),
              onTap: _pickDeadline,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: RunwaySpacing.cardInner),
            // —— 进阶（换算单价）折叠 ——
            ExpansionTile(
              title: const Text('进阶（换算单价）'),
              subtitle: const Text('预设单价 · 常买跟随'),
              initiallyExpanded: _customPriceExpanded,
              key: const Key('goalAdvanced'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final PriceRef p in defaultPrices)
                      ChoiceChip(
                        label: Text('${p.name} ¥${formatFen(p.fen)}'),
                        selected:
                            !_customPriceExpanded && _priceName.text == p.name,
                        onSelected: (_) => _pickPrice(p),
                        key: Key('priceOption-${p.name}'),
                      ),
                    ChoiceChip(
                      label: const Text('自定义'),
                      selected: _customPriceExpanded,
                      onSelected: (_) => setState(
                        () => _customPriceExpanded = !_customPriceExpanded,
                      ),
                      key: const Key('priceOption-custom'),
                    ),
                  ],
                ),
                const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
                // 换算上下文（SB-048 增补：chip 组归入换算区并带出阶梯语境）.
                Text(_convertHint(), key: const Key('goalConvertHint')),
                const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
                if (_customPriceExpanded) ...<Widget>[
                  TextField(
                    controller: _priceName,
                    decoration: const InputDecoration(
                      labelText: '单价名',
                      helperText: '可自定义，1–16字',
                    ),
                    maxLength: 16,
                    key: const Key('goalPriceName'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
                  TextField(
                    controller: _price,
                    decoration: const InputDecoration(labelText: '单价（元）'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    key: const Key('goalPrice'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: RunwaySpacing.sectionHeaderBottom),
                ],
                GoalFollowField(
                  db: widget.db,
                  onPick: (int medianFen, String noteName) {
                    setState(() {
                      _price.text = formatFen(medianFen);
                      _priceName.text = noteName;
                      _customPriceExpanded = true;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final String? dErr = validateDeadlineDate(_deadline.text);
            if (dErr != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(dErr)));
              return;
            }
            final GoalForm form = GoalForm()
              ..name = _name.text
              ..targetFen = parseAmountToFen(_target.text)
              ..priceName = _priceName.text
              ..priceFen = parseAmountToFen(_price.text)
              ..deadline = normalizeDeadline(_deadline.text);
            if (widget.onSave != null) {
              await widget.onSave!(context, form);
            } else {
              Navigator.of(context).pop(false);
            }
          },
          key: const Key('goalSave'),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

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
