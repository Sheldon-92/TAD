# EPIC-COMPLETION — Native Capability Adoption Wave (B-group)

**Epic**: EPIC-20260712-native-capability-adoption | **Executed**: 2026-07-13, single YOLO session
**Conductor**: Alex (hybrid Conductor + yolo-epic Workflow ×7 runs) | **Result**: 4/4 phases Done
**Merges to main**: abca584 (P1) → bf51be4 (P2) → 0f14d18 (P3) → 0b947a5 (P4)

---

## Per-Phase Summary

| Phase | Outcome | Merge | Behavioral evidence | Reviews (design / impl) |
|-------|---------|-------|--------------------|-----------------------|
| P1 PreCompact snapshot hook | ✅ SHIPPED | abca584 | AC3/4/5/6/7/8 live-proven; AC2a/T1 stdin = PENDING-REAL-EVENT (auto-tee at next real /compact) | 0 P0 re-validation / 0 P0 0 P1 |
| P2 reviewer memory + skills preload | ✅ NEGATIVE-RESULT | bf51be4 | Spike: `memory`+`skills` INERT on 2.1.172; shadowing PASS → spec-compliance-reviewer live (confirmed as available agent type same session) | 2 P0 (fixed) / 0 P0 0 P1 |
| P3 weekly GitHub scan | ✅ SPIKE PASS, partial automation | 0f14d18 | last_scan null→2026-07-13 real flip; merge-write fixture-proven; CRON-FIRE-VERIFY PASS (one-shot 3cea3b55 fired 10:40, guard clean-exit) | 0 P0 4 P1 (implemented) / 0 P0 0 P1 |
| P4 preview rule + rules pilot | ✅ SHIPPED | 0b947a5 | Rules spike LOADED (6/6 discriminative probes, @import confound defeated); preview protocol = observe-on-next-*design | 2 P0 (fixed) / 0 P0 0 P1 |

## Idea Scoreboard (6 promoted → outcomes)

- **Landed (4)**: precompact-hook-session-state; cron-revive-github-scan (capability proven,
  automation session-bound); claude-rules-path-scoped (LOADED, pilot live); askuser-preview-in-design
  (protocol text live, behavioral = observe-on-next-use).
- **Blocked-until CLI upgrade (2)**: subagent-persistent-reviewer-memory; subagent-skills-preload
  — fields INERT on 2.1.172; re-spike condition recorded in Epic P2. Byproduct shipped anyway:
  spec-compliance-reviewer as first project-level registered agent + fm-lint.sh.

## Native-Runtime Ground Truth Established (research → local reality)

1. `memory`/`skills` subagent frontmatter: **INERT** on 2.1.172 (doc-level research said available).
2. `.claude/agents/` project-level defs: **WORK**, fully shadow user-level (spike-proven).
3. `.claude/rules` paths-frontmatter: **WORKS** (GH issue #17204 "only globs:" did NOT reproduce);
   fires on READ only — blind writes to new files don't load it (explicit scope boundary).
4. CronCreate: fires reliably (one-shot verified) but **session-only + 7-day expiry even with
   durable:true** — no standing weekly automation on this CLI.
5. PreCompact hook event: registration accepted; live-fire evidence auto-captures at next real
   /compact (built-in stdin tee).
6. Headless `claude -p` sub-sessions: work end-to-end incl. keyring gh auth, BUT trigger the
   repo's own lifecycle hooks (REGISTRY flips, trace emission) — future in-repo fire-tests
   should use hook-disabled or fixture-dir invocation.

## Files / Commits

4 feature commits, +~1,460 lines net (mostly evidence), 0 code regressions, zero .js changes
in P4 (no-code lock held). All 4 merges verified in main: hook live-run, fm-lint FM-OK,
scan-log real data, rules file + mirror IDENTICAL.

## Escalations Requiring HUMAN Decision (carried to NEXT.md)

1. **AC2a real-compact evidence**: fire a real /compact in any NEW session (hooks snapshot at
   session start — this session predates registration); evidence auto-lands.
2. ***publish 前分发裁决**: `.claude/agents/` 与 `.claude/rules/` 均对两条分发路径不可见
   (derive-sync-set 只走 .tad/*/; tad.sh .claude 拷贝是硬编码 allow-list)。推荐 main-repo-only,
   若要分发必须加显式拷贝路径 + 同粒度 verifier (principles 2026-06-01)。
3. **CLI 升级时**: re-spike memory/skills (P2) + durable cron (P3) — Epic 有 BLOCKED-UNTIL 标记。
4. **周扫描 cadence**: 本会话 cron 90c01ae7 会随会话死亡;之后靠 STEP 3.9 staleness 警告提醒,
   或任何会话用 cron-prompt.md 一句话重注册。

## Knowledge Assessment (Gate 4 KA — 3-check iteration done)

- (a) Tool behavior discoveries: items 1-6 above — 6 项本地实测新事实,其中 3 项直接证伪
  doc-level 研究(memory/skills、durable cron、GH #17204)。
- (b) Expert-review novel concern: 设计 agent 系统性产出"本机跑不起来/不判别"的 AC 命令
  (P2: pyyaml 缺失 + grep -L 空参; P4: .js 子串误伤 .jsonl + 同款 pyyaml)——2/3 个新设计
  phase 含 P0 级 AC 可跑性缺陷,模式高度重复。
- (c) Claimed vs actual: 无差异——所有 completion 数字被 impl reviewer 独立重算并复现;
  P3 甚至抓回了 nested-session hook 副作用并在提交前回滚。
- → 2 条 L2 pattern 候选已定(见 patterns/ 提交): AC 本机可跑性预检 + native 能力采纳的
  spike-first 三连证据。
