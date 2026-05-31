---
handoff: HANDOFF-20260531-tad-lean-trustworthy-phase2.md
epic: EPIC-20260531-tad-lean-trustworthy.md
phase: 2/5
date: 2026-05-31
gate3_verdict: pass
---

# COMPLETION — Phase 2: Pack registry desync fix + drift-check

Blake (Agent B). All 4 steps implemented per handoff §6. All ACs (AC2.1–AC2.6) PASS with raw output below. No reviewer sub-agents invoked (per LIMITS). No blockers.

---

## Files Changed

**Created:**
- `.tad/capability-packs/ai-voice-production/CAPABILITY.md` — frontmatter (name/description/keywords verbatim from SKILL.md, type: reference-based, single-line keyword flow form) + col-0 `**CONSUMES**:`/`**PRODUCES**:` + Context Detection / Quick Rule Index pointers resolving under copied `references/`.
- `.tad/capability-packs/ai-voice-production/install.sh` — mirrors `video-creation/install.sh`; `PACK_NAME="ai-voice-production"`; prerequisites swapped to Python 3.10+ / FFmpeg / pip|uv + per-project venv TTS note; same `install_claude_code` copy mechanics + codex/cursor/gemini Phase-2 stubs. `chmod +x`.
- `.tad/capability-packs/ai-voice-production/references/*.md` — `cp -r` of the 7 reference files from `.claude/skills/ai-voice-production/references/`.
- `.tad/hooks/lib/pack-registry-driftcheck.sh` — advisory bidirectional drift-check; SAFETY/forbidden header comment; `shopt -s nullglob`; Set A (registry names), Set B (positive `type:`-frontmatter probe, NO allowlist), Set C (source packs gated on CAPABILITY.md); reports (a)(b)(c) exit-affecting + (d) WARN-only; `comm` over `LC_ALL=C sort`; no command-form `set -e`. `chmod +x`.

**Modified:**
- `.tad/capability-packs/academic-research/CAPABILITY.md` — Step 1b blockquote→col-0 conversion (`> **CONSUMES**:`→`**CONSUMES**:`, same for PRODUCES).
- `.tad/capability-packs/ml-training/CAPABILITY.md` — Step 1b blockquote→col-0 conversion.
- `.tad/capability-packs/video-creation/CAPABILITY.md` — Step 1b blockquote→col-0 conversion.
- `.tad/capability-packs/pack-registry.yaml` — regenerated via `scan-packs.sh` (14→16 packs; last_scanned→2026-05-31; synced_from_version 2.15.1→2.19.1).
- `.claude/skills/release-runbook/SKILL.md` — added 1 advisory drift-check item to Phase 1 pre-flight checklist (line 58).

---

## AC Results

| # | Acceptance Criterion | Result |
|---|---------------------|--------|
| AC2.1 | ai-voice-production indexed with non-empty keywords + type reference-based | PASS |
| AC2.2 | ml-training PRESENT; no true-phantom registry entry (drift (c) empty) | PASS |
| AC2.3 | drift-check exit 0 clean / exit 1 + name on inject / exit 0 after sed-revert; registry still 16 | PASS |
| AC2.4 | last_scanned == 2026-05-31; SAFETY/forbidden marker present; no command-form set -e / no blocking path | PASS |
| AC2.5a | scan-packs determinism — two post-16 scans diff empty | PASS |
| AC2.5b | committed→post-scan line-SET delta = enumerated only (2 adds + reorder + version bump + date); no degrade to "Not specified" | PASS |
| AC2.6 | no consumes/produces regression — committed "Not specified" count 2 → post-scan 1 (improved) | PASS |

---

## Raw Layer 1 Output

### Step 1 — ai-voice-production source dir + install --check

```
$ ls .tad/capability-packs/ai-voice-production/
CAPABILITY.md  install.sh  references/   (references: 7 files)

$ bash .tad/capability-packs/ai-voice-production/install.sh --check
=== Tool Prerequisites Check ===
✅  Python: 3.14.4
✅  FFmpeg: 8.0
✅  uv: uv 0.8.22 (Homebrew 2025-09-23)
ℹ️   TTS engines (...): install per-project in a venv
✅ All prerequisites satisfied.
check-exit=0

$ grep -n '^\*\*CONSUMES\*\*:\|^\*\*PRODUCES\*\*:' .tad/capability-packs/ai-voice-production/CAPABILITY.md
13:**CONSUMES**: Text manuscripts, reference audio samples (optional), brand voice guidelines (optional).
14:**PRODUCES**: Production-ready audio files (WAV 48kHz preferred, 44.1kHz for ACX). Naming: `{project}/{chapter|segment}-{NNN}.wav`.
```

### Step 1b — blockquote→col-0 conversion + missing-marker loop

```
# (loop over all .tad/capability-packs/*/ for missing col-0 CONSUMES marker)
=== missing-marker loop (expect zero output) ===
=== loop done ===     # zero "MISSING CONSUMES marker" lines

# converted lines:
--academic-research--  **CONSUMES**: Research question + optional domain constraints ...
--ml-training--        **CONSUMES**: Training data (JSONL/ShareGPT/audio+transcript pairs) ...
--video-creation--     **CONSUMES**: Brand/design artifacts (optional). **PRODUCES**: ...
```
Note: video-creation uses the single-line blockquote form (`> **CONSUMES**: ... **PRODUCES**: ...`); after conversion CONSUMES is col-0 (now a real registry value, an improvement) while PRODUCES stays mid-line → indexes "Not specified". It was already "Not specified" in the committed registry → no regression.

### Step 2 — scan-packs re-run

```
$ bash .tad/scripts/scan-packs.sh
scan-packs.sh: scanned 16 packs → .../pack-registry.yaml

$ grep -c '^  - name:' .tad/capability-packs/pack-registry.yaml
16

$ grep last_scanned .tad/capability-packs/pack-registry.yaml
last_scanned: "2026-05-31"

$ grep -A6 'name: "ai-voice-production"' .tad/capability-packs/pack-registry.yaml
  - name: "ai-voice-production"
    description: "AI voice production judgment for coding agents — ..."
    path: ".tad/capability-packs/ai-voice-production/"
    consumes: "Text manuscripts, reference audio samples (optional), brand voice guidelines (optional)."
    produces: "Production-ready audio files (WAV 48kHz preferred, 44.1kHz for ACX). Naming: `{project}/{chapter|segment}-{NNN}.wav`."
    keywords: ["TTS", "text-to-speech", "语音合成", ... 21 items ...]
    type: "reference-based"
```

### AC2.6 — no consumes/produces regression

```
$ git show HEAD:.tad/capability-packs/pack-registry.yaml | grep -E 'consumes:|produces:' | grep -c 'Not specified'
2          # committed baseline
$ grep -E 'consumes:|produces:' .tad/capability-packs/pack-registry.yaml | grep -c 'Not specified'
1          # post-scan — DECREASED (no degradation; AC2.6 PASS)
```

### AC2.5b — committed→post-scan line-SET diff (comm -3, LC_ALL=C sort)

Delta is exactly the enumerated expected set:
- +2 new packs: ai-voice-production, ml-training (name/description/path/consumes/produces/keywords/type lines).
- academic-research: description updated (current SKILL.md text) + consumes/produces gained trailing period & Reflexion clause — still real values, NOT "Not specified".
- video-creation: committed consumes "Not specified" → now real value (improvement).
- `synced_from_version` 2.15.1→2.19.1; `last_scanned` 2026-05-15→2026-05-31.
No line changes an existing pack's consumes/produces TO "Not specified".

### AC2.5a — determinism (two consecutive post-16 scans)

```
$ bash scan-packs.sh; cp registry /tmp/r1.yaml; bash scan-packs.sh; diff /tmp/r1.yaml registry
DIFF_EMPTY     # identical (same UTC day)
```

### AC2.3 — drift-check exit-code demo

```
$ bash .tad/hooks/lib/pack-registry-driftcheck.sh; echo exit=$?
... Set A=16  Set B=13  Set C=16
(a) source pack NOT in registry: (none)
(b) installed pack skill NOT in registry: (none)
(c) registry entry w/ neither src nor skill (true phantom): (none)
(d) WARN: source-only ml-training / product-thinking / research-methodology (advisory)
RESULT: clean
exit=0

$ printf '  - name: "zzz-fake-pack"\n' >> registry ; bash driftcheck.sh; echo exit=$?
(c) ... true phantom:
    zzz-fake-pack
RESULT: DRIFT DETECTED (advisory) — NOT a session/release blocker.
exit=1

$ sed -i '' '/name: "zzz-fake-pack"/d' registry    # NOT git checkout
$ bash driftcheck.sh; echo exit=$?
exit=0
$ grep -c '^  - name:' registry
16     # FR2 preserved
```

### AC2.4 — advisory contract markers

```
$ grep last_scanned registry
last_scanned: "2026-05-31"

$ grep -n 'forbidden\|MUST NOT' .tad/hooks/lib/pack-registry-driftcheck.sh
11:# ⚠️ SAFETY / forbidden (architecture.md 2026-04-15 ...)
13:#    - MUST NOT be registered as a blocking hook ...
14:#    - MUST NOT be added to settings.json `permissions.deny`.
15:#    - MUST NOT fail-closed or abort a session (no `set -e`); advisory exit code ONLY.

$ grep -cE '^[[:space:]]*set -e' .tad/hooks/lib/pack-registry-driftcheck.sh
0      # zero command-form set -e (only the comment mention on line 15)
```

### Step 4 — release-runbook wiring

```
$ grep -n 'pack-registry-driftcheck' .claude/skills/release-runbook/SKILL.md
58:- [ ] Pack registry drift-check run (advisory): `bash .tad/hooks/lib/pack-registry-driftcheck.sh` — exit 1 = registry/pack desync to review ..., NOT a release blocker.
```

---

## Edge Cases Verified (handoff §8.3)

- Injected fake registry name → (c) non-empty → exit 1 + name printed; sed-revert → exit 0; registry intact at 16. (AC2.3)
- ml-training (source-only) → IS in registry post-scan → no (a)/(b)/(c) flag; only (d) advisory WARN. (AC2.2)
- ai-voice-production now has BOTH CAPABILITY.md source dir and installed skill → no (b) flag.
- Empty-glob safety: `shopt -s nullglob` set near top so unpopulated `.claude/skills` / `.tad/capability-packs` yields empty sets (no literal `*` name, no crash). Set B uses `[ -f "$d/SKILL.md" ]` gate; Set C uses `[ -f "$d/CAPABILITY.md" ]` gate. `.claude/skills/_archived/`-style dirs without SKILL.md are gated out and lack `type:` frontmatter → never flagged.

---

## Sub-Agent Usage

| Sub-Agent | Invoked | Notes |
|-----------|---------|-------|
| test-runner | No | LIMITS forbade reviewer sub-agents; all AC commands run directly by Blake, raw output captured above. |
| bug-hunter | No | drift-check set logic behaved correctly on first run; no debugging needed. |

## Escalations

None. No blockers encountered. All 4 steps and all ACs completed within retry budget (no retries needed).
