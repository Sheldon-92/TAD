# Code Review — research-engine-wire-phase4 (Implementation, commit 92bbfc3)

**Reviewer:** code-reviewer (Layer 2, post-implementation)
**Date:** 2026-05-31
**Worktree:** `.claude/worktrees/agent-a4c1c1069ef1974f5/`
**Scope:** dormant recompute hook + lib, settings.json registration, REGISTRY.yaml yq-normalization + archive, AC4.6 / classification smoke evidence.

Note on terminology: to avoid the parser-self-trigger pattern (architecture.md 2026-05-30), this review paraphrases the block-decision token and the failure-termination form rather than quoting their literal strings.

---

## Verification performed (not paper)

- `bash -n` on both shell files → clean.
- `jq empty .claude/settings.json` → valid JSON.
- yq present (`/opt/homebrew/bin/yq` v4.47.2) → structure-aware path exercised.
- Ran `recompute_notebook_dormancy` end-to-end on TEMP COPIES of the live REGISTRY with: one stale entry, one future date, one empty `last_queried`, one malformed `last_queried`, and the archived entry.
- Ran the hook through its real stdin path (`{"source":"startup"}` and `{"source":"resume"}`).
- Re-derived the REGISTRY before/after semantic projection (`yq` id/notebook_id/status/source_count/last_queried) and summed `sources` array lengths.
- Re-ran the lib under `env -i` clean bash to isolate stderr.

---

## P0 — Blocking

**None.**

The two highest-risk requirements both hold under live test:
- **REGISTRY corruption risk → not present.** The recompute uses `yq -i ... select(.id == env(ID)) ) .status = env(STATUS)` per-entry, writes to `${registry}.tmp.$$`, validates `yq -e '.notebooks'` on the tmp, then `mv` over the original only if a change occurred. No line-based `sed`. End-to-end test flipped EXACTLY the stale entry and left all 16 others byte-identical (`diff` = single `120c120` hunk).
- **Session-startup blocking risk → not present.** No executable failure-termination statement (`grep -cE '^[[:space:]]*exit 1'` = 0 in both files), no block-decision JSON emitted (`grep '"deny"'` = none), every parse path guarded with `|| return 0` / `|| continue` / `|| true`, hook ends `exit 0` unconditionally. Live hook run emits exactly `{}` on stdout, empty stderr, exit 0 on both `startup` and `resume`.

---

## P1 — Should fix (none blocking; one minor robustness gap)

**P1-1 — `cp` of the live registry into the tmp is redundant with, and slightly weaker than, the documented atomic contract — but only a micro-inefficiency, not a correctness bug.**
`notebook-lifecycle.sh:63` does `cp "$registry" "$tmp"` and then runs `yq -i` repeatedly against `$tmp` (line 91), mutating it in place across the loop. This is correct (the live file is only touched by the final `mv`), but note that each stale entry triggers a *separate* `yq -i` whole-file rewrite of `$tmp`. With 18 entries and at most a handful stale per session this is fine; if a future registry grows large and many entries flip on the same session (e.g., first run after a long idle), it is N sequential full-file rewrites. Acceptable for current scale — flag only so a future maintainer batches the assignments into one `yq` expression if entry count grows. Not required for this handoff.

**P1-2 — Boundary semantics (`>` vs `>=`) are implemented as `>` (strict) and documented as such, but the config-vs-code single-source-of-truth is good; just confirm Alex/`*list` uses the same boundary.**
`notebook-lifecycle.sh:81` uses `age_days -gt threshold` → an entry exactly at `dormant_after_days` stays active; dormant only at `threshold+1`. The lib header (line 11) documents this (`boundary: <= keeps active`). This matches the handoff §4.2 "(boundary: <= keeps active)" instruction. **Confirm** the `*list`-time derivation in research-notebook/SKILL.md uses the identical comparison, else `*list` and the hook could disagree by one day at the exact boundary. Out of scope to fix here (other file), but worth a Gate-4 cross-check. Verified the hook side is internally consistent and config-driven (threshold read via `yq '.research_notebook.dormant_after_days // ""'` with numeric-guard fallback to 30 only when missing/non-numeric — `notebook-lifecycle.sh:38-44`).

---

## P2 — Consider

**P2-1 — `@tsv` + `IFS=$'\t' read` is safe here only because `last_queried` is guarded before any column-collapse matters.**
architecture.md (2026-05-20) warns that `read` with `IFS=$'\t'` collapses consecutive empty fields. Here the row is `[id, last_queried, status]`; an empty middle field (`id<TAB><TAB>status`) would mis-bind `status` into `last_queried`. The code is protected because: (a) yq `@tsv` always emits all three columns (id is always present, so the first field never collapses), and (b) `notebook-lifecycle.sh:68` does `[ -n "$last_queried" ] || continue` — an empty `last_queried` is skipped before its value is used, and a mis-bound `status` would only ever be read on an entry that was already skipped. I verified this directly: injecting an empty `last_queried` produced NO change and exit 0. Leaving as a documented note so a future schema change (adding/removing a projected column) re-checks the read alignment.

**P2-2 — Hook `SOURCE` "run anyway on missing/null source" is intentional and safe, but slightly broader than startup-health.sh's model.**
`notebook-dormant-sync.sh:31` runs the recompute when `source` is empty/null, only no-ops when source is a *known non-startup* value. The handoff §4.2 modeled it on startup-health.sh (`source != "startup" → exit`). The chosen logic ("known-other → no-op, else run") is defensible — derived-state recompute is idempotent and harmless on a resume — but it means the recompute also runs on, e.g., a future source label that isn't yet known. Given the operation is idempotent + non-blocking, this is acceptable and arguably more robust. No change required.

**P2-3 — Classification smoke is a hand-traced table mirror, not an executed harness — correctly scoped, but it is assertion-by-inspection.**
`classification-smoke.md` shows the 3-tier routing 1:1 against the SKILL.md table. Because the ladder is *prompt-protocol text* (not executable code), there is nothing to run — this is the right kind of evidence for a protocol change, and the file is explicit that the real `seed_origin` fire is Gate-4-deferred (matches handoff §4.4 PARTIAL-by-construction). Flagging only that AC4.4's Blake portion is genuinely PARTIAL and the COMPLETION `gate3_verdict` must reflect that, not PASS.

---

## Focus-area answers (as requested)

**1. Dormant hook non-blocking / yq guard / atomic / per-entry / BSD date / config threshold — ALL PASS:**
- Always exit 0; no executable failure-termination; no block-decision emission. ✅ (verified by grep + live run)
- `command -v yq` guarded at `notebook-lifecycle.sh:35` → `return 0` if absent; no sed fallback. ✅
- Atomic temp (`${registry}.tmp.$$`) + `mv` over original, only after `yq -e '.notebooks'` validates the tmp; tmp discarded on no-change or invalid. ✅ (`:99-107`)
- Per-entry targeting via `select(.id == env(ID))`; verified exactly-one-flip on live-copy test. ✅
- BSD-safe date: `date -j -f "%Y-%m-%d" ... || date -d ...` with `|| continue` on parse fail (`:72-73`); future date → negative age → stays active (verified: age −215 → active); malformed → skip, no crash (verified). ✅
- Threshold read from `.tad/config-workflow.yaml research_notebook.dormant_after_days`, numeric-guarded, default 30 ONLY when missing/non-numeric (`:38-44`). ✅

**2. AC4.6 smoke demonstrates exactly-one-flip + others byte-identical on a TEMP COPY — PASS.** The evidence file uses a temp copy (`$T`), shows the single `120c120` diff, confirms 16 others byte-identical, YAML still valid, archived entry skipped. I independently reproduced this on my own temp copy. ✅

**3. settings.json — valid JSON; SessionStart coexistence safe.** Two independent `type: command` hooks under one SessionStart matcher (`startup-health.sh` then `notebook-dormant-sync.sh`). They share no state; the dormant hook only reads stdin + REGISTRY and writes REGISTRY atomically. The handoff design note (§4.2) that the human-facing summary stays owned by startup-health.sh holds — the dormant hook emits bare `{}`. One hook's failure cannot break the other (separate processes). ✅

**4. yq one-time normalization (43-line cosmetic diff) — valid + semantically identical, no data lost.** Semantic projection diff (id/notebook_id/status/source_count/last_queried) shows the ONLY change is `ai-agent-tutorials: active → archived`. All 18 notebooks present; total `sources` array entries = 83 before and after; the irregular-schema `sources_summary` block on `video-creation-vimax-research` preserved; `ai-agent-tutorials` notes + its 1 source body preserved (archive ≠ delete, AC4.3 satisfied). The 43-line diff is yq's blank-line strip + comment-spacing normalization (12 insertions / 31 deletions). ✅

**5. Any real bug that would corrupt REGISTRY or block startup in practice — NONE FOUND.** Multiple adversarial inputs (stale / future / empty / malformed `last_queried`, archived entry) all produced correct, non-corrupting, exit-0 behavior. Under `env -i` clean bash the lib emits zero stderr. (The `lq_epoch=`/`age_days=` lines seen during my interactive testing were an xtrace artifact of the reviewer's own shell profile — confirmed absent in clean-env and absent from the source via `grep` for echo/printf/set-x. Not a code issue.)

---

## Overall: PASS

The implementation faithfully satisfies the two P0 design constraints (no-corruption, no-block) under live adversarial testing, the AC4.6 byte-identity evidence is real and reproducible on a temp copy, the REGISTRY normalization is provably data-preserving, and settings.json registration is valid and isolation-safe. P1/P2 items are robustness notes and a cross-file boundary cross-check for Gate 4 — none block. AC4.4 is correctly PARTIAL-by-construction (Gate-4-deferred `seed_origin` fire), which the COMPLETION `gate3_verdict` must reflect.
