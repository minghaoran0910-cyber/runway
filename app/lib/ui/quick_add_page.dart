import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../data/app_db.dart';
import '../../logic/entry.dart';
import '../../logic/price_watch.dart';
import 'theme/app_theme.dart';
import 'theme/motion_spec.dart';
import 'theme/tokens.dart';
import 'widgets/amount_keyboard.dart';

// SB-004 · 记一笔页（≤3 秒/3 步：输金额→选类目→保存回主屏）.
// 默认类目为首项一键选中；保存经领域校验后写 DAO；零裸 hex/裸时长.

class QuickAddPage extends StatefulWidget {
  const QuickAddPage({
    super.key,
    required this.db,
    this.categories = defaultCategories,
  });

  final AppDb db;
  final List<String> categories;

  @override
  State<QuickAddPage> createState() => _QuickAddPageState();
}

class _QuickAddPageState extends State<QuickAddPage> {
  String _amount = '0';
  late String _category = widget.categories.first;
  final TextEditingController _note = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final int? fen = parseAmountToFen(_amount);
    final String? err = validateEntry(
      amountFen: fen,
      category: _category,
      note: _note.text,
    );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await widget.db.insertOne(
      TransactionsCompanion(
        amountFen: Value(fen!),
        occurredAt: Value(DateTime.now()),
        category: Value(_category),
        note: Value(_note.text),
        source: const Value('manual'),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final int? fen = parseAmountToFen(_amount);
    final String preview = fen == null ? '—' : formatFen(fen);

    return Scaffold(
      appBar: AppBar(title: const Text('记一笔')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: ListView(
          padding: const EdgeInsets.all(RunwaySpacing.page),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('金额', style: theme.textTheme.bodySmall),
                    Text(
                      preview,
                      style: theme.textTheme.headlineMedium,
                      key: const Key('amountPreview'),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          key: const Key('amountError'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: RunwaySpacing.section),
            Text('类目', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String c in widget.categories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: RunwaySpacing.section),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              onChanged: (_) => setState(() {}),
            ),
            // SB-020 · 常买提示：同键≥3 条才现身（中性小字，只陈述，无说教）.
            // 无键（备注空）时不建 StreamBuilder、不订阅 watchAll：
            // 空态持流会在 widget 测试 teardown 触发 drift 零时长 Timer
            // pending（见 widget_test.dart 头注），且生产侧亦省一次订阅.
            Builder(
              builder: (BuildContext bctx) {
                final String? priceKey = priceKeyFor(
                  category: _category,
                  note: _note.text,
                );
                if (priceKey == null) return const SizedBox.shrink();
                return StreamBuilder<List<Transaction>>(
                  stream: widget.db.watchAll(),
                  builder: (BuildContext pctx, AsyncSnapshot<List<Transaction>> psnap) {
                    final List<Transaction> rows =
                        psnap.data ?? <Transaction>[];
                    final Map<String, PriceStats> all = summarizeAll(
                      rows
                          .map(
                            (Transaction r) => (
                              category: r.category,
                              note: r.note,
                              amountFen: r.amountFen,
                            ),
                          )
                          .toList(),
                    );
                    final PriceStats? stats = all[priceKey];
                    if (stats == null) return const SizedBox.shrink();
                    final int? cur = parseAmountToFen(_amount);
                    final String tail = cur == null
                        ? '共 ${stats.count} 笔'
                        : '共 ${stats.count} 笔 · 这次${describeVsAvg(currentFen: cur, avgFen: stats.avgFen)}';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '常买均价 ${formatFen(stats.avgFen)} · 最低 ${formatFen(stats.minFen)} · $tail',
                        style: Theme.of(pctx).textTheme.bodySmall,
                        key: const Key('priceHint'),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            AmountKeyboard(
              onKey: (String k) =>
                  setState(() => _amount = applyKey(_amount, k)),
              onBackspace: () =>
                  setState(() => _amount = applyKey(_amount, 'back')),
            ),
            const SizedBox(height: RunwaySpacing.section),
            AnimatedScale(
              scale: 1,
              duration: MotionSpec.press,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                key: const Key('saveEntry'),
                child: Text(_saving ? '保存中…' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
