#!/bin/sh
# runway loop watchdog（巡夜）手动入口：与 openclaw cron `runway-watchdog` 等价。
# 调度宿主结论见 LOOP.md（launchd 因 TCC 不可行）。经授权的 shell 里可直接跑本脚本。
set -u
REPO=/Users/dada561/Documents/runway
exec /usr/local/bin/opencode run "你是 runway 的巡夜 watchdog。先读仓库根 LOOP.md 的 watchdog 一节，再按清单执行。默认只读检查：健康则零写入直接退出，不许产生任何提交或文件改动；只有清单命中的 sick 项才允许该节规定的写操作（删死锁、progress 追加一行、熔断 WAITING_HUMAN 三选一，且一次只做一件）。绝不碰业务代码，绝不 merge/push。" --dir "$REPO"
