# backend-architect Review — HANDOFF-20260427-tad-cleanup-linear-and-hook

**Reviewer**: backend-architect (sub-agent role)
**Date**: 2026-04-27
**Handoff**: `.tad/active/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md`
**Scope**: Contract-change risk + system design coherence (3 simultaneous contract changes — Linear removal, *accept slim, Domain Pack hook passive mode)

---

## Critical Issues (P0 — must fix before Blake starts)

### P0-1. Linear-removal blast radius is undercounted — 4 additional files reference Linear that the handoff does not list

The handoff §3.1 FR1-FR6 names 3 files for Linear removal (`SKILL.md`, `config-platform.yaml`, `deprecation.yaml`). A `grep -RIn -i "linear"` across `.tad/` and `.claude/` (excluding archive/backup) found **4 additional active files that reference Linear**:

| File | Line | Reference | Severity |
|------|------|-----------|----------|
| `.tad/config.yaml` | 77 | `description: "MCP tools integration and Linear kanban"` | Dangling — keeps a Linear-feature mention while feature gone |
| `.tad/config.yaml` | 80 | `- linear_integration` (under config-platform.yaml's documented `contains:` list) | **Broken module catalog** — claims config-platform.yaml contains a section that no longer exists |
| `.tad/config.yaml` | 321-322 | `v2.6.0 changes:` "Linear Kanban Integration..." / "Linear Auto-Sync..." | Historical changelog — keep, but should add v2.8.4 entry mirroring deprecation |
| `.tad/templates/handoff-a-to-b.md` | 39 | `**Linear:** N/A <!-- Optional: TAD-42 ... — links to Linear issue for auto-sync on *accept -->` | **Live template** — every new handoff Alex creates from this template will still emit a `**Linear:**` field. Stale frontmatter contract. |
| `.tad/hooks/post-write-sync.sh` | 74 | `output_response "PostToolUse" "NEXT.md updated. Linear sync may be needed if items changed."` | **Active hook output** — every NEXT.md edit will inject a stale "Linear sync may be needed" reminder into Claude's context. Directly contradicts the cleanup. |

The most operationally damaging are `post-write-sync.sh:74` (live every NEXT.md edit) and `handoff-a-to-b.md:39` (every new handoff). The `config.yaml:80` `contains:` entry is a broken self-description in a file that the loader-binding chain still references.

Note: there is also `.tad/spike-v3/ARCHITECTURE-v3.md:56,74` referencing Linear, but that's a spike artifact — flag for ignore-or-archive but not a blocker.

**Fix**: Expand FR list to FR7-FR10 to cover:
- FR7: `.tad/config.yaml` line 77 — strip "and Linear kanban" from description; line 80 — remove `- linear_integration` from `contains:` list
- FR8: `.tad/templates/handoff-a-to-b.md` line 39 — remove the `**Linear:** N/A <!-- ... -->` row (template change propagates to every future handoff)
- FR9: `.tad/hooks/post-write-sync.sh` line 74 — change message to remove Linear sync hint (e.g., `"NEXT.md updated."` only, or remove the case branch entirely if no other content)
- FR10 (optional): leave changelog v2.6.0 untouched (historical record), but add explicit v2.8.4 changelog entry to `.tad/config.yaml` mirroring the deprecation.yaml entry — keeps single source of truth between the two registries

This converts the handoff from "3-file delete" to "7-file delete." That is a real scope expansion; consider whether it still fits one Standard handoff or warrants a follow-up cleanup pass. **My recommendation: include them in this handoff because partial Linear removal leaves a worse state than no removal — agent context will keep getting stale Linear hints from the template + hook.**

### P0-2. config-platform.yaml `important_notes` is structurally INSIDE `linear_integration:`, not a sibling — handoff guidance is contradictory and will produce broken YAML

Handoff §4.2 File 2 says:
> 紧接的 `important_notes:` 段保留（不属于 Linear 段，是 MCP 工具通用提醒）

But the actual YAML structure (verified by reading lines 229-285):

```yaml
# ==================== Linear Integration ====================
linear_integration:               # L230 — top-level key (0 indent)
  enabled: true                   # L231 — child (2-space indent)
  ...
  auto_sync:                      # L247 — child
    ...
  # 重要提醒
  important_notes:                # L278 — STILL 2-space indent — CHILD of linear_integration
    - "MCP 工具是 ENHANCEMENTS..."
```

`important_notes:` is at 2-space indent — it is a CHILD field of `linear_integration:`, not a top-level sibling. If Blake follows the handoff's instruction to "delete linear_integration entire section including its subfields auto_sync etc.", `important_notes` is structurally part of that block and goes with it.

This forces Blake into a real ambiguity at edit time:
- Option A: delete L229-276 (stop before `important_notes`). But then `important_notes:` is left as an orphan with 2-space indent and no parent key → invalid YAML.
- Option B: delete L229-285 entirely. Loses the MCP-general important_notes content (collateral damage Alex did not authorize).
- Option C: delete L229-276, then re-indent `important_notes:` to 0-space (top-level) OR move it under `mcp_tools:`. Changes file structure beyond what handoff specifies.

The handoff treats important_notes semantically (content is about MCP tools generally) while the YAML structure makes it a Linear-integration child. That semantic-vs-structural mismatch is the real defect; whoever originally placed it inside `linear_integration:` made a small error that this cleanup must now resolve.

**Fix**: Add explicit FR + spec resolving the ambiguity. Recommendation: Option C — delete L229-276 and promote `important_notes:` to a top-level key (0-indent) OR nest it under `mcp_tools:` (the actual semantic owner). Pick one and write it into §4.2 File 2 as concrete before/after YAML. Do NOT leave this as Blake's judgment call — last 3 phases (per architecture.md `AC Verification Commands Need Pre-Ship Smoke Test - 2026-04-25`) showed structural ambiguity at AC time produces gray-zone work.

### P0-3. AC4 is unsatisfiable as written and contradicts AC1-AC3 evidence-grep semantics

AC4: `grep -ci "linear" .claude/skills/alex/SKILL.md` 返回 0`

The flag combo `-ci` is case-insensitive count. After STEP 3.7 + step4b_linear_sync are deleted from SKILL.md, residual references will still exist (verified — `grep -ni "linear" SKILL.md` currently shows 33 hits, the vast majority inside the 3 deletion blocks but at least 1 outside: line 4026 "SessionStart reminder caught the rationalization mid-step. Actual expert review found" appears in a comment block discussing AR-001, and line 4026's surrounding context may mention Linear). Even if all 3 blocks delete cleanly, AC4 requires zero substring "linear" anywhere in the file (case-insensitive), which is a stronger claim than AC1-AC3 combined.

The AC4 escape clause "除非有合理引用，self-review 说明" (unless reasonable references, document in self-review) makes it a **soft AC** that contradicts the Phase 5 lesson `AC Precision: "≥N Triggers" vs "Specific List of N" Are Different Contracts - 2026-04-14` (architecture.md). Soft escape clauses on grep ACs are exactly the gray-zone problem that's now hit 3 phases in a row.

**Fix**: Either (a) delete AC4 entirely — AC1+AC2+AC3 already cover the load-bearing changes and a residual case-insensitive "linear" substring is harmless when not in a code path; or (b) replace AC4 with a precise grep that excludes known-OK contexts:

```
grep -ni "linear" .claude/skills/alex/SKILL.md \
  | grep -v "^[0-9]*:.*linear_id:" \
  | grep -v "^[0-9]*:.*Domain Pack" \
  | wc -l    # expected: 0
```

But (a) is simpler and does not introduce another regex maintenance burden. Recommend (a).

### P0-4. AC13 (`git diff --stat | tail -1` matches "4 files changed") will FAIL if Blake follows P0-1's expanded FR list — and may fail anyway because of test-evidence/log writes

Two sub-issues:
1. If P0-1 is accepted, Blake will modify ≥7 files, not 4. AC13 must be updated to match.
2. Phase 3 step 5 instructs Blake to run `claude -p` regression test which will WRITE to `.tad/hooks/.router.log` (which IS git-tracked under `.tad/hooks/`). Even with current 4-file scope, `git diff --stat` may show 5 files (4 spec'd + `.router.log`).

**Fix**: (a) Update AC13 to reflect actual file count after P0-1 fixes. (b) Either git-ignore `.router.log` if not already ignored, OR add an explicit AC step that runs `git checkout .tad/hooks/.router.log` before AC13 verification. Verify current `.gitignore` status of `.router.log` first.

### P0-5. Phase 3 regression test (Step 5) is brittle — `--system-prompt` injection probe is not a reliable way to verify "Domain Pack mention NOT in context"

Handoff §6 Phase 3 step 5:
```
echo "test domain pack matching prompt with mobile expo react native" | \
  claude -p --no-session-persistence --tools '' \
  --system-prompt 'Reply only with the literal string MARKER if you saw a "Domain Pack" mention in your context, otherwise reply NO_INJECTION'
```

Two problems:
- The test prompt itself ("test domain pack matching prompt with mobile expo react native") contains the literal substring "Domain Pack". The system-prompt's success criterion is "saw a 'Domain Pack' mention in your context" — but the user prompt also constitutes context. Even with passive mode (no injection), the model would correctly reply MARKER because Domain Pack IS in the user prompt itself. Test will produce false-FAIL.
- Even if you fix the test prompt to not contain "Domain Pack", `claude -p` always injects ~19k tokens of CLAUDE.md + skill catalogs as cache_creation. The skill catalog references "Domain Pack" by name. Hook regression must verify "no NEW additionalContext from THIS hook," not "no Domain Pack mention anywhere."

**Fix**: Replace with a more direct, deterministic test. Two options:
- (a) Direct hook-output inspection: `echo '{"prompt":"build a react native ios app"}' | bash .tad/hooks/userprompt-domain-router.sh; echo "exit=$?"` — verify stdout is empty (no JSON emitted) AND `.router.log` has new line. This bypasses `claude -p` overhead entirely. **Recommended.**
- (b) If you must use `claude -p`, change the marker probe to detect the SPECIFIC reminder text: `'Reply MARKER if you see the literal string "检测到任务匹配 Domain Pack" in your context, otherwise NO_INJECTION'`. The reminder string is unique to the deleted hook output; CLAUDE.md/skill catalog will not contain it.

Test (a) is also faster and dependency-free. Strongly recommend (a).

---

## Recommendations (P1 — should address)

### P1-1. AC for "SessionStart pack catalog still injected" is missing — regression risk acknowledged in review prompt but not in §9 ACs

The review prompt explicitly raised this as a regression to verify. Pack catalog injection is delivered via `.tad/hooks/startup-health.sh` (verified — that hook builds `DOMAIN_DETAIL` from `.tad/domains/*.yaml` and emits as SessionStart additionalContext). This hook is NOT modified by this handoff. But AC list does not check it.

**Fix**: Add AC15: `bash .tad/hooks/startup-health.sh < <(echo '{"source":"startup"}') | jq -e '.hookSpecificOutput.additionalContext | contains("Domain Pack")'` returns true (or `exit 0`). This proves the catalog-injection-on-startup path is intact post-cleanup.

### P1-2. AC for "*discuss step1.5 / *design step1_5 still functions" is missing

Handoff §1.3 explicitly relies on `domain_pack_awareness` (line 612) and `step1_5` (line 1586) for the "agent decides to load packs autonomously" claim. After deleting STEP 3.7, neither of these mechanisms is touched — but no AC verifies that. If a future grep-based delete accidentally also strips one of these blocks (collateral damage), the cleanup silently degrades pack discovery.

**Fix**: Add AC16: `grep -c "domain_pack_awareness:" .claude/skills/alex/SKILL.md` returns ≥1 AND `grep -c "step1_5:" .claude/skills/alex/SKILL.md` returns ≥2 (since step1_5 appears in both *discuss line 320 and *design line 1586). This is a regression smoke alarm.

### P1-3. *accept step0b vs acceptance_protocol step4b — equivalence verified, but handoff's claim of "完全重复" (fully duplicate) is technically wrong

Verified by reading both:

**acceptance_protocol step4b (L2321)** — checks:
1. Reads completion report Evidence Checklist → required items
2. Reads handoff frontmatter `e2e_required: yes` → confirm E2E evidence path exists
3. Reads handoff frontmatter `research_required: yes` → confirm research file path exists
4. BLOCK if any required missing

**accept_command.step0b_evidence_check (L2797)** — checks:
1. Reads completion report Evidence Checklist → required items checked
2. BLOCK if any required unchecked

step4b is a strict superset of step0b (it does everything step0b does, plus frontmatter path verification). Removing step0b is **safe** — anything step0b catches, step4b catches first.

But the handoff phrasing "完全重复" (fully duplicate) is technically inaccurate. step0b is a strict subset, not duplicate. This matters because the handoff's Intent Statement (§1.3) and FR3 implicitly assume "removing duplicate = no behavior change." Behavior change is in fact zero (step4b's superset coverage is unchanged), but for trace/audit clarity, restate the rationale precisely.

**Fix**: Replace handoff §1.1 wording "与 acceptance_protocol.step4b 完全重复" with "完全被 acceptance_protocol.step4b 覆盖（step4b 是严格超集，新增 frontmatter 路径校验）". Same in §1.2 and FR3. Pure documentation tweak; no code change.

### P1-4. deprecation.yaml 2.8.4 entry has `files: []` — correct for THIS cleanup, but inconsistent with `*sync` precedent

Handoff §4.2 File 4 specifies:
```yaml
"2.8.4":
  description: "Linear integration removed..."
  files: []  # No standalone files removed
```

This is correct given Linear was config-section deletion not file deletion. But `tad.sh` (the *sync runner) processes `files:` arrays for cleanup — `files: []` means the sync runner gives downstream projects no actionable cleanup hint. After P0-1 fix expands deletions to include `handoff-a-to-b.md` (template change) and `post-write-sync.sh` (hook change), the deprecation.yaml `note:` field becomes the only place where downstream projects learn about the Linear removal — but `note:` is human-readable, not script-actionable.

**Fix**: This is acceptable IF (a) downstream project re-sync via `*sync` will overwrite the affected files (templates, hooks, skill markdown) anyway — verify this is true given `last_synced_version: "2.8.3"` in `sync-registry.yaml`. If `*sync` does an `rsync`-style overwrite, files: [] is fine. If `*sync` is selective, the missing entries could leave stale Linear refs in downstream copies. Recommend Blake explicitly verify *sync mechanism in tad.sh and document in COMPLETION report which files downstream will and won't get refreshed.

### P1-5. Handoff §10.1 says "不要砍 hook 注册 in settings.json" but does not check that settings.json is in fact NOT being modified

Standard hygiene: AC for `git diff .claude/settings.json` returning empty (or specifically that the `userprompt-domain-router.sh` registration is unchanged). This is one-line and prevents Blake's pattern-match "while I'm in cleanup mode, why is this hook still registered if it does nothing useful" rationalization.

**Fix**: Add AC17: `git diff .claude/settings.json` shows no changes (exit 0 with empty output).

---

## Suggestions (P2 — nice to have)

### P2-1. Reversibility analysis is correct but understated

Handoff §12 lists "git revert if needed." Per architecture.md `Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15`, the precedent for hook-related rollback is: hook code archived to `.tad/archive/spikes/` rather than git-revert, because git history alone makes "research asset preservation" hard to find later. This handoff's hook change is contract-narrowing (delete 11 lines of injection, keep all evaluation+log infrastructure) so a future "revive injection" only requires re-adding the 11-line block. Pure git-revert is sufficient here. The 2026-04-15 precedent does NOT apply 1:1.

**Suggestion**: Add a one-line note in §12 making this distinction explicit ("Reversibility differs from Phase 3.B (Epic 1) which archived code; this cleanup is narrow-scope contract-narrowing — git revert is sufficient and no archive needed").

### P2-2. layer2-audit.sh slug regex compatibility verified — `tad-cleanup-linear-and-hook` PASSES

Verified by reading `.tad/hooks/lib/layer2-audit.sh:103`:
```bash
[[ "$slug_raw" =~ ^[A-Za-z0-9_]([A-Za-z0-9_-]*[A-Za-z0-9_])?$ ]]
```

Test: `tad-cleanup-linear-and-hook` — first char `t` (alnum), last char `k` (alnum), middle chars all alnum/hyphen → PASS. `bash -c 'echo "tad-cleanup-linear-and-hook" | grep -E ...'` confirmed PASS.

No fix needed; this is a positive verification for §9.1 row AC14.

### P2-3. The "smoke alarm > auto-extinguisher" pattern application is correct here

Per architecture.md `Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15` and `Path Layering: Three Defenses - 2026-04-24`, the canonical pattern is: monitoring (log/audit) over enforcement (hook deny/inject). This handoff's hook change is a textbook application — keep evaluation logic + log writes (smoke alarm), remove inject (auto-extinguisher). Trace data accumulates, future trace analysis can resurrect targeted enforcement when threat model warrants.

The single-user CLI threat model from 2026-04-15 also applies here (TAD framework dev = same single-user environment). Architecture coherence is **strong** on the hook half of this handoff.

The Linear-removal half is structurally separate from the smoke-alarm pattern (it's just unused-feature cleanup) but no contradiction.

### P2-4. AC11 (`.router.log` 行数 +1`) is a good positive-verification of "log still works" — keep as-is

Verifies that passive mode preserves the log path. This catches a class of failure where Blake accidentally deletes log code along with injection code. Good AC, no change.

### P2-5. Decision Summary §11 row 6 nicely captures the "step4b vs step0b" trade-off — reuse for similar future cleanups

The "保留 step4b、删除 step0b 重复" rationale is the kind of decision that should accumulate in project-knowledge for the Phase 6 process refinement. Consider whether `architecture.md` warrants a "Subset-Superset Cleanup Pattern" entry post-acceptance: when two checks exist, the strict subset is the safer one to delete because the superset's additional coverage is preserved.

---

## Overall Assessment

**CONDITIONAL PASS** — Architectural intent is sound (smoke alarm > auto-extinguisher hook redesign aligns with 2026-04-15 lesson; *accept slimming is safe due to step4b superset; Linear removal is justified by zero usage), but the handoff's blast-radius accounting is incomplete (4 additional active files reference Linear), config-platform.yaml `important_notes` placement is structurally ambiguous (P0-2 will produce invalid YAML or collateral data loss without explicit guidance), and at least 2 ACs (AC4 soft-escape, AC13 file-count) need tightening to avoid the gray-zone pattern that's now recurred in Phase 3, 4, 5. Hook regression test (Phase 3 step 5) is also unreliable as designed and needs replacement with direct hook-stdout inspection.

Blake should NOT start until P0-1 (expanded FR list), P0-2 (important_notes structural decision), P0-3 (AC4 disposition), P0-4 (AC13 file count + .router.log handling), and P0-5 (regression test redesign) are resolved by Alex.

---

**Reviewer signature**: backend-architect
**Review duration**: ~25 minutes
**Files read for verification**:
- `.tad/active/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md` (full)
- `.claude/skills/alex/SKILL.md` (lines 75-220, 605-660, 1580-1650, 2295-2380, 2760-2900)
- `.tad/hooks/userprompt-domain-router.sh` (full)
- `.tad/hooks/startup-health.sh` (full)
- `.tad/hooks/post-write-sync.sh` (lines 65-95)
- `.tad/hooks/lib/layer2-audit.sh` (lines 1-110)
- `.tad/config-platform.yaml` (lines 1-30, 220-285)
- `.tad/config.yaml` (lines 70-100, 315-325)
- `.tad/templates/handoff-a-to-b.md` (lines 30-50)
- `.tad/deprecation.yaml` (full)
- `.tad/sync-registry.yaml` (head 60)
- `.claude/settings.json` (full)
- `.tad/project-knowledge/architecture.md` entries: Mechanical Enforcement Rejected (2026-04-15), Hook Performance Single-awk (2026-04-07), Domain Pack Keyword Curation (2026-04-07), Claude Code Native Mechanism Validation (2026-03-31), UserPromptSubmit Hook Verified (2026-04-07), AC Verification Commands Need Pre-Ship Smoke Test (2026-04-25), AC Precision (2026-04-14), Path Layering (2026-04-24)
