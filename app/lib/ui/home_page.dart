import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../logic/entry.dart';
import 'quick_add_page.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-004 · 主屏（记录列表可查/可改/可删；重开 App 数据仍在，文件库持久化）.
// Hero 主卡沿 §3（AppTheme.heroCard）；列表行分隔仅用 hairline（§1.3）.

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.db});

  final AppDb db;

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => QuickAddPage(db: db)));
  }

  Future<void> _edit(BuildContext context, Transaction row) async {
    final TextEditingController note = TextEditingController(text: row.note);
    String category = row.category;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext dctx, StateSetter setDialogState) => AlertDialog(
          title: const Text('编辑记录'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final String c in defaultCategories)
                    ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setDialogState(() => category = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: '备注'),
                maxLength: 200,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dctx).pop(true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    try {
      if (ok == true) {
        await db.updateOne(
          TransactionsCompanion(
            id: Value(row.id),
            amountFen: Value(row.amountFen),
            occurredAt: Value(row.occurredAt),
            category: Value(category),
            note: Value(note.text),
            source: Value(row.source),
          ),
        );
      }
    } finally {
      note.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('攒够')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Transaction>>(
          stream: db.watchAll(),
          builder: (BuildContext ctx, AsyncSnapshot<List<Transaction>> snap) {
            final List<Transaction> rows = snap.data ?? <Transaction>[];
            final int total = rows.fold<int>(0, (p, r) => p + r.amountFen);
            return ListView(
              padding: const EdgeInsets.all(RunwaySpacing.page),
              children: <Widget>[
                Container(
                  decoration: AppTheme.heroCard(),
                  padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '本月已记（示例数据）',
                        style: TextStyle(
                          fontSize: RunwayHero.titleSize,
                          color: RunwayHero.title,
                        ),
                      ),
                      Text(
                        formatFen(total),
                        style: const TextStyle(
                          fontSize: RunwayHero.numberSize,
                          color: RunwayHero.number,
                          fontWeight: FontWeight.w700,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                        key: const Key('homeTotal'),
                      ),
                      const Text(
                        '本地加密保存',
                        style: TextStyle(
                          fontSize: RunwayHero.subSize,
                          color: RunwayHero.sub,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RunwaySpacing.section),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      '还没有记录，点右下角记第一笔',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      key: const Key('emptyHint'),
                    ),
                  ),
                for (final Transaction r in rows)
                  Card(
                    child: ListTile(
                      title: Text(
                        '${r.category} · ${formatFen(r.amountFen)}',
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        r.note.isEmpty ? '无备注' : r.note,
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: '编辑',
                            onPressed: () => _edit(context, r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: '删除',
                            onPressed: () => db.deleteOne(r.id),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        tooltip: '记一笔',
        child: const Icon(Icons.add),
      ),
    );
  }
}
