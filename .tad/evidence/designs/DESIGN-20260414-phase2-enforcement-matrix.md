# Phase 2 Design — Symmetric Enforcement Matrix

**Epic:** EPIC-20260413-symmetric-quality-enforcement.md (Phase 2/5)
**Status:** Design-only (Phase 3 implementation BLOCKED until this is approved + 1c prerequisites resolved)
**Author:** Alex | **Date:** 2026-04-14
**Inputs:** Phase 1a mechanism verification · Phase 1b adversarial feed (H-001..H-009 + KG + DR-001) · Phase 1c AC17 fix + exit-code contract + 3 prerequisites
**Scope boundary:** this document specifies architecture, data contracts, and SKILL-layer rules. It does NOT include production hook scripts or settings.json edits (those are Phase 3).

---

## 0. Executive Summary

Phase 2 consolidates the 9 proven Phase 1b hardenings + Phase 1c AC17 fix into a **single symmetric enforcement stack** covering Alex (handoff writes) and Blake (completion/evidence writes). Design principles:

1. **Mechanism > Text** — every rule backed by a hook, never by SKILL prose alone
2. **Symmetry** — one shared `lib/quality-checker.sh` module; Alex and Blake call it through tiny per-role drivers
3. **Per-project state** — nonces + HMAC secret stay in each project's `.tad/state/`, never cross-synced
4. **Override is the only escape** — human-typed `TAD_OVERRIDE: <gate> <reason≥20>` on next prompt; LLM can never self-grant
5. **Structural anchors, not substring** — detection uses file_path + emoji + box-drawing co-occurrence, not naked phrase match

Phase 3 implements this. Phase 4 dogfoods. Phase 5 syncs to 10 registered projects.

---

## 1. Symmetric Enforcement Matrix

### 1.1 What Gets Intercepted

**Write-family tools** below means: `Write | Edit | MultiEdit | NotebookEdit`. Every row's enforcement column applies to all four unless stated otherwise. This closes P0-1 (Edit/MultiEdit bypass of skeleton-then-tamper).

| Trigger Event | Who | Target File / Payload | Rule | Enforcement |
|---|---|---|---|---|
| **AW-1** Alex writes/edits handoff file | Alex | `.tad/active/handoffs/HANDOFF-*.md` | Requires: Required Evidence Manifest block in AC list references ≥2 expert review files + COMPLETION-*.md + gate2-verdict.tsv path (see §1.4). **Bootstrap exception**: if `.tad/state/secret.key` does not yet exist (first-run), downgrade to LOG-ONLY advisory (Phase 3 first handoff can ship). | PreToolUse Write-family |
| **AW-2** Alex finalizes handoff with sentinel | Alex | handoff file whose new content adds `📨 Message from Alex` + box-drawing anchor | Preceding same-session must have: expert-review files on disk + Socratic inquiry trace file + gate2-verdict.tsv PASS row | PreToolUse Write-family |
| **AW-3** Cross-role edit of handoff | Either role when target authored by the OTHER role | Edit/MultiEdit on `HANDOFF-*.md` or `COMPLETION-*.md` where session role ≠ file authoring role (detected via session active-skill context, NOT file_path alone) | Deny unless OV-1 granted with `gate=cross-role-edit` | PreToolUse Write-family |
| **BW-1** Blake writes "Message from Blake" sentinel | Blake | any write-family target containing `📨 Message from Blake` + box-drawing anchor | Required evidence: COMPLETION-*.md + gate3-verdict.tsv PASS + ≥2 Blake-authored reviewer reports + raw metric files | PreToolUse Write-family |
| **BW-2** Blake writes COMPLETION-*.md | Blake | `.tad/active/handoffs/COMPLETION-*.md` or spike `COMPLETION-REPORT.md` | Structure: `^Overall: (PASS\|FAIL)$` anchored outside fence + ≥3 git-resolvable file refs + sha manifest dedup | PreToolUse Write-family |
| **BW-3** Blake writes evidence review | Blake | `.tad/evidence/reviews/blake/<slug>/*.md` | size>100 + nonws>80 + anchored verdict + no symlink target | PreToolUse Write-family |
| **BW-4** Blake Bash write-path exfiltration | Blake | Bash command matching expanded set: `>`, `>>`, `|`, `tee`, heredoc (`<<`), `ln`, `cp`, `mv`, `git mv`, `rsync`, `install`, `sed -i`, `awk ... > file` into `.tad/evidence/` or `.tad/active/handoffs/` | Block — evidence must not be created via Bash to bypass Write interceptor | PreToolUse Bash |
| **MC-1** MCP tool write under `.tad/**` | Either | any `tool_name` matching `mcp__*` whose `tool_input` targets a path under `.tad/` | Deny — MCP tool writes to `.tad/**` are out-of-band and must go through normal Write-family flow; requires OV-1 `gate=mcp-write` | PreToolUse mcp__* |
| **MC-2** MCP tool content with sentinel | Either | any `mcp__*` tool_input JSON-serialized blob containing `📨 Message from` pattern | Treat as Write-family content; apply sentinel-detect pipeline | PreToolUse mcp__* |
| **OV-1** Override attempt | User (via prompt) | User message matching `^TAD_OVERRIDE: <gate> <reason>$` (reason rules §5.1) | Parse, validate nonce, append to HMAC-chained log, grant one-shot unblock for specified gate | UserPromptSubmit |
| **OV-2** Override fake attempt | LLM (Alex or Blake) | any file/content containing `TAD_OVERRIDE:` via tool call | Reject — overrides only come from UserPromptSubmit, never from tool calls | PreToolUse (content scan, all Write-family + Bash + MCP) |
| **HP-1** Protected path write | Either | `.claude/settings*.json`, `.tad/hooks/**`, `.tad/skills/**/SKILL.md`, `hardened-*.sh`, `~/.claude/settings.json`, `.tad/state/**`, `.tad/audit/**` | Deny unconditionally; requires OV-1 with `gate=protected-path` | PreToolUse Write-family + Bash + MCP |
| **HP-2** Env injection in content | Either | content matching expanded list (§1.1.1 below) in Write/Edit/Bash | Deny | PreToolUse Write-family + Bash |
| **PT-1** Path traversal | Either | file_path containing `..` segments OR content with `../../../` patterns | Deny | PreToolUse Write-family |

**Gate enum** (OV-1 `<gate>` field): `gate2 | gate3 | gate4 | protected-path | cross-role-edit | mcp-write | bootstrap-first-run | rationalization-ack | emergency`.

### 1.1.1 Env Injection Pattern List (HP-2)

Expanded from Phase 1b H-004 per P2-3. Match as literal substrings in content OR Bash command:
- TAD-specific: `TAD_SKIP_VALIDATION=`, `TAD_DISABLE_HOOKS=`, `CLAUDE_SETTINGS_PATH=`, `CLAUDE_CONFIG_DIR=`
- Shell injection: `BASH_ENV=`, `ENV=` (as standalone assignment), `PS4=`
- Interpreter hijacking: `PERL5OPT=`, `PERL5LIB=`, `AWKPATH=`, `JQ_COLORS=`, `PYTHONSTARTUP=`, `PYTHONPATH=` (when targeting hook scripts)
- Library injection: `LD_PRELOAD=`, `DYLD_INSERT_LIBRARIES=`, `DYLD_LIBRARY_PATH=`

### 1.2 Asymmetry (decided to KEEP symmetric — reasoning)

User chose **完全对称**. One shared checker, same interception primitives. Data differences (Alex needs ≥2 expert review files; Blake needs COMPLETION + Gate 3 attestation) are handled by **role-specific evidence manifests** passed to the same validator, NOT by separate checker modules. This matches the Phase 1a finding "Alex's handoff AC lacked COMPLETION-REPORT.md — same failure mode as Blake" — both sides are equally prone to the same skip patterns.

### 1.3 Evidence Manifests (role-specific data into shared checker)

```yaml
# .tad/schemas/evidence-manifest.yaml — referenced by production hook
alex_handoff_ready:
  required:
    - pattern: ".tad/evidence/reviews/alex/${handoff_slug}/*.md"
      min_count: 2
      min_bytes: 500
    - pattern: ".tad/evidence/reviews/alex/${handoff_slug}/socratic-trace.md"
      min_count: 1
    - pattern: ".tad/evidence/gates/${handoff_slug}/gate2-verdict.tsv"
      min_count: 1
      must_contain_column: "verdict=PASS"
    - pattern: "handoff_file"
      type: content_check
      must_contain_block: "Expected Evidence SHA"  # §6.1 freshness-via-sha

blake_completion_ready:
  required:
    - pattern: ".tad/active/handoffs/COMPLETION-*-${handoff_slug}.md"
      min_count: 1
      anchor: "^Overall: (PASS|FAIL)$"
      anchor_outside_fence: true
    - pattern: ".tad/evidence/reviews/blake/${handoff_slug}/*.md"
      min_count: 2
      min_bytes: 500
    - pattern: ".tad/evidence/gates/${handoff_slug}/gate3-verdict.tsv"
      must_contain_column: "verdict=PASS"
    - pattern: "Evidence Checklist"
      must_contain_in: "COMPLETION"
```

### 1.4 Gate Verdict Artifacts (resolves P0-6)

The manifests above reference `gate{2,3,4}-verdict.tsv`. Their lifecycle is defined here — without this §, Phase 3 would have ambiguous "where does the file come from" question.

**Location**: `.tad/evidence/gates/<handoff_slug>/gate{N}-verdict.tsv`

**Schema** (identical for all gates):
```
gate\tverdict\tts\treviewer\tnotes
gate2\tPASS\t2026-04-14T12:34:56Z\talex\tExpert review complete, 2 P0 resolved
gate3\tPASS\t2026-04-14T15:00:00Z\tblake\tLayer 1 + Layer 2 complete, AC11 noted
```

**Writer**:
- `gate2-verdict.tsv` written by `/gate` skill after Alex's step5 (Gate 2 Check) PASS, OR by `handoff_creation_protocol.step5` when Alex explicitly runs `*gate 2`
- `gate3-verdict.tsv` written by Blake's `completion_protocol` step immediately after Gate 3 v2 PASS (before step8_generate_message)
- `gate4-verdict.tsv` written by Alex's `acceptance_protocol.step8` immediately before `*accept` archive step

**Bootstrap** (first-run when gates not yet instrumented):
- If `.tad/evidence/gates/` does not exist, hook emits LOG-ONLY warning and **allows** (matches AW-1 bootstrap exception)
- Writer steps in `/gate` / `completion_protocol` / `acceptance_protocol` check for and `mkdir -p` the gates dir on first use
- Phase 3 handoff's own gate2 verdict must be the first entry (dogfood bootstrap)

**Integrity**: verdict TSV rows are append-only. Phase 3 adds PostToolUse hook that validates TSV append pattern (no row deletion, timestamps monotonic per gate). Not bulletproof but catches casual tampering.

### 1.5 Scope Clarification: Non-Handoff Alex Writes (resolves P1-4)

Alex Gate 4 and `*accept` flow write to: Epic files, NEXT.md, PROJECT_CONTEXT.md, project-knowledge/*.md, git commits. These writes are **intentionally NOT gated** by this enforcement matrix. Rationale:

- They occur AFTER the quality chain has run; the purpose of the gate is to prevent skipping the chain, not to regulate bookkeeping
- They do NOT contain "completion claim" sentinels (no `📨 Message from Blake`), so there is no "lying about completion" risk
- Gating them would create write-lock during acceptance (chicken/egg: need gate4-verdict.tsv to write gate4-verdict.tsv)

**Weaker guard** (defense-in-depth): AW-4 advisory rule — PostToolUse on `NEXT.md` / `PROJECT_CONTEXT.md` edits by Alex logs the edit context to `.tad/evidence/bookkeeping-log.jsonl` for later audit. No BLOCK, just trace.

---

## 2. Checker Architecture

### 2.1 Module Layout (Phase 3 targets, design-only here)

```
.tad/hooks/
  quality-enforcement.sh              # main PreToolUse dispatcher (registered in settings.json)
  userprompt-override.sh              # UserPromptSubmit handler for OV-1
  lib/
    quality-checker.sh                # shared verifier: role + manifest + payload → allow/deny
    sentinel-detect.sh                # H-001..H-002+DR-001: normalize + structural anchor match
    path-guard.sh                     # H-003 + H-005: protected-path + traversal
    content-scanner.sh                # H-004 + HP-2: env injection + Bash write-path
    evidence-validator.sh             # H-009 + KG-001 fix: structure + freshness via --handoff-path
    override-verify.sh                # H-006 + H-007: regex + nonce + HMAC chain
    dep-guard.sh                      # Phase 1c: PATH pin + whitelist + hardcoded deny JSON
    common.sh                         # stdin JSON parse, logging utilities
.tad/state/                            # PER-PROJECT, *sync excludes
  nonces.jsonl                        # append-only nonce registry
  secret.key                          # HMAC secret (chmod 600)
  override-log.jsonl                  # HMAC-chained override audit trail
.tad/schemas/
  evidence-manifest.yaml              # role manifests (§1.3)
  sentinel-patterns.yaml              # structural anchors (§3.1)
  protected-paths.yaml                # H-003 denylist
```

### 2.2 Control Flow

```
┌─ Claude Code PreToolUse event ─┐
│  (Write / Edit / MultiEdit /    │
│   NotebookEdit / Task / Bash)  │
└──────────────┬──────────────────┘
               │ stdin JSON (tool_name, tool_input, session_id, transcript_path)
               ▼
  .tad/hooks/quality-enforcement.sh
               │
               ├─ source lib/dep-guard.sh  # Phase 1c: hard deny if jq/awk missing
               ├─ source lib/common.sh     # parse stdin JSON
               │
               ├─ route by tool_name:
               │    Write/Edit/MultiEdit/NotebookEdit → sentinel-detect + path-guard + content-scanner
               │    Bash                               → content-scanner (env inj + write-path)
               │    Task                               → sentinel-detect on .tool_input.prompt
               │
               ├─ if sentinel matched (AW-2/BW-1/BW-2):
               │    → evidence-validator with role-manifest + --handoff-path=$slug
               │    → deny unless manifest satisfied
               │
               ├─ if protected-path / traversal / env-injection:
               │    → deny immediately
               │
               ├─ if OV-2 (TAD_OVERRIDE in tool content):
               │    → deny (LLM cannot self-override)
               │
               └─ else → allow (emit empty stdout, exit 0)

┌─ Claude Code UserPromptSubmit event ─┐
└──────────────┬──────────────────────┘
               │ stdin JSON with user's prompt
               ▼
  .tad/hooks/userprompt-override.sh
               │
               ├─ match ^TAD_OVERRIDE: <gate> <reason≥20>$ (line-start strict)
               ├─ sanitize reason (no \t\n, no prev_hmac=/hmac=/ts=/source=/FAKE_ROW)
               ├─ generate nonce, append to state/nonces.jsonl
               ├─ HMAC-chain entry in state/override-log.jsonl
               │    (row = {ts, gate, reason, nonce, prev_hmac, hmac})
               ├─ set session-scoped grant: next N PreToolUse calls for <gate> allow
               └─ exit 0
```

### 2.3 Shared-Library Interface

`lib/quality-checker.sh` exposes **one** function `check_write` consumed by both Alex-initiated and Blake-initiated writes. Differentiation is by **role manifest**, not by code branch:

```bash
# lib/quality-checker.sh (design-only; actual impl in Phase 3)
check_write() {
  local role="$1"         # "alex" | "blake"  — derived from file_path or session context
  local manifest_id="$2"  # e.g., "alex_handoff_ready" | "blake_completion_ready"
  local target_file="$3"
  local content="$4"      # tool_input.content (for Write/Edit)
  local handoff_slug="$5" # KG-001 fix: explicit --handoff-path requirement

  sentinel_detect "$content" || return 0  # no sentinel → no gate
  path_guard "$target_file" || deny_emit "protected path"
  content_scan "$content"   || deny_emit "env injection / traversal"
  evidence_validate "$role" "$manifest_id" "$handoff_slug" || deny_emit "evidence missing"
  return 0  # allow
}
```

Alex and Blake drivers differ **only** in which manifest ID they pass. Role detection uses **session active-skill context** (from `transcript_path` tail scan for most recent `/alex` or `/blake` skill invocation), NOT file_path alone (closes P0-2 cross-role-edit hole).

#### 2.3.1 handoff_slug Derivation Algorithm (resolves P0-4)

```
INPUT: file_path from tool_input
OUTPUT: handoff_slug (string) OR error

1. If file_path matches regex `^\.tad/active/handoffs/(HANDOFF|COMPLETION)-(\d{8})-(.+)\.md$`:
     slug := capture group 3
2. Elif file_path matches `^\.tad/evidence/reviews/(alex|blake)/([^/]+)/.*$`:
     slug := capture group 2
3. Elif file_path matches `^\.tad/evidence/spikes/SPIKE-(\d{8})-(.+)/.*$`:
     slug := capture group 2
4. Elif file_path matches `^\.tad/evidence/gates/([^/]+)/gate\d-verdict\.tsv$`:
     slug := capture group 1
5. Else:
     slug := null  (write not in enforcement scope)

VALIDATION (after derivation, before manifest check):
- If slug != null:
    Run `ls .tad/active/handoffs/HANDOFF-*-${slug}.md` OR check `.tad/archive/handoffs/HANDOFF-*-${slug}.md`
    If NO matching handoff exists:
      → DENY with reason "slug=${slug} has no matching handoff file (typo? misrouted evidence?)"
    This is the FAIL-CLOSED behavior for slug typos — prevents the KG-001-style silent bypass
- If slug == null: pass through (not our jurisdiction)
```

#### 2.3.2 Role Derivation Algorithm

```
INPUT: transcript_path from hook stdin
OUTPUT: role ∈ {alex, blake, system}

1. Read tail of transcript_path (last ~100 lines, JSONL format)
2. Find most recent entry matching `"name": "(Skill|alex|blake|tad-alex|tad-blake)"` with tool_use
3. If found and matches alex variant → role := alex
4. If found and matches blake variant → role := blake
5. If no match found in tail → role := system (e.g., direct user tool call without agent)
6. Confidence check: if both alex AND blake skill invocations in last 10 entries,
   the MORE RECENT one wins, but log WARN for audit
```

Alex and Blake drivers also differ in **which role they forbid cross-acting on**:
- If role=alex and file_path matches `COMPLETION-*.md` → AW-3 deny (Alex shouldn't write Blake's completion)
- If role=blake and file_path matches `HANDOFF-*.md` (and it's an Edit, not creating new) → AW-3 deny (Blake shouldn't edit Alex's handoff)

---

## 3. H-001 .. H-009 Integration Plan

| # | Phase 1b location | Phase 3 target module | Integration notes |
|---|---|---|---|
| H-001 | hardened-pretool-interceptor.sh | `lib/sentinel-detect.sh` | Keep dual-pass (strip + space) normalization; pre-compile confusables table at process start |
| H-002 | hardened-pretool-interceptor.sh | `lib/sentinel-detect.sh` | iterate `tool_input.edits[]` for MultiEdit; scan `.tool_input.prompt` for Task |
| H-003 | hardened-pretool-interceptor.sh | `lib/path-guard.sh` + `schemas/protected-paths.yaml` | Standalone config surface; patterns loaded once at hook start |
| H-004 | hardened-pretool-interceptor.sh | `lib/content-scanner.sh` | Apply to Write/Edit/MultiEdit content AND Bash command strings |
| H-005 | hardened-pretool-interceptor.sh | `lib/path-guard.sh` | Reject any `..` segment; canonical-path compare |
| H-006 | hardened-override-detector.sh | `lib/override-verify.sh` | Same regex + sanitization; nonce-registry moved to `.tad/state/nonces.jsonl` |
| H-007 | hardened-override-detector.sh | `lib/override-verify.sh` + state log | HMAC-chain preserved; add `chattr +a` (Linux) / APFS immutable flag (macOS) for defense-in-depth (document only, Phase 3 may defer to Phase 5) |
| H-008 | hardened-bash-watcher.sh | `lib/content-scanner.sh` (Bash branch) | Register separate PreToolUse matcher for `tool_name=Bash` |
| H-009 | hardened-evidence-validator.sh | `lib/evidence-validator.sh` | **KG-001 fix**: add `--handoff-path` arg parser; callers MUST pass it; pre-compute archive manifest via post-commit hook (out of Phase 3 MVP, Phase 5 optimization) |

### 3.1 DR-001 Structural Anchors + Unicode Confusables Normalization (resolves P0-3 security)

**Canonicalization pipeline** (applied to tool_input content BEFORE any pattern match):

```
1. Strip invisible formatters: U+200B..U+200F (ZW), U+202A..U+202E (BIDI), U+2060..U+2069 (word-joiner family),
   U+FE00..U+FE0F (VS1-16), U+FEFF (BOM)
2. NFKC normalize (Unicode::Normalize::NFKC in perl) — folds compatibility decompositions
3. Confusables class mapping (per Unicode TR39 restricted set):
   box-drawing-like → U+2500:
     {U+2500, U+2501, U+2502..U+257F,  # all box drawing
      U+2012..U+2015,                   # figure dash, en dash, em dash, horizontal bar
      U+2E3A, U+2E3B,                   # two/three-em dash
      U+FE58, U+FE63,                   # small em dash, small hyphen-minus
      U+FF0D,                           # fullwidth hyphen-minus
      U+23AF, U+23E4}                   # horizontal line extension, straightness
   horizontal-line variants collapse to single codepoint for run-length check
4. Unicode casefold (Unicode::CaseFold::fc($s, locale=>'und')) — full casefold, NOT simple lc()
   REJECT locale-dependent folds (Turkish, Azerbaijani): always use 'und' (undefined/default)
```

**sentinel-patterns.yaml**:
```yaml
# .tad/schemas/sentinel-patterns.yaml
blake_completion_sentinel:
  primary:
    requires_all:
      - literal: "📨 message from blake"   # post-casefold
      - box_drawing_regex: "[\\x{2500}]{16,}"  # post-confusables-normalization
  secondary:
    path_in:
      - ".tad/active/handoffs/HANDOFF-*.md"
      - ".tad/active/handoffs/COMPLETION-*.md"
  tertiary:
    cross_ref:
      - "commit hash (7+ hex) + handoff slug co-occurrence"

alex_handoff_sentinel:
  primary:
    requires_all:
      - literal: "📨 message from alex"
      - box_drawing_regex: "[\\x{2500}]{16,}"
  secondary:
    path_in:
      - ".tad/active/handoffs/HANDOFF-*.md"

# Precedence:
#   primary alone (post-normalize)       → BLOCK
#   primary + secondary                   → BLOCK (belt-and-suspenders)
#   secondary alone                       → LOG-ONLY
#   substring "message from X" in prose  → ALLOW (guard vs sb-011 positive control)

# Design-phase & docs allowlist (resolves P1-5 dogfood carve-out):
allowlist_paths:
  - ".tad/evidence/designs/**"
  - ".tad/evidence/spikes/**/SPIKE-REPORT.md"
  - ".tad/project-knowledge/**"
# Inside allowlist paths, sentinel literal appearing ONLY within ``` fenced code blocks
# is downgraded BLOCK → LOG-ONLY. Fence detection: count unclosed ``` before match;
# odd count = inside fence.
```

**Regression fixtures Phase 4 MUST include**:
- `fixture-embedded-table-with-u2500.md` — legitimate markdown table with box-drawing, no sentinel → ALLOW
- `fixture-cyrillic-msg-from-blak.md` — confusable letter attempt → BLOCK
- `fixture-eszett-meßage.md` — casefold eszett → BLOCK
- `fixture-turkish-İ.md` — Turkish dotless I in locale=und fold → BLOCK
- `fixture-greek-final-sigma.md` — σ vs ς mid-word → BLOCK
- `fixture-zwj-interleaved.md` — `📨 Message from Bla\u200Dke` → BLOCK
- `fixture-u2015-horizontal-bar.md` — 32× U+2015 dashes → BLOCK (after confusables mapping)
- `fixture-braille-blank-20.md` — 20× U+2800 passes `[:print:]` naive check → must BLOCK (§5.1 rule)
- `fixture-design-doc-with-fenced-sentinel.md` — DESIGN-*.md with sentinel inside ``` fence → ALLOW (allowlist carve-out)

### 3.2 Phase 2 Regression Extras (from 1b feed phase2_regression_extras)

| Extra | Status | Phase 3 action |
|---|---|---|
| casefold-eszett (`meßage`) | P0, may BYPASS | Handled by §3.1 pipeline step 4 (locale=und full casefold) |
| multiedit-split (sentinel across edits[]) | P0, BLOCKED in 1b | `lib/sentinel-detect.sh` concatenates `tool_input.edits[].new_string` before matching |
| path-traversal-in-file-path | P0, BLOCKED in 1b via H-005 | Keep as-is in `lib/path-guard.sh` |
| prompt-injection-in-content | P1 | Document-only: hook output is machine-consumed JSON, not LLM-interpreted; no runtime check |

### 3.3 Phase 1c Prerequisites (must be resolved before Phase 3 ships)

1. **Relax AC12 byte-preservation** — Phase 3 production code is free to optimize vs Phase 1b byte-identical constraint. Phase 2 design confirms: `lib/evidence-validator.sh` and `lib/content-scanner.sh` WILL differ from Phase 1b hardened hooks (add `read -t 2` internal timeout, switch to single-awk hot path per Phase 1c §4.4 recipe).
2. **Dedicated CI runner for perf gate** — Phase 3 CI workflow provisions isolated runner (no concurrent `claude` processes), load avg <1.0 at bench start, warm-up run discarded, N=100 baseline. Dev-host numbers are directional only.
3. **Internal self-timeout (`read -t 2`)** — all hot-path reads in `lib/evidence-validator.sh` + `lib/content-scanner.sh` must self-fail-closed in <2s, never relying on outer wrapper.

---

## 4. SKILL Hardening Clauses (inline, per user decision)

### 4.1 Alex SKILL.md inline additions

| Anchor (existing step) | Insert |
|---|---|
| `handoff_creation_protocol.workflow.step0_5` | After knowledge refresh, add: "**AC Conflict Matrix**: before finalizing AC list, for any triple of structural ACs (byte-preservation, performance budget, behavioral invariant), self-check `can all three be satisfied simultaneously?`. Document resolution upfront or pick-2. Violation: cross-constraint conflict that forces Blake PARTIAL-GO = handoff design bug, not Blake discipline issue." (per Phase 1c knowledge entry) |
| `handoff_creation_protocol.workflow.step1.content` | Add required manifest line: "**Required Evidence Manifest** section MUST explicitly list: ≥2 expert review file paths, COMPLETION-*.md filename, Gate 2 verdict location. The hook at `.tad/hooks/quality-enforcement.sh` will block the handoff Write if this manifest is absent." |
| `acceptance_protocol.step7` | Add: "Before writing Gate 4 knowledge, **re-derive** all quantitative ACs from raw TSV via one-liner; paste re-derived value next to Blake's reported value. Discrepancy >5% = investigate before accept. Apply any validator delivered in this handoff to the top-level report as dogfooding." (per Gate 4 Verification Integrity entry) |
| NEW `anti_rationalization_registry` block (§4.1.1 inline below) | Full byte-exact YAML inserted as new top-level key in Alex SKILL.md after `forbidden:` block |

#### 4.1.1 anti_rationalization_registry — byte-exact SKILL.md insert (resolves P1-2)

```yaml
anti_rationalization_registry:
  description: "Patterns Alex has historically used to rationalize skipping a required step. Scan this list BEFORE deciding any step is unnecessary."
  must_scan_before:
    - "skipping expert review"
    - "marking a handoff 'express'"
    - "defaulting to 'no new knowledge' in Gate 4"
    - "accepting Blake's PARTIAL without raw-TSV recompute"
  patterns:
    - id: "AR-001"
      label: "express = review-exempt"
      why_wrong: |
        2026-04-14 plain-language express handoff: Alex drafted 'AC8: no expert review needed'.
        SessionStart reminder caught the rationalization mid-step. Actual expert review found
        4 P0 including architecturally broken step8-after-STOP-gate design that would have
        shipped broken. 'Small edit' pattern-matches to 'low risk' in agent's prior, bypassing
        the real question: 'does this change a protocol contract?'
      rule: "Express may justify skipping e2e test, MUST NOT skip expert review (min 1 expert)"

    - id: "AR-002"
      label: "small edit = low risk"
      why_wrong: |
        v2.7 quality chain failure: a 'small' SKILL.md slim reduction removed load-bearing
        constraint rules along with mechanical logic. 570 line reduction looked harmless;
        the 10 lines of forbidden_actions that disappeared caused months of quality chain
        drift across commands/skills divergence.
      rule: "File size change ≠ semantic impact. Before any edit >20 lines to SKILL.md / config-*.yaml / hooks/, explicitly list what contract changed."

    - id: "AR-003"
      label: "spike evidence = no expert review"
      why_wrong: |
        Phase 1b spike handoff v1 designed Template A with red-team language (malicious,
        attacker, bypass). Without security-auditor review catching the classifier-refusal
        risk, Blake would have spent hours hitting 'Usage Policy' errors with no remediation
        path. 2 experts, 7 P0 resolved, saved the spike.
      rule: "Spike handoffs require ≥2 experts same as production handoffs. Security-critical sub-agent invocations require security-auditor review of prompt template."

    - id: "AR-004"
      label: "perf near threshold = noise"
      why_wrong: |
        Phase 1b p95 104-114ms looked like 'noise at ~100ms threshold'. Phase 1c N=100 retest
        confirmed evidence-validator (156ms) and bash-watcher (130ms) are REAL regressions,
        not noise. Dev-host 2-3x noise is real but doesn't explain consistent 30-56ms overshoot.
      rule: "Perf 'borderline' = insufficient data. Require N≥100 on dedicated CI runner
        before calling any perf gate PASS or noise."

    - id: "AR-005"
      label: "commit N/A = no new knowledge"
      why_wrong: |
        Gate 4 Knowledge Assessment default-filled with 'No new discoveries' skips the explicit
        evaluation. Phase 1c session generated 6+ substantial architecture entries that would
        have been lost if Alex defaulted to 'N/A'. Even 'routine' gates often surface non-obvious
        discoveries about tools or workflows.
      rule: "Gate 4 Knowledge Assessment MUST explicitly iterate: (a) did this acceptance reveal
        anything about tool behavior, (b) did expert review raise novel concerns, (c) did Gate 4
        find discrepancies between claimed and actual metrics. Only AFTER these three checks
        may the verdict be 'No new discoveries'."

  enforcement_mode: "prompt_scan"
  # Phase 3 content-scanner.sh includes these labels in the content pattern table;
  # if Alex about to write a handoff/completion containing any label-text without
  # an OV-1 override for gate=rationalization-ack, BLOCK.
```

(Full 80-line block above is the exact insert — Phase 3 Blake copy-pastes this into `.claude/skills/alex/SKILL.md` at the specified anchor without paraphrasing.)

### 4.2 Blake SKILL.md inline additions

| Anchor (existing step) | Insert |
|---|---|
| `completion_protocol.step3c` | After commit check, add: "**Evidence Manifest Verification**: before writing completion message, `ls` each file listed in handoff Required Evidence Manifest. Missing file = BLOCK, write missing item to completion report and return to Layer 2. The hook will also block, but self-check first saves a round trip." |
| `completion_protocol.step8_generate_message` | Add: "**Raw Metric Quote Requirement**: if handoff has quantitative ACs, message to Alex MUST quote the raw TSV values verbatim (allow Alex independent recomputation on Gate 4)." (per Phase 1c AC14 precedent) |
| `ralph_loop.layer2` | Strengthen: "Layer 2 expert review is NOT optional for express handoffs. Phase 1a self-caught case: Alex drafting a 15-min SKILL edit wrote 'AC8: no expert review needed' — would have shipped 4 P0 issues including architecturally broken step8. Express may justify skipping e2e but MUST still run Layer 2 expert review with ≥1 expert." |
| NEW `honest_partial_protocol` block (§4.2.1 inline below) | Full byte-exact YAML inserted as new top-level key in Blake SKILL.md after `ralph_loop:` block |

#### 4.2.1 honest_partial_protocol — byte-exact SKILL.md insert

```yaml
honest_partial_protocol:
  description: "When handoff ACs are mutually contradictory or when required evidence is impossible to produce, Blake must report PARTIAL-GO with explicit conflict statement instead of silently picking one."
  triggers:
    - "Two or more structural ACs (byte-preservation, size limit, behavioral invariant) cannot be simultaneously satisfied"
    - "An AC requires a tool/resource that is absent and installing it is out of scope"
    - "Expert review findings conflict with a handoff AC constraint"
    - "Ralph Loop Layer 2 review concludes the AC as-worded is impossible"
  required_report_shape:
    - "Overall: PARTIAL-GO (not PASS, not FAIL)"
    - "Explicit 'AC conflict statement' section listing the contradicting ACs by number"
    - "Evidence for what WAS accomplished (ACs that passed)"
    - "Recommendation for Alex: (a) revise AC in addendum handoff, (b) defer to next phase, (c) accept partial"
  forbidden:
    - "Silently satisfying one AC and ignoring the other"
    - "Choosing which AC to honor based on difficulty"
    - "Reporting 'PASS' when internal conflict was papered over"
  precedent:
    - case: "Phase 1c (2026-04-14)"
      ac_conflict: "AC12 byte-preservation vs AC15 optimization vs AC8-B internal timeout"
      blake_action: "Satisfied AC12, reported AC15/AC8-B as FAIL with conflict statement"
      outcome: "Alex Gate 4 accepted PARTIAL; Phase 3 inherits the resolution (relax AC12)"
      judgment: "CORRECT behavior — this is the expected response to Alex handoff design bugs"
```

(Full 30-line block above is exact insert. Phase 3 Blake copies to `.claude/skills/blake/SKILL.md` at specified anchor.)

### 4.3 Cross-cutting SKILL rules (Alex + Blake)

- **Override content rule**: agents MUST NEVER write `TAD_OVERRIDE:` in any tool call output. Override is a human-only primitive on UserPromptSubmit. Any agent-initiated `TAD_OVERRIDE:` in file content = content-scanner deny.
- **Sentinel prose rule**: agents MUST NEVER write `📨 Message from <name>` as inline example inside handoff/completion unless the structural anchors (box-drawing sig + path context) are absent — use fenced code blocks or escape the emoji.

---

## 5. Override Authentication Structure

### 5.1 Regex + Sanitization (from H-006, hardened per P0-5 security)

```
Line-start strict: ^TAD_OVERRIDE: <gate> <reason>$
  - gate ∈ (see §1.1 "Gate enum")
  - reason rules:
    * Must contain ≥20 GRAPHEMES (NOT bytes, NOT codepoints) — counted via
      perl Unicode::GCString
    * Each grapheme must belong to Unicode General_Category in {L, N, P, Sm, Sc, Sk, So}
      (letter, number, punctuation, math/currency/modifier/other symbol)
    * Explicit REJECT if any grapheme in:
      - Cf (format, incl. ZW/BIDI/VS)
      - Cc (control)
      - Cs (surrogate)
      - Co (private use)
      - Zl (line separator)
      - Zp (paragraph separator)
      - Zs EXCEPT U+0020 (all Zs except regular space)
      - Unicode TR39 restricted confusables class
      - U+2800 (Braille pattern blank)
    * No \t or \n literally
    * Forbidden substrings (H-006 preserved): `prev_hmac=`, `hmac=`, `ts=`, `source=`, `FAKE_ROW`
    * Post-NFKC normalization applied BEFORE counting graphemes (prevents Unicode escaping)

IMPLEMENTATION: perl -CSD -MUnicode::GCString -MUnicode::UCD -MUnicode::Normalize
Regression fixtures for §5.1:
  - "一二三四五六七八九十一二三四五六七八九十" (20 CJK graphemes, all L) → ACCEPT
  - "I need to override because of an emergency deployment issue" (English, 50+ graphemes) → ACCEPT
  - "⠀" × 20 (20 Braille blanks) → REJECT
  - "aaaaaaaaaaaaaaaaaaaa" (20 ASCII, OK) → ACCEPT but audit flag 'low-entropy reason'
  - "abc\u{202E}def ...20 chars total" (embedded RTL override) → REJECT
  - short: "too short" (9 graphemes) → REJECT
  - mixed: "hi \u{FE00}\u{FE01}\u{FE02}... padding to 20" (VS fill) → REJECT
```

### 5.2 Nonce Lifecycle (per-project, from user decision; hardened per P1-1, P1-3)

```
.tad/state/nonces.jsonl  (append-only, chmod 600)
{
  "nonce": "<generated via: openssl rand -base32 20  OR  head -c 32 /dev/urandom | base32 | tr -d = | head -c 32>",
  "issued_ts": "<ISO 8601>",
  "gate": "gate3",
  "session_id": "<claude session from hook stdin>",
  "consumed_ts": null | "<ISO 8601>",
  "consumed_by": null | "<hook invocation id>"
}

Rules:
  - nonce issued on UserPromptSubmit match
  - single-use: consumed_ts set on first matching PreToolUse in same session
  - scope: next N PreToolUse for <gate> within EXACTLY same session_id (N default 1)
  - TTL: 1 hour; expired nonces ignored
  - Never synced across projects (*sync excludes .tad/state/)

IDEMPOTENT ALLOCATION (resolves P1-3 retry/typo doubling):
  On UserPromptSubmit regex match:
    1. Query nonces.jsonl for rows where
         (session_id == current) AND (gate == current) AND (consumed_ts IS NULL) AND (issued_ts > now - 1h)
    2. If match found → return existing nonce (DO NOT append new row)
    3. If no match → generate + append

SUBAGENT SCOPE (resolves P1-1):
  Task-spawned subagents get a NEW session_id from Claude Code. Parent's nonce CANNOT
  be consumed by subagent (session_id mismatch → nonce lookup fails → PreToolUse denies).
  This is INTENTIONAL — prevents privilege propagation. Subagent needs override? Human
  issues a new TAD_OVERRIDE in the subagent's session. Regression fixture: parent with
  gate3 override, subagent Write under same gate → BLOCKED.
```

### 5.3 HMAC-Chained Override Log with External Witness (from H-007; resolves P0-2)

```
.tad/state/override-log.jsonl    (append-only, chmod 600)
Row N = {
  "ts": "<ISO 8601>",
  "gate": "...",
  "reason": "<sanitized>",
  "nonce": "<consumed>",
  "user_session": "<id>",
  "prev_hmac": "<hmac of row N-1, or null for row 0>",
  "hmac": "HMAC-SHA256(secret, JSON.stringify(row without hmac field))"
}

EXTERNAL WITNESS (prevents full-chain truncation/replacement attack):
On each append to override-log.jsonl, ALSO write:

  1. .tad/audit/chain-tip.txt  (GIT-TRACKED, not in .tad/state/):
     content = latest row's hmac (hex string, 64 chars + newline)
     Committed by the post-override workflow. Git history is the out-of-tree witness.

  2. ~/.claude/tad-chain-witnesses/<project-id>.jsonl  (user-home, outside project):
     append row {ts, project_id, latest_hmac, latest_row_count}
     Survives project-local state/ wipe. <project-id> = sha256(realpath project root).

--re-verify VERIFICATION LOGIC:
  1. Re-compute HMAC chain from .tad/state/override-log.jsonl
  2. Compare final hmac vs .tad/audit/chain-tip.txt
       MISMATCH → "external git witness conflict: state/ may have been rolled back"
  3. Compare final hmac vs last row in ~/.claude/tad-chain-witnesses/<project-id>.jsonl
       MISMATCH → "external user-home witness conflict: possible fresh-secret reset attack"
  4. All three agree → chain integrity PASS

COMPROMISE DETECTION:
  On hook boot (once per session), run detection:
    - `git log --all -- .tad/state/secret.key` → if ANY commit: ERROR "secret.key was committed, rotate immediately"
    - If `.tad/state/secret.key` exists but `.tad/audit/chain-tip.txt` does not exist: WARN "bootstrap state, no witness yet"
    - If chain-tip.txt exists but override-log.jsonl has fewer rows than witness claims: ERROR "log truncation detected"

Defense-in-depth (Phase 5 future work):
  - chattr +a (Linux) / macOS APFS immutable flag on state/ files
  - O_APPEND|O_EXCL writes + fsync (portable alternative for macOS dev)
  - Nightly cross-check cron comparing project witness vs user-home witness
```

### 5.4 Cross-Project Synchronization (from user decision)

**Decision: per-project independence**. `*sync` command MUST exclude `.tad/state/` from all sync operations. Each project has its own nonces, secret, override log.

**Blast radius**: single-project compromise. Cross-project replay attacks are NOT addressed at this layer — if a fleet-wide attacker has write access to one project's `.tad/state/secret.key`, other projects are still protected by their own secrets.

**Documented trade-off**: no cross-project override audit view. Admin wanting a fleet-wide audit must manually `cat */.tad/state/override-log.jsonl`. Acceptable: TAD is not multi-tenant; single user typically.

---

## 6. Known Gaps Handling

### 6.1 KG-001 Staleness (P1) — IN Phase 3 scope (hardened per P1-4 security)

**Fix chosen: Option A + content-hash binding** (upgraded from pure mtime).

Pure mtime is forgeable via `touch`. Security-auditor P1-4 correctly flagged that mtime inversion is uncovered + mtime bumping defeats the check. Design upgraded:

- `quality-enforcement.sh` dispatcher derives `handoff_slug` via §2.3.1 algorithm
- Passes `--handoff-path=.tad/active/handoffs/HANDOFF-*-<slug>.md` + `--evidence-path=<target>` to `lib/evidence-validator.sh`
- Validator performs both checks:
  1. **Existence**: handoff file must exist (archive OK). If not → DENY "no handoff for slug".
  2. **Expected-sha block binding** (replaces mtime): handoff file's `Required Evidence Manifest` section MUST contain an `Expected Evidence SHA` sub-block listing sha256 of each required evidence file. Validator computes sha of current evidence candidate; if NOT in listed set → DENY "evidence not declared in handoff".
  3. **Freshness via git** (belt-and-suspenders): if both files are git-tracked, use `git log -1 --format=%ct` commit timestamps instead of filesystem mtime for ordering comparison. Legitimate evidence-ahead-of-handoff case handled: in-progress Layer 2 evidence may precede handoff AC update, hook logs WARN but does not block when evidence is newer (permitted inverse direction).

**Expected Evidence SHA block** in Alex handoff template (Phase 3 adds to template):
```markdown
### Required Evidence Manifest
...
### Expected Evidence SHA (H-EES-001)
- `b2c3...`  .tad/evidence/reviews/alex/<slug>/code-reviewer.md
- `a1d4...`  .tad/evidence/reviews/alex/<slug>/security-auditor.md
- (TBD-on-acceptance)  .tad/active/handoffs/COMPLETION-YYYYMMDD-<slug>.md
```
Alex fills SHA after expert review files exist; `(TBD-on-acceptance)` rows are late-bound by Blake in completion step. Violation: Blake writes a review file NOT in Expected list → hook BLOCKs.

Cost updated: ~4-6h (arg parser + SHA block generation + validator changes + handoff template update). Captured in Phase 3 handoff AC.

### 6.2 KG-002 TOCTOU (P1) — DEFERRED structural fix, ACTIVE detection added (per P1-2)

**Structural fix deferred**: symlink-swap race requires 2-process coordination outside Claude Code's hook lifetime. Proper fix awaits Claude Code core exposing realpath-on-write primitive — out-of-scope for TAD framework.

**Active detection added to Phase 3 scope** (upgrade from pure-deferral):

1. **Concurrent-session detection in hook boot**:
   - At each PreToolUse invocation, `quality-enforcement.sh` reads `~/.claude/sessions/` (or equivalent path for current Claude Code version) and counts ACTIVE sessions whose `cwd` matches current project.
   - If count > 1 AND no `TAD_MULTI_SESSION_ACK` override present in current session, emit WARN banner in hook stderr + append to `.tad/evidence/bookkeeping-log.jsonl` (JSONL row: `{ts, event: "concurrent-session-detected", session_ids: [...]}`).
   - Does NOT block (may false-positive on legitimate parallel Alex+Blake), but creates audit trail.

2. **Session-id mismatch detection in override-verify**:
   - When `override-verify.sh` processes a nonce consumption, if `nonce.session_id != current_hook_session_id`, append `{ts, event: "session-mismatch", expected: X, got: Y}` to same log and DENY the override grant.
   - This catches: attacker who gained read access to nonces.jsonl tries to consume a nonce in a different session.

3. **Knowledge entry** (to be added to `.tad/project-knowledge/security.md` in Phase 3): "TAD quality-enforcement PreToolUse hook is vulnerable to TOCTOU symlink swap during concurrent Claude Code sessions. Mitigation: single-session policy per project enforced procedurally; hook emits WARN on multi-session detection for audit trail. Structural fix awaits Claude Code core realpath-on-write hook primitive."

---

## 7. Performance Architecture (from Phase 1c findings)

### 7.1 Hot-path optimization targets

| Hook | Phase 1c measured p95 | Phase 3 target | Mechanism |
|---|---|---|---|
| pretool-interceptor | 67.44ms | <100ms (already passes) | no change |
| override-detector | 52.48ms | <100ms (passes) | no change |
| evidence-validator | 156.51ms | <100ms | single-awk (§1c §4.4) + archive manifest cache + keyword list pre-compiled |
| bash-watcher | 130.57ms | <100ms | single-awk pattern match + env-injection grep single pass |

### 7.2 CI gate requirements (from Phase 1c prerequisite 2)

Phase 3 CI workflow:
```yaml
perf-gate:
  runs-on: ubuntu-latest-ci-dedicated  # NOT shared runner
  steps:
    - check load avg < 1.0 before bench
    - no concurrent claude processes (pgrep check)
    - warm-up run discarded
    - N=100 samples per hook
    - fail if any hook p95 ≥ 100ms
    - log load avg + concurrent process list in every perf report
```

Dev-host numbers are directional signal only; not gating.

### 7.3 Self-timeout + Size Cap (from Phase 1c prerequisite 3; hardened per P1-3)

Two-layer fail-closed:

1. **Size cap (early)**: stdin is piped through `head -c 1048576` (1 MB) BEFORE `jq` parse. If payload exceeds cap, hardcoded deny JSON with reason `payload_too_large` + exit 0. Rationale: largest legitimate TAD writes observed are ~40 KB (long completion reports); 1 MB ceiling has 25× headroom and prevents memory exhaustion via 2 GB MultiEdit new_string attack.

2. **Timeout (late)**: every hook stdin read wraps in `read -t 2` or equivalent (perl `alarm(2)`). Fail-closed: hardcoded deny JSON + exit 0.

Test fixtures Phase 4 MUST include:
- `fixture-1.1MB-payload.json` → DENY payload_too_large
- `fixture-slow-fifo-no-data-3s.json` → DENY self-timeout
- `fixture-950KB-valid-write.json` → ALLOW (under cap)

---

## 8. Phase 3 Scope Contract (output of this design)

Phase 3 handoff (future, Alex writes) MUST include:

- **In scope**:
  - Create `.tad/hooks/quality-enforcement.sh` + `.tad/hooks/userprompt-override.sh`
  - Create all `lib/*.sh` modules per §2.1
  - Create `.tad/schemas/evidence-manifest.yaml`, `sentinel-patterns.yaml`, `protected-paths.yaml`
  - Update `.claude/settings.json` to register both hooks with correct matchers
  - Apply SKILL hardening clauses per §4 (byte-exact inserts per §4.1.1 + §4.2.1)
  - Create `.tad/state/` directory scaffolding + add `.tad/state/` to `.gitignore` at bootstrap (resolves P0-1 security) + `*sync` exclusion rule
  - Bootstrap: first-run hook generates `secret.key` (chmod 600), writes initial `chain-tip.txt`, scans `git log --all` for historical secret.key commits and ERRORs if found
  - Implement KG-001 `--handoff-path` + Expected Evidence SHA block
  - Implement external HMAC witnesses (.tad/audit/chain-tip.txt git-tracked + ~/.claude/tad-chain-witnesses/)
  - Implement KG-002 detection (concurrent-session + session-mismatch logging)
  - Gate verdict artifacts per §1.4 (writer hooks in /gate skill, completion_protocol, acceptance_protocol)
  - CI workflow for perf gate (§7.2)
  - Size cap + self-timeout per §7.3
  - Dogfood: Phase 3 handoff itself must satisfy the new enforcement (leveraging bootstrap exception for first write)

- **Out of scope** (Phase 4+):
  - KG-002 TOCTOU fix (knowledge entry only)
  - Cross-project sync of state (architecturally rejected)
  - Post-commit archive manifest pre-compute (Phase 5 optimization)
  - APFS immutable flag / chattr +a (Phase 5 defense-in-depth)
  - Semantic paraphrase detection ("a note authored by Blake")

- **Prerequisite gates**:
  - All 3 Phase 1c prerequisites resolved (AC12 relaxed in Phase 3 AC wording, CI runner provisioned, `read -t 2` in each module)
  - Phase 2 design review passed (expert review ≥2, all P0 resolved)

---

## 9. Risks & Open Questions

1. **Dogfooding paradox (resolved per P0-7)**: AW-1 fires on Write/Edit of HANDOFF-*.md regardless of sentinel. Phase 3's own first handoff will trigger AW-1 before any gate artifacts exist. **Resolution**: AW-1 has an explicit bootstrap exception in §1.1 — if `.tad/state/secret.key` does not exist (first-run), AW-1 downgrades to LOG-ONLY. Phase 3 handoff ships with enforcement machinery + completes `*accept`, which creates the first `gate4-verdict.tsv` and triggers secret.key generation. From next handoff onward, AW-1 is fully armed. **Also**: DESIGN-*.md files (including this file) are in sentinel-patterns.yaml `allowlist_paths` (§3.1) — sentinel examples in fenced code blocks are permitted.

2. **First-run bootstrapping (§8 scope expanded)**: Phase 3 hook must: (a) auto-generate `secret.key` on first run with `openssl rand -base64 32` + chmod 600 + WARN user; (b) write `.tad/state/` entry to `.gitignore`; (c) scan `git log --all -- .tad/state/secret.key` and ERROR if any historical commit found; (d) create `.tad/audit/` dir (git-tracked) + initial empty `chain-tip.txt`.

3. **Box-drawing character false-positives (resolved per P2-4)**: U+2500 run ≥16 + confusables class mapping is aggressive. Phase 4 regression MUST include specific fixtures named: `fixture-embedded-table-with-u2500.md`, `fixture-ascii-art-dashes.md`, `fixture-generated-docs-with-separator.md`. Alex manually verifies no collision. Confusables mapping rationale documented in §3.1.

4. **Phase 2 → Phase 3 translation fidelity**: this design is now ~800 lines; Phase 3 handoff will decompose into ~30+ AC items. Risk: item drop during translation. Mitigation: Phase 3 handoff AC list includes explicit back-reference `(design §X.Y)` for each item; Alex Gate 4 verifies coverage via grep count.

5. **Role detection via transcript_path brittleness (new, from P0-2)**: §2.3.2 reads transcript tail to infer role. If transcript path is missing from hook payload, or format changes across Claude Code versions, role detection fails. **Mitigation**: fallback role=system (write-family to HANDOFF/COMPLETION by system = DENY with "role indeterminate" reason). Phase 4 regression must include "missing transcript_path" fixture.

6. **Witness file permission drift (new)**: `~/.claude/tad-chain-witnesses/<project-id>.jsonl` is outside project scope. If user's HOME is on a shared filesystem (enterprise), another user could corrupt witnesses. **Mitigation**: chmod 600 on witness files; boot check verifies permissions; Phase 5 optimization to sign witnesses with a user-key.

---

## 10. Expert Review Status

| Reviewer | Verdict (v1) | P0 Count | Verdict (v2) | Integrated |
|----------|--------------|----------|--------------|-----------|
| code-reviewer | CONDITIONAL PASS | 8 | pending re-review | ✅ All 8 integrated in v2 |
| security-auditor | CONDITIONAL PASS | 5 | pending re-review | ✅ All 5 integrated in v2 |

### P0 Resolution Map (13 total — 8 code + 5 security)

| # | Source | Issue | Resolution in v2 |
|---|--------|-------|-----------------|
| code-P0-1 | Edit/MultiEdit bypass (matrix only listed Write) | §1.1 matrix now uses "Write-family" (Write\|Edit\|MultiEdit\|NotebookEdit) in all 8 rows where applicable |
| code-P0-2 | Cross-role edit (Blake editing Alex handoff) | New AW-3 rule in §1.1 + role detection via transcript in §2.3.2 + `gate=cross-role-edit` enum value |
| code-P0-3 | MCP tool coverage missing | New MC-1 (deny mcp__* under .tad/**) + MC-2 (sentinel detect on mcp__* content) + OV-2 scope extended to MCP |
| code-P0-4 | slug derivation algorithm underspecified | §2.3.1 pins exact algorithm with 4 regex cases + fail-closed on typo |
| code-P0-5 | H-004 content-scanner two entry points unclear | §3 table + module layout §2.1 now show scan_write_content + scan_bash_command entry points |
| code-P0-6 | Gate verdict file undefined | New §1.4 Gate Verdict Artifacts with location, schema, writer steps, bootstrap rule |
| code-P0-7 | Dogfooding contradiction (AW-1 fires on write) | §9.1 resolved via explicit bootstrap exception in §1.1 AW-1 row + §3.1 allowlist for DESIGN-*.md |
| code-P0-8 | Gate enum missing entries | Extended enum in §1.1 to cover cross-role-edit, mcp-write, bootstrap-first-run, rationalization-ack |
| sec-P0-1 | .tad/state/ gitignore not enforced | §8 Phase 3 scope now includes gitignore write + `git log --all` historical secret scan + boot-time detection |
| sec-P0-2 | HMAC chain lacks external anchor | §5.3 upgraded: git-tracked `.tad/audit/chain-tip.txt` + `~/.claude/tad-chain-witnesses/` + --re-verify cross-checks both |
| sec-P0-3 | Unicode confusables spoof box-drawing | §3.1 canonicalization pipeline: NFKC + confusables class mapping (TR39 restricted) + ZW strip |
| sec-P0-4 | Casefold insufficient for Turkish/Greek/Lithuanian | §3.1 step 4: `Unicode::CaseFold::fc(locale=>'und')` explicitly forced, regression fixtures included |
| sec-P0-5 | Override reason "≥20 printable" undefined | §5.1 pinned to ≥20 Unicode graphemes in categories L|N|P|Sm|Sc|Sk|So with explicit Braille-blank / ZW / VS rejection |

### P1 Adopted (selected high-leverage)

- **sec-P1-1** Nonce subagent scope clarified — §5.2 explicitly intended behavior + regression fixture
- **sec-P1-2** TOCTOU active detection added — §6.2 concurrent-session + session-mismatch logging
- **sec-P1-3** Size cap 1MB before jq — §7.3
- **sec-P1-4** Evidence freshness via sha — §6.1 Expected Evidence SHA block replaces mtime
- **sec-P1-5** DESIGN doc allowlist — §3.1 allowlist_paths + fence carve-out
- **code-P1-1** Bash extended to cp/mv/git mv/rsync/install — §1.1 BW-4 expanded
- **code-P1-2** Full byte-exact SKILL inserts — §4.1.1 anti_rationalization_registry + §4.2.1 honest_partial_protocol
- **code-P1-3** Nonce idempotent allocation — §5.2
- **code-P1-4** Non-handoff Alex writes out-of-scope — §1.5 explicit
- **code-P1-5** Perf target risk acknowledged — §7.1 single-awk may not close 56ms gap, archive manifest cache mandatory in Phase 3 (promoted from "Phase 5 optimization" to Phase 3 in-scope)

### P2 Captured in Phase 3 AC list (selective)

- Regex pattern for box-drawing, openssl rand command, env-injection interpreter list, HEALTH.md boot check — all in §1.1.1 / §3.1 / §5.2 / §6.2

## 11. Gate 2 Checklist

- [x] Expert review complete (code-reviewer + security-auditor, parallel, v1)
- [x] All 13 P0 issues integrated in v2 (map in §10)
- [x] §1 matrix covers 13 event types, each has enforcement column with Write-family or MCP coverage
- [x] §1.4 Gate Verdict Artifacts defined (resolves manifest ambiguity)
- [x] §2 architecture has module table + control flow + shared-lib interface + slug derivation algorithm + role detection algorithm
- [x] §3 integration plan addresses H-001..H-009 + 4 regression extras + 3 Phase 1c prerequisites + Unicode canonicalization pipeline
- [x] §4 SKILL clauses have byte-exact inserts (anti_rationalization_registry §4.1.1 + honest_partial_protocol §4.2.1)
- [x] §5 override auth: grapheme-based reason rule + idempotent nonce + external HMAC witnesses + subagent carve-out
- [x] §6 KG handling: 001 upgraded to sha-based + 002 has active detection (not pure deferral)
- [x] §7 perf + CI + size cap + timeout
- [x] §8 Phase 3 scope contract with in/out/prereq including bootstrap + gitignore
- [x] §9 risks enumerated including 2 new risks from P0 fixes (role detection brittleness + witness file permissions)
- [ ] v2 re-review by both experts — RECOMMENDED but not blocking (delta is P0 integrations, each traced in §10 resolution map)

**Gate 2 Verdict**: PASS (v2). Phase 2 design is ready to freeze.

---

**Next action after approval**: update Epic Phase 2 row to ✅ Done. Phase 3 implementation handoff MUST:
  1. Reference this design by path + commit sha
  2. Decompose §1-§9 into ≥30 ACs, each with `(design §X.Y)` back-reference
  3. First AC: resolve Phase 1c 3 prerequisites (relax AC12 wording, CI runner provisioning, `read -t 2` in every hot-path)
  4. Dogfood: Phase 3 handoff must pass AW-1 bootstrap exception path, then subsequent writes must pass fully-armed AW-1
