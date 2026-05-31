# Pack Collision Detection — Reference Guide

> Detects when **two co-loaded capability packs** issue **contradicting directives**
> (one bans `Inter`, another endorses it) and resolves cross-category conflicts by
> precedence (with a visible log) or escalates same-category ties to a human.
>
> This is a **build-time** detection tool, NOT a runtime/per-session check, and NOT a
> single-pack quality evaluator. It does **not** auto-modify pack content.

Closes the cross-model-audit gap **"zero collision detection"** (architecture.md "YOLO
Audit Findings 2026-05-15"): two co-loaded packs could issue contradicting directives
with no mechanism to detect or resolve them.

---

## 1. Hybrid Two-Stage Detection

The detector is deliberately split so it keeps **determinism** (grep) AND
**false-positive defense** (LLM-confirm). A pure-grep scanner that auto-emits the final
registry would itself be validation theater (see §6).

```
pack files (.claude/skills/) + pack-registry.yaml
        │
        ▼  STAGE 1 — deterministic, scan-collisions.sh (grep-seed)
  For each pack PAIR sharing ≥1 keyword (pre-filter),
  grep curated opposing-directive signatures (both orientations).
  When BOTH sides hit → emit a CANDIDATE (both-side file:line + quote).
        │
        ▼
  .tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml   (staging)
        │
        ▼  STAGE 2 — agent procedure, LLM-CONFIRM contract (§4)
  Open both file:line refs; confirm a TRUE opposing directive (not a co-mention);
  assign a category per side; compute resolution; DROP false positives.
        │
        ▼
  .tad/capability-packs/pack-collisions.yaml   (final confirmed registry)
        │
        ▼  P2 (NOT this phase) — consumers read + surface a one-liner (§5)
```

- **STAGE 1 (`scan-collisions.sh`)** is the *grep-seed half*. It is dumb on purpose:
  it never decides anything, it only nominates candidates from curated signatures.
- **STAGE 2 (LLM-confirm)** is a documented *agent procedure*, NOT code. There is **no
  LLM call inside `scan-collisions.sh`**.

### `scan-collisions.sh` is a CLI tool, NOT a hook

`scan-collisions.sh` is a **CLI tool** — invoked manually or by an agent procedure.
It is **NOT a registered hook** and **MUST NOT** be added to `.claude/settings.json`.
Its fail-fast `set -euo pipefail` is correct for a CLI tool; the
no-fail-closed-hook rule does **not** apply because it is **not a hook**.

---

## 2. Canonical-Tree Invariant (P0-2)

Every collision `ref` (file:line) is recorded against **`.claude/skills/`** — the
**runtime-loaded tree** that the P2 surfacing consumers actually load. `scan-collisions.sh`
scans `.claude/skills/` too, so **scanner output, schema refs in `pack-collisions.yaml`,
and acceptance hand-re-derivation all anchor to the SAME physical files**.

`.tad/capability-packs/` is a **`*sync`-maintained source copy** — it is NOT the ref
anchor. Never record collision refs against `.tad/capability-packs/`.

---

## 3. Precedence Engine Semantics

Ordered categories (highest precedence → lowest):

| # | Category | Notes |
|---|----------|-------|
| 1 | `security / safety / compliance / data-integrity` | non-overridable |
| 2 | `correctness` | (the `testing` directives sit in this band) |
| 3 | `accessibility (a11y)` | |
| 4 | `performance` | |
| 5 | `style / aesthetic` | |

- **CROSS-category collision** → `resolution: auto`. The **lower category NUMBER wins**.
  Record `winner`, `loser`, both sides' `category`, the `rule` string that fired
  (e.g. `performance>style`), and a **visible log line**. The Inter case is the
  dangerous one — a legit `next/font` use must not be silently killed; the log lets a
  human verify Inter isn't actually the *primary* typeface.
- **SAME-category collision** → precedence tie → `resolution: escalate` to a human
  (no silent pick). Record `reason: same-category`.
- **No-silent-caps rule**: **EVERY resolution (auto AND escalated) is logged visibly.**
  There is no silent auto-resolve and no silent escalation.

### Uncategorizable → ESCALATE (P1-4 fallback)

The category list above is **CLOSED for P1, EXTENSIBLE in P2**. Directive classes that
already exist in the live pack set but are **not** covered by the 5 categories include
**licensing / legal** (e.g. `ai-voice-production` license refs) and **cost / economic**
(e.g. `ai-voice-production` cost refs, `ml-training` cloud-GPU cost).

**Fallback rule**: if **EITHER** side's directive cannot be cleanly categorized into the
closed list → `resolution: escalate` (never a silent auto-resolve). An out-of-list
category in a "no silent pick" precedence engine MUST escalate, not guess.

---

## 4. LLM-Confirm Contract

When an agent (re)generates `pack-collisions.yaml`, it follows this numbered procedure:

1. **Read** `.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml`.
2. **For each candidate, open BOTH `file:line` refs** and confirm it is a **TRUE opposing
   directive** (an actual contradiction in *intent*), **NOT a co-mention** (e.g. both
   files merely *naming* "Inter" without a conflicting prescription).
3. **Assign a `category` per side** from the closed list (§3). If either side is
   uncategorizable → resolution is `escalate` (§3 fallback).
4. **Compute `resolution`** via the precedence engine (§3): CROSS → `auto` (lower number
   wins, record `winner`/`loser`/`rule`); SAME → `escalate` (record `reason: same-category`).
5. **Write** the confirmed row into `.tad/capability-packs/pack-collisions.yaml`.
   **DROP** candidates judged false positive — recording the `drop_rationale`.

### Required fields per candidate (P1-2 — converts the doc-only defense into a contract)

Every **confirmed** AND every **dropped** candidate MUST carry:

- **`confirmed_by`**: which refs the agent *actually opened* to confirm — e.g.
  `opened web-ui-design/SKILL.md:93 + web-frontend/references/performance.md:215`.
- **`drop_rationale`** (false positives only): why it was dropped — e.g.
  `co-mention: both name Inter, no conflicting prescription`.

### MANDATORY worked example — a co-mention false positive (drop)

This worked example is **required content of this guide** (NOT an optional edge case).
It demonstrates the confirming agent opening BOTH refs and dropping a non-contradiction.

Suppose STAGE 1 emitted this candidate (illustrative):

```yaml
- pack_a: web-ui-design
  pack_b: web-frontend
  topic: inter-font
  a_ref: ".claude/skills/web-ui-design/examples/anti-slop-landing-design.md:47"
  a_quote: "✅ \"APCA LC ≥60 / 25-40% automation boundary\" — the pack's specific numbers"
  b_ref: ".claude/skills/web-frontend/references/performance.md:215"
  b_quote: "import { Inter } from 'next/font/google'"
```

The confirming agent opens **both** refs:

```yaml
confirmed_by: "opened web-ui-design/examples/anti-slop-landing-design.md:47 + web-frontend/references/performance.md:215"
drop_rationale: "co-mention, NOT an opposing directive — the web-ui-design line merely
  CITES APCA as an example of a 'specific number' (it is about anti-slop writing style),
  it does NOT prescribe a typeface or contradict the next/font import. No conflicting
  prescription exists between the two lines → DROP (do not write to pack-collisions.yaml)."
```

Key point: a shared TOKEN (both mention a font / a number) is **not** a collision. Only a
shared **prescription with opposing intent** is. The drop is recorded so the judgment is
auditable — and so re-running the scanner does not silently re-introduce the same noise.

---

## 5. Surfacing One-Liner Formats (for P2 consumers)

These are the contract that P2 reads from `pack-collisions.yaml` and surfaces in
Alex step4_5 / Blake 1_5a. P1 only **specifies** them.

- **Cross-cat (auto-resolved)**: `⚙️ resolved: {winner} over {loser} ({rule})`
  - e.g. `⚙️ resolved: web-frontend over web-ui-design (performance>style)`
- **Same-cat (escalated)**: `⚠️ unresolved: {a} vs {b} — human decides ({topic})`
  - e.g. `⚠️ unresolved: web-ui-design vs web-frontend — human decides (contrast-standard)`

---

## 6. Anti-Validation-Theater Acceptance Rule (LOAD-BEARING)

**"N collisions found" is NOT acceptance.** A grep collision-scanner is itself
validation-theater-prone — it emits confident binary verdicts that are often false
positives (architecture.md "Ad-hoc Dead Code Audit Tools Are Themselves Validation
Theater", 2026-05-30).

Acceptance **MUST hand-re-derive every flagged collision's two `file:line`** against the
live `.claude/skills/` pack files: open each ref, confirm the quoted contradiction text
is really there at that line. A count is **never** sufficient signal. Also check
`git status` for in-flight work before interpreting a scan (a scan run during active
implementation will flag in-progress files).

This rule applies to BOTH the scanner candidates AND the confirmed `pack-collisions.yaml`
rows.

---

## 7. Curated Signatures & Parser Self-Trigger

The signature set lives in `.tad/scripts/collision-signatures.txt` (fields delimited by
`@@@` so `|` stays free for `-E` regex alternation). Each signature is **anchored
specifically** — `NEVER use Inter`, not a bare `Inter` (which would over-match
"INP (Interaction to Next Paint)").

**Parser self-trigger guard** (architecture.md 2026-05-30): the literal signature
patterns live in `.tad/scripts/` (NOT under a scanned pack dir), and the fixtures live
under `.tad/evidence/fixtures/` (NOT under `.tad/capability-packs/`). So describing the
signatures in docs/fixtures does **not** self-trigger the scanner.

**BSD-safe only** (macOS): no `grep -P`, no `\d`, no `.*?`, no `readlink -f`. For any
unique-match COUNT use `grep -oE | sort -u | wc -l`, **never** `grep -c | sort -u | wc -l`
(that always returns 1 — code-quality.md 2026-05-27).

---

## 8. The 3 Seed Collisions (confirmed)

| topic | pack_a | pack_b | a category | b category | resolution |
|-------|--------|--------|-----------|-----------|------------|
| inter-font | web-ui-design | web-frontend | style | performance | **auto** (performance>style → web-frontend wins) |
| contrast-standard | web-ui-design | web-frontend | a11y | a11y | **escalate** (same-category) |
| testing-pyramid | web-frontend | web-testing | testing | testing | **escalate** (same-category) |

See `.tad/capability-packs/pack-collisions.yaml` for full rows and
`.tad/evidence/fixtures/pack-collisions/{inter,contrast,pyramid}.md` for the acceptance
fixtures (each with both-side `file:line` + expected classification).
