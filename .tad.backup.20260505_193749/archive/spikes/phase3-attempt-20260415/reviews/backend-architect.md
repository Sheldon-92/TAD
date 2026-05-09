# Backend Architect Review — Phase 3 Hooks + SKILL Implementation (v3-LEAN)

**Handoff:** HANDOFF-20260415-phase3-hooks-skill-impl.md
**Design:** DESIGN-20260414-phase2-enforcement-matrix-v3-LEAN.md
**Reviewer:** backend-architect (Alex-side, pre-Blake)
**Date:** 2026-04-15
**Scope:** Module architecture, shared-state/coupling, interfaces, failure isolation, performance architecture, phase ordering, scalability, data-flow contracts.

---

## 1. Critical Issues (P0 — must fix before Blake starts)

### P0-1. `check_write` signature in §2.3 is underspecified — missing `session_id`, `tool_name`, and stdin-envelope context

The shared interface is declared as:

```
check_write role manifest_id target_file content handoff_slug
```

Three concrete problems that will bite Blake mid-implementation:

1. **Nonce scoping requires `session_id`.** §6.1 states "Scope: same session_id + same gate, TTL 1h, single-use". `override-verify.sh` must consume a nonce during the same PreToolUse call where `check_write` makes its allow/deny decision (the override consumes on the next Write, not on the UserPromptSubmit itself). Without `session_id` as an explicit parameter, `check_write` cannot bind its decision to the right nonce and must reach into global state — exactly the pollution the function-factoring is trying to avoid.

2. **Tool-name discrimination.** AW-3 cross-role edit needs to know it's on `Edit|MultiEdit`; BW-3 Bash write-path needs to know it's on `Bash`; path-guard needs to differentiate `Write` (target is `file_path`) from `Bash` (target is extracted from command). One positional `content` cannot carry this. Either add `tool_name` or promote the interface to a struct-like associative array.

3. **MultiEdit payload** is `edits[]` not a single content; the §4 H-002 note says "Concat edits[].new_string before match" — but this concat must happen in the dispatcher before calling `check_write`, or inside `check_write`. The handoff does not say which. This ambiguity will produce two different implementations depending on who Blake asks.

**Required fix:** Replace positional args with a bash associative array or documented env-var convention (`TAD_ROLE`, `TAD_SESSION_ID`, `TAD_TOOL_NAME`, `TAD_TARGET_FILE`, `TAD_CONTENT`, `TAD_HANDOFF_SLUG`, `TAD_MANIFEST_ID`). Document in a new handoff sub-section §2.3.1 which layer does the MultiEdit concat. Recommend: dispatcher does concat; libs see already-concatenated content.

---

### P0-2. Gate verdict TSV writers — handoff calls for SKILL-level contracts but does not specify code that performs the write

§1.2 of the design and AC7/AC11/AC13 reference `gate2-verdict.tsv`, `gate3-verdict.tsv`, `gate4-verdict.tsv`. §1.2 says "Writer ensures `.tad/evidence/gates/<slug>/` exists before write." The handoff file §11 shows these files appearing in the evidence tree but nowhere in §3 AC1–AC15 is there a concrete AC for **"modify `/gate` skill / completion_protocol / acceptance_protocol to emit these writes."**

This is the exact failure pattern logged in the knowledge base as "Gate Verdict TSV — is this a hidden assumption?" There are two ways these files can materialize:

- **(a) Skill text instructs the model to Write them** — but those Writes then go through the new PreToolUse hooks and risk being denied as protected paths or as writes-without-manifest.
- **(b) A shell helper invoked from a hook/skill produces them** — but no such helper is specified.

If Blake implements path (a), Alex Gate 4 step that writes gate4-verdict.tsv will itself be gated by the very hook chain Alex is trying to satisfy, producing a bootstrap paradox on **every handoff**, not just the first.

**Required fix:** Add **AC16** (or expand AC3/AC7) that explicitly specifies:
- Who writes each gate verdict (skill-driven `Write` call vs hook-invoked shell helper).
- Whether `.tad/evidence/gates/**` is on the protected-paths list or exempt.
- If skill-driven `Write`: an explicit carve-out in `path-guard.sh` matching `.tad/evidence/gates/*/gate[234]-verdict.tsv` (allow-list, not deny).
- If shell-helper: a 9th script (`lib/gate-verdict-writer.sh`) with interface `write_verdict <gate> <slug> <verdict> <reviewer> <notes>`.

Recommend path (b) — a thin writer lib that skills shell-out to. This keeps hooks as pure gatekeepers (single responsibility) and eliminates the recursion.

---

### P0-3. Failure isolation: `sentinel-detect.sh` fails-open when `perl` unavailable, contradicting fail-closed stance

§3 canonicalization pipeline mandates `perl -CSD -MUnicode::CaseFold`. `lib/dep-guard.sh` (Phase 1c) whitelists binaries but the handoff does not declare whether `perl` (with `Unicode::CaseFold`) is in the dep-guard whitelist or in the hard-dep check. The Phase 1c `evidence-validator` missing-dep bug (AC17 fail-OPEN regression) is already in the knowledge base as a critical learning.

If `perl` is missing or `Unicode::CaseFold` module is not installed:
- Best case: hook errors out with stderr noise, dispatcher must treat as DENY.
- Worst case (Phase 1b regression): dispatcher silently proceeds because `set -e` was relaxed for resilience.

The handoff's AC set has **no fail-closed test for sentinel-detect specifically.** AC7 covers bootstrap, AC10 covers protected-path/env-inj/traversal, AC14 covers the 10 fixtures — but none exercise "what happens when the canonicalizer process itself fails."

**Required fix:** Add a specific AC (or extend AC1) stating: "If any lib script `return`s non-zero or its required binary is missing (verified by `command -v` at hook entry), `quality-enforcement.sh` MUST emit a deny JSON with `reason='hook_dependency_unavailable'` and exit 0. A fixture `fixture-missing-perl-fails-closed.sh` verifies by running the hook with `PATH=/usr/bin:/bin` (no perl) and expecting deny." This mirrors the Phase 1c AC17 fix.

---

### P0-4. Phase 3.C bootstrap self-generation violates HP-1 deny by design — the escape is undocumented

§3.1 AC Conflict Matrix row 3 handwaves this: "bootstrap 写入使用 shell `>` 重定向（不是 Claude 的 Write tool），hook 自我写入豁免". This is **correct in principle** but creates a subtle invariant that Blake must get exactly right:

- The bootstrap code inside `quality-enforcement.sh` runs in a subshell spawned BY Claude Code to service a PreToolUse event. Its own `>` redirects are NOT intercepted (hooks don't recursively intercept their own shell children). Good.
- BUT: if the bootstrap logic is accidentally placed in a code path reachable from a `Task` subagent invocation, OR if a future refactor moves bootstrap into a `pre-accept-check.sh`-style companion script that Claude invokes via Bash tool, the exemption silently breaks.

There is also a **real race**: if two `claude` sessions on the same project hit first-run simultaneously, both may `openssl rand` and both may append to `.gitignore`. The design says "procedural" for concurrent sessions (KG-002), but first-run bootstrap is exactly when procedural mitigation hasn't run yet.

**Required fix:** Add to AC6:
- (a) Explicit comment block at top of bootstrap function: "INVARIANT: this function only runs inside the hook's own subshell; DO NOT refactor into a Bash-tool-invoked script."
- (b) Use `flock` or `ln -s` atomic-create pattern for `secret.key` generation so concurrent first-run is deterministic (`openssl rand -base64 32 > .tad/state/secret.key.tmp && ln .tad/state/secret.key.tmp .tad/state/secret.key || true` — ln refuses if target exists).
- (c) `.gitignore` append must be line-match guarded: `grep -qxF '.tad/state/' .gitignore || echo '.tad/state/' >> .gitignore` (the handoff says "idempotent check" but no specific command).

---

### P0-5. Performance budget is not decomposed across the 6-lib chain; p95 < 100ms is an aggregate risk

§8 sets p95 < 100ms for each hook (pretool-interceptor, evidence-validator, override-verify, bash-watcher). But §2.2 control flow has Write-family going through **4 libs in sequence** (sentinel-detect + path-guard + content-scanner + evidence-validator), each potentially spawning jq/awk/perl subprocesses. With the Phase 1c measurement — `evidence-validator` alone at p95 ~156ms on dev host, ~100ms on CI — the aggregate p95 under AC13 is a **real risk**.

Specifically missing:
1. **No per-lib budget.** With 4 libs and 100ms aggregate, each has ~25ms. That's tight but possible. Without a per-lib target, Blake cannot locally verify progress — he'll discover failure only at CI.
2. **No call-ordering mandate.** The cheapest check (path-guard: pure regex on file_path, ~5ms) should run **first** so HP-1/HP-2/PT-1 short-circuit before the expensive sentinel canonicalization (perl invocation, ~30-50ms).
3. **No short-circuit contract.** If path-guard denies, sentinel-detect and evidence-validator must NOT execute. The handoff does not state this.

**Required fix:** Update §2.2 in the handoff (or add §2.2.1) with:
```
Write-family fast path (in order, short-circuit on first deny):
  1. path-guard (HP-1/HP-2/PT-1)           target: p95 < 10ms
  2. content-scanner (HP-2 env-inj, OV-2)  target: p95 < 15ms
  3. sentinel-detect (primary pattern)     target: p95 < 40ms
  4. evidence-validator (only if sentinel) target: p95 < 40ms
  Aggregate p95 budget: < 100ms
```
Add AC13 sub-bullet: "Per-lib p95 is measured and reported separately in `ci-bench-N100.tsv` (columns: `lib\tp50\tp95\tp99`). Any single lib exceeding its per-lib target is a FAIL even if aggregate passes."

---

## 2. Recommendations (P1 — should address)

### P1-1. Module boundary: `content-scanner.sh` mixes two distinct concerns

The handoff assigns H-004 (env-injection detection on Write content) AND H-008 (Bash write-path exfiltration) to one module. These share the "scan arbitrary string for hostile patterns" shape, but:

- H-004 operates on `tool_input.content` (the file body being written)
- H-008 operates on `tool_input.command` (a shell command line)

The **pattern sets are disjoint** (env-var prefixes vs shell redirect operators) and the **target extraction logic differs** (for Bash, `>` has a target path to re-feed into path-guard; for Write, there is no such re-feed). Bundling them saves one script filename but creates an internal dispatch (`if tool_name == Bash then ... else ...`) that duplicates the top-level dispatcher's routing logic.

**Recommendation:** Keep `content-scanner.sh` for H-004 only. Move H-008 into `path-guard.sh` as a `check_bash_redirect_targets` function, since its job is fundamentally "extract write target from Bash command and apply protected-path rules" — that's path-guard's domain. This produces cleaner boundaries: path-guard owns "where can you write", content-scanner owns "what env-poisoning strings are forbidden in any payload".

### P1-2. Cross-role edit detection (AW-3) via "transcript tail scan" is underspecified

§2.5 Role Derivation reads 100 lines of `transcript_path`. §1 AW-3 says "file authored by OTHER role (detected via transcript tail scan)". But **who authored a file** is NOT the same as **which role is currently active** — a file Alex wrote 3 commits ago being edited by Blake now is the AW-3 case, but "which Skill last fired in the transcript" only tells you the current role. The handoff conflates two distinct lookups.

**Recommendation:** Split into:
- `role_current()` — from transcript tail (for allow/deny asymmetric rules).
- `role_authored(file_path)` — from `git log --follow --format=%an` or from a sentinel in the file's front-matter (handoff YAML frontmatter has no `author:` field today; add one).

If `git log` is infeasible for fresh files, lean on the fact that `HANDOFF-*.md` ≡ Alex-authored and `COMPLETION-*.md` ≡ Blake-authored by naming convention (already enforced elsewhere), and derive `role_authored` by filename pattern alone. Document this.

### P1-3. Scalability to Phase 5 — per-project state works, but version drift is unaddressed

The design says "per-project state" with `.tad/state/**`. When Phase 5 `*sync` fans out to 10 projects:
- Project A (TAD v3.0.5, has `sentinel-patterns.yaml` key `allowlist_paths`)
- Project B (TAD v3.0.2, does not have that key yet)

…the shared hook code (`.tad/hooks/sentinel-detect.sh`) is assumed identical because `*sync` copies it. But the YAML schemas under `.tad/schemas/` are also copied — and if Project B has custom edits the user wants preserved, sync semantics are ambiguous. The handoff does not specify whether `.tad/schemas/**` is treated as user-content (preserve on sync) or framework-content (overwrite on sync).

**Recommendation:** Add one line to §12 / Phase 5 prep note: "`.tad/schemas/**` is framework-managed; `*sync` overwrites. User customization is done via `.tad/schemas-local/**` (not yet implemented; reserved)." This prevents a costly Phase 5 sync-time surprise.

### P1-4. `lib/common.sh` grep-fallback path is a silent-failure risk for the new libs

Current `lib/common.sh::get_json_field` falls back to regex when `jq` is unavailable. The fallback only works for "simple top-level or one-level nested fields" — but the new libs will parse `.tool_input.edits[].new_string` (nested array) and `.tool_input.content` (potentially multi-line with escaped quotes). The fallback will silently return empty strings for these, which downstream `check_write` will interpret as "no sentinel present" → ALLOW.

This is the same fail-open class as P0-3.

**Recommendation:** Make `jq` a **hard dependency** for Phase 3 hooks (not a fallback). Let `dep-guard.sh` refuse to load if `jq` absent, emitting a clear deny. Document in AC1: "All 8 scripts assume `jq` ≥ 1.6 present; `lib/common.sh::get_json_field` fallback is intentionally NOT used by Phase 3 libs." Update the common.sh grep-fallback to emit a stderr warning when invoked, so we can trace any accidental Phase 3 use.

### P1-5. `sentinel-detect.sh` caching opportunity for Phase 5

The 2-step canonicalization (strip invisibles + casefold) is idempotent on a given content blob. For large handoff files (~30KB) being repeatedly edited via MultiEdit, recanonicalizing every PreToolUse is wasteful. The handoff correctly defers "archive manifest cache" to Phase 5 but does not reserve a cache hook point for canonicalization.

**Recommendation:** Non-blocking for Phase 3. Add a 1-line knowledge note to §10.2 Out of Scope: "Canonicalization result cache (SHA256(content) → casefolded) is a Phase 5 candidate optimization if evidence-validator or sentinel-detect exceeds per-lib budget at scale." This reserves the design space without scope creep.

---

## 3. Suggestions (P2 — nice to have)

### P2-1. Consider consolidating `override-verify.sh` and `evidence-validator.sh` I/O layer

Both read JSONL state files under `.tad/state/` (`nonces.jsonl`, `override-log.jsonl`) and both need chmod-600-preserving atomic append. Factoring a tiny `lib/state-io.sh` with 2 functions (`append_jsonl_atomic`, `scan_jsonl_head`) would DRY the write paths and give one place to audit for TOCTOU (relevant to KG-002 knowledge entry).

### P2-2. `sentinel-patterns.yaml` secondary path_in uses glob — document the matcher

`.tad/active/handoffs/HANDOFF-*.md` glob — matched by bash `[[ == ]]`, by `case`, by `fnmatch`, or by `find`? Each has different semantics for `**` and brace expansion. Phase 1c learned this the hard way ("Hook Path Matching: Glob Prefix Must Handle Relative Paths"). Spell out the matcher ("`case "$f" in ...*.tad/active/handoffs/HANDOFF-*.md)`") inline in the YAML comment so Blake doesn't re-derive it.

### P2-3. `dogfood-trace.jsonl` schema is implicit

AC15 requires 3 events (bootstrap-allow, completion-write, post-bootstrap-deny). A 2-line JSON schema in §11 (fields: `ts`, `event`, `hook`, `verdict`, `reason`) would eliminate Blake's guess-work and let Alex Gate 4 re-derive event count with `jq -s 'length==3'` instead of line-counting.

### P2-4. Document the 60s–300s cache boundary for `jq` subprocess reuse

Micro-optimization: if Phase 3 perf measurement shows aggregate p95 near the 100ms edge, investigate whether a single `jq -n --slurpfile ... --slurpfile ... '<mega-filter>'` call can replace 2–3 sequential `jq` invocations across libs. This is in the spirit of the Phase 2b "Single-awk vs Per-item grep Loop" optimization. Reserve as a Phase 5 item if not needed in Phase 3.

---

## 4. Boundary Assessment Summary

| Module | Single Responsibility? | Coupling | Verdict |
|---|---|---|---|
| `quality-enforcement.sh` | Dispatch + role derive + bootstrap | High (owns control flow, acceptable) | OK |
| `userprompt-override.sh` | OV-1 allocation + logging | Low | OK |
| `lib/common.sh` | JSON I/O, logging | Low (reused) | OK |
| `lib/dep-guard.sh` | PATH pin + whitelist | Low (reused) | OK |
| `lib/quality-checker.sh` | `check_write` shared entry | Medium — interface under-specified | **See P0-1** |
| `lib/sentinel-detect.sh` | Canonicalize + pattern match | Medium — perl dep fail-open risk | **See P0-3** |
| `lib/path-guard.sh` | Protected paths + traversal | Low | OK (after P1-1 absorbs H-008) |
| `lib/content-scanner.sh` | Env-inj + (currently) Bash write-path | Medium — **mixed concerns** | **See P1-1** |
| `lib/evidence-validator.sh` | Manifest check + KG-001 | Low | OK |
| `lib/override-verify.sh` | Regex + nonce | Low | OK |

**Net**: boundaries are 7/10 clean. Two refactors in Phase 3 scope (absorb H-008 into path-guard) would bring this to 9/10. The underspecified `check_write` interface is the single largest risk.

---

## 5. Overall Assessment

### Verdict: **CONDITIONAL PASS**

The v3-LEAN design is architecturally sound — the threat-model calibration is correct, the 6-lib decomposition is appropriate for the scope, and Phase 1c lessons are well-incorporated into the AC set (shell portability, grep -P prohibition, single-awk pattern, perl timing, dedicated CI runner).

However, Blake cannot start cleanly until the following are resolved:

- **P0-1** (`check_write` signature with `session_id` + `tool_name` + MultiEdit concat ownership) — **must fix**, pure spec ambiguity.
- **P0-2** (gate verdict TSV writer mechanism) — **must fix**, architectural gap between SKILL contracts and hook enforcement.
- **P0-3** (fail-closed AC for `sentinel-detect.sh` missing deps) — **must fix**, regression risk.
- **P0-4** (bootstrap self-generation invariant + race handling) — **must fix**, data integrity.
- **P0-5** (per-lib performance budget + short-circuit ordering) — **must fix**, AC13 feasibility.

With these five addressed (estimated Alex rework: 45-90 minutes), the handoff is ready for Blake. The P1 items are genuine improvements but do not block implementation; the P2 items are Phase 5-adjacent.

**Confidence**: High on critical-issue identification. The fixes are straightforward spec tightenings, not design pivots.

---

*Review generated by backend-architect persona as mandated by handoff §10.3 (Phase 3 = high-risk infra, ≥3 experts required).*
