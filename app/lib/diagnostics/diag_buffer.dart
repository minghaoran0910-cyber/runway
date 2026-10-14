// SB-034 · 环形缓冲 200 条（纯 Dart，禁 import flutter）.
// 事件统一为 DiagEvent：崩溃堆栈 / 掉帧计数 / 面包屑步骤；满则覆盖最旧.
// 单条截断 1KB：200 条批量 <= 200KB，贴合服务端 256KB 上限.

import 'dart:convert';

/// 单条诊断事件（message 须已脱敏，金额走 maskAmountFen；面包屑只记步骤名）.
class DiagEvent {
  const DiagEvent({
    required this.kind,
    required this.message,
    required this.at,
  });

  final String kind;
  final String message;
  final DateTime at;

  Map<String, Object?> toJson() => <String, Object?>{
    'kind': kind,
    'message': message,
    'at': at.toIso8601String(),
  };
}

/// 定容环形缓冲（默认 200；drain 取走并清空）.
class DiagBuffer {
  DiagBuffer({this.capacity = 200});

  final int capacity;
  final List<DiagEvent> _items = <DiagEvent>[];

  static const int maxMessageLen = 1024;

  int get length => _items.length;

  List<DiagEvent> get snapshot => List<DiagEvent>.unmodifiable(_items);

  void add(DiagEvent event) {
    final DiagEvent capped = event.message.length <= maxMessageLen
        ? event
        : DiagEvent(
            kind: event.kind,
            message: event.message.substring(0, maxMessageLen),
            at: event.at,
          );
    if (_items.length >= capacity) _items.removeAt(0);
    _items.add(capped);
  }

  void breadcrumb(String step, {DateTime? at}) {
    add(DiagEvent(kind: 'breadcrumb', message: step, at: at ?? DateTime.now()));
  }

  List<DiagEvent> drain() {
    final List<DiagEvent> out = List<DiagEvent>.from(_items);
    _items.clear();
    return out;
  }

  String toJsonPayload() => jsonEncode(<String, Object?>{
    'v': 1,
    'events': _items.map((DiagEvent e) => e.toJson()).toList(),
  });
}
