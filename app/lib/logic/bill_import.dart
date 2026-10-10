// SB-011 · 账单文件导入解析（PRD §3 半自动口径 / §5 处理后不留原文副本 / §4 本文件禁 import flutter）.
// CSV 轻量 in-repo 实现（零 pub 依赖，卡约束）：RFC4180 子集（引号/逗号/转义引号/换行容忍）.
// 去重键=日期+金额+对方（卡验收 2）；失败行给出行号原因，不整体失败（验收 1）.
// 原文件不留副本：importBillFile 读后即删缓存（单测断言，验收 4）.
// 产品文案统一半自动口径：本文件及全库禁止"全自动"表述.

import 'dart:io';

import 'category_rules.dart';
import 'entry.dart';

/// 账单来源（表头自适应识别；未知按通用列名兜底）.
enum BillSource { alipay, wechat, generic }

/// 解析出的单行（结构化-only；无原文整行留存）.
class BillRow {
  BillRow({
    required this.lineNo,
    required this.occurredAt,
    required this.amountFen,
    required this.counterparty,
    required this.product,
    required this.direction,
    required this.category,
    required this.dedupKey,
  });

  final int lineNo;
  final DateTime occurredAt;
  final int amountFen;
  final String counterparty;
  final String product;
  final String direction;
  final String category;
  final String dedupKey;
}

/// 失败行（行号+原因；解析整体不失败）.
class BillFailure {
  BillFailure({required this.lineNo, required this.reason});

  final int lineNo;
  final String reason;
}

/// 解析结果（成功行+失败行并存）.
class BillParseResult {
  BillParseResult({required this.rows, required this.failures});

  final List<BillRow> rows;
  final List<BillFailure> failures;
}

/// 去重键：日期(天)+金额分+对方（卡验收 2 口径）.
String billDedupKey({
  required DateTime occurredAt,
  required int amountFen,
  required String counterparty,
}) {
  final String day =
      '${occurredAt.year.toString().padLeft(4, '0')}-'
      '${occurredAt.month.toString().padLeft(2, '0')}-'
      '${occurredAt.day.toString().padLeft(2, '0')}';
  return '$day|$amountFen|${counterparty.trim()}';
}

/// CSV 行切分（引号包裹/逗号/双引号转义；轻量实现）.
List<String> splitCsvLine(String line) {
  final List<String> out = <String>[];
  final StringBuffer cur = StringBuffer();
  bool inQuotes = false;
  for (int i = 0; i < line.length; i++) {
    final String ch = line[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          cur.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cur.write(ch);
      }
    } else {
      if (ch == '"') {
        inQuotes = true;
      } else if (ch == ',') {
        out.add(cur.toString());
        cur.clear();
      } else {
        cur.write(ch);
      }
    }
  }
  out.add(cur.toString());
  return out.map((String s) => s.trim()).toList();
}

int _colOf(List<String> header, List<String> names) {
  for (final String n in names) {
    final int i = header.indexWhere((String h) => h.contains(n));
    if (i >= 0) return i;
  }
  return -1;
}

BillSource detectBillSource(List<String> header) {
  final String joined = header.join(',');
  if (joined.contains('交易订单号')) return BillSource.alipay;
  if (joined.contains('交易单号')) return BillSource.wechat;
  if (joined.contains('收/支')) return BillSource.generic;
  return BillSource.generic;
}

String _cleanAmount(String raw) {
  return raw
      .replaceAll('￥', '')
      .replaceAll('¥', '')
      .replaceAll('元', '')
      .replaceAll(',', '')
      .trim();
}

DateTime? _parseBillTime(String raw) {
  String s = raw.trim().replaceAll('/', '-');
  if (s.isEmpty) return null;
  // 微信/支付宝常见 `2026-09-01 12:34:56`；容忍 `T` 与秒缺失.
  s = s.replaceAll('T', ' ');
  DateTime? v = DateTime.tryParse(s);
  if (v != null) return v;
  // 日期-only 回退为当日 00:00.
  final RegExp d = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
  final RegExpMatch? m = d.firstMatch(s);
  if (m != null) {
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }
  return null;
}

bool _isSuccessStatus(String status) {
  if (status.trim().isEmpty) return true;
  final String s = status.trim();
  const List<String> ok = <String>['交易成功', '支付成功', '已完成', '成功'];
  for (final String k in ok) {
    if (s.contains(k)) return true;
  }
  return false;
}

/// 解析账单 CSV 全文 → 成功行+失败行（整体不抛；空文件即 0 行+1 失败说明）.
BillParseResult parseBillCsv(String content) {
  final List<String> lines = content
      .split(RegExp(r'\r?\n'))
      .where((String l) => l.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    return BillParseResult(
      rows: <BillRow>[],
      failures: <BillFailure>[BillFailure(lineNo: 0, reason: '文件为空')],
    );
  }
  // 跳过支付宝式注释头（以 # / 交易时间段 开头的非表头行）.
  int headIdx = 0;
  while (headIdx < lines.length &&
      !lines[headIdx].contains('交易时间') &&
      !lines[headIdx].contains('交易對方')) {
    headIdx++;
  }
  if (headIdx >= lines.length) {
    return BillParseResult(
      rows: <BillRow>[],
      failures: <BillFailure>[BillFailure(lineNo: 1, reason: '缺少表头(含交易时间列)')],
    );
  }
  final List<String> header = splitCsvLine(lines[headIdx]);
  final int cTime = _colOf(header, <String>['交易时间']);
  final int cParty = _colOf(header, <String>['交易对方', '交易對方', '对方']);
  final int cProduct = _colOf(header, <String>['商品说明', '商品']);
  final int cDir = _colOf(header, <String>['收/支', '收支', '方向']);
  final int cAmt = _colOf(header, <String>['金额']);
  final int cStatus = _colOf(header, <String>['交易状态', '当前状态', '状态']);
  final List<BillRow> rows = <BillRow>[];
  final List<BillFailure> failures = <BillFailure>[];
  if (cTime < 0 || cParty < 0 || cAmt < 0) {
    return BillParseResult(
      rows: <BillRow>[],
      failures: <BillFailure>[
        BillFailure(lineNo: headIdx + 1, reason: '表头缺关键列(时间/对方/金额)'),
      ],
    );
  }
  for (int i = headIdx + 1; i < lines.length; i++) {
    final int lineNo = i + 1;
    final List<String> cols = splitCsvLine(lines[i]);
    String at(int c) => c >= 0 && c < cols.length ? cols[c].trim() : '';
    final String timeRaw = at(cTime);
    final String partyRaw = at(cParty);
    final String amtRaw = at(cAmt);
    final String statusRaw = cStatus >= 0 ? at(cStatus) : '';
    final String productRaw = cProduct >= 0 ? at(cProduct) : '';
    final String dirRaw = cDir >= 0 ? at(cDir) : '';
    if (timeRaw.isEmpty && partyRaw.isEmpty && amtRaw.isEmpty) continue;
    if (!_isSuccessStatus(statusRaw)) {
      failures.add(BillFailure(lineNo: lineNo, reason: '非成功状态已跳过($statusRaw)'));
      continue;
    }
    final DateTime? when = _parseBillTime(timeRaw);
    if (when == null) {
      failures.add(BillFailure(lineNo: lineNo, reason: '时间格式无效($timeRaw)'));
      continue;
    }
    if (partyRaw.isEmpty) {
      failures.add(BillFailure(lineNo: lineNo, reason: '交易对方为空'));
      continue;
    }
    final int? fen = parseAmountToFen(_cleanAmount(amtRaw));
    if (fen == null) {
      failures.add(BillFailure(lineNo: lineNo, reason: '金额无效($amtRaw)'));
      continue;
    }
    String party = partyRaw.trim();
    if (party.length > 32) party = party.substring(0, 32);
    final String category = canonicalCategory(
      classifyTransaction(
        merchant: '$party $productRaw'.trim(),
        amountFen: fen,
      ),
    );
    rows.add(
      BillRow(
        lineNo: lineNo,
        occurredAt: when,
        amountFen: fen,
        counterparty: party,
        product: productRaw.trim(),
        direction: dirRaw.trim(),
        category: category,
        dedupKey: billDedupKey(
          occurredAt: when,
          amountFen: fen,
          counterparty: party,
        ),
      ),
    );
  }
  return BillParseResult(rows: rows, failures: failures);
}

/// 导入缓存文件：读→解析→返回结果，**读后即删原文缓存**（§5 不留副本）.
/// 调用方负责落库；删失败不阻塞解析（返回 deleted=false 供上报）.
Future<({BillParseResult result, bool deleted})> importBillFile(
  File cacheFile,
) async {
  final String content = await cacheFile.readAsString();
  final BillParseResult result = parseBillCsv(content);
  bool deleted = false;
  try {
    await cacheFile.delete();
    deleted = true;
  } catch (_) {
    deleted = false;
  }
  return (result: result, deleted: deleted);
}
