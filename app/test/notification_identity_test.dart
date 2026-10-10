import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/notification_parse.dart';

// SB-010R3 · 通知对象身份去重（验收 4，d6ae1ab 定稿，废时间桶）.
// 卡要求 3 条单测：①同商户同金额不同 when → 保留 2 条
// ②同通知重投（三同）→ 仅 1 条 ③回退路径生效.
// 已知边界（卡 4b）：when 系 App 自报，同秒两笔理论可并（人手不可达）；
// 通知重建出毫秒级新 when 的罕见情形多出一条待确认，由待确认池消化，非静默错账.
// 合成 fixtures，真实账目=0；键体 40 位 hex，标题原文不明文落库（§5 不变）.

void main() {
  test('SB-010R3 验收4①：同商户同金额不同when → 保留 2 条', () async {
    const int w1 = 1760000000000;
    const int w2 = 1760000001000;
    final PendingDraft a = parsePaymentNotice(
      packageName: alipayPackage,
      title: '店',
      text: '到账10元',
      tag: '',
      notifId: 7,
      whenMs: w1,
      postTimeMs: w1,
    )!;
    final PendingDraft b = parsePaymentNotice(
      packageName: alipayPackage,
      title: '店',
      text: '到账10元',
      tag: '',
      notifId: 7,
      whenMs: w2,
      postTimeMs: w2,
    )!;
    // when 不同 → 异键（即使同商户同金额同分钟也不吞）.
    expect(a.notifyKey == b.notifyKey, isFalse);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: Value(a.amountFen),
        occurredAt: Value(a.occurredAt),
        category: Value(a.category),
        merchant: Value(a.merchant),
        sourcePkg: Value(a.sourcePkg),
        notifyKey: Value(a.notifyKey),
      ),
    );
    await db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: Value(b.amountFen),
        occurredAt: Value(b.occurredAt),
        category: Value(b.category),
        merchant: Value(b.merchant),
        sourcePkg: Value(b.sourcePkg),
        notifyKey: Value(b.notifyKey),
      ),
    );
    expect((await db.listPending()).length, 2);
  });

  test('SB-010R3 验收4②：同通知重投（三同）→ 仅 1 条', () async {
    const int w = 1760000000000;
    PendingDraft draft() => parsePaymentNotice(
      packageName: wechatPackage,
      title: '瑞幸咖啡',
      text: '微信支付收款25.5元',
      tag: 'tag0',
      notifId: 11,
      whenMs: w,
      postTimeMs: w,
    )!;
    final PendingDraft a = draft();
    final PendingDraft b = draft();
    expect(a.notifyKey, b.notifyKey);
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final int id1 = await db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: Value(a.amountFen),
        occurredAt: Value(a.occurredAt),
        category: Value(a.category),
        merchant: Value(a.merchant),
        sourcePkg: Value(a.sourcePkg),
        notifyKey: Value(a.notifyKey),
      ),
    );
    final int id2 = await db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: Value(b.amountFen),
        occurredAt: Value(b.occurredAt),
        category: Value(b.category),
        merchant: Value(b.merchant),
        sourcePkg: Value(b.sourcePkg),
        notifyKey: Value(b.notifyKey),
      ),
    );
    expect(id1, id2);
    expect((await db.listPending()).length, 1);
  });

  test('SB-010R3 验收4③：回退路径生效（when缺失→postTime秒）', () {
    // when 缺失：同 postTime 秒 → 同键；不同秒 → 异键.
    final String f1 = makeNotifyKey(
      packageName: 'p',
      title: 't',
      amountFen: 10,
      postTimeMs: 1710000000,
    );
    final String f2 = makeNotifyKey(
      packageName: 'p',
      title: 't',
      amountFen: 10,
      postTimeMs: 1710000500,
    );
    final String f3 = makeNotifyKey(
      packageName: 'p',
      title: 't',
      amountFen: 10,
      postTimeMs: 1710001000,
    );
    expect(f1, f2);
    expect(f1 == f3, isFalse);
    // 秒级 when（非毫秒可信）同样走回退，不与毫秒键相等.
    final String secWhen = makeNotifyKey(
      packageName: 'p',
      title: 't',
      amountFen: 10,
      whenMs: 1710,
      postTimeMs: 1710000000,
    );
    expect(secWhen, f1);
    // 形状仍为 40 位 hex（§5 不变）.
    expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(f1), isTrue);
  });
}
