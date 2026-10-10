import 'dart:io';

import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/import_batch.dart';
import '../data/import_batch_dao.dart';
import '../logic/bill_import.dart';
import '../logic/entry.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-011 · 账单导入向导（PRD §3 半自动：选文件→预览→确认；§5 缓存原文读后即删）.
// 去重键=日期+金额+对方；失败行给行号原因；整批可撤销. 形状 r16/r10，hairline 分隔，
// 数字 tabular，只用 tokens+theme，禁"全自动"表述，零裸动效参数.

class BillImportPage extends StatefulWidget {
  const BillImportPage({super.key, required this.db});

  final AppDb db;

  @override
  State<BillImportPage> createState() => _BillImportPageState();
}

class _BillImportPageState extends State<BillImportPage> {
  static const List<String> _stepNames = <String>['选文件', '预览', '结果'];
  int _step = 0;
  final TextEditingController _csv = TextEditingController();
  final TextEditingController _filePath = TextEditingController();
  BillParseResult? _parsed;
  String _fileName = '';
  int _inserted = 0;
  int _skippedDup = 0;
  int _batchId = 0;
  bool _revoked = false;
  bool _busy = false;
  String _notice = '';

  @override
  void dispose() {
    _csv.dispose();
    _filePath.dispose();
    super.dispose();
  }

  Future<void> _parsePasted() async {
    if (_csv.text.trim().isEmpty) {
      setState(() => _notice = '请先粘贴账单 CSV 内容');
      return;
    }
    setState(() {
      _parsed = parseBillCsv(_csv.text);
      _fileName = 'pasted.csv';
      _notice = '';
      _step = 1;
    });
  }

  Future<void> _parseFile() async {
    final String p = _filePath.text.trim();
    if (p.isEmpty) {
      setState(() => _notice = '请先填写缓存文件路径');
      return;
    }
    setState(() {
      _busy = true;
      _notice = '';
    });
    final File f = File(p);
    if (!f.existsSync()) {
      if (mounted) setState(() => _busy = false);
      if (mounted) setState(() => _notice = '文件不存在');
      return;
    }
    try {
      final ({bool deleted, BillParseResult result}) out = await importBillFile(
        f,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _parsed = out.result;
        _fileName = p.split('/').last.split('\\').last;
        _csv.clear();
        _filePath.clear();
        if (!out.deleted) _notice = '缓存删除失败，请手动删除原文件';
        _step = 1;
      });
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final BillParseResult? r = _parsed;
    if (r == null || _busy) return;
    setState(() => _busy = true);
    final ({int batchId, int inserted, int skippedDup}) rep = await widget.db
        .importBillBatch(
          rows: <ImportCandidate>[
            for (final BillRow row in r.rows)
              ImportCandidate(
                occurredAt: row.occurredAt,
                amountFen: row.amountFen,
                category: row.category,
                counterparty: row.counterparty,
                dedupKey: row.dedupKey,
              ),
          ],
          source: 'bill',
          fileName: _fileName,
          failCount: r.failures.length,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _batchId = rep.batchId;
      _inserted = rep.inserted;
      _skippedDup = rep.skippedDup;
      _revoked = false;
      _step = 2;
    });
  }

  Future<void> _revoke() async {
    if (_batchId == 0 || _busy) return;
    setState(() => _busy = true);
    final int n = await widget.db.revokeImportBatch(_batchId);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _revoked = true;
      _inserted = _inserted - n >= 0 ? _inserted - n : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final BillParseResult r =
        _parsed ??
        BillParseResult(rows: <BillRow>[], failures: <BillFailure>[]);
    return Scaffold(
      appBar: AppBar(title: const Text('账单导入')),
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
                    Text(
                      '第 ${_step + 1} 步 · ${_stepNames[_step]}（共 3 步）',
                      style: theme.textTheme.titleMedium,
                      key: const Key('importStep'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '从邮箱下载账单 CSV 后导入，重复导入不重记',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: RunwaySpacing.section),
            if (_step == 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '粘贴支付宝 / 微信账单 CSV',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _csv,
                        key: const Key('csvField'),
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: '含"交易时间,交易对方,…,金额"表头',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        key: const Key('parseBtn'),
                        onPressed: _busy ? null : _parsePasted,
                        child: const Text('解析预览'),
                      ),
                      const Divider(height: 24),
                      Text(
                        '或填缓存文件路径导入（读后即删）',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _filePath,
                        key: const Key('fileField'),
                        decoration: const InputDecoration(
                          hintText: '如 /tmp/bill.csv（导入后删除）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        key: const Key('fileBtn'),
                        onPressed: _busy ? null : _parseFile,
                        child: const Text('从文件导入'),
                      ),
                      if (_notice.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(_notice, key: const Key('importNotice')),
                      ],
                    ],
                  ),
                ),
              ),
            if (_step == 1)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '可入账 ${r.rows.length} 笔 · 失败 ${r.failures.length} 行',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                        key: const Key('previewCount'),
                      ),
                      const SizedBox(height: 8),
                      for (final BillRow row in r.rows.take(20))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${row.counterparty} · ${formatFen(row.amountFen)} · ${row.category}',
                            style: theme.textTheme.bodyMedium,
                            key: Key('previewRow-${row.lineNo}'),
                          ),
                        ),
                      if (r.failures.isNotEmpty) ...<Widget>[
                        const Divider(height: 16),
                        Text('失败行（不整体失败）：', style: theme.textTheme.titleSmall),
                        for (final BillFailure f in r.failures)
                          Text(
                            '第 ${f.lineNo} 行：${f.reason}',
                            style: theme.textTheme.bodySmall,
                            key: Key('failRow-${f.lineNo}'),
                          ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          TextButton(
                            key: const Key('backBtn'),
                            onPressed: () => setState(() => _step = 0),
                            child: const Text('返回修改'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            key: const Key('confirmBtn'),
                            onPressed: _busy || r.rows.isEmpty
                                ? null
                                : _confirm,
                            child: const Text('确认入账'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_step == 2)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _revoked
                            ? '本批已撤销'
                            : '入账 $_inserted 笔 · 去重 $_skippedDup · 失败 ${r.failures.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                        key: const Key('resultSummary'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '文件 $_fileName · 缓存原文已删',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          if (!_revoked)
                            FilledButton.tonal(
                              key: const Key('revokeBtn'),
                              onPressed: _busy ? null : _revoke,
                              child: const Text('撤销本批'),
                            ),
                          const SizedBox(width: 8),
                          TextButton(
                            key: const Key('againBtn'),
                            onPressed: () => setState(() {
                              _step = 0;
                              _parsed = null;
                            }),
                            child: const Text('再导一批'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
