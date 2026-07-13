# Phase 2 Design Review — code-reviewer lens

**Handoff**: HANDOFF-20260713-native-capability-adoption-phase2.md
**Reviewer**: code-reviewer (Conductor 3-lens, AC command runnability + grep-anchor robustness)
**Date**: 2026-07-13
**Verdict**: BLOCK (2 P0) — design is coherent and well-grounded, but two acceptance commands are not runnable-as-written on this machine.

---

## Summary

This is a strong, unusually disciplined handoff: spike-first, explicit degradation matrix, behavioral (not structural) evidence gates, in-body anti-anchoring boundary, zero-machine-global-write guard. Factual claims verified against the live repo all hold (CLI 2.1.172, code-security pack present, no project `.claude/agents/`, 30 user-level defs, spec-compliance-reviewer genuinely absent, blake L550/L584 pack consumption points exact). File list is complete and §7.3 grounding is real.

The blocking issues are narrow but real: the **primary Layer-1 verification tool (`python3 yaml.safe_load`) does not run on this machine** because pyyaml is not installed, and **AC3's `grep -L` silently reads STDIN in the exact degradation branch the handoff defines** (memory VERDICT=FAIL → no memory-enabled defs → empty file-arg list). Both are the "AC must be mechanically runnable" failure class the project's own ac-verification pattern warns about.

---

## P0 — Blocking

### P0-1: AC2 / NFR1 `import yaml` is NOT runnable — pyyaml absent from the only python3
- **Where**: NFR1 (L215), AC2 (L574), grounding L50-51.
- **Evidence (live)**:
  ```
  which python3 → /opt/homebrew/bin/python3 (3.14.4)
  python3 -c "import yaml" → ModuleNotFoundError: No module named 'yaml'
  python3 -m pip show pyyaml → Package(s) not found: pyyaml
  no .venv, no local pyyaml
  ```
  The grounding file itself mandates "`python3 yaml.safe_load` on the frontmatter block" as the repo's Layer 1 substitute — but that check cannot execute here. AC2 as written (`import ... yaml.safe_load ... || echo FAIL`) will emit `FAIL:` for **every** def purely because the import fails, not because any frontmatter is malformed. So the gate is both non-runnable and, if run, produces a false FAIL for correct files.
- **Why P0**: AC2 is the *only* structural correctness check on the deliverable (agent-def frontmatter). If it can't run, Gate 3 loses its single mechanical guard on the artifacts being produced. This is precisely the "unverified tool assumption" hazard (principles.md: Never Hand-Write What a Tool Does / Measure Before Optimizing).
- **Fix options** (pick one, encode in NFR1 + AC2):
  - (a) Switch to a stdlib-only frontmatter check that needs no pyyaml — the frontmatter here is simple `key: value` + a `skills:` list, parseable with a stdlib script, OR use `python3 -c "import tomllib"`-style stdlib only. Simplest robust stdlib check: verify the block splits cleanly and every non-list line matches `^\s*[\w-]+:\s`, plus the list items are `^\s*-\s`.
  - (b) Per global CLAUDE.md package policy, provision pyyaml **in a venv** (`uv venv && uv pip install pyyaml==<pinned>`), and make AC2 call that venv's python explicitly. Do NOT `pip install pyyaml` into the Homebrew global (violates the user's venv rule).
  - (c) If the CLI's own `Task`/agent loader validates frontmatter at spawn time, make AC2 assert "agent spawns without a frontmatter error" (behavioral) instead of an offline parse.
- Recommend (a): zero new dependency, matches the repo's no-npm/stdlib Layer-1 ethos, runs today.

### P0-2: AC3 `grep -L` reads STDIN in the memory-FAIL degradation branch → hang / false result
- **Where**: AC3 (L575): `grep -L 'MUST NOT store past verdicts' $(grep -l '^memory' .claude/agents/*.md 2>/dev/null | grep -v tad-spike)`
- **Evidence (live)**: when the inner `grep -l '^memory'` returns nothing, the outer `grep -L` gets **no file arguments** and falls back to reading STDIN:
  ```
  grep -L 'MUST NOT store past verdicts' $(... empty ...)
  → prints "(standard input)", exit 0    # read STDIN, not files
  ```
  In a non-interactive Gate 3 runner this either blocks on STDIN or consumes piped input and returns a meaningless result.
- **Why P0**: This is not a corner case — it is the handoff's **own defined degradation path**. §4.1 matrix row 1 (memory FAIL, skills PASS) and Phase-2 spike-gating mean "zero memory-enabled defs" is a first-class expected state. AC3 must PASS (vacuously) in that state, not hang. As written it silently misbehaves exactly when the degradation policy is exercised — undermining the "never silently drop" guarantee the handoff is built on.
- **Fix**: guard the empty set. E.g.:
  ```bash
  files=$(grep -l '^memory' .claude/agents/*.md 2>/dev/null | grep -v tad-spike)
  if [ -z "$files" ]; then echo "AC3 vacuous PASS (no memory-enabled defs — memory VERDICT=FAIL branch)"; \
  else grep -L 'MUST NOT store past verdicts' $files; fi
  ```
  Add to the AC3 Expected Evidence cell: "empty file set → vacuous PASS with reason (memory degradation branch)".

---

## P1 — Should Fix

### P1-1: AC2 `split('---')[1]` is fragile against multi-`---` frontmatter/body
- **Where**: AC2 (L574).
- **Evidence**: real agent defs contain `---` inside the body (verified: `grep -c '^---' code-reviewer.md` → 2 for the fences, but bodies of these reviewer personas routinely use `---` horizontal rules). `t.split('---')[1]` grabs everything between the *first two* `---`, which is correct for a leading fence — but if a shadow def's copied body opens with a stray `---` or the description contains `---`, index `[1]` silently captures the wrong slice and either parses garbage or masks a real frontmatter error. Combined with P0-1's replacement, adopt a frontmatter extractor that anchors on the **leading** fence only (split with maxsplit=2 and require the file to start with `---`).
- **Fix**: `parts = t.split('---', 2); assert t.startswith('---'); front = parts[1]`. Or, in the stdlib check from P0-1, read lines between the first `^---$` and the next `^---$`.

### P1-2: tad-spike-memory-agent lifecycle vs AC2/AC3 is under-specified
- **Where**: Component §4.2.1 ("完成后删除或保留为 fixture——Blake 决定"), AC2 globs `.claude/agents/*.md`, AC3 filters `grep -v tad-spike`.
- **Issue**: AC3 explicitly excludes the spike agent (good), but AC2 does **not** — if Blake keeps the spike agent as a fixture and it carries a raw/experimental `memory` value that fails the parse, AC2 flips to FAIL for a non-deliverable file. And if the spike agent is deleted, START_MARKER's `find -newer` (AC7) and the fixture reference in §12 dangle.
- **Fix**: make the decision deterministic in the handoff, not "Blake decides": either (a) require the spike agent be **deleted** after Phase 1 (cleanest; AC7/AC10 unaffected), or (b) if kept, require its frontmatter to be parse-valid and add `grep -v tad-spike` to AC2 as well, symmetric with AC3.

### P1-3: AC10 scope regex depends on `^ M \.gitignore` git-status format that varies
- **Where**: AC10 (L582): `grep -vE '...|^ M \.gitignore|...'`.
- **Issue**: `.gitignore` is tracked, so `git status --porcelain` yields ` M .gitignore` (leading space + M) — the regex matches. But if `.gitignore` ends up staged (`M  .gitignore`) or the runner uses `-z`/different porcelain version, the leading-space anchor misses and AC10 false-FAILs. Verified the happy path passes (empty output). Minor, but a one-char format drift breaks it.
- **Fix**: loosen to ` ?M \.gitignore` or match `\.gitignore$` without leading-status anchoring, since path-based exclusion is the intent.

---

## P2 — Nice to Have

### P2-1: AC4 `git check-ignore -v` needs a concrete path, resolved only at runtime
- AC4 verifies "memory 落点 gitignored" but the path is `<spike 报告的 repo 内落点路径>` — a placeholder resolved from spike output. Fine, but add an explicit instruction that Blake must substitute the literal spike-reported path and paste both the substituted command and its output, so Gate 3 isn't re-deriving the path.

### P2-2: AC5/AC6 nested-spawn feasibility already flagged in 8.4 — good, but no fallback anchor line
- Friction Preflight (L533) correctly anticipates "subagent 无法二次 spawn". The allowed substitute (cross-turn Task calls) is sound. Suggest adding to the evidence schema a `SPAWN-METHOD: single-session|cross-turn` line so Gate 3 can confirm which path was taken and that the two RUNs were genuinely separate spawns (not one context reused — which would invalidate the memory-recall claim).

### P2-3: `skills: [code-security]` value shape is spike-determined but AC has no shape check
- FR5/Data Model show `skills: [code-security]`, but if the spike reveals the field wants a path or a different key, no AC catches a wrong shape (AC2 only checks YAML validity, AC6 checks behavior). Behavioral AC6 is the real guard, so this is P2 — but a one-line "frontmatter skills value matches spike-VERDICT-skills shape" note would close the loop.

---

## Frontmatter / Coherence Checks (all PASS)

- **task_type**: `mixed` — correct (spike + config files + behavioral verification). ✅
- **e2e_required: yes** — correct and load-bearing; AC5/AC6 are behavioral. ✅
- **research_required: no** — correct; local spike explicitly supersedes doc-level notebook. ✅
- **git_tracked_dirs: [".claude/agents"]** — correct; matches the new tracked dir; Known Constraint L624 correctly flags the deny-list sync implication. ✅
- **Design coherence**: requirements (FR1-7) map 1:1 to Technical Design §4 and to AC0-AC10; degradation matrix §4.1 is referenced consistently from FR/NFR/8.4. ✅
- **File list completeness**: §7.1/7.2 cover every artifact the FRs/ACs reference; no missing file. START_MARKER, spike-report, behavioral-evidence, 3 reviewer defs, spike agent, .gitignore all present. ✅

---

## Verification log (live, this machine)
- `claude --version` → 2.1.172 ✅ (AC0 confirmed)
- `ls .claude/skills/code-security/SKILL.md` → present ✅ (AC0b)
- `ls .claude/agents` → No such file or directory ✅ (AC0c baseline)
- `ls ~/.claude/agents | wc -l` → 30; spec-compliance-reviewer absent ✅
- blake SKILL L550/L584 "Capability Pack" grep → exact match ✅ (MQ1)
- `python3 -c "import yaml"` → ModuleNotFoundError → **P0-1**
- AC3 `grep -L` empty-arg → reads STDIN → **P0-2**
- AC1/AC5/AC6 ERE anchors on BSD grep → correct counts ✅
- AC10 happy-path → empty output (pass) ✅
