import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/role_resolver.dart';
import 'package:runway/logic/week_warm.dart';

// SB-022 · 零日温度线单测（纯函数；合成数据，真实账目=0）.

({int amountFen, String category, DateTime occurredAt}) w(
  int fen,
  String c,
  DateTime t,
) => (amountFen: fen, category: c, occurredAt: t);

void main() {
  test('summarizeWeekRoles 空即全零', () {
    final WeekRoleSums s = summarizeWeekRoles(
      flows: const <({int amountFen, String category, DateTime occurredAt})>[],
      now: DateTime(2026, 10, 11, 20),
    );
    expect(s.necessaryFen, 0);
    expect(s.flexibleFen, 0);
    expect(s.fixedFen, 0);
  });

  test('summarizeWeekRoles 默认映射分组（旧名归一）', () {
    // 2026-10-11 是周日，本周一为 10-05.
    final DateTime now = DateTime(2026, 10, 11, 20);
    final WeekRoleSums s = summarizeWeekRoles(
      flows: <({int amountFen, String category, DateTime occurredAt})>[
        w(1000, '餐饮', DateTime(2026, 10, 10, 12)), // 食=必要
        w(2000, '玩', DateTime(2026, 10, 9, 12)), // 弹性
        w(3000, '居住', DateTime(2026, 10, 8, 12)), // 居=固定
        w(400, '火星开支', DateTime(2026, 10, 7, 12)), // 未知兜底弹性
      ],
      now: now,
    );
    expect(s.necessaryFen, 1000);
    expect(s.flexibleFen, 2400);
    expect(s.fixedFen, 3000);
  });

  test('summarizeWeekRoles 上周不计/下周不计', () {
    final DateTime now = DateTime(2026, 10, 8, 20); // 周四，本周一 10-05
    final WeekRoleSums s = summarizeWeekRoles(
      flows: <({int amountFen, String category, DateTime occurredAt})>[
        w(999900, '玩', DateTime(2026, 10, 4, 12)), // 上周日，排除
        w(1000, '玩', DateTime(2026, 10, 5, 0, 0)), // 本周一 00:00，计入
        w(2000, '玩', DateTime(2026, 10, 6, 12)),
      ],
      now: now,
    );
    expect(s.flexibleFen, 3000);
  });

  test('summarizeWeekRoles 覆盖优先', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    final WeekRoleSums s = summarizeWeekRoles(
      flows: <({int amountFen, String category, DateTime occurredAt})>[
        w(5000, '玩', DateTime(2026, 10, 10, 12)),
      ],
      now: now,
      overrides: <String, CategoryRole>{'玩': CategoryRole.necessary},
    );
    expect(s.necessaryFen, 5000);
    expect(s.flexibleFen, 0);
  });

  test('isZeroDay 口径（<=0 即零日）', () {
    expect(isZeroDay(savedFen: 0), isTrue);
    expect(isZeroDay(savedFen: -5), isTrue);
    expect(isZeroDay(savedFen: 1), isFalse);
  });

  test('zeroDayHeadline 三段首行：攒0+笔数', () {
    final String t = zeroDayHeadline(todayCount: 3);
    expect(t, contains('今天攒 0'));
    expect(t, contains('已记 3 笔'));
  });

  test('zeroDayEncourage 无感叹号堆叠', () {
    final String t = zeroDayEncourage();
    expect(t.contains('!'), isFalse);
    expect(t.contains('！'), isFalse);
    expect(t.isNotEmpty, isTrue);
  });

  test('weekRoleLine 只报归组金额零评判', () {
    final String t = weekRoleLine(
      sums: const WeekRoleSums(
        necessaryFen: 10000,
        flexibleFen: 20000,
        fixedFen: 0,
      ),
    );
    expect(t, contains('本周必要 ¥100'));
    expect(t, contains('弹性 ¥200'));
    expect(t, contains('固定 ¥0'));
  });

  test('零日文案扩展禁词零命中（含浪费/超支/还差/花光）', () {
    final List<String> texts = <String>[
      zeroDayHeadline(todayCount: 3),
      zeroDayEncourage(),
      weekRoleLine(
        sums: const WeekRoleSums(
          necessaryFen: 100,
          flexibleFen: 200,
          fixedFen: 300,
        ),
      ),
    ];
    for (final String t in texts) {
      for (final String wd in warmExtendedBannedWords) {
        expect(t.contains(wd), isFalse, reason: '零日文案命中禁词 $wd：$t');
      }
    }
    // 扩展集确含卡文点名词（扫描非空断言；「多花」系诚实事实词已移出，v3）.
    expect(warmExtendedBannedWords.contains('多花'), isFalse);
    expect(warmExtendedBannedWords.contains('多花了'), isFalse);
    expect(warmExtendedBannedWords.contains('浪费'), isTrue);
    expect(warmExtendedBannedWords.contains('超支'), isTrue);
  });

  test('overspendHeadline 诚实承认多花（¥X=|saved|，走 formatFen）', () {
    expect(overspendHeadline(savedFen: -2700), '虽然今天多花了 ¥27');
    expect(overspendHeadline(savedFen: -2550), contains('¥25.5'));
    // 首段必须能说「多花」：扩展集已移出，扫描放行.
    for (final String wd in warmExtendedBannedWords) {
      expect(
        overspendHeadline(savedFen: -2700).contains(wd),
        isFalse,
        reason: '负结余首行命中禁词 $wd',
      );
    }
  });

  test('pickJoyNotes 只点弹性+非估算+有备注的最大一笔', () {
    final List<String> notes = pickJoyNotes(
      today: <JoyRow>[
        JoyRow(5000, '居住', '房租', 'manual'),
        JoyRow(2700, '玩', '霸王茶姬', 'manual'),
        JoyRow(99900, '其他', '每日收口估算', 'estimate'),
        JoyRow(8000, '玩', '  ', 'manual'),
      ],
    );
    expect(notes, <String>['霸王茶姬']);
  });

  test('pickJoyNotes 可合并≤2 笔（金额倒序，原样引用）', () {
    final List<String> notes = pickJoyNotes(
      today: <JoyRow>[
        JoyRow(1000, '玩', '小台灯', 'manual'),
        JoyRow(2700, '玩', '霸王茶姬', 'manual'),
        JoyRow(500, '玩', '贴纸', 'manual'),
      ],
    );
    expect(notes, <String>['霸王茶姬', '小台灯']);
  });

  test('overspendSecondLine 无名可点→退档通用句（禁编造物件名）', () {
    final String t = overspendSecondLine(
      today: <JoyRow>[JoyRow(500000, '居住', '', 'manual')],
    );
    expect(t, contains('该交的'));
    // 编造防护：退档句禁点名账上不存在的物件.
    for (final String made in <String>['房租', '水电', '奶茶', '霸王茶姬']) {
      expect(t.contains(made), isFalse, reason: '退档句疑似编造物件：$t');
    }
  });

  test('overspendSecondLine 无行可退→记账动作句', () {
    final String t = overspendSecondLine(today: const <JoyRow>[]);
    expect(t, contains('账记明白'));
  });

  test('overspendComfort 犒劳前瞻零感叹号零禁词', () {
    final String t = overspendComfort();
    expect(t.contains('!'), isFalse);
    expect(t.contains('！'), isFalse);
    expect(t.contains('💪'), isTrue);
    for (final String wd in warmExtendedBannedWords) {
      expect(t.contains(wd), isFalse, reason: '犒劳段命中禁词 $wd：$t');
    }
  });

  test('负结余全量文案扩展禁词零命中', () {
    final List<String> texts = <String>[
      overspendHeadline(savedFen: -2700),
      overspendSecondLine(today: <JoyRow>[JoyRow(2700, '玩', '霸王茶姬', 'manual')]),
      overspendComfort(),
    ];
    for (final String t in texts) {
      for (final String wd in warmExtendedBannedWords) {
        expect(t.contains(wd), isFalse, reason: '负结余文案命中禁词 $wd：$t');
      }
    }
  });

  test('warmBannedWords 与成就表同一引用（禁第二套）', () {
    expect(warmBannedWords, same(achievementBannedWords));
  });
}
