#!/bin/bash
# SB-001 CI 四闸门：format / analyze / test / build
# 用法：tool/ci.sh（仓库根执行）
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== [1/4] dart format ==="
dart format --set-exit-if-changed .

echo "=== [2/4] flutter analyze ==="
flutter analyze --fatal-infos --fatal-warnings app

echo "=== [3/4] flutter test ==="
(cd app && flutter test test/smoke_test.dart)

echo "=== [4/4] flutter build macos --debug ==="
(cd app && flutter build macos --debug)

echo "ALL GREEN SB-001"
