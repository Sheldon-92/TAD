# Layer 2 — Reviewer B (independent, scope + consumer scan)

Model: harness=claude-code | model=claude-opus-4-6 | route=host

**Verdict: CONDITIONAL PASS — 0 P0, 4 P1, 3 P2**

## Consumer scan (§8.3 mandate) — independently re-run

**(a) Protocol registrations** — 9 hits, **0 live consumers**: parity-criterion.md:27-29
and portable-rules.md:77-79 are *allowlist* semantics ("absent = expected, NOT drift");
release-verify.sh:6 comment only; CHANGELOG.md:579 historical (NFR3). Removing the
source keys makes them absent → still expected-absent → inert by construction.

**(b) Deleted file paths** — 3 hits, 0 dangling: only the intentional `git show 0566ee4d:`
history pointers in the retirement comment. ✅

**(c) harvest-scan** — sole live caller `alex/SKILL.md:1365` (+ mirror). All other hits
handoff/eval-bundle/dependency-registry prose. **Not more callers than expected →
§8.2 did not fire.** 方案 A correctly chosen.

## §8.1 hard bans — all verified

(a) tad.sh untouched; (b) publish-protocol.md present both sides, *publish ×8;
(c) diff touches no decisions/CHANGELOG/audit file; (d) harvest-scan.sh present +
executable → 方案 A right; (e) ordering demonstrably right (stub verified post-deletion).

## §2 sync-ops stub — references resolve

All 6 referrers verified non-dangling (release-runbook:22,24 / alex-lite:411 /
blake-lite:554 ×2 mirrors); stub byte-identical. **`*publish` NOT broken** —
release-runbook:22 routes publish to publish-ops.md (separate intact file);
sync branch lands on retirement notice, not 404.

## §5 value-proposition — correct

Old live-claim ("registry IS the live sync target list... 14 entries") replaced
with retirement-consistent prose + decision-trail pointer. **No residual live-target
claim.**

## P1 — all evaluated by Blake

| # | Finding | Blake disposition |
|---|---|---|
| P1-1 | AC-7 = 3 vs stated 0; exclusion regex incomplete | ✅ **已由人裁定解决**：历史 3 处保留，Alex 以 addendum 补排除正则。不改源文件（会碰 NFR3）。无需代码动作 |
| P1-2 | migrations yaml reason 末尾 "*sync continues to read the local copy" 现为假 | **记录不动**：人裁定历史 3 处一字不动。列入 completion/NEXT 交 Alex 裁定是否追加补记 |
| P1-3 | alex/SKILL.md:1365 仍承诺 table/COLLISIONS 输出（FR-6 影响半径内） | ✅ **已修**（两侧镜像）：改为退休说明 + 仅本仓库候选 |
| P1-4 | harvest-scan.sh 缺末尾换行（POSIX 非规范） | ✅ **已修**：补 `\n`，tail -c1 → 0x0a |

## P2 — 记录，非阻塞

- **§6 残留（跨文件）**：intent-router:152/201-203（skip-list + standby 触发，死但惰性）、
  tad-help:70-72（**用户可见度最高**的过时广告）、workflow-completion-trigger:22、
  publish-protocol:205（*publish 流程内的过时建议——最可达）、
  research-notebook:1153 = **假阳性**（NotebookLM 自己的 *sync，与项目同步无关，
  绝不能动）。→ 交 Alex 另单（tad-help + publish-protocol 优先）。
- **FR-1 不可从 git 验证**：注册表 untracked，删除不进 diff；AC-1 仅本地文件系统
  可验 → completion 须写明，防止未来 fresh-clone 审查误判 FR-1 被跳过。
- **parity-criterion/portable-rules allowlist 幽灵条目**：惰性无害，低优先清理。

## Overall: CONDITIONAL PASS — 条件已全部满足/交代

0 P0。四个条件：P1-1 人裁定解决；P1-3 已修；P1-2/P1-4 已处置（一记录一修）。
P2 全部为 Alex 后续单，明确非本单阻塞。