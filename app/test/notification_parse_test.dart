import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/notification_parse.dart';

// SB-010 · 通知解析单测（合成 fixtures；真机走查见卡验收 5）.
// 覆盖：双渠道解析/丢弃口径/金额精度/引擎归类/去重键/风暴/DAO 幂等/原文零落库/禁词 grep.

void main() {
  test('SB-010 支付宝到账：金额/商户/归类', () {
    final PendingDraft? d = parsePaymentNotice(
      packageName: alipayPackage,
      title: '支付宝',
      text: '支付宝到账12.34元',
      now: DateTime(2026, 10, 10, 9, 30),
    );
    expect(d, isNotNull);
    expect(d!.amountFen, 1234);
    expect(d.merchant, '支付宝');
    expect(d.sourcePkg, alipayPackage);
  });

  test('SB-010 微信收款：标题即商户', () {
    final PendingDraft? d = parsePaymentNotice(
      packageName: wechatPackage,
      title: '瑞幸咖啡',
      text: '微信支付收款25.5元',
      now: DateTime(2026, 10, 10, 9, 31),
    );
    expect(d, isNotNull);
    expect(d!.amountFen, 2550);
    expect(d.merchant, '瑞幸咖啡');
    // SB-005 引擎接入：瑞幸→食（无第二套口径）.
    expect(d.category, '食');
  });

  test('SB-010 转账通知：￥格式', () {
    final PendingDraft? d = parsePaymentNotice(
      packageName: alipayPackage,
      title: '张三',
      text: '收到一笔转账 ￥200',
      now: DateTime(2026, 10, 10, 9, 32),
    );
    expect(d, isNotNull);
    expect(d!.amountFen, 20000);
    expect(d.merchant, '张三');
  });

  test('SB-010 非目标包丢弃', () {
    expect(
      parsePaymentNotice(
        packageName: 'com.example.bank',
        title: '银行',
        text: '到账12.34元',
      ),
      isNull,
    );
  });

  test('SB-010 非支付通知丢弃（验证码/系统）', () {
    expect(
      parsePaymentNotice(
        packageName: wechatPackage,
        title: '微信',
        text: '你的验证码是 482913，五分钟内有效',
      ),
      isNull,
    );
    expect(
      parsePaymentNotice(
        packageName: alipayPackage,
        title: '系统',
        text: '花呗本月账单已出',
      ),
      isNull,
    );
  });

  test('SB-010 金额精度：12.34→1234 分，0 元非法', () {
    expect(
      parsePaymentNotice(packageName: alipayPackage, title: '店', text: '到账0元'),
      isNull,
    );
    final PendingDraft? d = parsePaymentNotice(
      packageName: alipayPackage,
      title: '店',
      text: '到账0.5元',
    );
    expect(d!.amountFen, 50);
  });

  test('SB-010 空标题回退渠道名，超长商户截断', () {
    final PendingDraft? d = parsePaymentNotice(
      packageName: wechatPackage,
      title: '',
      text: '收款10元',
    );
    expect(d!.merchant, '微信支付');
    final String long = '超长商户名' * 10;
    final PendingDraft? d2 = parsePaymentNotice(
      packageName: alipayPackage,
      title: long,
      text: '到账10元',
    );
    expect(d2!.merchant.length, lessThanOrEqualTo(32));
  });

  test('SB-010 去重键：同身份同when同键，when不同异键（验收4身份制）', () {
    const int w1 = 1760000000000;
    const int w2 = 1760000001000;
    final String k1 = makeNotifyKey(
      packageName: alipayPackage,
      title: '店',
      amountFen: 1000,
      whenMs: w1,
      postTimeMs: w1,
    );
    final String k2 = makeNotifyKey(
      packageName: alipayPackage,
      title: '店',
      amountFen: 1000,
      whenMs: w1,
      postTimeMs: w1,
    );
    final String k3 = makeNotifyKey(
      packageName: alipayPackage,
      title: '店',
      amountFen: 1000,
      whenMs: w2,
      postTimeMs: w2,
    );
    expect(k1, k2);
    expect(k1 == k3, isFalse);
  });

  test('SB-010R2 去重键哈希化：40位hex且不含标题明文（§5值级）', () {
    const String title = '张三早餐店消费';
    const int w = 1760000000000;
    final String k = makeNotifyKey(
      packageName: alipayPackage,
      title: title,
      amountFen: 820,
      whenMs: w,
      postTimeMs: w,
    );
    // SHA-1 hex 形状.
    expect(k.length, 40);
    expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(k), isTrue);
    // 值级原文零落库：键中不得出现标题明文子串（含 2 字以上片段）.
    for (int i = 0; i + 2 <= title.length; i++) {
      expect(k.contains(title.substring(i, i + 2)), isFalse);
    }
    // 去重语义（身份制）：同身份同 when 同键，when 不同异键.
    final String same = makeNotifyKey(
      packageName: alipayPackage,
      title: title,
      amountFen: 820,
      whenMs: w,
      postTimeMs: w,
    );
    final String next = makeNotifyKey(
      packageName: alipayPackage,
      title: title,
      amountFen: 820,
      whenMs: w + 1000,
      postTimeMs: w + 1000,
    );
    expect(same, k);
    expect(next == k, isFalse);
  });

  test('SB-010R2 SHA-1标准向量：内容哈希+身份键（与Kotlin MessageDigest对拍）', () {
    // 标准SHA-1（FIPS 180-4，UTF-8）已知答案，锁定纯Dart实现与
    // Android侧MessageDigest.SHA-1一致；内容预镜像=`包|标题|金额分`.
    expect(
      notifyContentHash(packageName: '', title: '', amountFen: 0),
      'd2abfc062166748fe6f65cd607650e7697768649',
    );
    expect(
      notifyContentHash(packageName: 'a', title: 'b', amountFen: 99),
      'ebadb7a4a47ddd58c50467429e1e65414cda395a',
    );
    // 身份键向量：包=com.eg.android.AlipayGphone/标题=店/1000分/
    // tag=''/id=0/when=1760000000000 → edc5af55….
    expect(
      makeNotifyKey(
        packageName: alipayPackage,
        title: '店',
        amountFen: 1000,
        whenMs: 1760000000000,
        postTimeMs: 1760000000000,
      ),
      'edc5af55eef780e31fb2cf3a0ddbfee986f21aeb',
    );
  });

  test('SB-010R2 金额边界：8.20→820分（Kotlin侧BigDecimal HALF_UP镜像）', () {
    // Dart 侧 parseAmountToFen 为字符串精确解析，天然无浮点截断；
    // 此用例锁定与 Kotlin 侧 BigDecimal(path) 对齐的边界值（旧 Kotlin
    // toDouble*100+toInt 截断得 819，第 1 轮问题 2；现两侧均为 820）.
    final PendingDraft? d = parsePaymentNotice(
      packageName: alipayPackage,
      title: '店',
      text: '到账8.20元',
    );
    expect(d!.amountFen, 820);
    final PendingDraft? d2 = parsePaymentNotice(
      packageName: wechatPackage,
      title: '店',
      text: '微信支付收款8.20元',
    );
    expect(d2!.amountFen, 820);
  });

  test('SB-010 通知风暴：1 分钟 50 条合成不丢', () {
    const int base = 1760000000000;
    final Set<String> keys = <String>{};
    for (int i = 0; i < 50; i++) {
      final PendingDraft? d = parsePaymentNotice(
        packageName: i.isEven ? alipayPackage : wechatPackage,
        title: '商户$i',
        text: '到账${10 + i}.00元',
        tag: '',
        notifId: i,
        whenMs: base + i * 1000,
        postTimeMs: base + i * 1000,
      );
      expect(d, isNotNull);
      keys.add(d!.notifyKey);
    }
    // 50 条身份各异（tag/id/when 不同）→ 50 个互异键（风暴不丢）.
    expect(keys.length, 50);
  });

  test('SB-010 重复投递：同身份同when去重为 1', () {
    const int w = 1760000000000;
    final PendingDraft a = parsePaymentNotice(
      packageName: alipayPackage,
      title: '店',
      text: '到账10元',
      tag: 't0',
      notifId: 42,
      whenMs: w,
      postTimeMs: w,
    )!;
    final PendingDraft b = parsePaymentNotice(
      packageName: alipayPackage,
      title: '店',
      text: '到账10元',
      tag: 't0',
      notifId: 42,
      whenMs: w,
      postTimeMs: w,
    )!;
    expect(a.notifyKey, b.notifyKey);
  });

  test('SB-010 DAO：insertPendingDedup 同键幂等', () async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    PendingRecordsCompanion entry() => PendingRecordsCompanion(
      amountFen: const Value(1000),
      occurredAt: Value(DateTime(2026, 10, 10, 9, 30)),
      category: const Value('食'),
      merchant: const Value('店'),
      sourcePkg: Value(alipayPackage),
      notifyKey: const Value('k-dedup-1'),
    );
    final int id1 = await db.insertPendingDedup(entry());
    final int id2 = await db.insertPendingDedup(entry());
    expect(id1, id2);
    expect((await db.listPending()).length, 1);
  });

  test('SB-010 DAO：一键入账走 transactions（source=notify）', () async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: const Value(2550),
        occurredAt: Value(DateTime(2026, 10, 10, 9, 31)),
        category: const Value('食'),
        merchant: const Value('瑞幸咖啡'),
        sourcePkg: Value(wechatPackage),
        notifyKey: const Value('k-confirm-1'),
      ),
    );
    final PendingRecord row = (await db.listPending()).single;
    await db.confirmPending(row);
    expect(await db.listPending(), isEmpty);
    final List<Transaction> txs = await db.listAll();
    expect(txs.length, 1);
    expect(txs.single.amountFen, 2550);
    expect(txs.single.note, '瑞幸咖啡');
    expect(txs.single.source, 'notify');
  });

  test('SB-010 DAO：rollbackPendingToV4 回滚后 pending 不可用', () async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    await db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: const Value(100),
        occurredAt: Value(DateTime(2026, 10, 10)),
        category: const Value('食'),
        merchant: const Value('店'),
        notifyKey: const Value('k-rb-1'),
      ),
    );
    await db.rollbackPendingToV4();
    await expectLater(db.listPending(), throwsA(anything));
  });

  test('SB-010 隐私红线：pending 表无原文列', () async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final Map<String, Expression<Object>> cols = PendingRecordsCompanion(
      amountFen: const Value(1),
      occurredAt: Value(DateTime(2026, 10, 10)),
      category: const Value('食'),
      merchant: const Value('店'),
      sourcePkg: const Value('p'),
      notifyKey: const Value('k'),
    ).toColumns(false);
    for (final String name in cols.keys) {
      expect(
        RegExp(
          'raw|content|body|text|message',
          caseSensitive: false,
        ).hasMatch(name),
        isFalse,
        reason: '原文列嫌疑：$name',
      );
    }
  });

  test('SB-010 文案红线：全库禁"全自动"表述', () {
    // 作用域：Dart + 原生（kt/xml）；含"禁"字的行是禁令声明本身，予以豁免，
    // 其余任何命中均为用户可见文案/代码表述违规.
    final List<String> hits = <String>[];
    for (final String dir in <String>['lib', '../packages', 'android']) {
      final Directory d = Directory(dir);
      if (!d.existsSync()) continue;
      for (final FileSystemEntity e in d.listSync(recursive: true)) {
        if (e is! File) continue;
        final String p = e.path;
        if (!(p.endsWith('.dart') || p.endsWith('.kt') || p.endsWith('.xml'))) {
          continue;
        }
        final List<String> lines = File(p).readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final String line = lines[i];
          if (line.contains('全自动') && !line.contains('禁')) {
            hits.add('$p:${i + 1}:$line');
          }
        }
      }
    }
    expect(hits, isEmpty, reason: '违规表述命中：$hits');
  });
}
