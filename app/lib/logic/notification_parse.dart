// SB-010 · 通知解析（PRD §3 全量采集/待确认口径 / §5 通知原文零留存 / §4 本文件禁 import flutter）.
// 输入为系统通知的包名/标题/正文（调用方解析后立即丢弃原文，不落库不写文件）；
// 输出仅结构化字段（金额分/商户/类目/时间/去重键），pending 表无原文列（单测断言）.
// 产品文案统一"待确认"口径：本文件及全库禁止"全自动"表述（单测 grep 断言覆盖）.

import 'dart:convert';

import 'category_rules.dart';
import 'entry.dart';

/// 采集目标包：支付宝 / 微信支付（其他包一律丢弃）.
const String alipayPackage = 'com.eg.android.AlipayGphone';
const String wechatPackage = 'com.tencent.mm';

/// 金额口径（与 Android 侧 PendingListenerService.AMOUNT 对齐）：
/// `12.34元` / `￥12.34` / `到账12.34元`；小数至多 2 位.
final RegExp _amountYuan = RegExp(r'(\d+(?:\.\d{1,2})?)元');
final RegExp _amountCny = RegExp(r'￥\s*(\d+(?:\.\d{1,2})?)');

/// 是否为采集目标包.
bool isCollectorPackage(String packageName) {
  return packageName == alipayPackage || packageName == wechatPackage;
}

/// 待确认草稿（结构化-only；无原文/标题原文以外的任何冗余）.
class PendingDraft {
  PendingDraft({
    required this.amountFen,
    required this.merchant,
    required this.category,
    required this.occurredAt,
    required this.sourcePkg,
    required this.notifyKey,
  });

  final int amountFen;
  final String merchant;
  final String category;
  final DateTime occurredAt;
  final String sourcePkg;
  final String notifyKey;
}

/// 毫秒可信下界：when < 1e12 视为秒级/缺失（当前毫秒 ~1.7e12，秒 ~1.7e9）.
const int notifyWhenMsThreshold = 1000000000000;

/// 内容哈希：SHA-1 hex（40 字符），原文为 `包名|标题(trim)|金额分`.
/// 与 Android 侧 PendingListenerService 同口径（MessageDigest SHA-1，UTF-8）.
/// PRD §5：标题原文只进哈希预镜像，不以明文落库.
String notifyContentHash({
  required String packageName,
  required String title,
  required int amountFen,
}) {
  return _sha1Hex('$packageName|${title.trim()}|$amountFen');
}

/// when 是否毫秒可信（缺失/秒级/0/负一律不可信，走回退）.
bool isTrustedWhenMs(int? whenMs) {
  return whenMs != null && whenMs >= notifyWhenMsThreshold;
}

/// 去重键：SHA-1 hex（40 字符），按 SB-010 验收 4『通知对象身份』（d6ae1ab 定稿，废时间桶）.
/// - when 可信：预镜像 `包名|tag|id|when毫秒|内容哈希`；
///   同 key(包|tag|id)+同 when+同内容哈希=重复投递（同键，DAO 吞），
///   when 不同→即使同商户同金额同分钟也是两笔（异键，各自入待确认）.
/// - when 缺失/非毫秒可信：回退预镜像 `包名|tag|id|内容哈希|postTime秒`.
/// 与 Android 侧 PendingListenerService.makeNotifyKey 同口径（UTF-8，分隔符 `|`）.
/// 已知边界（卡 4b）：when 系 App 自报，同秒两笔理论可并（人手不可达）；
/// 通知重建出毫秒级新 when 的罕见情形多出一条待确认，由待确认池消化，非静默错账.
/// 纯 Dart 实现（零 pub 依赖，卡约束），已知答案见单测标准向量.
String makeNotifyKey({
  required String packageName,
  String tag = '',
  int notifId = 0,
  int? whenMs,
  int? postTimeMs,
  required String title,
  required int amountFen,
}) {
  final String content = notifyContentHash(
    packageName: packageName,
    title: title,
    amountFen: amountFen,
  );
  if (isTrustedWhenMs(whenMs)) {
    return _sha1Hex('$packageName|$tag|$notifId|$whenMs|$content');
  }
  final int postSec = (postTimeMs ?? 0) ~/ 1000;
  return _sha1Hex('$packageName|$tag|$notifId|$content|$postSec');
}

/// 最小 SHA-1（FIPS 180-4），输入按 UTF-8 编码，仅供去重键哈希（非安全用途）.
String _sha1Hex(String input) {
  final List<int> bytes = utf8.encode(input);
  final int bitLen = bytes.length * 8;
  final List<int> padded = List<int>.from(bytes)..add(0x80);
  while (padded.length % 64 != 56) {
    padded.add(0);
  }
  for (int i = 7; i >= 0; i--) {
    padded.add((bitLen >> (i * 8)) & 0xFF);
  }
  const int mask = 0xFFFFFFFF;
  int rotl(int v, int n) => ((v << n) | (v >> (32 - n))) & mask;
  int h0 = 0x67452301;
  int h1 = 0xEFCDAB89;
  int h2 = 0x98BADCFE;
  int h3 = 0x10325476;
  int h4 = 0xC3D2E1F0;
  for (int off = 0; off < padded.length; off += 64) {
    final List<int> w = List<int>.filled(80, 0);
    for (int i = 0; i < 16; i++) {
      w[i] =
          (padded[off + i * 4] << 24) |
          (padded[off + i * 4 + 1] << 16) |
          (padded[off + i * 4 + 2] << 8) |
          padded[off + i * 4 + 3];
    }
    for (int i = 16; i < 80; i++) {
      w[i] = rotl(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
    }
    int a = h0, b = h1, c = h2, d = h3, e = h4;
    for (int i = 0; i < 80; i++) {
      int f, k;
      if (i < 20) {
        f = (b & c) | ((~b) & d);
        k = 0x5A827999;
      } else if (i < 40) {
        f = b ^ c ^ d;
        k = 0x6ED9EBA1;
      } else if (i < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8F1BBCDC;
      } else {
        f = b ^ c ^ d;
        k = 0xCA62C1D6;
      }
      final int tmp = (rotl(a, 5) + f + e + k + w[i]) & mask;
      e = d;
      d = c;
      c = rotl(b, 30);
      b = a;
      a = tmp;
    }
    h0 = (h0 + a) & mask;
    h1 = (h1 + b) & mask;
    h2 = (h2 + c) & mask;
    h3 = (h3 + d) & mask;
    h4 = (h4 + e) & mask;
  }
  return <int>[
    h0,
    h1,
    h2,
    h3,
    h4,
  ].map((int h) => h.toRadixString(16).padLeft(8, '0')).join();
}

int? _extractFen(String text) {
  final RegExpMatch? m =
      _amountYuan.firstMatch(text) ?? _amountCny.firstMatch(text);
  if (m == null) return null;
  return parseAmountToFen(m.group(1)!);
}

/// 解析支付通知 → 待确认草稿；非目标包/非支付通知/无有效金额一律返回 null（丢弃）.
/// [merchant] 取通知标题（截 32 字，超长截断）；空标题回退到渠道名.
/// [category] 走 SB-005 引擎（classifyTransaction），不另建第二套口径.
/// 身份参数（SB-010 验收 4）：[tag]/[notifId] 为系统通知身份（sbn.tag/sbn.id），
/// [whenMs] 为通知自报毫秒（sbn.notification.when），[postTimeMs] 为投递毫秒
/// （sbn.postTime；when 不可信时回退用）. occurredAt 取 when 可信值，否则回退
/// postTime，否则取 [now]/当前时间——仅作展示时间，去重以 notifyKey 为准.
PendingDraft? parsePaymentNotice({
  required String packageName,
  required String title,
  required String text,
  DateTime? now,
  String tag = '',
  int notifId = 0,
  int? whenMs,
  int? postTimeMs,
}) {
  if (!isCollectorPackage(packageName)) return null;
  final int? fen = _extractFen(text).orElse(() => _extractFen(title));
  if (fen == null) return null;
  if (fen <= 0) return null;
  final DateTime at = isTrustedWhenMs(whenMs)
      ? DateTime.fromMillisecondsSinceEpoch(whenMs!)
      : (postTimeMs != null && postTimeMs > 0
            ? DateTime.fromMillisecondsSinceEpoch(postTimeMs)
            : (now ?? DateTime.now()));
  String merchant = title.trim();
  if (merchant.isEmpty) {
    merchant = packageName == alipayPackage ? '支付宝' : '微信支付';
  }
  if (merchant.length > 32) merchant = merchant.substring(0, 32);
  final String category = classifyTransaction(
    merchant: merchant,
    amountFen: fen,
  );
  return PendingDraft(
    amountFen: fen,
    merchant: merchant,
    category: canonicalCategory(category),
    occurredAt: at,
    sourcePkg: packageName,
    notifyKey: makeNotifyKey(
      packageName: packageName,
      tag: tag,
      notifId: notifId,
      whenMs: whenMs,
      postTimeMs: postTimeMs,
      title: title.trim(),
      amountFen: fen,
    ),
  );
}

extension _OrElse on int? {
  int? orElse(int? Function() other) => this ?? other();
}
