# Backend Architect Review — Phase 5 Evolve Data Capture

**Reviewer**: backend-architect
**Date**: 2026-04-25
**Handoff**: HANDOFF-20260425-phase5-evolve-data-capture.md
**Scope**: Cross-system architectural consistency across 4 subsystems (frontmatter / Alex SKILL / hooks / Domain Pack)

---

## P0 (Blocking — must fix before sending to Blake)

### [P0-1] AskUserQuestion → askuser-capture.sh has NO link to active handoff slug
- **Where**: FR2 (§3.1) + Data Models (§4.3) + AC-P5.2-c. The example JSONL line `"slug":"phase5-evolve-data-capture"` is presented as if the hook knows it.
- **Why blocks Blake**: PostToolUse hooks receive `tool_input` + `tool_response` + a system envelope (`session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`). They do NOT receive `TAD_HANDOFF_SLUG` or any active-handoff identifier — environment variables exported in the user's interactive shell are not propagated into Claude Code's hook execution context (the hook runs as a subprocess of the Claude Code harness, not as a child of the interactive shell). The handoff is silent on how the hook derives `slug`. Without that, *evolve cannot join `decisions.jsonl` lines back to a specific handoff — the entire data-capture line of Phase 5 collapses to "we logged user choices but cannot say which task they were for."
- **Fix**: Pick ONE of the following and document it explicitly in FR2:
  1. **`cwd`-based scan (recommended)**: Hook reads `cwd` from stdin envelope, then `ls .tad/active/handoffs/HANDOFF-*.md | head -1` → extracts slug from filename. Backward-compatible (works for existing handoffs), no env-var dependency, matches what `read_stdin_json` already exposes. Edge case: 0 active handoffs → write line with `"slug":null` (still useful for *evolve coverage stats); 2+ active → join with `|` or use newest mtime.
  2. **Alternatively**: drop `slug` from the JSONL schema entirely and let *evolve correlate via `session_id` + transcript-replay against handoff timestamps. But this pushes complexity into *evolve and defeats one of the explicit Q2 goals.
  - Either way, AC-P5.2-c needs an explicit fixture for "what slug ends up in the JSONL when 0 / 1 / 2 active handoffs exist."

### [P0-2] `TAD_HANDOFF_SLUG` env-var contract is undefined — who exports it, when, where
- **Where**: FR4 (§3.1), Decision #7 (§11.2), §10.2 Known Constraints (silent on this).
- **Why blocks Blake**: Decision #7 says "Blake/Alex 在执行前显式 export" but neither Blake's SKILL.md nor Alex's SKILL.md is modified to do this in the handoff (the only Alex SKILL edits are step4d / step7d / cancel_protocol). If neither side actually exports it, the `else` branch of trace-step.sh always fires and per-handoff dirs are never written — meaning AC-P5.4-b can only PASS in fixture mode (`TAD_HANDOFF_SLUG=test bash ...`) but the *production* code path silently never triggers. This is the same class of failure as Quality Chain v2.7 (text says one thing, runtime does another).
- **Fix**: Add to handoff §6 a new Micro-Task in Stage A: "Edit Alex SKILL.md acceptance_protocol step1 (and Blake SKILL.md implementation_protocol entry point) to `export TAD_HANDOFF_SLUG=$(basename "$ACTIVE_HANDOFF_FILE" | sed 's/^HANDOFF-[0-9]*-//; s/\.md$//')` at session start." Add a corresponding AC: `grep -c 'export TAD_HANDOFF_SLUG' .claude/skills/{alex,blake}/SKILL.md` ≥ 2. **Or** simplify by deriving slug inside trace-step.sh itself the same way as P0-1 (read `pwd`'s active handoff) — this removes the env-var dependency entirely and makes both Hooks behave consistently. I strongly recommend the latter because env vars + Claude Code subprocess boundaries have bitten this project before.

### [P0-3] `*cancel` lacks the symmetric `forbidden_implementations` block — AR-001 attack surface open
- **Where**: §3.1 FR3 + §10.1 (mentions "*cancel 不能滥用" in passing) + Alex SKILL `cancel_protocol` (to be created).
- **Why blocks Blake**: Phase 3's Path Layering knowledge entry (2026-04-24) specifies that *every* new path-like command MUST carry a 5-item `forbidden_implementations` block parallel to `*express` (line 1035) and `*experiment` (line 1164) and `skip_knowledge_assessment` (line 2421). Without it, the next agent maintaining cancel_protocol can rationalize "register a hook to auto-detect abandonment", or "couple *cancel to skip_KA so cancelled tasks bypass Gate 4 ceremony" — exactly the AR-001 drift the user 2026-04-15 explicitly forbade. This is a structural defense, not a "nice to have."
- **Fix**: In Alex SKILL.md cancel_protocol section (Micro-Task 5), append a `forbidden_implementations:` list with at minimum:
  1. MUST NOT register PreToolUse / PostToolUse / UserPromptSubmit hook to auto-trigger *cancel
  2. MUST NOT add to .claude/settings.json
  3. MUST NOT couple *cancel to skip_knowledge_assessment (cancelled handoffs bypass Gate 4 by design but MUST still write cancel_reason + cancel_rationale)
  4. Anti-AR-001: "*cancel = silent abandonment" is a forbidden interpretation — both reason taxonomy AND rationale text are mandatory
  5. MUST NOT auto-downgrade Standard TAD handoff to *cancel via any mechanism (no Alex AskUserQuestion suggestion, no signal-word auto-detection)
  - Add AC-P5.3-d: `awk '/^cancel_protocol:/,/^[a-z_]+_protocol:/' .claude/skills/alex/SKILL.md | grep -c 'forbidden_implementations'` ≥ 1.

### [P0-4] AC-P5.4-b and AC-P5.4-c describe mutually exclusive behaviors but the implementation contract for trace-step.sh is not specified
- **Where**: §9.1 AC-P5.4-b ("with env var writes to BOTH") vs AC-P5.4-c ("without env var writes ONLY to date file"). FR4 says "如果未设置就 skip per-handoff 写入" but the actual control flow in modified trace-step.sh is left to Blake.
- **Why blocks Blake**: This is exactly the AC Conflict Matrix lesson (2026-04-14). The two ACs describe two state machines selected by an environment variable, but neither the FR nor §6 §6.4 describes the implementation pattern (where in trace-step.sh the branch goes, which jq invocation outputs to which path, whether the per-handoff write reuses the same jq -nc result or makes a second call). Blake's natural reading could implement this with `tee` (one jq, two writes — efficient) OR with two `jq` calls (slower but cleaner) OR with an `if`-block around the entire per-handoff write (maintainable). Without spec, all three pass AC verification but produce different latencies and different failure modes.
- **Fix**: Add to FR4 (or a new §6.6 "trace-step.sh modification spec"):
  ```
  # Pseudocode pattern Blake MUST follow:
  TODAY_FILE="$TRACE_DIR/$TODAY.jsonl"
  jq -nc ... > /tmp/trace-line.$$
  cat /tmp/trace-line.$$ >> "$TODAY_FILE"
  if [ -n "${TAD_HANDOFF_SLUG:-}" ]; then
    # Validate slug whitelist (reuse layer2-audit pattern: ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$)
    if [[ "$TAD_HANDOFF_SLUG" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$ ]]; then
      PER_HANDOFF_DIR="$TRACE_DIR/per-handoff/$TAD_HANDOFF_SLUG"
      mkdir -p "$PER_HANDOFF_DIR"
      cat /tmp/trace-line.$$ >> "$PER_HANDOFF_DIR/$TODAY.jsonl"
    fi
  fi
  rm -f /tmp/trace-line.$$
  ```
  - Explicitly handle: invalid slug (whitelist failure → log to stderr, fall through to date-only — never crash), mkdir failure (treat as advisory, continue with date-only), file append failure on per-handoff (DO NOT propagate to date-keyed write — the date file is the canonical record). Add AC-P5.4-e: "trace-step.sh with `TAD_HANDOFF_SLUG=evil/../../../etc` (path traversal) writes ONLY to date file, no directory created."

### [P0-5] AC-P5.5-a forces dict-form quality_criterion BUT no other Domain Pack file uses dict-form quality_criteria, AND existing consumers don't parse dicts
- **Where**: FR5 + AC-P5.5-a + §10.1 warning.
- **Why blocks Blake**: I confirmed via `grep -rn "quality_criteria"` that ALL 8 existing Domain Pack files (web-testing, hw-firmware, web-deployment, web-backend, web-ui-design, etc.) use list-of-strings form. The only consumer that touches `quality_criteria` is `userprompt-domain-router.sh` (line 227 — uses string-only `Read` reminder, doesn't parse) and Alex SKILL line 1798-1801 ("Append as supplementary AC items") which is text-templating, not structured parsing. Converting ONE entry in ONE file to dict-form creates a polymorphic schema where some entries are strings and others are objects. This breaks two contracts simultaneously:
  1. **Format consistency**: Phase 4's HOW-TO-CREATE-DOMAIN-PACK.md (line 161) shows list-of-strings as the canonical form. Mixing forms means Blake/Alex must defensively `if (typeof entry === 'object')` everywhere — and won't because the docs don't say so.
  2. **Future *optimize / *evolve**: Any future tool that does `yq '.capabilities.X.quality_criteria[]'` and expects strings will hit "expected string, got map" and fail or silently coerce.
  - The handoff §10.1 warning says "Blake 需 grep 所有 quality_criteria 用法点确认 dict-aware" but doesn't mandate the audit nor specify the AC for it. This is dropping a load-bearing burden on Blake without a verification path.
- **Fix**: TWO options, pick ONE:
  - **(a) Use a string-form annotation instead** (recommended, smallest blast radius): Keep the entry as a string but extend the convention: `"Pattern: UUID-Scoped Pub/Sub Channel Names — ... [applies_when: supabase_realtime + react_strictmode]"`. Trailing `[applies_when: X]` tag is grep-able, machine-extractable via `sed`, and preserves list-of-strings homogeneity. Update FR5 + AC-P5.5-a accordingly.
  - **(b) Accept dict-form but mandate full schema migration** + parser updates: Add Micro-Tasks for (i) updating HOW-TO-CREATE-DOMAIN-PACK.md to declare dict form is canonical, (ii) auditing userprompt-domain-router.sh (line 227 reminder text — does it imply parsing?), (iii) auditing all 4 places in Alex SKILL.md that mention quality_criteria. This is at least 4 more hours of work and likely a separate phase.
  - I recommend (a). It captures the same `applies_when` semantics with zero cross-cutting consumer impact and zero schema drift.

---

## P1 (Should fix)

### [P1-1] Backward compatibility: existing tools' tolerance of new frontmatter fields is asserted, not verified
- **Where**: §2.2 Current State table, FR1, FR3.
- **Why**: Phase 5 adds `gate4_delta`, `cancel_reason`, `cancel_rationale` to handoff frontmatter. Existing tools (`gate3-git-tracked-check.sh` line 58-94, `drift-check.sh` line 320-335, `stale-knowledge-check.sh`, `layer2-audit.sh`) all parse frontmatter via `yq`. `yq` tolerates extra fields, so reads are safe. BUT: the *write path* during *cancel (FR3 step 3-4 — move to `cancelled/` + update NEXT.md) needs to interact with NEXT.md's existing structure, and it's unclear whether `tad-maintain` SYNC mode (which scans active handoffs) handles the new `cancelled/` subdir cleanly.
- **Fix**: Add AC-P5.3-e: "After *cancel runs on a fixture handoff, `bash .tad/hooks/lib/drift-check.sh` exits 0 (no drift introduced by the new cancelled/ subdir) AND `bash .tad/hooks/lib/layer2-audit.sh <slug>` returns either PASS or 'no audit needed' (not error)." This mirrors the dogfood pattern from Phase 1.

### [P1-2] No spec for *evolve query format → forward-compat risk
- **Where**: §1.2 ("成功的样子" mentions "下一次 *evolve 跑 cross-project trace 聚合"), §4.1 architecture diagram (4 boxes pointing to "*evolve reads"), but Phase 5 is explicitly NOT building *evolve.
- **Why**: 4 new data sources (gate4_delta in YAML frontmatter, decisions JSONL, cancel_reason in YAML frontmatter, per-handoff JSONL) are designed *speculatively* for a consumer that doesn't exist. Without even a draft *evolve query specification, we can't verify whether the chosen shapes are queryable. Specifically: gate4_delta is YAML-list-of-objects in frontmatter, decisions is JSONL line-per-event, cancel_reason is YAML scalar — three different shapes that *evolve must unify. JSONL flattens nicely but YAML frontmatter requires `yq` per-handoff scan. If *evolve later wants single-pipeline aggregation, gate4_delta might need to be promoted to its own JSONL file (e.g., `.tad/evidence/gate4-deltas/{slug}.jsonl`).
- **Fix**: Add a §12 "Forward Compatibility Notes for *evolve" section listing:
  1. Each data source's storage location, format, and retention.
  2. The expected join key (`slug` for gate4_delta + cancel_reason, `slug + ts` for decisions JSONL, `slug + step_name` for per-handoff trace).
  3. An explicit non-goal: "Phase 5 does NOT prescribe *evolve query mechanics; future *evolve Epic owns that. But these 4 schemas WILL be consumed verbatim, so renaming/restructuring later is a breaking change."
  - This is mostly a documentation hygiene issue, not a blocker, but cheap to add and prevents rework.

### [P1-3] AC-G4 ("≥1 new architecture.md entry") may FAIL even when implementation is correct
- **Where**: §9.1 AC-G4.
- **Why**: AC-G4 mandates "≥1 NEW entry added to architecture.md" but does NOT specify what learning topic justifies an entry. If Blake's implementation goes smoothly with no surprises, there's no genuine learning to record — and forcing a synthetic entry violates the project-knowledge §"What NOT to Record" rule (avoid generic / 1-project / inconclusive observations). This conflicts with `skip_knowledge_assessment: no` semantics: KA "no" means *expect* findings, but expecting and *guaranteeing* are different.
- **Fix**: Soften to "AC-G4: at least 1 NEW entry added to `.tad/project-knowledge/architecture.md` OR `.tad/project-knowledge/frontend-design.md`, OR a documented justification in COMPLETION-{slug}.md `## Knowledge Assessment` section explaining why no new entry was warranted." This matches the Phase 3 P3.3 design philosophy where Blake can override skip_KA based on actual findings (Alex sets default, Blake judges runtime).

### [P1-4] P5.7 order invariant is human-prose-only, not structurally enforced
- **Where**: §3.1 FR7, §6.2 Stage C step 12 ("Order invariant: First create frontend-design.md, then delete..."), §10.1.
- **Why**: If Blake uses parallel-coordinator (suggested in §10.3), the "create then delete" order can be violated — a parallel sub-agent might race the delete before the create commits. The handoff text says it but doesn't enforce it.
- **Fix**: TWO options:
  1. Add an explicit AC: AC-P5.7-c: "git log --diff-filter=A `.tad/project-knowledge/frontend-design.md` and git log -p `.tad/domains/web-ui-design.yaml` | grep -B1 'warm_palette removed' show frontend-design.md created BEFORE warm_palette deletion (ordered commit history)." Slightly fragile, but verifiable.
  2. **Better**: Restructure as one atomic edit per stage. Change §6.2 Stage C step 12-13 to Micro-Task #15 "atomic move: in a single git commit, BOTH create frontend-design.md AND delete the warm_palette section from web-ui-design.yaml". A single commit cannot be racing-violated. Update §10.3 to remove parallel-coordinator suggestion for Stage C (keep for Stage A/B).

### [P1-5] Missing AC for "*cancel does NOT execute Gate 4 ceremony" — silent acceptance loophole
- **Where**: FR3 step 5 ("不需要执行 *accept — cancel 不走 Gate 4 ceremony").
- **Why**: This is a designed exception that an implementer could rationalize backwards into "*cancel auto-runs *accept with synthetic Gate 4 PASS so we get a nice closed lifecycle." That breaks the core *cancel semantic and contaminates Gate 4 archival data. Need explicit AC.
- **Fix**: Add AC-P5.3-f: "After *cancel runs, the cancelled handoff has NO `## Gate 4` section addition (verify via `diff` against pre-cancel state). The handoff is moved to `.tad/archive/handoffs/cancelled/` with frontmatter `cancel_reason` + `cancel_rationale` fields populated and NO knowledge_assessment ceremony executed."

---

## P2 (Nice to have)

### [P2-1] Per-handoff trace dir cleanup policy is undefined
- **Where**: FR4, §4.3 layout.
- **Why**: Per-handoff dirs accumulate per slug forever. After 50 handoffs, `.tad/evidence/traces/per-handoff/` has 50 subdirs. No archival policy. Long-running TAD installs will see this dir grow unbounded.
- **Fix**: Add to §10.2 Known Constraints: "Per-handoff trace dirs are retained for 90 days post-Gate-4-archive, then moved to `.tad/archive/traces/per-handoff/` by future tad-maintain extension. Phase 5 does NOT implement this — it's a Phase 6+ concern."

### [P2-2] decisions JSONL has no rotation policy → file growth
- **Where**: FR2, §4.3.
- **Why**: `decisions/{date}.jsonl` is daily-rotated by file naming, but old daily files are never archived. Same accumulation pattern as per-handoff trace dirs.
- **Fix**: Same as P2-1, add to known constraints. Or simpler: a single one-liner cron-style note that all `.tad/evidence/` accumulation is currently unmanaged and will be addressed when the dir hits N files (smoke alarm vs auto-cleanup, consistent with project's "smoke alarm not automatic enforcement" ethos).

### [P2-3] Decision #1 says "JSON 嵌入 frontmatter" but spec uses YAML list of objects
- **Where**: §11.1 row 1 ("JSON 嵌入 frontmatter") vs §4.3 (YAML structure).
- **Why**: Cosmetic terminology inconsistency. Frontmatter IS YAML. The data model in §4.3 is YAML, not JSON. Blake will figure it out but the row label is misleading.
- **Fix**: Change Decision #1 row 1 chosen value to "YAML inline (frontmatter list-of-objects)". Single-word fix.

### [P2-4] Per-handoff trace cleanup invalidates trace-digest.sh smoke-alarm semantics on archive
- **Where**: FR4 + AC-P5.4-d.
- **Why**: When a handoff is archived (post-*accept), `trace-digest.sh <slug>` will eventually hit `fixture-missing-slug` exit-2 path (advisory). That's fine for active runs but breaks any future reproducibility tool that wants to replay archived handoff trace events. Not Phase 5's concern but worth flagging.
- **Fix**: Add a comment in trace-digest.sh source that "this CLI is designed for active handoff slugs; archived handoffs require re-pointing the script's slug-dir lookup to `.tad/archive/...`." Single-line maintenance note.

---

## Overall Assessment: **CONDITIONAL PASS**

The architecture is fundamentally sound — Phase 5 correctly applies Anti-Epic-1 (PostToolUse logger never blocks; trace-digest is advisory CLI; gate4_delta is prompt-level reminder; *cancel is judgment-based not mechanical). The 4-subsystem decomposition is clean, and the mapping from "Phase 4 over-fit corrections" + "data-capture infrastructure" into one Phase 5 handoff is reasonable.

**However, 5 P0 issues block hand-off to Blake**:
1. **P0-1** (slug derivation in askuser-capture.sh): without it, *evolve cannot correlate decisions to handoffs — the entire decision-capture pillar is data-poor.
2. **P0-2** (TAD_HANDOFF_SLUG export contract): without it, per-handoff trace silently never fires in production.
3. **P0-3** (missing *cancel forbidden_implementations): violates Phase 3 Path Layering knowledge entry.
4. **P0-4** (trace-step.sh dual-write spec): underspecified branching, conflicting ACs.
5. **P0-5** (YAML dict-form blast radius): polymorphic schema introduced without consumer audit.

P0-1 and P0-2 share a remediation path (derive slug from active handoff filename inside both hooks; eliminate env-var dependency). Recommend addressing both with the same fix — single source of truth, no environment leakage, backward-compatible.

P0-3 and P0-5 are pure spec additions (~30 lines + format change).

P0-4 needs a pseudocode block in the handoff (~15 lines).

**Estimated time to address all P0 + P1**: 60-90 minutes of Alex revision time. After integration, this is a clean handoff.

**P1-4 (atomic commit for P5.7 order invariant)** is strongly recommended even if classified P1 — race conditions on parallel-coordinator have caused Phase 4 issues before.

**Strong points worth preserving**:
- Anti-Epic-1 boundary discipline is rigorous (AC-G1, AC-G2, AC-G3 directly enforce never-block invariant).
- AC-P5.2-e (privacy boundary fixture) is exactly right — explicit "secret content" grep is the only reliable check.
- Backward-compat note in NFR6 for trace-step.sh is correct in principle (just needs P0-2 fix to actually work).
- Decision #10 (frontend-design.md mirrors security.md "foundational + accumulated") is good architecture — adopt the same cross-pack pattern.

Once P0s integrated → PASS.
