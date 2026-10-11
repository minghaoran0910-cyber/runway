#!/bin/bash
# SB-012 G5 性能预算检查（卡内授权新增）：合成库聚合耗时 + 其他占比 + 包体基线.
# 用法：tool/perf_check.sh [--release]（仓库根执行；--release 另做 release 包体预估，耗时较长）
# 真机冷启动/帧 trace/三端冒烟由监工真机轮留数，本脚本只锁 CI 可测部分.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BASELINE_FILE="$ROOT/tool/perf_baseline.txt"

echo "=== [1/3] perf budget test（合成 1 万条） ==="
(cd app && flutter test test/perf_budget_test.dart)

echo "=== [2/3] debug apk 包体 ==="
(cd app && flutter build apk --debug)
APK="$ROOT/app/build/app/outputs/flutter-apk/app-debug.apk"
SIZE=$(stat -f%z "$APK" 2>/dev/null || stat -c%s "$APK")
echo "debug apk size: $SIZE bytes"
if [ -f "$BASELINE_FILE" ]; then
  BASE=$(cat "$BASELINE_FILE")
  echo "baseline: $BASE bytes"
  LIMIT=$(python3 -c "print(int($BASE * 1.2))")
  echo "limit (baseline+20%): $LIMIT bytes"
  if [ "$SIZE" -gt "$LIMIT" ]; then
    echo "FAIL: 包体超基线+20%"
    exit 1
  fi
  echo "包体 OK（≤基线+20%）"
else
  echo "$SIZE" > "$BASELINE_FILE"
  echo "baseline 建立：$SIZE bytes（下轮起按 +20% 卡）"
fi

if [ "$1" = "--release" ]; then
  echo "=== [3/3] release apk 预估 ==="
  (cd app && flutter build apk --release)
  APK_R="$ROOT/app/build/app/outputs/flutter-apk/app-release.apk"
  SIZE_R=$(stat -f%z "$APK_R" 2>/dev/null || stat -c%s "$APK_R")
  echo "release apk size: $SIZE_R bytes（记录在案）"
else
  echo "=== [3/3] release 预估跳过（监工真机轮带 --release 实测） ==="
fi

echo "PERF GREEN SB-012"
