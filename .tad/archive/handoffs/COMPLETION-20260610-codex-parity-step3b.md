---
gate3_verdict: pass
---

# Completion Report: Codex Parity Gate (step3b) — v3 (post Gate 4 round 2 fix)

**Task ID**: TASK-20260610-codex-parity-step3b
**Handoff**: .tad/active/handoffs/HANDOFF-20260610-codex-parity-step3b.md
**Commits**: 16983f6 (v1) → ebe92cf (P1) → 238a56d (G4 P0 r1: DIRECTION inversion) → e82704f (G4 P0 r2: parse failure STOP)
**Date**: 2026-06-10

## What Was Done

Publish-time parity gate: `.claude/skills` ↔ `.agents/skills` byte-identity check. Default STOP on any indeterminate input, including parse failures.

### Gate 4 Round 2 Fix (e82704f)

L566 `[ -z "$apath" ] && continue` was a fail-open: when sed couldn't parse a diff line (e.g., space-in-filename), the empty apath was silently skipped. Since the loop was trying to PROVE claude-newer for every path, skipping a path meant it went unproven — but `all_claude_newer` stayed true because no code flipped it. Result: parse failure → fail-open to destructive rsync.

Fix: `if [ -z "$apath" ]; then all_claude_newer=false; echo "  ⚠️  unparseable diff line — cannot prove direction"; break; fi`

Note: the 238a56d commit message claimed "parse failure stays at STOP" — that was incorrect. The default inversion (238a56d) handled the non-git and orphan cases correctly, but the sed-parse-failure path inside the loop was still fail-open. This round closes it.

---

## AC1–AC13 Verification Evidence (post e82704f)

### AC1: `bash -n` exits 0
```
EXIT: 0
```
**PASS**

### AC2: Clean parity exits 0
```
✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0)
```
**PASS**

### AC3: Agents-side content drift → exit 1, agents-newer, --fix REFUSES
```
echo "d" >> .agents/skills/blake/SKILL.md
DIRECTION: agents-newer (STOP)
VERDICT: parity FAIL (exit 1)
--fix: 🛑 REFUSED (exit 1)
git checkout -- .agents/skills/blake/SKILL.md
```
**PASS**

### AC4: Orphan file → exit 1, orphan NAMED, agents-newer, --fix REFUSES
```
echo x > .agents/skills/orphan.txt
❌ Only in .../TAD/.agents/skills: orphan.txt
⚠️  orphan on .agents side
DIRECTION: agents-newer (STOP)
--fix: FIX-REFUSED (exit 1)
rm .agents/skills/orphan.txt
```
**PASS**

### AC5: Claude-side drift → claude-newer → --fix succeeds → re-verify exit 0
```
echo "d" >> .claude/skills/alex/references/publish-protocol.md
DIRECTION: claude-newer
VERDICT: parity FAIL (exit 1)
--fix: ✅ Fix successful, FIX-PASS (exit 0)
re-verify: parity PASS (exit 0)
git checkout -- .claude/skills/alex/references/publish-protocol.md .agents/skills/...
```
**PASS** — Uncommitted .claude edit positively identified as claude-newer.

### AC6a: Missing dirs → exit 2
```
parity "$(mktemp -d)" → ERROR: no .claude/skills, EXIT: 2
```
**PASS**

### AC6b: No-arg → exit 2, parity listed
```
parity (no args) → Usage: ... parity [--fix] <repo_root>, EXIT: 2
```
**PASS**

### AC7: publish-protocol step3b content
```
step3b: at line 84 (between step3:75 and step3c:109)
FIX-REFUSED/FIX-FAIL: 2 matches
NEVER -A: 1 match
investigate (refusal): 2 matches
Re-run step3: 1 match
```
**PASS**

### AC8: Runbook step3b references
```
L240: step3b (codex parity, `release-verify.sh parity [--fix]`)
Pre-flight checklist: parity check item present
```
**PASS**

### AC9: Regression
```
version "$PWD" "2.28.0" → PASS (exit 0)
derive-sync-set.sh --dirs → exit 0
```
**PASS**

### AC10: CONTRACT header
16 grep matches for exit codes / DIRECTION / no-patch-downgrade (lines 77-93).
**PASS**

### AC11 (FINAL): Clean tree + parity exit 0
```
git status --porcelain -- .claude/skills .agents/skills → (empty)
parity "$PWD" → PASS (exit 0)
```
**PASS**

### AC12: Non-git directory → heuristic blind → STOP → --fix REFUSES
```
tmpdir (no .git), drift injected
⚠️  not a git repository — cannot determine direction (default: STOP)
DIRECTION: agents-newer (STOP)
--fix: 🛑 REFUSED (exit 1)
```
**PASS**

### AC13: Space-in-filename → parse failure → STOP → --fix REFUSES → .agents content survives
```
mkdir ".claude/skills/zz space test" ".agents/skills/zz space test"
echo cv > ".claude/skills/zz space test/SKILL.md"
echo av > ".agents/skills/zz space test/SKILL.md"

parity:
⚠️  unparseable diff line — cannot prove direction
DIRECTION: agents-newer (STOP)
VERDICT: parity FAIL (exit 1)

--fix:
🛑 REFUSED (exit 1)

.agents content survived: "av" (unchanged)
cleanup: porcelain clean
```
**PASS**

---

## Layer 2 Expert Review

### Reviewer History

1. **code-reviewer** (sub-agent, Layer 2 initial): 11 AC spec + code quality. Found 2 P1 (sed fragility, echo backslash). Fixed ebe92cf.
2. **Gate 4 round 1** (Alex + independent sub-agents): Found P0 DIRECTION default inversion. Fixed 238a56d.
3. **Gate 4 round 2** (Alex + security re-test): Found P0 L566 parse-failure fail-open. Fixed e82704f.

Evidence: `.tad/evidence/reviews/blake/codex-parity-step3b/review-summary.md`

---

## Friction Status

| Friction Point | Status | Notes |
|----------------|--------|-------|
| Draft on separate branch (75ef98c) | READY | Re-implemented with v2 deltas |
| Gate 4 P0 round 1 (DIRECTION default) | READY | Inverted in 238a56d |
| Gate 4 P0 round 2 (L566 parse failure) | READY | Fixed in e82704f |
| `.agents/skills/blake/SKILL.md` +17 (ebe92cf) | READY | Mirror of 4a779fa user-guidance, direction Claude→Codex, human verified |

---

## Reflexion History

无 Layer 1 reflexion（ACs 一次通过）。

Gate 4 surfaced two P0s that Layer 2 missed:
- Round 1: DIRECTION default claude-newer (should be STOP). Root cause: implemented the heuristic as "start safe, break to unsafe" but the variable default was inverted.
- Round 2: L566 `continue` on empty apath. Root cause: the `continue` was a leftover from the v1 logic where default was claude-newer (skipping was harmless). After the inversion, every skipped path is an unproven path that should flip `all_claude_newer=false`.

Both were DESIGN-LEVEL errors invisible to decidable-input ACs — the system working as designed (Gate 4 independent verification catches what Layer 2 misses).

---

## Knowledge Assessment

**Q1: New discoveries?** ✅ Yes

**File**: `.tad/project-knowledge/patterns/ac-verification.md`
**Entry**: "Fail-Safe-Default Requirements Need an Undecidable-Input AC — 2026-06-10"
**Status**: Entry exists on disk (verified: `grep -c 'Fail-Safe-Default' .tad/project-knowledge/patterns/ac-verification.md` = 1).

**Q2: Reusable working pattern?** ❌ No — undecidable-input AC technique already captured as project knowledge pattern.

**Q3: Workflow pattern?** ❌ No.

**Skillify Candidate**: No (already captured in project knowledge).

---

## KNOWN RESIDUAL GAP

Parity gate runs at **publish** time. Historical drifts were at **edit** time. Follow-up: Blake completion-protocol parity check.
