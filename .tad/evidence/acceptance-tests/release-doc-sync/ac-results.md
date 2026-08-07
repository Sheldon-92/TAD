# AC Results — LITE-20260806-1600-release-doc-sync (v2.40.0 发布准备，release 单 A)

**Date**: 2026-08-06
**Executor**: Blake-Lite | harness=claude-code | model=deepseek-v4-flash
**Verdict**: AC1–AC8 全部 PASS（8 条 AC；repair round 1 后；tad-help numstat 差异按判据优先级记录处理）

---

## AC1 — 发布闸三门全过（PASS，最强判据）

改前基线（工具输出存 /tmp/rd_*_before.txt）：version **29 处 STALE**（退出码 1）/ version-sweep **Layer 1 FAIL(12 stale)** / parity PASS（exit 0）。

repair round 1 前：version 剩 2 处 STALE（`.claude/.agents` tad-help L17 `Version: v2.39.0 | Generated: [timestamp]`）——29 处清单之一，批量脚本遗漏。修复后：

```
version:        ✅ zero non-historical stale '2.39.0' refs — VERDICT: version PASS (exit 0)
version-sweep:  VERDICT: version-sweep PASS (exit 0)
parity:         ✅ .claude/skills <-> .agents/skills byte-identical — VERDICT: parity PASS (exit 0)
```

## AC2 — tad.sh 成品 md5（PASS）

```
md5: 4c26e5ba08b7e8e9430aef0b015ad993（期望 4c26e5ba08b7e8e9430aef0b015ad993）✓
行数: 1855（期望 1855）✓（改前 2cab1d1926d79e736510fa69df8c3da6 / 1856）
```

## AC3 — tad.sh 能跑且没碰逻辑（PASS）

```
bash -n tad.sh → 退出码 0 ✓
TARGET_VERSION="2.40.0" → 1 ✓（P0-1 修复）
[ -d ".claude/skills/alex" ] → 1 ✓（平台检测存活）
[ -d ".agents/skills/alex" ] → 1 ✓
git diff HEAD --numstat -- tad.sh → 4	5	tad.sh（逐字）✓
```

## AC4 — 路由新串（PASS，6/6 == 1）
Pick a Channel 标题 / alex-lite 表行 / 命令表两行 / IG 快速开始 / AGENTS.md 默认通道描述——全部命中。

## AC5 — 路由旧串消失（PASS）
旧标题 Open Two Terminals == 0、命令表 3 旧行 == 0（-Fxc 全行精确，`/alex` 是 `/alex-lite` 前缀必须 -x）、IG `/alex` 整行 == 0；正向锁 `| \`/alex\` | \`/blake\` |` == 1（Reserved 表内）+ `**Reserved — full TAD**…` == 1。

## AC6 — CHANGELOG 有内容（PASS）
2.40.0 标题 1 / Unreleased(-Fx) 1 / `62,220 chars` 1 / `retired as a broken criterion` 1 / `tad.sh` upgrade freeze 1 / 段长 **50** 行（≥45）。

## AC8 — 逐文件改动形状（PASS，判据优先级应用）

numstat 17 条：15 条精确命中（1→1 ×8、2→2 ×2、3→3 ×2、README 18→7、IG 8→6、AGENTS 1→1）。
**2 条差异（如实记录）**：tad-help 两侧 `7→10` vs 契约期望 `7→9`。
- 根因：L17 `Version: v2.39.0 | Generated: [timestamp]` 修复（29 处 STALE 之一，**AC1 version 判据强制要求**，契约 §文件清单「版本 bump 由 release-verify 定义」含它）为额外 1→1；契约期望值按未含 L17 的 Highlights 段计算。
- 判据优先级（契约明文）：`wc -l` 是主判据——README 475 ✓ / IG 141 ✓ 全对；numstat 差 ±1-2 行按差分实现差异处理 → **判 PASS，不塞行凑数**。
- diff 结构验证：2 hunk 干净（L17 版本行 + Highlights 段 8 删 6 插），无孤儿、无意外内容。

wc -l 主判据：README **475**（改前 464，净 +11）✓ / IG **141**（改前 139，净 +2）✓。

集合闭合：`git diff HEAD --name-only` 24 个 = **19 本单新增** + 5 基线既有（lite-pricing-gate-protocol ×3、decisions/2026-08-06.jsonl、REGISTRY.yaml——均在执行前基线 23 行内）→ 本单新增**恰好 19 个路径** ✓。

肯定锚 3 条（Ralph Loop v2.40.0 / GLOBAL SKILL EXCLUSION v2.40.0 ×2）全 == 1 ✓。

Highlights 锚 4 条：v2.40.0 标题 1 / v2.39.0 标题 0 / 段内 bullet **5**（防孤儿）/ `~35K tokens/cycle` 0（旧成本数字消失）✓；两侧 byte-identical（cmp IDENTICAL）✓。

## AC7 — 零越权 + 未执行 release 动作（PASS）

```
HEAD: 21816d6（期望 21816d6）✓
最新 tag: v2.39.0（未打新 tag）✓
tag 数: 62 ✓
相对基线新增：恰好 19 个（全部由 AC1 三门工具输出定义）✓
黑名单（CLAUDE.md、{alex-lite,blake-lite} 两侧、hooks、settings.json、agents/、gitignore、
sync-registry、logs、ROADMAP）：零命中 ✓
本单零 git 写操作（无 add/commit/push/tag/checkout/stash）✓
```

## 横幅补锚（§发布横幅新文案，7 条全 PASS）
README 全串 1（仅剩 L88 历史标题）/ L88 正向锁 1 / IG 0 / MULTI-PLATFORM 0 / config.yaml 0 / PROJECT_CONTEXT 小写 0 / 大写 1（L21 历史成就）——历史记录未追溯性修改 ✓。

## pack-registry driftcheck（advisory 存证）
退出码 1 = DRIFT DETECTED (advisory)：Set A 25 / B 34 / C 25；(a)(c) 均 none；(b) 11 个 skill-only（installed skill 无 source pack——**既有状态，与本单 synced_from_version 字符串改动无关**，本单不增删条目）。NOT a release blocker。

## 实现方式
- 25 处批量精确替换（python3，每处断言唯一匹配）+ 8 处复杂块（tad.sh 路由提示 ×2 / README 两块 / IG 块 / AGENTS / tad-help Highlights ×2 / CHANGELOG）
- repair round 1：补 tad-help L17 版本行（两侧），AC1 version 从 2 STALE → 0
