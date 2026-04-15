# Code-Reviewer — Alex Handoff Review: Phase 3 Hooks + SKILL Impl

**Reviewer:** code-reviewer (handoff-contract focus, not code quality — code does not exist yet)
**Target:** `.tad/active/handoffs/HANDOFF-20260415-phase3-hooks-skill-impl.md` (v3.1.0, 358 lines)
**Spec-of-truth:** `.tad/evidence/designs/DESIGN-20260414-phase2-enforcement-matrix-v3-LEAN.md` (423 lines, commit 3dbc998)
**Scope:** AC testability, AC Conflict Matrix soundness, phase ordering, evidence manifest completeness, design cross-refs, knowledge-entry enforceability, scope-to-AC mapping, file layout completeness.
**Date:** 2026-04-15

---

## Summary

Handoff is well-structured, cites the v3-LEAN doc as single source of truth, and already internalises Phase 1a/1b/1c lessons (AC imperative form, Conflict Matrix, bootstrap exception, Gate 4 raw-TSV recompute). The 15 ACs mostly map to v3-LEAN §10.1's 12 in-scope items. However, several ACs conflate multiple falsifiable sub-claims into one checklist bullet, two items from §10.1 are **missing or implicit**, one AC has a genuine logical conflict with the bootstrap exception that §3.1 does NOT resolve, and the File Layout omits three paths Blake will need to create. Phase ordering is largely sound but has **one ordering trap** in 3.C that will dogfood-lock Blake.

---

## 1. Critical Issues (P0 — must fix before Blake starts)

### P0-1. AC7 contradicts v3-LEAN §9 / §1 on what "fully armed" means — bootstrap exception resolves secret.key, NOT gate2-verdict

Handoff AC7 reads: *"secret.key exists and no gate2-verdict → should DENY"*. But v3-LEAN §9 step 4 says: *"After first gate2-verdict.tsv PASS, bootstrap exception clears"* — the bootstrap gate is **`secret.key` presence**, not the presence of a specific slug's gate2-verdict. v3-LEAN §1 AW-1 says: *"if `.tad/state/secret.key` missing (first-run), LOG-ONLY advisory"* — no mention of per-slug gate2-verdict.

AC7's "fixture-post-bootstrap-deny.sh: leave state, drop gate verdict, expect deny JSON" is testing a DIFFERENT rule: the standard AW-1/BW-1 evidence-manifest check (AC8). AC7 as written duplicates AC8 and creates ambiguity about which layer is being tested.

**Fix:** Reword AC7 so "DENY" path tests secret.key-present + sentinel-Write + missing-evidence (this is already AC8). The bootstrap-specific positive assertion is: secret.key absent → LOG-ONLY even for sentinel Writes with NO evidence at all. Currently AC7's deny fixture doesn't exercise the boundary.

### P0-2. AC Conflict Matrix §3.1 row "AC3 × AC4/5 × AC10" resolution is INTERNALLY INCONSISTENT

Row says: *"Blake must first change SKILL (AC4/5 before hook registered) → then install hook (AC3) → then run AC10 verification"*. But AC10 targets include `.tad/skills/**/SKILL.md` as a protected path. Once Phase 3.C activates hooks (step 7), any further Edit to SKILL.md is denied. §10.2 "Bash write-path 豁免" correctly notes this, but:

- Blake's Phase 3.E step 15 writes a `📨 Message from Blake` sentinel. If Blake discovers a P0 fix during Layer 2 review (Phase 3.E step 13) that requires editing SKILL.md, there is **no documented OV-1 recovery path** — the matrix says "requires OV-1 `gate=protected-path`" (v3-LEAN §1 HP-1) but handoff never mentions how Blake requests a `protected-path` override from the user mid-execution.
- The resolution paragraph claims "Blake 必须按以下顺序" but does not state what happens if the strict ordering is violated. What is the recovery? This is load-bearing for Blake.

**Fix:** Add an explicit sub-row to §3.1: *"If SKILL.md fix needed post-activation, Blake PAUSE and request user `TAD_OVERRIDE: protected-path <reason>`, then resume."* Also document this in §4 Phase 3.E as the sanctioned recovery.

### P0-3. AC4 / AC5 "byte-exact diff vs v2 §4.1.1 / §4.2.1" has no verification command and no reference file

AC4: *"diff 对比 v2 §4.1.1 原文 byte-exact"*. AC5: *"diff 对比 v2 §4.2.1"*. There is no path to the v2 file in the AC row. The v2 file is named *elsewhere in the handoff* (§2 "v2 版本 `DESIGN-20260414-phase2-enforcement-matrix.md`") but Blake's verification command is not spelled out.

Worse: "byte-exact" cannot be verified by `diff` alone if v2 embeds the block in Markdown code fences with surrounding prose — Blake will need to extract the fenced block first, and the extraction rule is not specified. Knowledge entry 2026-04-14 *"AC Precision"* explicitly warned that vague ACs hide failures.

**Fix:** Rewrite AC4/AC5 verification column as concrete: `awk '/^```yaml$/,/^```$/' .tad/evidence/designs/DESIGN-20260414-phase2-enforcement-matrix.md | sed -n '/anti_rationalization_registry:/,/^$/p' > /tmp/v2-ar.yaml && diff /tmp/v2-ar.yaml <(yq '.anti_rationalization_registry' .claude/skills/alex/SKILL.md)` — or equivalent. Commit the extracted v2 block to `.tad/evidence/designs/extracts/v2-ar-registry.yaml` as the diff target, so "byte-exact" has a fixed reference.

### P0-4. Required Evidence Manifest §1.4 is MISSING two categories

Comparing against the "Required Evidence Manifest" knowledge entry (2026-04-14, "*must explicitly list ALL required evidence files*") and v3-LEAN §10.1:

- **Knowledge Assessment output** — every Gate 3/4 under TAD protocol includes a Knowledge Assessment entry (CLAUDE.md §3 Rule 5 "Gate 必须含 Knowledge Assessment (BLOCKING)"). Not in manifest.
- **gate3-verdict.tsv** — handoff §11 File Layout line 327 lists it, but §1.4 manifest does not. AC8 implicitly depends on its presence (per v3-LEAN §1.1 `blake_completion_ready` schema).
- **KG-002 knowledge entry** — v3-LEAN §10.1 item 11 ("Document KG-002 knowledge entry") is an in-scope deliverable. Neither §1.4 manifest nor any AC references the `.tad/project-knowledge/security.md` append.
- **dogfood-trace.jsonl** — mentioned in AC15 and handoff §11 File Layout line 336, but §1.4 manifest does not list it, and its path `.tad/evidence/traces/phase3-hooks-skill-impl/dogfood-trace.jsonl` is implicit.

**Fix:** Add to §1.4 `required_evidence`:
```yaml
  knowledge_assessment:
    - path: ".tad/evidence/gates/phase3-hooks-skill-impl/knowledge-assessment.md"
      min_bytes: 200
  gate_verdicts:
    # (add to existing list)
    - path: ".tad/evidence/gates/phase3-hooks-skill-impl/gate3-verdict.tsv"
      must_contain: "PASS"
  knowledge_updates:
    - path: ".tad/project-knowledge/security.md"
      anchor_regex: "KG-002.*TOCTOU"
  dogfood:
    - path: ".tad/evidence/traces/phase3-hooks-skill-impl/dogfood-trace.jsonl"
      min_lines: 3
```

### P0-5. Phase 3.C step 7 "modify settings.json" will self-block under AC10 HP-1

AC10 lists `.claude/settings.json` as a protected path (matching v3-LEAN §1 HP-1: *".claude/settings*.json"*). §10.2 note says Blake's Write hooks "不会被 BW-3 拦截" because BW-3 only guards `.tad/evidence/**` + `.tad/active/handoffs/**`. **But HP-1 does guard `.claude/settings.json`**, and HP-1 applies to Write-family (not Bash). The handoff gives no resolution.

The matrix §3.1 covers AC10 vs AC3 only at a high level ("solution: bootstrap exception or ordering"). But Phase 3.C step 7 happens BEFORE hook activation (so HP-1 isn't active yet), which means it works — EXCEPT that Blake must **never** need to Edit settings.json again post-activation without OV-1. §3.1 should state this explicitly; a simple "Blake edits settings.json once in 3.C step 7 and must not touch it again during Phase 3" guard would do.

**Fix:** Add to §3.1 matrix row AC10 × AC3: *"post-step7, any further settings.json edit requires TAD_OVERRIDE: protected-path from user."* Add as Phase 3.C post-condition.

### P0-6. AC13 f-item "所有 hook p95 < 100ms" contradicts v3-LEAN §8 hedge on evidence-validator

v3-LEAN §8 says: *"If evidence-validator doesn't hit <100ms via single-awk alone, document gap in Phase 3 completion report; Phase 5 adds archive manifest cache."* This means evidence-validator has a documented PARTIAL-acceptable path. AC13 item (f) imperatively requires *"所有 hook p95 < 100ms"* — Phase 1c already measured evidence-validator at p95=156.51ms on dev-host, so even with CI dedicated runner this is the most likely failure point. AC13 as written forces Blake to either miss the AC or violate §8's PARTIAL clause.

**Fix:** Split AC13 item (f) into (f1) "pretool, override-detector, override-verify, bash-watcher p95 < 100ms (hard)" + (f2) "evidence-validator p95 < 100ms target; if miss, COMPLETION must document gap per §8, verdict PARTIAL-GO". This matches v3-LEAN §8 exactly.

---

## 2. Recommendations (P1 — should address)

### P1-1. AC1 "脚本可执行" does not test actual dispatch — only syntax

AC1 runs `bash -n` (syntax check) + `chmod +x` + `ls -la`. This misses runtime correctness. A script that `source`s a missing lib passes `bash -n` but dies on actual PreToolUse invocation. Add a minimal smoke test: `echo '{"session_id":"t","transcript_path":"/tmp/x","tool_name":"Write","tool_input":{"file_path":"/tmp/y","content":"hello"}}' | bash .tad/hooks/quality-enforcement.sh; echo "exit=$?"` — expect exit 0 + allow JSON.

### P1-2. AC9 Bash exfil pattern list is under-specified for detection logic

AC9 lists ≥10 shell operators (`>`, `>>`, `tee`, `<<`, `ln`, `cp`, `mv`, `git mv`, `rsync`, `sed -i`) but specifies only 1 fixture (`cp dummy.md .tad/evidence/...`). Blake's single-awk pattern can easily miss edge cases (`cat a > "$HOME/tad/evidence/..."` with quoting; `mv -f`; `>> .tad/evidence/...` with leading space). Knowledge entry 2026-04-07 *"Hook Performance: Single-awk"* also warns about `-v` vs `ENVIRON[]` injection. Recommend at least 3 fixtures covering: (a) simple `cp`, (b) `>>` redirect with variable expansion, (c) `sed -i` on handoff file. File these under `fixture-bash-*.sh` per v3-LEAN §3 fixture 10 plus two new ones — AC9 should say *"≥3 fixtures covering distinct operator classes (copy/redirect/inplace-edit)"*.

### P1-3. AC11 fixture "OV-2 伪造" placement

AC11 lists the OV-2 (tool_input content containing `TAD_OVERRIDE:` must deny) under the OV-1 override AC. OV-2 is a **separate** enforcement rule per v3-LEAN §1 (row OV-2) enforced on Write-family + Bash, not UserPromptSubmit. Putting it inside the UserPromptSubmit AC obscures whether it's tested on Write tool_input AND Bash command (both required per v3-LEAN §1). Move OV-2 fixture count requirement into AC10 (content-scanner coverage) or create a sub-AC. At minimum, AC11's "OV-2 fixture" should specify BOTH channels (Write content + Bash command).

### P1-4. AC12 "mtime < handoff mtime → deny" lacks tolerance window

KG-001 per v3-LEAN §7.1 is mtime-based. Real filesystems have ~1s granularity on macOS HFS+ and 1ns on APFS; git clone / rsync can preserve or reset mtimes. If evidence and handoff are written in the same second (common during fast Blake completion), mtime comparison is a tie. Define tie-breaker: `evidence_mtime >= handoff_mtime - 2s` is fresh. Otherwise edge cases around Git checkout will cause false denies.

### P1-5. Phase 3.D step 10 "CI workflow dry-run" is hand-wavy

"可先本地 dry-run 验证，再 push 到 GitHub Actions 真 CI runner" — `act` (nektos/act) does NOT reproduce dedicated-runner conditions (AC13 req (a)) and cannot provide the p95 number that AC13 item (f) requires. The AC13 acceptance target is the GitHub Actions run, not dev-host `act`. Clarify: local `act` is for syntax/workflow-file correctness only; AC13 verdict comes ONLY from real CI artifact. Add this to §4 Phase 3.D step 10 explicitly.

### P1-6. AC15 dogfood trace has no schema contract

AC15 says "3 条事件：bootstrap-allow、completion-write、post-bootstrap-deny". No schema. Knowledge entry *"AC Precision"* warns against aggregate count thresholds — here, if Blake writes 3 events with different names ("first-run", "armed-write", "deny-event"), verification is ambiguous. Spell out the JSONL line schema: `{"ts":"ISO","event":"bootstrap-allow|completion-write|post-bootstrap-deny","session_id":"...","outcome":"allow|deny","detail":"..."}`.

### P1-7. §1.4 manifest regex `anchor_regex: "^Overall: (PASS|FAIL|PARTIAL-GO)$"` differs from v3-LEAN §1.1

v3-LEAN §1.1 `blake_completion_ready.anchor` says `^Overall: (PASS|FAIL)$`. Handoff §1.4 adds `PARTIAL-GO`. This is a legitimate expansion (Phase 1b/1c used PARTIAL-GO) but it means the actual `evidence-validator.sh` anchor regex and the `schemas/evidence-manifest.yaml` ARE NOT what v3-LEAN §1.1 specifies — Blake's `evidence-manifest.yaml` must include PARTIAL-GO. Add a note: *"schemas/evidence-manifest.yaml.blake_completion_ready.anchor = '^Overall: (PASS|FAIL|PARTIAL-GO)$' (extends v3-LEAN §1.1 based on Phase 1b/1c precedent)"*. Make the divergence explicit so Blake doesn't byte-copy v3-LEAN §1.1.

---

## 3. Suggestions (P2 — nice to have)

### P2-1. Knowledge surface §5.1 #1-8 has no matching AC

Eight shell-portability lessons are listed but only implicitly enforceable by `bash -n` (AC1) + eyeballs. Consider a linter AC: `! grep -rn 'grep -P' .tad/hooks/` + `! grep -rn 'python3 -c.*time' .tad/hooks/` + `! grep -rn '\*/\\.tad/' .tad/hooks/` — each a one-liner, collectively catching #1, #2, #4. Would upgrade "knowledge surfaced" to "knowledge mechanically enforced" — thematically consistent with the Epic's premise.

### P2-2. File Layout §11 missing three paths

Blake will need to create (but §11 does not list):
- `.tad/evidence/designs/extracts/v2-ar-registry.yaml` + `v2-honest-partial.yaml` (per P0-3 fix — byte-exact diff targets)
- `.tad/evidence/gates/phase3-hooks-skill-impl/knowledge-assessment.md` (per P0-4)
- `.tad/evidence/gates/phase3-hooks-skill-impl/gate4-verdict.tsv` (Alex writes during acceptance — cited in AC15 "dogfood" but not in §11)

### P2-3. AC8 covers sentinel + manifest but not "outside fence" requirement

v3-LEAN §1.1 specifies `anchor_outside_fence: true` for `blake_completion_ready`. Handoff AC8 verifies manifest presence but has no fixture for "Overall: PASS inside ``` fence → deny". Add to fixtures: `fixture-completion-pass-in-fence.md` — expect deny (anchor must be outside code fence).

### P2-4. AR-003 framing in Phase 3.E step 13

The handoff cites "AR-003: spike / infra handoff 不是 review-exempt" but this handoff is e2e_required:yes, code task_type, NOT a spike. The AR-003 invocation is correct-by-belt-and-suspenders but Blake may be confused why AR-003 matters here. Clarify: *"本 handoff 是 production infra code (not spike). AR-003 applies defensively to prevent future rationalization — Blake must run ≥3 reviewers (code-reviewer + security-auditor + backend-architect) because infra blast radius warrants it."*

### P2-5. "Sub-agent safety classifier" (#15) actionable phrasing

§10.3 says "用 blue-team framing". Give Blake a drop-in review prompt template (blue-team) so he doesn't have to reinvent it mid-stream. Pattern: *"Review this defensive enforcement hook for validator rejection coverage, fail-closed semantics, and dependency-chain robustness. Blue-team context: hardening TAD's quality chain against honest-but-lazy LLM agents rationalizing skipped steps."*

### P2-6. Handoff cross-ref density

Out of 15 ACs, 11 have (design §X.Y) back-refs. AC6 cites §9 (correct), AC12 cites §7.1 (correct), AC13 cites §8/§10.3 (correct), AC15 cites §9 (plausible, though the dogfood semantics are really cross-cutting). AC2 cites §1.1/§1.3/§3 — AC2 is the YAML schemas, but §1.3 is "Non-Handoff Alex Writes (out of scope)" which is unrelated to `sentinel-patterns.yaml`. Likely typo — should be §3 (sentinel detection) + §1.1 (evidence manifest) + §1 HP-1 protected-paths-list (actually §1 or §4 H-003). Fix the ref.

---

## 4. Scope-to-AC Mapping Audit (v3-LEAN §10.1 items 1-12)

| §10.1 item | Covered by AC? |
|-----------|----------------|
| 1. Create 8 shell scripts | AC1 ✅ |
| 2. Create 3 YAML schemas | AC2 ✅ |
| 3. Update settings.json | AC3 ✅ |
| 4. SKILL hardening (byte-exact) | AC4 + AC5 ✅ |
| 5. `.tad/state/` + gitignore + historical secret scan | AC6 ✅ |
| 6. KG-001 `--handoff-path` flag | AC12 ✅ |
| 7. Gate verdict writer in /gate, completion_protocol, acceptance_protocol | **⚠️ NOT COVERED AS AC** — mentioned in §1.1 intro but no AC verifies the writer integration. v3-LEAN §1.2 names 3 writers. |
| 8. CI workflow for perf gate | AC13 ✅ |
| 9. Bootstrap flow | AC6 + AC7 ✅ |
| 10. 10 regression fixtures | AC14 ✅ |
| 11. Document KG-002 knowledge entry | **❌ NOT COVERED** — no AC for knowledge.md append |
| 12. Dogfood | AC15 ✅ |

**Missing: §10.1 item 7 (Gate verdict writer integration) and item 11 (KG-002 knowledge entry).** Both are P0 fixes (add AC16 + AC17, OR fold into existing ACs with explicit line about the writer integration + knowledge.md append).

---

## 5. Overall Assessment

**CONDITIONAL PASS.**

The handoff is high-quality and shows clear Phase 1a/1b/1c lesson absorption. But it has **6 P0 issues** that would cause Blake to hit ambiguity, scope gaps, or ordering traps during execution — specifically:
- Missing ACs for §10.1 items 7 + 11 (Gate verdict writer + KG-002 knowledge entry) — **hard scope gap**
- AC7 boundary condition logic contradicts v3-LEAN §9 (conflates secret.key-gate with slug-gate2 evidence check)
- AC13 f-item too strict vs v3-LEAN §8 hedge (evidence-validator PARTIAL clause)
- Conflict Matrix §3.1 AC3×AC4/5×AC10 has no post-activation recovery path documented (Blake cannot fix SKILL mid-review)
- AC4/AC5 "byte-exact" has no concrete verification command + no reference extract path
- Phase 3.C self-block on settings.json post-activation is not explicitly documented

Fixable in one revision pass (~30 min). No architectural rework needed. After P0 fixes, upgrade to PASS.

---

## Appendix — verification commands I actually ran

- Read handoff in 2 passes (1-180, 180-358)
- Read v3-LEAN §0-120, §120-300, §300-423
- Read Epic phase map + context
- Cross-referenced handoff `(design §X.Y)` refs against v3-LEAN section headers
- Mapped v3-LEAN §10.1 items 1-12 to handoff ACs 1-15 (table above)
