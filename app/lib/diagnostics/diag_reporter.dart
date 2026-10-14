// SB-034 · 批量上报（纯 Dart；debug 态由调用方传入，本文件禁 import flutter）.
// 三触发：30s 周期 tick / 满 20 条 / 崩溃即发；任一闸关闭即零发送（sender 零调用）.
// 用户开关为内存态（默认开，重启恢复默认开；体验期口径，无 schema 迁移）.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'diag_buffer.dart';
import 'diag_config.dart';

/// 网络投递函数（默认走 HttpClient；测试注入假函数计数）.
typedef DiagPost =
    Future<bool> Function(Uri url, Map<String, String> headers, String body);

/// 默认投递：POST + Bearer，5s 超时；抛错一律吞为 false（诊断通道永不炸主流程）.
Future<bool> defaultDiagPost(
  Uri url,
  Map<String, String> headers,
  String body,
) async {
  final HttpClient client = HttpClient();
  try {
    client.connectionTimeout = const Duration(seconds: 5);
    final HttpClientRequest req = await client.postUrl(url);
    headers.forEach(req.headers.set);
    req.headers.contentType = ContentType.json;
    req.write(body);
    final HttpClientResponse res = await req.close().timeout(
      const Duration(seconds: 5),
    );
    await res.drain<void>();
    return res.statusCode >= 200 && res.statusCode < 300;
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

/// 上报器（buffer 满 20 / 周期 / 崩溃三路共用 flush）.
class DiagReporter {
  DiagReporter({
    required this.buffer,
    required this.post,
    required this.endpoint,
    required this.token,
    required this.expiryMs,
    this.debugMode = true,
    this.clock,
  });

  static const int flushThreshold = 20;
  static const Duration period = Duration(seconds: 30);

  final DiagBuffer buffer;
  final DiagPost post;
  final String endpoint;
  final String token;
  final int expiryMs;
  final bool debugMode;
  final DateTime Function()? clock;

  bool userEnabled = true;
  Timer? _timer;

  DateTime get _now => clock == null ? DateTime.now() : clock!();

  bool get active => diagIsEnabled(
    debugMode: debugMode,
    userEnabled: userEnabled,
    endpoint: endpoint,
    token: token,
    expiryMs: expiryMs,
    now: _now,
  );

  /// 周期触发（main 内 30s Timer 回调；未启用即空转）.
  Future<bool> tick() => flush();

  void startPeriodic() {
    _timer ??= Timer.periodic(period, (_) => flush());
  }

  void stopPeriodic() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> addAndMaybeFlush(DiagEvent event) async {
    buffer.add(event);
    if (buffer.length >= flushThreshold) await flush();
  }

  /// 崩溃即发（hook 调用；fire-and-forget，调用方不 await 也可）.
  Future<bool> reportCrash(Object error, StackTrace stack) async {
    buffer.add(
      DiagEvent(
        kind: 'crash',
        message: '${error.runtimeType}: $error\n$stack',
        at: _now,
      ),
    );
    return flush();
  }

  /// 批量 POST；关闸 / 空缓冲即返回 false 且 sender 零调用.
  Future<bool> flush() async {
    if (!active) return false;
    final List<DiagEvent> events = buffer.drain();
    if (events.isEmpty) return true;
    final String body = jsonEncode(<String, Object?>{
      'v': 1,
      'platform': Platform.operatingSystem,
      'events': events.map((DiagEvent e) => e.toJson()).toList(),
    });
    try {
      return await post(Uri.parse('$endpoint?batch=1'), <String, String>{
        'Authorization': 'Bearer $token',
      }, body);
    } catch (_) {
      return false;
    }
  }
}

/// 进程单例（main 挂接与设置页开关共用；内存态，无 schema 迁移）.
class DiagRuntime {
  DiagRuntime._() : buffer = DiagBuffer() {
    reporter = DiagReporter(
      buffer: buffer,
      post: defaultDiagPost,
      endpoint: DiagEnv.endpoint,
      token: DiagEnv.token,
      expiryMs: DiagEnv.expiryMs,
    );
  }

  static final DiagRuntime instance = DiagRuntime._();

  final DiagBuffer buffer;
  late final DiagReporter reporter;
}
