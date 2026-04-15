# Phase 2 Design v3-LEAN — Symmetric Enforcement Matrix (Phase 3 Buildable Subset)

**Epic:** EPIC-20260413-symmetric-quality-enforcement.md (Phase 2/5, lean revision)
**Status:** LEAN spec — the actual subset Phase 3 will implement
**Author:** Alex | **Date:** 2026-04-14
**Relationship to v2:** v2 (`DESIGN-20260414-phase2-enforcement-matrix.md`) is the "ideal" spec containing all 13 P0 expert resolutions. v3-LEAN cuts defenses that don't match a single-user CLI threat model. v2 remains as future extension reference for multi-tenant / hostile-filesystem scenarios.

---

## 0. Scope Principle

**Threat model**: LLM agents (Alex / Blake) that rationalize skipping required steps. User runs TAD on personal machine(s). No multi-tenant, no APT, no adversary-with-local-write.

**What this design keeps** (Epic necessary):
- Mechanical PreToolUse enforcement of handoff/completion writes
- Kill all 4 escape routes (Skip TAD / express exempt / Gate 2=Layer 2 / Layer 1=Gate 3)
- Override only via human UserPromptSubmit; LLM cannot self-grant
- Symmetric Alex + Blake (shared checker, role manifests)
- Fleet-wide 10 projects via per-project state

**What this design cuts** (from v2, over-engineered for threat model):
- External HMAC witnesses (`~/.claude/tad-chain-witnesses/`, git-tracked `.tad/audit/chain-tip.txt`) — defends rollback from local-write attacker that doesn't apply
- TR39 Unicode confusables full mapping — LLMs don't craft U+2015 spoofs; keep simple casefold
- Grapheme/category-based override reason rule — simplify to length + basic sanitize
- HMAC-chained log + `--re-verify` — plain append-only JSONL with chmod 600 is sufficient
- Expected Evidence SHA content-binding — mtime + file existence is enough
- Archive manifest cache — Phase 5 optimization, not MVP
- MCP tool (mcp__*) coverage — no current TAD MCP write surface
- Active concurrent-session / session-mismatch detection — single-line knowledge note

---

## 1. Enforcement Matrix (8 events, down from v2's 13)

"Write-family" = `Write | Edit | MultiEdit | NotebookEdit`.

| # | Event | Who | Target / Payload | Rule | Enforcement |
|---|-------|-----|------------------|------|-------------|
| AW-1 | Alex writes/edits handoff | Alex | `.tad/active/handoffs/HANDOFF-*.md` | Required Evidence Manifest block exists in AC list referencing ≥2 expert review files + COMPLETION placeholder + gate2-verdict.tsv path. **Bootstrap**: if `.tad/state/secret.key` missing (first-run), LOG-ONLY advisory. | PreToolUse Write-family |
| AW-2 | Alex finalizes with sentinel | Alex | handoff containing `📨 Message from Alex` + box-drawing | Preceding same-session: expert-review files on disk + gate2-verdict.tsv PASS | PreToolUse Write-family |
| AW-3 | Cross-role edit | Either | Edit/MultiEdit on file authored by OTHER role (detected via transcript tail scan) | Deny unless OV-1 with `gate=cross-role-edit` | PreToolUse Write-family |
| BW-1 | Blake writes Message-from-Blake sentinel | Blake | any write containing `📨 Message from Blake` + box-drawing | Required: COMPLETION-*.md + gate3-verdict.tsv PASS + ≥2 Blake reviewer reports | PreToolUse Write-family |
| BW-2 | Blake writes COMPLETION | Blake | `COMPLETION-*.md` (active or spike `COMPLETION-REPORT.md`) | `^Overall: (PASS\|FAIL)$` anchored outside fence + ≥3 git-resolvable file refs | PreToolUse Write-family |
| BW-3 | Blake Bash write-path exfiltration | Blake | Bash containing `>`, `>>`, `tee`, `<<`, `ln`, `cp`, `mv`, `git mv`, `rsync`, `sed -i` into `.tad/evidence/` or `.tad/active/handoffs/` | Block — evidence via Bash bypasses Write interceptor | PreToolUse Bash |
| OV-1 | Override | User | UserPromptSubmit matching `^TAD_OVERRIDE: <gate> <reason>$` | Validate nonce (issue if new), append to plain JSONL log, grant one-shot unblock | UserPromptSubmit |
| OV-2 | Fake override attempt | LLM | any tool_input content containing `TAD_OVERRIDE:` | Reject — overrides only via UserPromptSubmit | PreToolUse Write-family + Bash |
| HP-1 | Protected path write | Either | `.claude/settings*.json`, `.tad/hooks/**`, `.tad/skills/**/SKILL.md`, `hardened-*.sh`, `~/.claude/settings.json`, `.tad/state/**` | Deny; requires OV-1 `gate=protected-path` | PreToolUse Write-family + Bash |
| HP-2 | Env injection | Either | content matches `TAD_SKIP_VALIDATION=`, `TAD_DISABLE_HOOKS=`, `CLAUDE_SETTINGS_PATH=`, `CLAUDE_CONFIG_DIR=`, `BASH_ENV=`, `LD_PRELOAD=`, `DYLD_INSERT_LIBRARIES=` | Deny | PreToolUse Write-family + Bash |
| PT-1 | Path traversal | Either | file_path contains `..` segments | Deny | PreToolUse Write-family |

**Gate enum**: `gate2 | gate3 | gate4 | protected-path | cross-role-edit | bootstrap-first-run | emergency`

### 1.1 Evidence Manifests

```yaml
# .tad/schemas/evidence-manifest.yaml
alex_handoff_ready:
  required:
    - pattern: ".tad/evidence/reviews/alex/${handoff_slug}/*.md"
      min_count: 2
      min_bytes: 500
    - pattern: ".tad/evidence/gates/${handoff_slug}/gate2-verdict.tsv"
      must_contain: "PASS"

blake_completion_ready:
  required:
    - pattern: ".tad/active/handoffs/COMPLETION-*-${handoff_slug}.md"
      anchor: "^Overall: (PASS|FAIL)$"
      anchor_outside_fence: true
    - pattern: ".tad/evidence/reviews/blake/${handoff_slug}/*.md"
      min_count: 2
      min_bytes: 500
    - pattern: ".tad/evidence/gates/${handoff_slug}/gate3-verdict.tsv"
      must_contain: "PASS"
```

**Manifest cap**: ≤5 required patterns per manifest (lean rule — Alex should not be allowed to balloon this list).

### 1.2 Gate Verdict Files

| File | Writer | Location |
|------|--------|----------|
| gate2-verdict.tsv | `/gate` skill after Alex step5 | `.tad/evidence/gates/<slug>/gate2-verdict.tsv` |
| gate3-verdict.tsv | Blake completion_protocol after Gate 3 v2 PASS | same |
| gate4-verdict.tsv | Alex acceptance_protocol step8 | same |

Schema (all gates):
```
gate\tverdict\tts\treviewer\tnotes
```
Plain TSV, append-only, no HMAC. Writer ensures `.tad/evidence/gates/<slug>/` exists before write.

### 1.3 Non-Handoff Alex Writes (out of scope)

Epic file updates, NEXT.md, PROJECT_CONTEXT.md, knowledge entries, git commits — NOT gated. No sentinel risk; gating creates chicken/egg on gate4-verdict.tsv.

---

## 2. Checker Architecture

### 2.1 Module Layout (Phase 3 targets)

```
.tad/hooks/
  quality-enforcement.sh              # main PreToolUse dispatcher
  userprompt-override.sh              # UserPromptSubmit for OV-1
  lib/
    common.sh                         # stdin JSON parse, logging (existing reuse)
    dep-guard.sh                      # Phase 1c existing — PATH pin + whitelist + hardcoded deny
    quality-checker.sh                # shared role+manifest verifier
    sentinel-detect.sh                # literal + casefold match on content (§3)
    path-guard.sh                     # protected-path + traversal (H-003 + H-005)
    content-scanner.sh                # env injection + Bash write-path (H-004 + H-008)
    evidence-validator.sh             # structure check (H-009) + --handoff-path flag (KG-001)
    override-verify.sh                # regex + nonce lookup (H-006 simplified)
.tad/state/            (PER-PROJECT, chmod 700 dir, gitignored)
  nonces.jsonl                       # plain append-only, chmod 600
  secret.key                         # chmod 600, used only for optional `/gate --sign` future
  override-log.jsonl                 # plain append-only, chmod 600 (no HMAC chain)
.tad/schemas/
  evidence-manifest.yaml
  sentinel-patterns.yaml
  protected-paths.yaml
```

**6 libs + 2 dispatchers = 8 shell scripts total**, down from v2's 10+.

### 2.2 Control Flow

```
PreToolUse event → quality-enforcement.sh
  ├─ source dep-guard.sh (Phase 1c, reused verbatim)
  ├─ source common.sh, parse stdin JSON
  ├─ derive handoff_slug via §2.4 algorithm
  ├─ derive role via transcript tail scan (§2.5)
  ├─ route by tool_name:
  │    Write-family     → sentinel-detect + path-guard + content-scanner + evidence-validator
  │    Bash             → content-scanner (Bash branch) + path-guard on redirect targets
  │    Task (subagent)  → sentinel-detect on .tool_input.prompt
  ├─ if AW-3 role mismatch → deny
  ├─ if sentinel + manifest satisfied → allow
  ├─ if OV-2 (TAD_OVERRIDE in tool content) → deny
  └─ else → allow (no gating concern)

UserPromptSubmit event → userprompt-override.sh
  ├─ match OV-1 regex
  ├─ sanitize reason (length + no \t\n + no reserved substrings)
  ├─ idempotent nonce lookup; allocate if new
  ├─ append to override-log.jsonl (plain JSONL, chmod 600)
  └─ exit 0
```

### 2.3 `check_write` Interface

```bash
check_write role manifest_id target_file content handoff_slug
  # role: alex | blake | system
  # manifest_id: alex_handoff_ready | blake_completion_ready
  # Returns 0 (allow) or 1 (deny with reason on stderr → hook emits deny JSON)
```

### 2.4 handoff_slug Derivation

```
1. .tad/active/handoffs/(HANDOFF|COMPLETION)-\d{8}-(<slug>).md           → slug = $2
2. .tad/evidence/reviews/(alex|blake)/<slug>/.*                          → slug = $2
3. .tad/evidence/spikes/SPIKE-\d{8}-(<slug>)/.*                          → slug = $1
4. .tad/evidence/gates/(<slug>)/gate\d-verdict.tsv                       → slug = $1
5. else                                                                  → slug = null

VALIDATION: if slug != null and no HANDOFF-*-${slug}.md in active/ or archive/ → DENY "slug typo"
```

### 2.5 Role Derivation

Read last 100 lines of transcript_path (JSONL). Most recent `Skill` tool_use matching `tad-alex|alex` → role=alex; `tad-blake|blake` → role=blake; else role=system. System role writing HANDOFF/COMPLETION denied with "role indeterminate".

---

## 3. Sentinel Detection (simplified from v2 §3.1)

**Canonicalization pipeline (2 steps, not 4)**:
```
1. Strip invisible formatters: U+200B..U+200F, U+202A..U+202E, U+2060..U+2069, U+FEFF
2. Unicode casefold: perl -CSD -MUnicode::CaseFold; Unicode::CaseFold::fc($s, locale=>'und')
```

No TR39 confusables mapping. No box-drawing variant normalization.

**sentinel-patterns.yaml**:
```yaml
blake_completion_sentinel:
  primary:
    requires_all:
      - literal: "📨 message from blake"        # post-casefold
      - box_drawing_regex: "[\\x{2500}]{16,}"   # raw U+2500 only
  secondary:
    path_in:
      - ".tad/active/handoffs/HANDOFF-*.md"
      - ".tad/active/handoffs/COMPLETION-*.md"

alex_handoff_sentinel:
  primary:
    requires_all:
      - literal: "📨 message from alex"
      - box_drawing_regex: "[\\x{2500}]{16,}"
  secondary:
    path_in:
      - ".tad/active/handoffs/HANDOFF-*.md"

# Precedence: primary → BLOCK. secondary alone → LOG-ONLY. substring-only in prose → ALLOW.

# Dogfood / docs allowlist:
allowlist_paths:
  - ".tad/evidence/designs/**"
  - ".tad/evidence/spikes/**/SPIKE-REPORT.md"
  - ".tad/project-knowledge/**"
# Inside allowlist, sentinel only inside ``` fences → LOG-ONLY.
```

**Regression fixtures (10 total, down from v2's 30)**:
1. `fixture-legit-handoff-with-sentinel.md` → BLOCK without evidence, ALLOW with evidence
2. `fixture-docs-mention-blake-by-name.md` → ALLOW (positive control)
3. `fixture-edit-add-sentinel-after-skeleton.md` → BLOCK (Edit family)
4. `fixture-multiedit-split-sentinel.md` → BLOCK (edits[] concat)
5. `fixture-cross-role-blake-edits-handoff.md` → BLOCK (AW-3)
6. `fixture-eszett-meßage.md` → BLOCK (casefold)
7. `fixture-zwj-interleaved-sentinel.md` → BLOCK (ZW strip)
8. `fixture-embedded-table-with-u2500.md` → ALLOW (no Message-from sentinel)
9. `fixture-design-doc-fenced-sentinel.md` → LOG-ONLY (allowlist carve-out)
10. `fixture-bash-cp-to-evidence.md` → BLOCK (BW-3 cp pattern)

---

## 4. H-001 .. H-009 Integration (Lean)

| # | Capability | Phase 3 module | Notes |
|---|-----------|----------------|-------|
| H-001 | Confusable strip + space | `sentinel-detect.sh` | Simplified per §3 — 2-step pipeline only |
| H-002 | Multi-tool coverage (edits[], Task.prompt) | `sentinel-detect.sh` | Concat edits[].new_string before match |
| H-003 | Protected-path denylist | `path-guard.sh` + `protected-paths.yaml` | Load once at hook start |
| H-004 | Env injection detection | `content-scanner.sh` | Shared by Write content + Bash command |
| H-005 | Path traversal rejection | `path-guard.sh` | Reject any `..` segment |
| H-006 | Override regex + sanitize | `override-verify.sh` | Simplified reason rule: ≥20 non-whitespace chars, no `\t\n`, no `prev_hmac=`/`hmac=`/`ts=`/`source=`/`FAKE_ROW` |
| H-007 | Override log | `override-verify.sh` | **Plain append-only JSONL, no HMAC chain**. chmod 600. No `--re-verify` |
| H-008 | Bash write-path detection | `content-scanner.sh` (Bash branch) | Pattern list includes `>`, `>>`, `tee`, `<<`, `ln`, `cp`, `mv`, `git mv`, `rsync`, `sed -i` |
| H-009 | Evidence structure | `evidence-validator.sh` | KG-001 fix: `--handoff-path` flag required. **Freshness check: mtime + existence** (no SHA content-binding) |

---

## 5. SKILL Hardening (byte-exact inserts kept)

Same as v2 §4 — these have high value and no over-engineering:

- **Alex SKILL.md**: insert `anti_rationalization_registry` YAML block (5 patterns AR-001..AR-005 from v2 §4.1.1, byte-exact)
- **Blake SKILL.md**: insert `honest_partial_protocol` YAML block (v2 §4.2.1, byte-exact)
- **Both**: cross-cutting rules (no agent-written `TAD_OVERRIDE:`, sentinel prose escape via fences)
- **Alex**: `handoff_creation_protocol.step0_5` adds **AC Conflict Matrix self-check** (from Phase 1c knowledge)
- **Alex**: `handoff_creation_protocol.step1` manifest-line requirement
- **Alex**: `acceptance_protocol.step7` raw-TSV recompute requirement (Gate 4 integrity)
- **Blake**: `completion_protocol.step3c` evidence manifest ls-check
- **Blake**: `completion_protocol.step8_generate_message` raw metric quote
- **Blake**: `ralph_loop.layer2` express-review-mandatory strengthening

**No SKILL-only enforcement** (text alone is known-broken). All SKILL additions backed by corresponding hook checks.

---

## 6. Override Authentication (Simplified)

```
Line-start strict: ^TAD_OVERRIDE: <gate> <reason>$
  - gate ∈ §1 gate enum
  - reason rules:
    * Length ≥20 non-whitespace chars (bytes OK for simplicity; Chinese/English both work)
    * No \t, \n literally
    * No forbidden substrings: prev_hmac=, hmac=, ts=, source=, FAKE_ROW
  - No grapheme counting, no Unicode category whitelist, no Braille-blank specific check
```

### 6.1 Nonce (simplified)

`.tad/state/nonces.jsonl` — plain JSONL, chmod 600:
```json
{"nonce": "<openssl rand -base32 20>", "issued_ts": "<ISO>", "gate": "gate3", "session_id": "<id>", "consumed_ts": null}
```

Rules:
- Scope: same session_id + same gate, TTL 1h, single-use
- Idempotent allocation: if unconsumed + unexpired match exists, return existing
- Subagent spawn gets new session_id → parent nonce not consumable by subagent (intentional, documented)

### 6.2 Override Log (plain, no HMAC chain)

`.tad/state/override-log.jsonl` — plain append-only JSONL, chmod 600:
```json
{"ts": "<ISO>", "gate": "...", "reason": "<sanitized>", "nonce": "<consumed>", "user_session": "<id>"}
```

Audit = `cat`. No chain-sign, no `--re-verify`, no external witness.

---

## 7. Known Gaps

### 7.1 KG-001 Staleness (IN Phase 3)

`lib/evidence-validator.sh` requires `--handoff-path` arg:
- Validates handoff file exists (active/ or archive/)
- Compares mtime: if evidence mtime < handoff mtime → DENY "stale evidence"
- No SHA content-binding, no git-timestamp fallback — mtime is good enough for LLM-scoped threat model

Cost: ~2h.

### 7.2 KG-002 TOCTOU (KNOWLEDGE ENTRY ONLY)

Add to `.tad/project-knowledge/security.md`:

> TAD quality-enforcement PreToolUse hook is vulnerable to TOCTOU symlink swap during concurrent Claude Code sessions on the same project. Mitigation: single-session policy per project, procedural. Structural fix awaits Claude Code core realpath-on-write hook primitive.

No active detection in Phase 3. Not worth the complexity for the threat model.

---

## 8. Performance & CI

From Phase 1c prerequisites:

1. **Relax AC12 byte-preservation** — Phase 3 hooks can differ from Phase 1b hardened (add internal timeout, switch to single-awk, etc.)
2. **Dedicated CI runner for perf gate** — `ubuntu-latest-ci-dedicated` or equivalent; no concurrent `claude`; load avg <1.0; N=100 baseline; warm-up discarded
3. **Internal self-timeout** — `read -t 2` in every stdin-reading hook; hardcoded deny JSON + exit 0 on timeout
4. **Size cap** — `head -c 1048576` (1MB) before `jq` parse; deny `payload_too_large` if exceeded

Targets:
- pretool-interceptor, override-detector, override-verify, bash-watcher: p95 < 100ms
- evidence-validator: p95 < 100ms via single-awk optimization (no archive manifest cache — Phase 5)

If evidence-validator doesn't hit <100ms via single-awk alone, document gap in Phase 3 completion report; Phase 5 adds archive manifest cache.

---

## 9. Bootstrap & Gitignore

First-run behavior in `quality-enforcement.sh`:

1. If `.tad/state/secret.key` missing:
   - Generate via `openssl rand -base64 32`, chmod 600
   - Write warning to stderr
   - Append `.tad/state/` to `.gitignore` (idempotent check)
2. Scan `git log --all -- .tad/state/secret.key`:
   - If any commit found → ERROR "secret.key was historically committed, rotate + investigate"
3. AW-1 downgrades to LOG-ONLY during bootstrap (secret.key absent = first-run marker)
4. After first gate2-verdict.tsv PASS, bootstrap exception clears

---

## 10. Phase 3 Scope Contract

### 10.1 In Scope (≤15 ACs target)

1. Create 8 shell scripts per §2.1 (hooks + libs)
2. Create 3 YAML schemas per §2.1 (evidence-manifest, sentinel-patterns, protected-paths)
3. Update `.claude/settings.json` with 2 hook registrations
4. Apply SKILL hardening per §5 (byte-exact inserts from v2 §4.1.1 + §4.2.1)
5. Create `.tad/state/` scaffolding + gitignore update + historical secret scan
6. KG-001 `--handoff-path` flag implementation
7. Gate verdict writer integration in `/gate`, completion_protocol, acceptance_protocol
8. CI workflow for perf gate (§8)
9. Bootstrap flow (§9)
10. Add 10 regression fixtures (§3)
11. Document KG-002 knowledge entry (§7.2)
12. Dogfood: Phase 3 handoff passes bootstrap AW-1 advisory; subsequent writes armed

### 10.2 Out of Scope (explicitly deferred)

- MCP tool coverage (no current surface)
- External HMAC witnesses (v2 §5.3)
- TR39 confusables mapping (v2 §3.1 pipeline beyond 2 steps)
- Grapheme-based override reason (v2 §5.1)
- Archive manifest cache (Phase 5)
- Active concurrent-session detection (v2 §6.2)
- Content-hash evidence binding (v2 §6.1 Expected Evidence SHA)
- HMAC chain + `--re-verify` CLI
- Semantic paraphrase sentinel detection

### 10.3 Phase 3 Prerequisites (inherited from 1c)

1. Relax AC12 byte-preservation (now covered — Phase 3 is production code, not delta spike)
2. CI runner provisioning
3. `read -t 2` + 1MB cap in every hot-path hook

---

## 11. Gate 2 Checklist (v3-LEAN)

- [x] 8 events matrix (down from v2's 13) — all essential enforcement preserved
- [x] Module layout ≤10 scripts (v2 had 10+)
- [x] Simplified sentinel pipeline (2 steps, not 4)
- [x] Simplified override reason rule (≥20 non-whitespace, not grapheme/category)
- [x] Plain append-only logs (no HMAC chain, no external witnesses)
- [x] KG-001 mtime-based (not SHA-binding)
- [x] KG-002 knowledge-only (not active detection)
- [x] SKILL byte-exact inserts preserved (high-leverage, kept from v2)
- [x] Bootstrap + gitignore rule (real issue, kept)
- [x] Phase 3 scope ≤15 ACs

**Verdict**: LEAN design ready. Phase 3 handoff can reference this file as its spec.

---

## 12. Relationship to v2

`DESIGN-20260414-phase2-enforcement-matrix.md` (v2) remains archived as the "ideal" spec for future hardening if/when TAD expands to:
- Multi-tenant / shared-filesystem deployments
- Adversarial threat models beyond LLM-rationalization
- MCP tool ecosystem with .tad/** write surface

Items cut from v2 are NOT design errors — they are correctly scoped defenses for different threat models. v3-LEAN = current TAD's actual threat surface. v2 = reference for extension.

**Lessons logged** (to add to architecture.md in Phase 3 accept):
- Expert reviewers default to maximally-hardened designs; architect must threat-model the actual environment before accepting all P0 fixes
- "Lean revision" is a valid design artifact after expert review; not every P0 must ship — threat-model-match matters
- v2 → v3 delta demonstrates Epic principle: **mechanism > text, but calibrated to threat model**
