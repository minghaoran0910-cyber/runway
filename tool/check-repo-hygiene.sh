#!/bin/bash
# SB-001 仓库卫生检查：fixtures 目录外出现金额+日期模式的 json/csv 即报警
# 用法：tool/check-repo-hygiene.sh（仓库根执行）
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PATTERN='(20[2-9][0-9]-[0-9]{2}-[0-9]{2}).*[0-9]+\.[0-9]{2}|[0-9]+\.[0-9]{2}.*(20[2-9][0-9]-[0-9]{2}-[0-9]{2})'
FAIL=0

while IFS= read -r f; do
  # 跳过允许区：fixtures / golden 基线 / 依赖锁 / 本脚本自身 inti
  case "$f" in
    */fixtures/*|*/golden/*|*/build/*|*/.dart_tool/*|*pubspec.lock|*.png|*.jpg) continue ;;
  esac
  if grep -lE "$PATTERN" "$f" >/dev/null 2>&1; then
    echo "HYGIENE FAIL: 疑似真实账目数据: $f"
    FAIL=1
  fi
done < <(find . -type f \( -name "*.json" -o -name "*.csv" \) -not -path "./app/build/*" -not -path "./app/.dart_tool/*" -not -path "./.git/*")

if [ "$FAIL" -eq 1 ]; then
  echo "repo hygiene: FAIL"
  exit 1
fi
echo "repo hygiene: OK"
