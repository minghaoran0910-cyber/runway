// SB-034 · 诊断通道单测：三道闸 / 环形覆盖 / 三触发 / 开关零发送 / 挂载门默认隐藏.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/diagnostics/diag_buffer.dart';
import 'package:runway/diagnostics/diag_config.dart';
import 'package:runway/diagnostics/diag_reporter.dart';
import 'package:runway/ui/diagnostics_card.dart';

const String _ep = 'https://example.invalid/diag/ingest';
const String _token = 'test-token';
final DateTime _now = DateTime(2026, 10, 14, 12);
final int _live = _now.millisecondsSinceEpoch + 7 * 24 * 3600 * 1000;
final int _past = _now.millisecondsSinceEpoch - 1000;

DiagReporter _reporter({
  DiagBuffer? buffer,
  required List<int> counter,
  List<Map<String, String>>? seenHeaders,
  bool debugMode = true,
  bool userEnabled = true,
  String endpoint = _ep,
  String token = _token,
  int? expiryMs,
}) {
  final DiagReporter r = DiagReporter(
    buffer: buffer ?? DiagBuffer(),
    post: (Uri url, Map<String, String> headers, String body) async {
      counter[0]++;
      seenHeaders?.add(headers);
      return true;
    },
    endpoint: endpoint,
    token: token,
    expiryMs: expiryMs ?? _live,
    debugMode: debugMode,
    clock: () => _now,
  );
  r.userEnabled = userEnabled;
  return r;
}

DiagEvent _ev(int i) =>
    DiagEvent(kind: 'breadcrumb', message: 'step-$i', at: _now);

void main() {
  test('SB-034 总闸四缺一即关', () {
    bool open({
      bool debug = true,
      bool user = true,
      String ep = _ep,
      String tk = _token,
      int? exp,
    }) => diagIsEnabled(
      debugMode: debug,
      userEnabled: user,
      endpoint: ep,
      token: tk,
      expiryMs: exp ?? _live,
      now: _now,
    );
    expect(open(), isTrue);
    expect(open(debug: false), isFalse);
    expect(open(user: false), isFalse);
    expect(open(ep: ''), isFalse);
    expect(open(tk: ''), isFalse);
    expect(open(exp: _past), isFalse);
    expect(open(exp: 0), isFalse);
  });

  test('SB-034 环形 200 覆盖最旧 + drain 清空', () {
    final DiagBuffer b = DiagBuffer();
    for (int i = 0; i < 205; i++) {
      b.add(_ev(i));
    }
    expect(b.length, equals(200));
    expect(b.snapshot.first.message, equals('step-5'));
    expect(b.snapshot.last.message, equals('step-204'));
    final List<DiagEvent> out = b.drain();
    expect(out.length, equals(200));
    expect(b.length, equals(0));
  });

  test('SB-034 单条截断 1KB', () {
    final DiagBuffer b = DiagBuffer();
    b.add(DiagEvent(kind: 'crash', message: 'x' * 5000, at: _now));
    expect(b.snapshot.single.message.length, equals(1024));
  });

  test('SB-034 开关关 = 零发送', () async {
    final List<int> counter = <int>[0];
    final DiagReporter r = _reporter(counter: counter, userEnabled: false);
    for (int i = 0; i < 25; i++) {
      await r.addAndMaybeFlush(_ev(i));
    }
    expect(await r.flush(), isFalse);
    expect(counter[0], equals(0));
    expect(r.buffer.length, equals(25));
  });

  test('SB-034 过期 = 零发送', () async {
    final List<int> counter = <int>[0];
    final DiagReporter r = _reporter(counter: counter, expiryMs: _past);
    await r.addAndMaybeFlush(_ev(0));
    expect(await r.flush(), isFalse);
    expect(counter[0], equals(0));
  });

  test('SB-034 满 20 条即发 + Bearer 头', () async {
    final List<int> counter = <int>[0];
    final List<Map<String, String>> headers = <Map<String, String>>[];
    final DiagReporter r = _reporter(counter: counter, seenHeaders: headers);
    for (int i = 0; i < 20; i++) {
      await r.addAndMaybeFlush(_ev(i));
    }
    expect(counter[0], equals(1));
    expect(headers.single['Authorization'], equals('Bearer $_token'));
    expect(r.buffer.length, equals(0));
  });

  test('SB-034 崩溃即发（含堆栈）', () async {
    final List<int> counter = <int>[0];
    final DiagReporter r = _reporter(counter: counter);
    final bool ok = await r.reportCrash(StateError('boom'), StackTrace.empty);
    expect(ok, isTrue);
    expect(counter[0], equals(1));
    expect(r.buffer.length, equals(0));
  });

  test('SB-034 空缓冲 flush 不发网络', () async {
    final List<int> counter = <int>[0];
    final DiagReporter r = _reporter(counter: counter);
    expect(await r.flush(), isTrue);
    expect(counter[0], equals(0));
  });

  testWidgets('SB-034 默认环境挂载门隐藏（golden 不动证明）', (WidgetTester t) async {
    await t.pumpWidget(const MaterialApp(home: DiagnosticsSection()));
    await t.pump();
    expect(find.byKey(const Key('diagSwitch')), findsNothing);
  });

  testWidgets('SB-034 开关卡拨动回调用', (WidgetTester t) async {
    bool? got;
    await t.pumpWidget(
      MaterialApp(
        home: DiagnosticsCard(enabled: true, onChanged: (bool v) => got = v),
      ),
    );
    await t.tap(find.byKey(const Key('diagSwitch')));
    await t.pump();
    expect(got, isFalse);
  });

  // SB-039 ③ · 关于诊断常驻行：规则数/占比健康两态，文案 bodySmall 常显.
  testWidgets('SB-039 关于诊断行健康态', (WidgetTester t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: AboutDiagnosticsCard(
          ruleCount: 179,
          categoryCount: 6,
          otherShare: 0.0,
          otherFault: false,
        ),
      ),
    );
    await t.pump();
    expect(find.byKey(const Key('aboutDiagTitle')), findsOneWidget);
    expect(find.text('内置规则 179 条 · 6 类目'), findsOneWidget);
    expect(find.byKey(const Key('aboutDiagHealthy')), findsOneWidget);
    expect(find.byKey(const Key('aboutDiagFault')), findsNothing);
  });

  testWidgets('SB-039 关于诊断行故障态', (WidgetTester t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: AboutDiagnosticsCard(
          ruleCount: 179,
          categoryCount: 6,
          otherShare: 0.1,
          otherFault: true,
        ),
      ),
    );
    await t.pump();
    expect(find.textContaining('其他占比 10.0%'), findsOneWidget);
    expect(find.byKey(const Key('aboutDiagFault')), findsOneWidget);
  });
}
