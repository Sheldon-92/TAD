---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/scripts", ".claude/skills"]
skip_knowledge_assessment: no
gate4_delta: []
---

# HANDOFF: P5 Capability pack behavioral eval runner + 16-pack fixtures

**From:** Alex (YOLO Conductor) | **To:** Blake | **Date:** 2026-05-31
**Epic:** EPIC-20260531-tad-lean-trustworthy.md (Phase 5/5)

## 1. Task Overview
Build the missing fixture RUNNER (assertion engine) + author ≥1 behavioral fixture for ALL 16 installed packs,
so "13/13 installed" becomes "behaviorally verified." Add a `behaviorally_verified` flag to the registry.
The runner is the ASSERTION engine (greps a captured agent output for fixture markers, asserts min_marker_count);
the CONDUCTOR drives sub-agent spawning (a bash script cannot spawn Claude agents — that division is intentional).

## 3. Requirements
- Fixtures MUST use the existing format `.tad/templates/pack-example-fixture.md` (frontmatter min_marker_count +
  tests_rules; Input Scenario; Expected Markers with ≥1 [structural]; Verification Command using
  `grep -oE 'p1|p2|...' <output> | sort -u | wc -l`; Anti-Slop Check with discriminative ❌ markers).
- Markers MUST be DISCRIMINATIVE: pack-specific terms a frontier LLM would NOT emit without the pack (anti-gaming;
  architecture.md "Parser Self-Trigger" + anti-slop formula: specific thresholds/terms > generic principles).
- Runner advisory + BSD-safe; never fail-closed.

## 6. Implementation Steps
### Step 1 — Build `.tad/scripts/pack-eval-runner.sh`
- Usage: `pack-eval-runner.sh <fixture.md> <agent-output-file>`.
- Parse fixture frontmatter `min_marker_count` (awk). Extract the Verification Command's grep pattern from the
  ```bash block under `## Verification Command` (the `grep -oE '...'` pattern).
- Run: `grep -oE '<pattern>' <agent-output-file> | sort -u | wc -l` → actual_count.
- PASS if actual_count ≥ min_marker_count, else FAIL. Print `PACK {pack} FIXTURE {name}: {actual}/{min} → PASS|FAIL`.
- Batch mode: `pack-eval-runner.sh --all <outputs-dir>` iterates every `.claude/skills/*/examples/*.md` fixture,
  looks for a matching captured output in <outputs-dir>/{fixture-name}.md, runs the assertion, emits a results
  table + summary `{P} pass / {F} fail / {S} skipped (no output captured)`.
- SAFETY header (advisory, never fail-closed, not a hook). bash -n clean, no grep -P.
- ⚠️ The runner's own grep must be the CORRECT form (grep -oE … | sort -u | wc -l) — do NOT use grep -c (P4 lint rule A).

### Step 2 — Author 16 fixtures (≥1 per installed pack)
Installed capability packs (from `ls .claude/skills/*/SKILL.md` minus framework skills): academic-research,
ai-agent-architecture, ai-evaluation, ai-prompt-engineering, ai-tool-integration, ai-voice-production,
code-security, product-thinking, research-methodology, video-creation (HAS 2 already — no new one needed),
web-backend, web-deployment, web-frontend, web-testing, web-ui-design. (= 15 needing a fixture; video-creation
already has 2. Target: every installed capability pack has ≥1 fixture in `.claude/skills/{pack}/examples/`.)
For each pack:
1. Read the pack's SKILL.md (Quick Rule Index / capabilities) to find 2-4 DISCRIMINATIVE rules.
2. Write `.claude/skills/{pack}/examples/{scenario-slug}.md` per the template. Input Scenario = a realistic user
   task that triggers the pack. Expected Markers = pack-specific grep patterns (≥1 [structural]). min_marker_count
   = 3 (or 2 for thin packs). Anti-Slop Check with ✅ pack-specific + ❌ generic.
3. ⚠️ Marker patterns must be terms the pack INTRODUCES (e.g. ai-evaluation: "Spearman", "pass@k", "self-enhancement
   bias"; web-backend: specific status-code/idempotency rules), NOT generic words any LLM emits. A fixture whose
   markers a no-pack agent would also produce is theater.

### Step 3 — registry flag
Add `behaviorally_verified: pending` to each pack entry in pack-registry.yaml (the Conductor flips to `true` after
a passing eval run). Do NOT hand-set true — only the runner result justifies true. (If editing the auto-generated
registry is fragile, instead write a side-file `.tad/capability-packs/behavioral-eval-status.yaml` mapping pack→status;
your call — state which in COMPLETION.)

### Step 4 — Self-test the runner (Blake, no sub-agent needed)
Create a synthetic output file that contains the video-creation photo-to-beat-sync markers (first_frame, last_frame,
montage, view-specific, camera.tree) and run `pack-eval-runner.sh .claude/skills/video-creation/examples/photo-to-beat-sync.md <synthetic>`
→ confirm it computes the marker count + PASS/FAIL correctly. (This tests the ASSERTION engine mechanically; the
REAL behavioral eval with live sub-agents is driven by the Conductor in Y6/dogfood, not by you.)

## 7. Files
- CREATE `.tad/scripts/pack-eval-runner.sh`
- CREATE 15 fixtures `.claude/skills/{pack}/examples/{slug}.md` (every installed pack except video-creation gets ≥1)
- MODIFY pack-registry.yaml (or CREATE behavioral-eval-status.yaml) — behaviorally_verified flag
- **Grounded Against:** .tad/templates/pack-example-fixture.md; .claude/skills/video-creation/examples/*.md (2 real fixtures); pack SKILL.md files.

## 9. Acceptance Criteria
- [ ] **AC5.1 (runner assertion works)**: runner on the video-creation photo-to-beat-sync fixture + a synthetic output containing the 5 markers → reports the correct marker count (the fixture's min is 4) and PASS. Paste raw.
- [ ] **AC5.2 (16-pack coverage)**: every installed capability pack has ≥1 fixture: `for d in $(ls -d .claude/skills/*/ ...); do ...; done` — count fixtures == count installed capability packs (video-creation's 2 count). No pack skipped. List them.
- [ ] **AC5.3 (discriminative markers)**: each new fixture's Verification Command uses `grep -oE ... | sort -u | wc -l` (NOT grep -c — would trip P4 Rule A); each has ≥1 [structural] marker + an Anti-Slop ❌ list. Spot-check 5 fixtures that markers are pack-specific (would a no-pack agent emit them? must be NO).
- [ ] **AC5.4 (registry flag)**: behaviorally_verified field present per pack (default pending); runner --all batch mode runs + emits a results table (skips packs with no captured output — that's expected until Conductor drives the eval).
- [ ] **AC5.5 (runner advisory + BSD-safe)**: bash -n 0; no grep -P; SAFETY header; runner grep uses correct form (no grep -c).
- [ ] **AC5.6 (Conductor behavioral dogfood — driven in Y6)**: Conductor spawns ≥3 real pack-loaded sub-agents on their fixtures' Input Scenarios, captures output, runs the runner → real PASS/FAIL recorded; flips behaviorally_verified=true for the packs that pass. (This AC is satisfied by the Conductor, not Blake — Blake delivers the runner + fixtures + synthetic self-test.)

## 10. Important Notes
- ⚠️ Anti-gaming is the real risk: a fixture whose markers a frontier LLM emits WITHOUT the pack is theater
  (architecture.md YOLO audit "validation theater"). Discriminative ❌ markers mitigate. Prefer specific
  numbers/terms the pack introduces (anti-slop formula).
- ⚠️ Runner never fail-closed; not a hook.
- Anti-self-trigger: COMPLETION no §11 Decision Summary table / bare-pipe Decision-Chosen rows.

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | runner ↔ sub-agent split | runner = assertion engine; Conductor drives spawning | bash can't spawn Claude agents; clean separation, runner reusable |
| 2 | fixture format | reuse pack-example-fixture.md (the proven video format) | don't reinvent; discriminative ❌ markers already in the format |
| 3 | behaviorally_verified default | pending; flip to true only on passing eval | count ≠ signal; only a real eval run justifies "verified" |

## Required Evidence Manifest
```yaml
required_evidence:
  completion_report:
    path: ".tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase5.md"
    must_contain:
      - "pack-eval-runner.sh full script"
      - "AC5.1 synthetic self-test raw output (marker count + PASS)"
      - "AC5.2 fixture coverage list (every installed pack has ≥1)"
      - "AC5.3 spot-check of 5 fixtures' discriminative markers"
      - "AC5.5 bash -n + no grep -P + SAFETY header"
    gate3_verdict: "frontmatter marker: pass|fail|partial"
```
