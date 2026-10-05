# Gate 4 Acceptance — 上游知识接缝与下游隔离 (TASK-20260908-KNOWLEDGE-SEAM-ISOLATION)

**Date:** 2026-09-09  
**Owner:** Alex (Solution Lead)  
**Task ID:** TASK-20260908-KNOWLEDGE-SEAM-ISOLATION  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md` (Gate2-R4 dual PASS)  
**Completion:** `.tad/active/handoffs/COMPLETION-20260908-knowledge-seam-isolation.md` (gate3_verdict: pass)  
**Implementation SHAs:** `e6e2126e` (implementation) + `65963d6b` (completion & evidence sync) — local only; do not push  
**Task Type:** feature / distribution & installer infrastructure  
**e2e_required:** yes · **research_required:** no · **feedback_required:** false  
**Human Locks (2026-09-08):**  
1. Option A: Pure isolation (only `README.md` installed on fresh installs; empty `patterns/` and `incidents/` subdirectories; no `framework-principles.md`).  
2. Quarantine: Strictly opt-in via `tad.sh --quarantine-pk`; zero auto-quarantine on `tad.sh update`.  

## Verdict: ✅ PASS → ACCEPTED

---

## 1. Prerequisite Checks

| Check | Status | Evidence / Notes |
|---|---|---|
| Gate 3 Passed | ✅ PASS | Completion report frontmatter `gate3_verdict: pass` & Layer 1 19/19 rows all green |
| Gate 3 Evidence Manifest (§7) | ✅ Exists | `.tad/evidence/reviews/gate3-evidence-knowledge-seam-isolation.md` (Manifest File 1) & `.tad/evidence/fixtures/quarantine-test-manifest.md` (Manifest File 2) |
| Layer 2 Expert Reviews | ✅ Complete | 3 independent reviews on disk (`spec-compliance-reviewer`, `code-reviewer`, `test-runner`), all PASS, P0=0, P1=0 |
| Scope & Implementation Commits | ✅ Verified | `e6e2126e` (impl) + `65963d6b` (completion/evidence). All changes local; no push, no tag, no release |
| Human Locks Conformance | ✅ 100% | Option A confirmed (only clean README.md at pk root, 0 md in subdirs, 0 framework-principles.md); opt-in quarantine confirmed (absence proof in update path) |
| Dual-Platform Parity | ✅ 100% | `.claude/skills/` and `.agents/skills/` mirrors byte-for-byte identical (`release-verify.sh parity .` exit 0) |

---

## 2. Functional Acceptance — AC Independent Verification (§9.1)

All 19 rows from Handoff §9.1 independently evaluated against evidence carriers and verified execution logs:

| # | Check / AC | Requirement | Evidence & Verification Result | Status |
|---|---|---|---|---|
| AC1.1 | derive-sync-set.sh TOP_DENY | `brain-index.md` declared in multiline `TOP_DENY` | `.tad/hooks/lib/derive-sync-set.sh:77-78` multiline string matches `sync-registry.yaml\nbrain-index.md` | ✅ PASS |
| AC1.2 | tad.sh TAD_TOP_DENY | `brain-index.md` declared in multiline `TAD_TOP_DENY` | `tad.sh:575-576` multiline string matches `sync-registry.yaml\nbrain-index.md` | ✅ PASS |
| AC1.3 | Consumer set-membership | `derive_framework_top_files` uses set-membership grep | `tad.sh:610` `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq -e "$bn" && continue`; comment updated to "the excluded files" | ✅ PASS |
| AC1.4 | Behavioral top-file probe | `brain-index.md` + `sync-registry.yaml` excluded, `version.txt` included | Main-free loader probe executed verbatim; exit code 0 | ✅ PASS |
| AC1.5 | Denylist parity check | `bash tad.sh --verify-denylist` passes | `tad.sh inlined DENY_LIST == derive-sync-set.sh (17 entries)`, exit code 0 | ✅ PASS |
| AC2.1 | Clean install Option A | Fresh install creates README-only at pk root, empty patterns/ and incidents/ | `(cd $TMPD && bash $SRC/tad.sh ...)` creates pk root with exactly README.md + 2 subdirs; 0 `*.md` in subdirs; no brain-index leak; exit code 0 | ✅ PASS |
| AC3.1 | brain-index-gen.sh pipefail robust | Runs to completion under `set -e` without crash | All 8 grep sites wrapped `{ grep ... 2>/dev/null \|\| true; }` + find parens + defaults; exits 0, generates 278 lines | ✅ PASS |
| AC3.2 | Archived handoffs cap & completeness | 50 rows cap with non-empty task_type and summary | Count = 50 rows (≥50); zero `\|\s*\|` empty cells; zero `(see file)` fallback; exit code 0 | ✅ PASS |
| AC4.1 | CLI help documentation | `tad.sh --help` documents `--quarantine-pk` | Synopsis + option table match; description printed; exit code 0 | ✅ PASS |
| AC4.2 | Quarantine script syntax & executable | Executable permission and `bash -n` clean | `-rwxr-xr-x`, `bash -n` clean; exit code 0 | ✅ PASS |
| AC4.3 | Fixture: README & modified preservation | Preserves `README.md` and user-modified files, quarantines identical | Fixture test: `README.md` byte-identical, `custom.md` preserved; identical framework files moved to timestamped archive with valid `MANIFEST.md` | ✅ PASS |
| AC4.4 | Quarantine idempotency | Clean tree run produces 0 files quarantined and creates no archive | Clean tree output: "0 files quarantined", 0 archives created, exit code 0 | ✅ PASS |
| AC4.5 | Post-quarantine rebuild | Rebuilds local `brain-index.md` after quarantine | Non-blocking execution verified; exit code 0 | ✅ PASS |
| AC5.1 | Project-owned skill preservation | Preserves bare, single-quoted, double-quoted `ownership: project-owned` and `local/` | Bare / single / double quoted skills (c1, c2, c3) + `local/keep.txt` survive re-sync in both `.claude/` and `.agents/` loops; real 2.40.0→2.44.3 upgrade proof verified | ✅ PASS |
| AC6.1 | Distillation Step 6 soft trigger | Soft rebuild trigger in Step 6 of distillation protocol | `distillation-loop-protocol.md` Step 6 and `acceptance-protocol.md` step4f contain `brain-index-gen.sh >/dev/null 2>&1 \|\| true` in both platform trees | ✅ PASS |
| AC6.2 | Doctor / maintain freshness WARN-only | Freshness check warns when stale but exits 0 | Stale probe prints `⚠️ brain-index.md is older than project-knowledge`, exit code 0; fresh probe prints `✓ brain-index.md is fresh`, exit code 0 | ✅ PASS |
| AC7.1 | Dual platform mirror parity | 100% byte-identical across modified skills | `release-verify.sh parity .` exits 0 (100% byte identical) | ✅ PASS |
| AC8.1 | Negative: update never calls quarantine | `tad.sh update` contains zero quarantine calls | `sed -n '/"update")/,/;;/p' tad.sh \| grep -F "quarantine-framework-pk"` output empty (exit code 1) | ✅ PASS |
| AC8.2 | Negative: Gate 3/4 never block on freshness | Gate pre-checks contain zero blocking freshness checks | `grep -rn "brain-index" .tad/gates/ pre-gate-check.sh pre-accept-check.sh \| grep -i "block"` output empty (exit code 1) | ✅ PASS |
| AC8.3 | Negative: zero framework-principles.md | No framework principles file or provenance tagging installed | `ls .tad/project-knowledge/framework-principles.md` → No such file or directory | ✅ PASS |

---

## 3. Layer 2 Independent Review Audit & Adaptation Rulings

### Reviewer Verdicts
1. **spec-compliance-reviewer (Group 0)**:
   - Output: `.tad/evidence/reviews/2026-09-09-gate3-layer2-spec-compliance-knowledge-seam.md`
   - Verdict: **PASS** (19/19 rows PASS, 0 P0, 0 P1, 1 P2)
   - P2 Note: Active handoff summary cells empty due to pre-existing generator logic requiring `### 1.1`, outside §9.1 AC3.2 scope.
2. **code-reviewer (Group 1)**:
   - Output: `.tad/evidence/reviews/2026-09-09-gate3-layer2-code-review-knowledge-seam.md`
   - Verdict: **PASS** (0 P0, 0 P1, 5 P2)
   - 3 P2 applied: `-e` flag added to consumer grep (`grep -Fxq -e "$bn"`), `--help` synopsis updated, quarantine `MANIFEST.md` header append-guarded.
   - 2 P2 deferred to Alex: `--verify-denylist` TOP_DENY coverage and `find -quit` portability note.
3. **test-runner (Group 2)**:
   - Output: `.tad/evidence/reviews/2026-09-09-gate3-layer2-test-runner-knowledge-seam.md`
   - Verdict: **PASS** (19/19 rows PASS, 5 supplemental probes all PASS)

### Gate 4 Adaptation Rulings (Alex Decisions)

- **Ruling (a): Adaptation D1 — Positional Install Form vs CWD Install**
  - **Context**: Literal AC2.1/AC5.1 command `bash tad.sh ... "$TMPD"` fails because `tad.sh` installs to CWD and does not accept a positional directory argument.
  - **Blake Disposition**: Used `(cd "$TMPD" && bash "$SRC/tad.sh" --source "$SRC" --platform both --yes)` to execute installation.
  - **Alex Ruling**: **ACCEPT as `EQUIVALENT_SUBSTITUTE`**. The target state assertions (directory structure, file presence/absence, seed integrity) are 100% identical. All three Layer 2 reviewers verified this adaptation.

- **Ruling (b): Adaptation D2 — Scoped `local/` Skill Skip**
  - **Context**: Handoff literal task suggested unconditional `[ "$skill_name" = "local" ] && continue`. In fresh installations, this prevented installing the `local/` seed directory required by the installer's post-installation self-check, causing automatic rollback.
  - **Blake Disposition**: Scoped the skip to existing target skill trees: `[ "$skill_name" = "local" ] && [ -e "$TARGET_SKILL_DIR/local" ] && continue`.
  - **Alex Ruling**: **ACCEPT as `EQUIVALENT_SUBSTITUTE`**. This preserves custom user skills in existing repositories while correctly seeding fresh installs with the necessary boilerplate. Ownership branches confirmed on both fresh install and real 2.40.0→2.44.3 upgrade.

- **Ruling (c): Adaptation D3 — Script-Directory Resolution for `--quarantine-pk`**
  - **Context**: When running `tad.sh --quarantine-pk` with CWD outside the repository root, bare `.tad/hooks/lib/...` fails to resolve.
  - **Blake Disposition**: Resolved `_qp_self_dir="$(cd "$(dirname "$0")" && pwd)"` before dispatching.
  - **Alex Ruling**: **ACCEPT as `EQUIVALENT_SUBSTITUTE`**. Conforms to existing `self_dir` idiom in `tad.sh` and ensures CLI invocations work reliably from arbitrary directories.

- **Ruling (d): Deferred Code-Reviewer P2 Items**
  - **P2-2 (TOP_DENY drift check)**: Logged for future design consideration. Denylist parity between `tad.sh` and `derive-sync-set.sh` currently covers `DENY_LIST`; expanding to `TOP_DENY` touches the release validator and will be tracked for a future maintenance cycle.
  - **P2-3 (`find -quit` portability)**: In `tad_doctor`, the check is strictly advisory and WARN-only with exit code 0. Both Linux and macOS BSD `find` support `-quit` in standard development environments. Acceptable as-is.

---

## 4. Friction Status Review (Gate 4)

| Friction Point | Completion Status | Alex Gate 4 Disposition |
|---|---|---|
| Bash 3.2+ compatibility | READY | Verified: no associative arrays, no `\|&`, portable hash + wraps used throughout |
| Portable sha256 helper | READY | Verified: `hash_file()` dispatches `sha256sum` → `shasum -a 256` |
| Denylist parity verification | READY | Verified: `bash tad.sh --verify-denylist` exits 0 (17 entries) |
| Dual platform mirror parity | READY | Verified: `release-verify.sh parity .` exits 0 |
| Quarantine fixture isolation | READY | Verified: all testing performed in isolated `/tmp` sandboxes; live tree untouched |
| Adaptations D1–D3 | EQUIVALENT_SUBSTITUTE | Confirmed intent-preserving by 3/3 Layer 2 reviewers and Alex |
| Sub-agent availability | READY | 3 independent reviews executed and logged on disk |

No `BLOCKED` items. All friction points successfully handled.

---

## 5. Knowledge Assessment (Gate 4)

| Question | Answer | Rationale & Distillation |
|---|---|---|
| Blake Gate 3 Journal Verified? | ✅ Yes | Blake completed the Knowledge Assessment with a justified "No" (episode-specific installer quirks that did not pass the variabilize test). Verified. |
| Alex Gate 4 Discoveries? | ✅ Yes | **Pattern: Downstream Knowledge Seam & Zero-Touch Isolation (下游知识接缝与零接触隔离模式)**<br>1. *Granularity-Matched Exclusion*: Synchronizing complex directories requires deny-lists at every copy granularity (both top-level files and directory hierarchies). Neglecting top-level sync allowed `brain-index.md` to leak into downstream projects despite `project-knowledge/` being marked zero-touch.<br>2. *Safe Non-Destructive Quarantine*: When cleaning upstream pollution from downstream repositories, an automated tool must (a) never delete user-modified files, (b) never modify sanctioned seed files (`README.md`), (c) provide transparent audit logging via `MANIFEST.md`, and (d) remain strictly opt-in.<br>3. *Skill Ownership Multi-Format Preservation*: Allowing projects to author custom skills while maintaining upstream framework updates requires regex matching across all legal YAML serialization forms (bare, single-quoted, double-quoted `ownership: project-owned`) and defensive handling of seed directories like `local/`. |
| Project Knowledge Action | ✅ Recorded | Documented in this Gate 4 record and reflected in project context. |

---

## 6. Archival and Post-Acceptance Summary

1. **Handoff & Completion Archival**:
   - `HANDOFF-20260908-knowledge-seam-isolation.md` moved to `.tad/archive/handoffs/`
   - `COMPLETION-20260908-knowledge-seam-isolation.md` moved to `.tad/archive/handoffs/`
   - Gate 4 report saved to `.tad/evidence/reviews/2026-09-09-gate4-acceptance-knowledge-seam-isolation.md` and archived to `.tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md`
2. **Project Documentation Updates**:
   - `NEXT.md`: Marked `TASK-20260908-KNOWLEDGE-SEAM-ISOLATION` as completed; marked pre-existing `brain-index-gen.sh` set -e defect as resolved.
   - `PROJECT_CONTEXT.md`: Added entry under `Recently Completed`.
3. **Repository State**:
   - Commits `e6e2126e` and `65963d6b` accepted locally.
   - Strictly no push, no tag, no release per instructions.
