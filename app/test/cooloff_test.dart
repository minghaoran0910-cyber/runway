import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/cooloff.dart';

// SB-017 · 大额冷静期引擎单测（纯函数；合成数据，真实账目=0）.

CooloffCandidate c(int fen, String source, DateTime t) =>
    CooloffCandidate(amountFen: fen, source: source, occurredAt: t);

void main() {
  test('默认倍数=3（卡口径 日均×3）', () {
    expect(defaultCooloffMultiple, 3);
  });

  test('冷静窗=24h', () {
    expect(cooloffWindow, const Duration(hours: 24));
  });

  test('cooloffThreshold 自动=日均×3', () {
    expect(cooloffThreshold(dailyAvgFen: 5000), 15000);
  });

  test('cooloffThreshold 自定义优先', () {
    expect(cooloffThreshold(dailyAvgFen: 5000, customFen: 20000), 20000);
  });

  test('cooloffThreshold 日均0即0零编造', () {
    expect(cooloffThreshold(dailyAvgFen: 0), 0);
    expect(cooloffThreshold(dailyAvgFen: -5), 0);
  });

  test('shouldPropose 手动大额即触发', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldProposeCooloff(
        candidate: c(20000, 'manual', now),
        thresholdFen: 15000,
        alreadyProposed: false,
      ),
      isTrue,
    );
  });

  test('shouldPropose 等阈值即触发（>=）', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldProposeCooloff(
        candidate: c(15000, 'manual', now),
        thresholdFen: 15000,
        alreadyProposed: false,
      ),
      isTrue,
    );
  });

  test('shouldPropose 未达阈值不触发', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldProposeCooloff(
        candidate: c(14999, 'manual', now),
        thresholdFen: 15000,
        alreadyProposed: false,
      ),
      isFalse,
    );
  });

  test('shouldPropose 采集/导入/估算不触发（只手动）', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    for (final String s in <String>['notify', 'import', 'estimate']) {
      expect(
        shouldProposeCooloff(
          candidate: c(999999, s, now),
          thresholdFen: 15000,
          alreadyProposed: false,
        ),
        isFalse,
        reason: 'source=$s 不应触发',
      );
    }
  });

  test('shouldPropose 已建单不弹第二次', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldProposeCooloff(
        candidate: c(999999, 'manual', now),
        thresholdFen: 15000,
        alreadyProposed: true,
      ),
      isFalse,
    );
  });

  test('shouldPropose 阈值0不问', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldProposeCooloff(
        candidate: c(999999, 'manual', now),
        thresholdFen: 0,
        alreadyProposed: false,
      ),
      isFalse,
    );
  });

  test('shouldExpire 24h边界', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldExpireCooloff(
        proposedAt: now.subtract(const Duration(hours: 23, minutes: 59)),
        now: now,
      ),
      isFalse,
    );
    expect(
      shouldExpireCooloff(
        proposedAt: now.subtract(const Duration(hours: 24)),
        now: now,
      ),
      isTrue,
    );
    expect(
      shouldExpireCooloff(
        proposedAt: now.subtract(const Duration(hours: 25)),
        now: now,
      ),
      isTrue,
    );
  });

  test('提出文案口径 24小时+金额', () {
    final String t = cooloffAskText(amountFen: 20000);
    expect(t, contains('¥200'));
    expect(t, contains('24 小时'));
  });

  test('副文案口径 決定权在人（仍要买不等待）', () {
    expect(cooloffAskHint(), contains('仍要买'));
  });

  test('忍住文案口径 省额+称号（复用SB-014池）', () {
    final String t = cooloffHeldText(savedFen: 20000, targetFen: 1649900);
    expect(t, contains('省出 ¥200'));
    expect(t, isNotEmpty);
  });

  test('仍要买文案中性无摩擦词', () {
    expect(cooloffBoughtText(amountFen: 20000), contains('已记 ¥200'));
  });

  test('超时文案静默记入不补弹', () {
    expect(cooloffExpiredText(amountFen: 20000), contains('已记'));
  });

  test('文案零禁词（问/副/忍住/仍要买/超时）', () {
    final List<String> texts = <String>[
      cooloffAskText(amountFen: 20000),
      cooloffAskHint(),
      cooloffHeldText(savedFen: 20000, targetFen: 1649900),
      cooloffBoughtText(amountFen: 20000),
      cooloffExpiredText(amountFen: 20000),
    ];
    for (final String t in texts) {
      for (final String w in achievementBannedWords) {
        expect(t.contains(w), isFalse, reason: '文案命中禁词 $w：$t');
      }
    }
  });

  test('文案零说教零恐吓抽查', () {
    const List<String> preachy = <String>[
      '说教',
      '惩罚',
      '冲动',
      '剁手',
      '警告',
      '克制',
      '自律',
      '后悔',
      '罪恶',
      '浪费',
    ];
    final List<String> texts = <String>[
      cooloffAskText(amountFen: 20000),
      cooloffAskHint(),
      cooloffHeldText(savedFen: 20000, targetFen: 1649900),
      cooloffBoughtText(amountFen: 20000),
      cooloffExpiredText(amountFen: 20000),
    ];
    for (final String t in texts) {
      for (final String w in preachy) {
        expect(t.contains(w), isFalse, reason: '文案命中说教词 $w：$t');
      }
    }
  });

  test('validateCooloffCustomFen 口径（0=自动）', () {
    expect(validateCooloffCustomFen(0), isNull);
    expect(validateCooloffCustomFen(20000), isNull);
    expect(validateCooloffCustomFen(null), isNotNull);
    expect(validateCooloffCustomFen(-1), isNotNull);
  });

  test('validateCooloffAmountFen 口径', () {
    expect(validateCooloffAmountFen(null), isNotNull);
    expect(validateCooloffAmountFen(0), isNotNull);
    expect(validateCooloffAmountFen(100), isNull);
  });

  test('状态值域锁定（pending/bought/held/expired）', () {
    for (final String s in <String>['pending', 'bought', 'held', 'expired']) {
      expect(
        CooloffDecision(
          amountFen: 1,
          proposedAt: DateTime.now(),
          status: s,
        ).status,
        s,
      );
    }
  });
}
