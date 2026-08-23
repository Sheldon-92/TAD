#!/usr/bin/env bash
# harvest-scan.sh — Read-only scan of registered projects' skillify candidates.
# RETIRED 2026-08-17 with *sync / *sync-add / *sync-list (human decision):
#   TAD 不再持有下游项目清单——是否升级由各项目自行决定。
#   注册表已删除，跨项目无对象可扫；本仓库候选由 *harvest 步骤 1_scan 单独列出。
# STRICTLY READ-ONLY: this script contains NO mutation commands.
# Exit 0 always (reporting tool, not a gate).
set -euo pipefail

# 注册表已随 *sync 退休删除——「从注册表推导项目列表」的旧逻辑永不成立，已移除。
echo "跨项目 harvest 扫描已随 *sync 退休（2026-08-17，人裁定）。"
echo "本仓库候选见 .tad/active/skillify-candidates/（由 *harvest 步骤 1_scan 单独列出）。"
exit 0
