# Security Audit — HANDOFF-20260712-memory-redirect-capture-layer

**Reviewer**: security-auditor
**Date**: 2026-07-12
**Scope**: §1, §6 (T1-T7), §9.1 AC table, §10, §8.4 + `.gitignore` + `.claude/settings.local.json` (first 30)
**Verdict**: **CONDITIONAL PASS** — 2 P0 must be fixed before implementation

Grounding performed (not paper review):
- Enumerated the real 36 native memory files at `~/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD/memory/`.
- Read `user_agent-builder-goals.md` (a `type: user` profile memory) and grepped all 36 for PII/paths.
- Confirmed remote: `origin → https://github.com/Sheldon-92/TAD.git` (published repo).
- Confirmed `git check-ignore .tad/memory/<file>` → **NOT IGNORED** (will be committed + pushed).
- Confirmed `.claude/settings.local.json` **is** gitignored (abs path not pushed — good).
- Read `derive-sync-set.sh` contract + current `--zero-touch` (10 dirs, no `memory`) and `--dirs` derivation (`ls -d .tad/*/` MINUS DENY_LIST).

---

## 1. Critical Issues (P0 — must fix before implementation)

### P0-1 — Committing native memory to a PUBLIC repo leaks a `type: user` personal profile + sensitive references; no pre-commit content scan exists as an AC

**Severity**: Critical · **CWE-200 (Exposure of Sensitive Information)** / CWE-359 (Privacy Violation)

**Location**: D1 (§2-4 "git 策略: `.tad/memory/` 全部进 git"), T2 (§6), T7 commit, AC9. `.gitignore` (memory dir NOT covered).

**Evidence (concrete, not hypothetical)**:
- Remote is `https://github.com/Sheldon-92/TAD.git` and the handoff itself states "The repo may be pushed to GitHub (TAD publishes releases)". `git check-ignore .tad/memory/user_agent-builder-goals.md` → **NOT IGNORED**.
- `user_agent-builder-goals.md` has `type: user` and contains a first-person profile of the repo owner: "Creator and primary user of TAD", "Runs OpenClaw agents daily", "Considers Claude Code the best AI agent product they've used", product-direction intentions (hardware, strategic planning). This is exactly the class of content a public-repo author would not knowingly publish.
- `grep` across the 36 files flagged `project_co-thinking-workshop-seed.md` and `reference_claude-code-source.md` as containing absolute local paths / source-analysis references (`reference_claude-code-source.md` is titled "Key files and patterns from **leaked source** analysis" per MEMORY.md — publishing an analysis of leaked Claude Code source under the owner's name is a distinct legal/reputational exposure).
- Several `feedback_*` and `project_*` files encode private product strategy (surplus-burn backlog, next-direction, monetization thinking) — competitively sensitive if the repo is public.

**Why the current plan does not catch it**: The plan treats "commit memory" as a settled design decision (D1) and AC9 only checks that the *file set* matches the plan — it never inspects *content*. There is no AC that scans the 36 migrated files for user-type memories, emails, absolute home paths, or secrets before the commit. AC8 verifies redirection works; nothing gates what gets published.

**Impact**: One-way disclosure. Once pushed to a public remote, git history retains the profile/strategy/leaked-source-reference content permanently even if later deleted; scrubbing requires history rewrite + force-push + assuming no clone/fork already exists.

**Required remediation (pick the combination; at minimum a + b)**:
- **(a) Add a BLOCKING pre-commit content-scan AC** (new AC, P0) over the migration set. Must run BEFORE `git add`:
  - Fail the gate if any file has `type: user` frontmatter (route user-type memories to a human decision — do NOT auto-commit them).
  - Scan for secrets/PII: run the repo's existing `code-security` pack tooling (Gitleaks/TruffleHog per the `code-security` skill) OR at minimum `grep -rIE '(gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(com|edu|org))'` across `.tad/memory/`. Any hit ⇒ human review, not auto-commit.
  - Flag absolute-home-path leakage (`/Users/<name>/`) as a report item.
- **(b) Human confirmation gate**: because "what is safe to publish" is a human-domain judgment (per principles.md 2026-07-03 AI/Human domain awareness — this is a *taste/direction/privacy* call, not an AI-域 mechanical check), the migration MUST present the operator a **shortlist** ("these N files contain user-profile / private-strategy / leaked-source content — commit all / commit subset / keep out of git?") rather than silently committing all 36. This is a choice question, not a rubber-stamp "对不对?".
- **(c) Recommended default**: reconsider D1 for the *user-type and strategy* subset. Even if `.tad/memory/` is tracked in general, add a `.gitignore` carve-out (e.g. `.tad/memory/user_*.md`) or a per-file allowlist, so that model-written *methodology* memories can be shared but *personal-profile* memories stay local. D1 was decided as a blanket "全部进 git" without separating publishable-methodology from private-profile — the two populations have different disclosure risk and should not share one flag.

> Note: this P0 is a genuine design-scope escalation, not a nitpick — the handoff explicitly asked whether "a pre-commit scan of the 36 migrated files [is] warranted as an AC". Answer: **yes, and it is currently absent.**

### P0-2 — AC3 SAFETY exclusion is asserted at ONE granularity only; the load-bearing EXCLUSION assertion + fresh-install path are not covered

**Severity**: Critical (SAFETY red-line, self-declared) · maps to principles.md 2026-06-01 "deny-list must apply at EVERY copy granularity" + "the load-bearing AC is the EXCLUSION assertion".

**Location**: T3, AC3.

**Findings**:
1. **AC3 tests inclusion-in-zero-touch (`grep -cx memory == 1`) and absence-from-`--dirs` (`== 0`) — but not the *actual data-flow exclusion*.** Per the 2026-06-01 lesson, the load-bearing assertion is that the sync SET does not contain memory AND that a broken `grep -vxE` cannot *leak* memory into the sync set. Adding `memory` to `ZERO_TOUCH` makes it part of `DENY_LIST`, and `--dirs = ls -d .tad/*/ MINUS DENY_LIST`. The plan's AC3 `--dirs | grep -cx memory == 0` does cover the derived-dirs exclusion (good), but there is **no assertion that `tad.sh`'s install/sync actually skips `.tad/memory/`** end-to-end. Verified today: `--dirs` currently omits memory only because the dir does not yet exist — after T2 creates it, the exclusion depends entirely on T3 landing correctly. If T2 (create dir) runs but T3 (deny-list) is skipped or mis-edited, memory silently enters the sync set. Sequencing/atomicity is a real risk.
2. **Fresh-install granularity not verified.** `derive-sync-set.sh` documents an EMBEDDABLE-VERBATIM copy of the DENY_LIST + pipeline into `tad.sh` for fresh machines where `.tad/hooks/lib/` isn't yet sourced ("P2 embeddability / NFR4"). If `tad.sh` carries an **inline** copy of the deny-list, editing only `derive-sync-set.sh` (T3) may leave the inline `tad.sh` copy stale → fresh installs would NOT exclude memory. The handoff relies on "tad.sh drift 检查通过 `--zero-touch` flag 读取,自动一致" — that drift-check must actually be run and asserted, not assumed. AC3 does not invoke `tad.sh --verify-denylist`.
3. **Downstream data-destruction direction.** The 2026-06-01 lesson warns the WORSE failure is a broken exclusion *clobbering* downstream project data (memory is per-project user data). AC3 has no assertion in the "would a downstream sync overwrite/delete a target's own `.tad/memory/`" direction.

**Required remediation**:
- Add to AC3: `bash .tad/hooks/lib/tad.sh --verify-denylist` (or the actual drift-check entrypoint) returns 0 / reports memory consistently across the inline copy and the lib. If `tad.sh` has an inline DENY_LIST, assert `memory` is present there too (or that the drift-check couples them).
- Add an end-to-end exclusion assertion: simulate the sync copy (dry-run) and assert `.tad/memory/` is neither read from source nor written to target. Presence in `--zero-touch` is necessary but not sufficient — the 2026-06-01 principle says verify the EXCLUSION, at the granularity the copy actually happens.
- Make T2→T3 ordering explicit and gated: T3 (deny-list) and its verification must PASS before any commit that introduces `.tad/memory/`. Consider doing T3 before T2 so the exclusion exists the moment the dir is born.

---

## 2. Recommendations (P1 — should address)

### P1-1 — `cp -n *.md` migration: partial-copy + count-AC blindness + glob edge cases (T1/T2, AC2)
- **Silent-skip on any error**: `cp -n "$OLD_DIR"/*.md "$TARGET_DIR"/ 2>/dev/null || true` swallows ALL failures (permission, disk full, partial copy). AC2 only checks `ls .tad/memory | wc -l >= 36`. A count floor cannot prove content-completeness — this is the exact "presence + non-empty ≠ content-complete" trap from principles.md 2026-06-01. Recommend replacing the count check with a per-file diff: `diff -rq "$OLD_DIR" "$TARGET_DIR"` (source is local) and asserting every source `*.md` is byte-identical in target. That is the only check that catches a partial copy.
- **`cp -n` re-run semantics**: AC7 claims idempotency, but `cp -n` also means a memory the user later *updated* in the old dir will NOT refresh into the target on a second `--enable`. Fine for one-shot migration, but the runbook/CLAUDE.md should state `--enable` is migrate-once, not sync.
- **Glob non-match**: if `$OLD_DIR` exists but has zero `.md`, the unquoted glob passes the literal `*.md` to `cp` → error suppressed by `|| true`, count stays 0, AC2 fails loudly (acceptable, but note the diagnostic is poor). Prefer `find "$OLD_DIR" -maxdepth 1 -name '*.md' -exec cp -n {} "$TARGET_DIR"/ \;` or a nullglob guard.
- **MEMORY.md migration**: T2 copies MEMORY.md into the target, but T4 step 2 correctly excludes it from distillation, and §10.3 says don't add extra files. Confirm native regenerates its own MEMORY.md index in the new dir — copying a stale index may confuse the runtime's ledger. Worth an explicit AC8 sub-check.

### P1-2 — Silent-failure detection for the redirect itself (workspace trust) — AC8 covers happy path only
- The plan hinges on the **workspace trust dialog** being accepted for `autoMemoryDirectory` in `settings.local.json` to take effect (Research Notebook S1b). §8.4 acknowledges a one-time human click. **The dangerous case is the SILENT one**: trust is declined / dialog never appears / key ignored → the model keeps writing to the OLD dir (`~/.claude/projects/.../memory/`) and nobody notices; distillation then silently reads an empty/stale `.tad/memory/`. 
- AC8 verifies the positive ("new memory lands in `.tad/memory/`") but there is **no negative-detection AC**: nothing asserts the OLD dir stops growing. Recommend adding to AC8: after the test-session write, assert the OLD dir file-count/mtime is UNCHANGED (still 36, no newer mtime) AND the new file is in `.tad/memory/`. If the old dir grew, the redirect silently failed — that must FAIL the gate, not pass. This is the falsification the handoff's own §9.1 warning gestures at but does not encode as a check.
- Consider a lightweight `--status` drift line: "WARNING: old dir has files newer than target's newest — redirect may not be active."

### P1-3 — `SLUG` derivation is a guess encoded in `sed` and is fragile (T1)
- `SLUG="$(printf '%s' "$ROOT" | sed 's![/ ]!-!g')"` reproduces Claude Code's internal project-dir naming. The repo path contains a space AND the derivation must match exactly, or `OLD_DIR` points nowhere → migration silently copies nothing (masked by `|| true`), AC2 fails. The handoff's "实现提示" says to verify against the real dir — good — but that verification is prose, not an AC. Recommend a hard preflight in `--enable`: if `$OLD_DIR` does not exist, do NOT silently proceed; print the derived path and the actual candidates (`ls -d "$HOME/.claude/projects/"*TAD*/memory` ) and exit non-zero so the operator fixes the slug. Relying on an undocumented internal naming rule is brittle across Claude Code versions.
- Leading-`-` filenames: the derived slug legitimately starts with `-` (`-Users-...`). Any later `ls`/`cp` that receives it as a bare arg could mis-parse it as a flag. Current code always embeds it in `$OLD_DIR` path so it's safe today, but note it for future edits.

### P1-4 — `jq` merge preserves keys but not necessarily formatting/comments; verify permissions array integrity (T1, AC1)
- `jq '. + {autoMemoryDirectory: $d}'` on `settings.local.json` will reserialize the whole file (drops any comments, may reorder keys, normalizes whitespace). The current file is pure JSON with a large `permissions.allow` array, so no data loss — but AC1 should assert `jq '.permissions.allow | length'` is byte-for-byte equal before/after (the AC text says "与基线一致" — make it an exact numeric+content equality, e.g. `jq -S '.permissions'` diff == empty), not just key-set equality. A key-set check would miss a value-level mutation inside `permissions`.
- `mv "$tmp" "$LOCAL_SETTINGS"` after `jq ... > "$tmp" &&`: good (atomic, no clobber-on-jq-failure). `mktemp` with default TMPDIR is fine. One gap: `mktemp` output on a different filesystem than `.claude/` makes `mv` a copy+unlink (still atomic-enough for a single writer). Acceptable.

## 3. Suggestions (P2 — nice to have)
- **P2-1**: `set -euo pipefail` + `ls "$OLD_DIR" 2>/dev/null | wc -l` in `status()` — the pipeline masks `ls` failure via the pipe, fine, but under `pipefail` a failing `ls` won't abort because `wc` succeeds. Intentional here; just noting it's relying on that.
- **P2-2**: Add a `.tad/memory/.gitattributes` or a short `README`-less note in CLAUDE.md that memory files are model-authored and may contain informal/unverified content, so a reader of the public repo doesn't treat them as authoritative TAD docs. (§10.3 forbids a README *inside* the dir for native-dedup reasons — put the caveat in CLAUDE.md §7.5 instead.)
- **P2-3**: Consider committing memory with a periodic scrub policy in the runbook (P2 gotcha): "before `*publish`, re-run the memory content-scan (P0-1) in case new user-type memories accumulated since last release."
- **P2-4**: `TARGET_DIR="$ROOT/.tad/memory"` is absolute (good — `autoMemoryDirectory` requires abs/`~`). But `.claude` is created with `mkdir -p .claude` (relative) — harmless since `ROOT=$(pwd)`, but if the script is ever run from a subdir, `pwd` ≠ repo root and everything lands in the wrong place. Add a guard: assert `.tad/` and `.git/` exist under `$ROOT`, else exit "run from project root".

---

## 4. Overall Assessment

**CONDITIONAL PASS** — the layered design (redirect-not-disable, read-only contract, deny-list SAFETY, additive protocol edits, opt-in downstream) is sound and the handoff correctly internalizes prior principles. But two Critical issues must be resolved before implementation:

- **P0-1**: Committing native memory to a **public** GitHub repo will publish a `type: user` personal profile, private product strategy, and a leaked-source-analysis reference, with **no content-scan AC** gating the commit. Requires a blocking pre-commit scan + human choice-gate for user-type/private files (this is a human-domain publish decision, not an AI-mechanical one).
- **P0-2**: The AC3 SAFETY exclusion is asserted only at the `--dirs`/`--zero-touch` granularity and not as an end-to-end EXCLUSION across the fresh-install `tad.sh` inline copy; the load-bearing exclusion + drift-check + T2/T3 ordering are unverified.

Resolve P0-1 and P0-2 (and ideally P1-1/P1-2 which harden the two most likely silent-failure modes) → PASS.
