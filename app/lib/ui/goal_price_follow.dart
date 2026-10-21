import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/price_watch.dart';

// SB-020 · 目标页常买跟随字段（自 goal_page.dart 拆出，DEV §2 单文件 ≤400）.
// SB-048 · 人话改名："常买键"→"按你常买的价格自动定单价"（黑话外泄修复）；
// 键精确匹配，≥3 笔取中位数回填单价；<3 笔不猜只提示；换算引擎零改动.
class GoalFollowField extends StatefulWidget {
  const GoalFollowField({super.key, required this.db, required this.onPick});

  final AppDb? db;
  final void Function(int medianFen, String noteName) onPick;

  @override
  State<GoalFollowField> createState() => GoalFollowFieldState();
}

class GoalFollowFieldState extends State<GoalFollowField> {
  late final TextEditingController followKey = TextEditingController();

  @override
  void dispose() {
    followKey.dispose();
    super.dispose();
  }

  Future<void> followMedian() async {
    final AppDb? db = widget.db;
    if (db == null) return;
    final String raw = followKey.text.trim();
    final List<String> parts = raw.contains('｜')
        ? raw.split('｜')
        : raw.split('|');
    if (parts.length != 2) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('格式：类目｜备注，如 餐饮｜咖啡')));
      }
      return;
    }
    final String? key = priceKeyFor(category: parts[0], note: parts[1]);
    if (key == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('格式：类目｜备注，如 餐饮｜咖啡')));
      }
      return;
    }
    final List<Transaction> rows = await db.listAll();
    final List<int> amounts = <int>[];
    for (final Transaction r in rows) {
      if (priceKeyFor(category: r.category, note: r.note) == key) {
        amounts.add(r.amountFen);
      }
    }
    final PriceStats? stats = summarizePrices(key: key, amounts: amounts);
    if (stats == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('该组合不足 3 笔，换个常买试试')));
      }
      return;
    }
    final String note = parts[1].trim();
    widget.onPick(
      stats.medianFen,
      note.length > 16 ? note.substring(0, 16) : note,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: followKey,
          decoration: const InputDecoration(
            labelText: '按常买价填单价（可选）',
            helperText: '输入 类目｜备注，如 餐饮｜咖啡，≥3笔取中位数',
          ),
          key: const Key('goalFollowKey'),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: followMedian,
            key: const Key('goalFollowFetch'),
            child: const Text('取常买中位数'),
          ),
        ),
      ],
    );
  }
}
