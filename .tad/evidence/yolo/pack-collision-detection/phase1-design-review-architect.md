# Phase 1 Design Review — Pack Collision Detection (backend-architect, blue-team, PRE-impl)

**Reviewer role**: backend-architect (design/architecture quality gate)
**Artifact**: HANDOFF-20260531-pack-collision-detection-phase1.md (+ grounding + Epic)
**Date**: 2026-05-31
**Verdict**: **CONDITIONAL PASS** — P0 count: **1**, P1: 4, P2: 3
**Mode**: evidence-based; every claim below verified against live files.

---

## Verification performed (ground truth, not paper)

| Check | Result |
|-------|--------|
| Inter ban source | ✅ `web-ui-design/{CAPABILITY.md,SKILL.md}:93` both present, byte-identical line |
| Inter endorse source | ✅ `web-frontend/references/performance.md:215` (both trees), also `:207` @import, `CONVENTIONS.md:195` |
| Contrast APCA | ✅ `web-ui-design SKILL/CAPABILITY:454,476` |
| Contrast WCAG | ✅ `web-frontend/references/accessibility.md:45`; `web-testing/references/accessibility-testing-rules.md:12` |
| Pyramid frontend | ✅ `web-frontend/references/testing.md:15,17,19` (~60% / ~10% / >20% cut) |
| Pyramid testing | ✅ `web-testing/references/test-strategy-rules.md:25,27,31` (70% / 10% / "More E2E" for UI-heavy) |
| Keyword pre-filter for 3 pairs | ✅ ui×frontend share `frontend,accessibility`; frontend×testing share `performance,accessibility,WCAG`; ui×testing share `accessibility` |
| settings.json AC7 baseline | ✅ exists, `grep -c scan-` == 0 |
| guides/ + fixtures/ dirs | ✅ exist |

The 3 documented contradictions are **real and live**. The grounding file is honest. This is genuinely closing the audit gap, not validation theater at the design level.

---

## P0 (blocking)

### P0-1 — Path-namespace ambiguity: the scanner reads `.tad/capability-packs/`, but the schema/grounding cite `.claude/skills/`. They are TWO INDEPENDENT COPIES, not one source.

**Evidence:**
- scan-packs.sh (the mandated mirror) enumerates `for cap_file in "$PACKS_DIR"/*/CAPABILITY.md` where `PACKS_DIR="$TAD_DIR/capability-packs"` (scan-packs.sh:46, :18). So scan-collisions.sh, mirroring it, scans the **`.tad/capability-packs/`** tree.
- But every `ref:` in the §4.3 `pack-collisions.yaml` schema and in the grounding fixtures points to **`.claude/skills/...`** (e.g. `.claude/skills/web-ui-design/SKILL.md:93`, `.claude/skills/web-frontend/references/performance.md:215`).
- `ls -la` confirms the two trees are **separate physical files** (not symlinks): `.claude/skills/web-frontend/references/performance.md` and `.tad/capability-packs/web-frontend/references/performance.md` are distinct inodes with identical content *today*.
- The pack-name container files also differ: `.tad/capability-packs/web-ui-design/` has **CAPABILITY.md (no SKILL.md)**; `.claude/skills/web-ui-design/` has **SKILL.md (no CAPABILITY.md)**. The Inter ban currently lives at line 93 in BOTH, but they are maintained independently and WILL drift.

**Why this is P0, not P1:** The handoff's AC2/AC3/AC6 acceptance is "hand-re-derive each collision's two file:line against the **live pack files**." But the handoff never decides WHICH tree is canonical. Concretely:
1. The scanner (mirroring scan-packs.sh) will emit candidate file:line refs under `.tad/capability-packs/...`.
2. The schema `pack-collisions.yaml` records refs under `.claude/skills/...`.
3. A reviewer hand-re-deriving the schema ref opens a *different physical file* than the one the scanner read. Today the line numbers coincide by luck (byte-identical copies). The moment one tree is edited (and `.claude/skills/` is the one Claude Code actually loads at runtime — it is the consumer-facing copy), the scanner's `.tad/capability-packs/` line and the schema's `.claude/skills/` line **diverge silently**, and the "hand-re-derive" acceptance becomes non-reproducible.

Worse for the downstream purpose: P2 surfaces collisions to Alex step4_5 / Blake 1_5a, which load packs from **`.claude/skills/`**. If the detector scans `.tad/capability-packs/` (the registry/distribution copy), it can report a collision that does not exist in the runtime-loaded copy, or miss one that does.

**Required resolution (pick one, document in the handoff before build):**
- (A) **Make `.claude/skills/` the scan target** for collision detection (since that is the runtime-loaded tree the surfacing consumers read), overriding the scan-packs.sh `PACKS_DIR` default. Then schema refs are consistent and acceptance is reproducible. This breaks the "mirror scan-packs.sh verbatim" assumption for `PACKS_DIR` — that is fine; the mirror is about *conventions* (set -e, arg-parse-before-OUTPUT, anchored awk), not the literal directory.
- (B) Keep scanning `.tad/capability-packs/` AND rewrite every §4.3/grounding ref to `.tad/capability-packs/...` so the schema matches what the scanner actually reads. Then add an explicit NOTE that P2 consumers must map back to `.claude/skills/` (or that the two trees are kept in sync by `*sync`).
- Either way, add a one-line invariant to the guide: "collision refs are recorded against {chosen tree}; the other tree is a copy kept in sync by `*sync`."

This is the single must-fix: without it, the load-bearing "hand-re-derive file:line" contract is anchored to an undefined file, and the count≠signal discipline the whole Epic is built on cannot be exercised reproducibly.

---

## P1 (should fix before build)

### P1-1 — Signature scan file-enumeration is unspecified, yet the contradictions live in body + `references/*.md`, which scan-packs.sh never reads.

scan-packs.sh only reads **CAPABILITY.md frontmatter** (`extract_frontmatter_field`, `extract_keywords`). The 3 contradictions live in: CAPABILITY.md/SKILL.md **body** (Inter ban :93, APCA :454) and **`references/performance.md`, `references/accessibility.md`, `references/testing.md`, `references/test-strategy-rules.md`**. The handoff (FR2, step 3) says "在 pack_a 文件集跑 A 侧 grep" but **never defines "pack_a 文件集"** (the file set) or how it is enumerated (`find <pack>/ -name '*.md'`? include `scripts/`? exclude `CHANGELOG.md`/`LICENSE`?). This is the core mechanism of the grep-seed half and it is hand-waved. Mirroring scan-packs.sh gives Blake **no** pattern for multi-file body scanning — scan-packs.sh is frontmatter-only. Specify: the per-pack file set (recommend `find "$pack_dir" -name '*.md'` minus CHANGELOG/LICENSE/README), and that signatures grep that set with `grep -nE`.

### P1-2 — The LLM-CONFIRM "defense" against grep-theater is a guide doc with zero enforcement; the architecture's central claim (NFR3) rests on it.

NFR3 + §4.1 claim the grep/LLM split "keeps determinism AND false-positive defense; a pure-grep scanner would be validation theater." But in P1, the LLM-confirm pass is **only a numbered procedure in a markdown guide** (§4.2C). There is no checklist artifact, no gate, no per-candidate drop-rationale schema field in `candidates.yaml`, nothing that forces the confirming agent to actually open both refs. Given architecture.md 2026-05-30 ("ad-hoc audit tools are themselves validation theater") and 2026-05-15 ("structural checks prove files exist, not behavior"), a doc-only confirm step is exactly the soft self-check that prior lessons say agents skip under pressure. **Recommend**: add a required `confirmed_by` + `drop_rationale` field to the candidate→confirmed flow, and a worked false-positive example in the guide (the handoff mentions a "co-mention drop" example in §8.3 — make it MANDATORY content, not optional). This converts the defense from prose to a fillable contract.

### P1-3 — Bare-token signatures will over-match; determinism of the grep-seed is only as good as curation the handoff explicitly defers.

Verified: a bare `Inter` regex matches `INP (Interaction to Next Paint)` (performance.md:16), `Interaction`, `Internal`, etc. The handoff's example B-side regex (`Inter.*next/font|family=Inter`) is correctly anchored, but the handoff labels all regex "illustrative — Blake curates exact regex," pushing the entire false-positive surface onto Blake with no acceptance check that the seed set does NOT over-fire. **Recommend** an explicit NFR/AC: each seed signature must be validated to match ONLY the intended contradiction line(s) in the target pack (`grep -nE 'sig' <files>` returns the expected line, no extras) — i.e., dry-run each signature and record the matched lines in the candidates evidence. This is the "spot-verify every flagged item" discipline (architecture.md 2026-05-30) applied at the signature level, not just the candidate level.

### P1-4 — Category list is not exhaustive for 16 packs; "uncategorizable side" has no defined behavior (your focus-area 2a).

The 5-category ladder (security/correctness/a11y/performance/style) does NOT cover directive classes that exist live in the pack set: **licensing/legal** and **cost/economic** directives are present in `ai-voice-production` (license + cost reference files) and `ml-training` (cloud-GPU cost, GPU-hours). A future collision like "pack A: use proprietary TTS (best quality) vs pack B: only CC0/Apache voices (licensing safety)" has no category slot → the precedence engine cannot resolve OR escalate it deterministically. For the 3 P1 fixtures this never fires, so it is P1 not P0, but the handoff should (a) state the list is **closed for P1, extensible in P2**, and (b) define the **fallback for an uncategorizable side**: it MUST escalate (never silently auto-resolve), and the guide must say so. Right now an out-of-list category is undefined behavior in a precedence engine whose whole value proposition is "no silent pick."

---

## P2 (minor / note)

### P2-1 — False-pair safety (your focus 2b) is handled but not stated as an invariant.
If pack_a's matched directive is topic X and pack_b's is a different topic entirely, the design relies on (i) the keyword pre-filter and (ii) the per-topic paired signatures (A-side AND B-side of the SAME topic must both hit) and (iii) LLM-confirm. That is structurally sound — a candidate only emits when BOTH sides of ONE topic signature match. But the guide should state explicitly: "a candidate requires both opposing signatures of the SAME topic to match; cross-topic co-occurrence never emits a candidate." This makes the false-pair defense auditable rather than emergent.

### P2-2 — Inter resolution (your focus 3) is the RIGHT call, but the log line under-specifies the residual risk.
performance(4)>style(5) → web-frontend wins is correct *for the documented case*, because web-ui-design bans Inter **as PRIMARY TYPEFACE** while web-frontend uses it **for font-LOADING mechanics** — these are not actually the same claim, so "performance wins" does not violate the style rule (the ban is about primary type choice, not about whether `next/font` may load a font). The precedence engine gets the right answer almost by accident, though: it resolves on category numbers, not on the semantic distinction. The mitigation ("visible log lets a human verify Inter isn't the primary typeface") is adequate ONLY if the log line carries enough to make that check — see P2-3. **Recommendation**: the surfacing one-liner for THIS class should hint the residual ("⚙️ resolved … — verify loser's constraint isn't independently violated"), or the guide should flag Inter as the canonical "auto-resolve but human-spot-check" example. Precedence COULD mis-resolve a case where the ban should win (e.g., if a pack endorsed Inter explicitly as primary display type under a "performance" framing) — the log is the only thing standing between that and a silent wrong answer, so the log content is load-bearing.

### P2-3 — Schema VALUE-field propagation (your focus 4) is correctly required but the candidates→confirmed carry is asymmetric.
Good: §4.3 + MQ3 explicitly require carrying `quote` + `file:line` (not just topic/key) per architecture.md 2026-05-31 "propagate VALUE fields." The schema rows DO carry `quote`, `ref`, `category` per side, `winner/loser/rule/logged` — sufficient for P2 consumers to render both one-liner formats. **One gap**: the surfacing one-liner formats (§4.5) use `{rule}` and `{topic}` but NOT the quotes — so the auto-resolve one-liner (`⚙️ resolved: web-frontend over web-ui-design (performance>style)`) does NOT surface the loser's actual quote, which is exactly the "human spot-check Inter isn't primary" info P2-2 needs. The data is in the YAML; the one-liner just doesn't expose it. Acceptable for a one-liner, but the guide should note "full quotes available in pack-collisions.yaml for the human follow-up the log invites."

---

## Focus-area 5 — Non-collision claim vs lean-trustworthy P4/P5: CONFIRMED conflict-free.
- P1 creates only new files (scan-collisions.sh, collision-signatures.txt, pack-collisions.yaml, guide, fixtures). Verified none exist yet.
- `pack-registry.yaml` is read-only here; P5's `behaviorally_verified` write targets that file → no overlap (P1 writes a SEPARATE `pack-collisions.yaml`).
- P4's `verify-ac-commands.sh` is a different new file. No alex/SKILL.md or blake/SKILL.md edits in P1 (those are P2, correctly deferred).
- **Verdict: the concurrency claim holds.** One nuance: P1 emits `pack-collisions.candidates.yaml` and `pack-collisions.yaml` *into* `.tad/capability-packs/` — the same dir P5 writes `pack-registry.yaml` in. Different files, so no write-conflict, but worth a one-line note that the new YAMLs must NOT be picked up by `scan-packs.sh`'s `*/CAPABILITY.md` glob (they won't — glob is `*/CAPABILITY.md`, these are top-level `.yaml` — verified, fine).

---

## Summary

The design is **sound and honest** — the contradictions are real, the hybrid split is the right anti-theater architecture, the precedence semantics are coherent, and the concurrency isolation holds. The one blocking issue is **P0-1: the scanner and the schema point at two different physical pack trees** (`.tad/capability-packs/` vs `.claude/skills/`), which breaks the load-bearing "hand-re-derive file:line" acceptance the entire Epic is built on. Fix the canonical-tree decision before build; the four P1s (file enumeration, confirm-step enforcement, signature over-match, category exhaustiveness) should be resolved in the handoff text but are not individually blocking.

**Overall: CONDITIONAL PASS — resolve P0-1 (canonical scan tree) before Blake starts; address P1-1 (file-set enumeration) in the same edit since it's the other half of "what does the scanner actually read."**
