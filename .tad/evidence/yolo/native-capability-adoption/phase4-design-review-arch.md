# Phase 4 Design Review — Architecture Lens

**Reviewer**: backend-architect (architecture / blast-radius / design-completeness)
**Handoff**: HANDOFF-20260713-native-capability-adoption-phase4.md
**Date**: 2026-07-13
**Domain auto-detect**: Files to Modify = 2 protocol `.md` + 1 `.claude/rules` config `.md` + evidence files. No frontend, no API/DB, no auth. → **Default: backend/architecture review** (protocol-as-config architecture).

---

## Verdict

Design is **architecturally sound and mergeable after 2 P1 fixes**. The two-track split (protocol-text vs spike-gated pilot), the spike-first gate replicating Phase 2's NEGATIVE-RESULT precedent, the thin-rule-with-pointer anti-drift design, and the mirror-parity discipline are all correctly modeled. Blast radius is genuinely minimal (2 tracked files + additive rules dir + evidence). The problems are in **verification-command precision** (ACs that pass without proving the thing they claim), not in the architecture.

I independently re-verified every baseline claim in §2.2 — all confirmed (preview=0, rules dir absent, mirror IDENTICAL, anchor at L146, 5 constraints all traceable to source, CLI harness-native discovery).

---

## P0 (blocking)

None.

---

## P1 (should fix before Gate 3)

### P1-1 — AC3 is a structural no-op: `step1_5b` already occurs 5× in baseline, so the ≥2 threshold PASSES with zero negative-example added
`AC3` verifies the negative example (preference questions / pack selection) was written into the rule block via:
```
grep -cE 'preference|step1_5b' design-protocol.md   # expected ≥ 2
```
I ran this against the **current unmodified** file: `preference` = 0 occurrences, but `step1_5b` = **5** occurrences (L124, L158, and the step definition region). So the baseline already returns **5 ≥ 2 = PASS** before Blake writes a single line. This is exactly the Validation-Theater / self-leak failure class the handoff itself warns against (§9.2 selects code-reviewer specifically for "self-leak") and that principles.md flags as "a metric that passes without the artifact existing".

The token `step1_5b` is the WRONG discriminator because it's a pre-existing protocol step name, not a marker of the new negative-example prose. **Fix**: anchor AC3 on a token that only exists in the NEW block — e.g. require `grep -c 'preference'` ≥ 2 (currently 0, so it actually discriminates), or scope the count to the inserted block region, or grep for a distinctive phrase like `never_when` co-located with `preference`. As written, AC3 proves nothing.

### P1-2 — Insertion-anchor collides with the tournament-wiring edit region; "after step1_5c, before step2" resolves to L154, but step1_5c's own content (incl. the A2 edit target at L146) lives L122-153
The design says (§4.1, §4.2, A1) insert the `preview_usage_rule` block **"after step1_5c, before step2"**. I confirmed the actual structure: `step1_5c` spans L122-153, `skip_conditions` ends at L153, `step2:` starts at L155. So "after step1_5c before step2" = insert at ~L154. Meanwhile A2 edits step 4 **inside** step1_5c at L146, and A4/AC4 verify via the `sed -n '/Use the merged_design/,/skip_conditions/p'` range which is only **4 lines (L146→L150)**.

Two coupled hazards for the line-set diff discipline (NFR3 / AC8, the load-bearing SAFETY control here):
1. Inserting a multi-line block at L154 shifts every line below it — the `comm` line-set diff (C1) will show the block as FORWARD-added (fine) but the operator must NOT let the A2 in-region edit and the block insertion blur together. The handoff should state the two edits are **non-adjacent** (L146 region edit vs L154 insertion) so C1's FORWARD-missing set is explainable as exactly {the one original step-4 sentence being expanded} — nothing else.
2. The A2 edit must fit **between L146 and L150** (before `skip_conditions`). That's a 4-line window inside a YAML `action: |` block scalar. §8.3 already flags "keep block-scalar style" but the design should explicitly say the step-4 expansion stays inside the `action: |` scalar and does not push `skip_conditions` semantics. **Fix**: add one sentence to §4.1/A1 pinning the block insertion point precisely (recommend: immediately after `step1_5c`'s `skip_conditions` block, i.e. as a new sibling key, NOT interleaved) and stating the two edits are disjoint so the line-set diff stays interpretable.

---

## P2 (nice to fix)

### P2-1 — AC1 threshold `grep -c 'preview' ≥ 8` is an arbitrary count, not a structural check
The block could satisfy `preview ≥ 8` while omitting the `use_when`/`never_when` bidirectional structure. The second clause (`grep -cE 'never_when|multiSelect' ≥ 2`) partially covers this and I confirmed both tokens are 0 in baseline (good discriminators). Consider making AC1 assert presence of BOTH `use_when` and `never_when` keys explicitly rather than relying on a raw preview count that a verbose example could inflate. Low risk given AC2 also checks the example.

### P2-2 — Degradation matrix has a benign internal contradiction on the INERT artifact
§10.2 says on INERT: "不创建 `.claude/rules/` 文件 … **或** 创建后立即删除并在 evidence 留存内容草稿". Two divergent disposal paths ("never create" vs "create then delete") are both offered without a deciding rule. Since AC10-AC14 are all gated `(LOADED)`/`N/A when INERT`, either path passes the gate — so this is not blocking — but pick one to avoid Blake improvising. Recommend the **"do not create, stash draft in spike evidence"** path (cleaner: no dead config in `.claude/rules/` to mislead future readers, which §10.2's own rationale prefers).

### P2-3 — `.claude/rules` discovery mechanism is entirely harness-implicit — spike must confirm discovery, not just parse
I grepped `settings*.json` and `CLAUDE.md`: there is **zero** wiring that registers `.claude/rules/`. Discovery is 100% harness-native convention. This strengthens the handoff's spike-first stance (good), but B1's fire-test must verify the harness actually **discovers + loads** the file on a `.tad/hooks/**` touch, not merely that the frontmatter YAML-parses (AC10 only proves parse-ability, which is INERT-compatible). The handoff mostly says this (FR5, §8.4), but AC9's verdict criterion should explicitly require the fire-test to distinguish "discovered & loaded into context" from "file parses". Consider adding to AC9 expected-evidence: the raw context-injection observation or the honest PENDING-REAL-EVENT note — not just `Verdict: LOADED`.

### P2-4 — Context-delta measurement (NFR2 / AC14) measures file bytes, not actual per-session context cost
`wc -c` of the rule file ≠ the context tax when it fires (harness may add framing, path-match metadata, or load it every matching-path session). This is acceptable as a first-order proxy for a single-file pilot (the handoff correctly scopes it as "measurement record, not optimization"), but the measurement doc should label it "file-size proxy for context-delta" so a future scale-up decision isn't made on a number that undercounts real cost. Aligns with the "Measure Before Optimizing" principle's intent.

---

## Architecture strengths (worth preserving)

- **Spike-first gate correctly inherits the Phase 2 NEGATIVE-RESULT precedent** — same CLI 2.1.172 that silently accepted-but-inert `memory`/`skills` frontmatter. Treating `.claude/rules` path-scoping as the same "documented-but-harness-parsed" risk class is the right prior. This is the single best design decision in the handoff.
- **Thin-excerpt + pointer + sync-note** is the correct anti-drift topology (source-of-truth stays in `patterns/shell-portability.md`; rule file is a follower). The 60-line/4KB cap (NFR2/AC11) enforces it mechanically. I confirmed all 5 chosen constraints trace to the source file.
- **Mirror-parity as an AC** (AC7 `diff -q IDENTICAL`) with the explicit carve-out that `.claude/rules` has no `.agents` counterpart is complete and correct — matches the release-sync "parity at every granularity" pattern.
- **Line-set diff (C1/AC8/NFR3)** as the scope-lock control is the right ground-truth verifier for protocol-text edits, per the 2026-05-31 principle. My only ask (P1-2) is to keep its FORWARD-missing set interpretable.
- **Blast radius is genuinely minimal**: 2 tracked-file edits (both additive), 1 new additive rules dir, evidence files. No `.js`, no code path, no data flow. AC5 (`git diff --stat | grep -c '.js' = 0`) locks the no-code invariant.

---

## Summary

The architecture is right; the verification layer has one dead AC (P1-1) and one under-specified insertion anchor that threatens the line-set-diff control (P1-2). Both are cheap fixes to the handoff, no redesign. The spike-gate, degradation matrix, thin-rule anti-drift, and mirror-parity are all correctly modeled and independently re-verified against the live codebase.
