---
gate: 2
handoff: HANDOFF-20260909-release-v2444.md
reviewer: Gate 2 Reviewer 1 (Spec & Pathspec Compliance)
date: 2026-09-09
verdict: PASS
counts:
  P0: 0
  P1: 1
  P2: 2
---

Model: harness=cursor | model=Cursor Grok 4.6 | route=unknown

# Gate 2 Review — Spec & Pathspec Compliance (v2.44.4)

**Handoff:** `.tad/active/handoffs/HANDOFF-20260909-release-v2444.md`  
**Design pointer:** `.tad/evidence/designs/2026-09-09-release-v2444-scope.md`  
**Reviewer role:** independent; no implementation; no push/tag  
**Focus:** 12 version patterns, CHANGELOG honesty, 16-file pathspec, sequential publish, Gate 4 citation  

---

## Method (bounded)

Read only the mandated handoff sections (Execution Mandate, §3.0–3.7, §4/§5, §9.1, Forbidden, Files/pathspec), the design pointer, the 12 stated identity line sites, CHANGELOG head, and the two Gate 4 citation paths. No repo-wide explore; no bump.

---

## Findings vs focus items

### 1) Twelve OLD identity markers (must still be `2.44.3`)

| # | Path / line (as stated) | On-disk | Match |
|---|-------------------------|---------|-------|
| 1 | `.tad/version.txt` | `2.44.3` | YES |
| 2 | `.tad/TAD-VERSION` | `2.44.3` | YES |
| 3 | `.tad/config.yaml` L1 | `# TAD Configuration v2.44.3 - Full is the Default Channel (lite frozen 2026-08-13)` | YES |
| 3 | `.tad/config.yaml` L3 | `version: 2.44.3` | YES |
| 4 | `package.json` `version` | `"2.44.3"` | YES |
| 5 | `tad.sh` L26 `TARGET_VERSION` | `TARGET_VERSION="2.44.3"` | YES |
| 6 | `README.md` L3 / L5 / L190 / L506 | all still `2.44.3` (L3/L5/L506 still carry v2.44.3 Local Wiki blurb) | YES |
| 7 | `INSTALLATION_GUIDE.md` L3 / L51 | `2.44.3` | YES |
| 8 | `PROJECT_CONTEXT.md` L4 / L6 | `2.44.3` | YES |
| 9 | `docs/MULTI-PLATFORM.md` L3 | `2.44.3` | YES |
| 10 | `.claude/skills/tad-help/SKILL.md` L17 | ` Version: v2.44.3 \| Generated: [timestamp]` (leading space present) | YES |
| 11 | `.claude/skills/alex/SKILL.md` L50 | `<!-- TAD v2.44.3 Framework -->` | YES |
| 12 | `.claude/skills/blake/SKILL.md` L166 | `<!-- TAD v2.44.3 Framework -->` | YES |

§3.1 NEW strings are specified line-by-line. tad-help instruction to preserve leading space matches disk. `tad.sh` bump is scoped to L26 only (Forbidden/§10 correctly exclude dynamic `TARGET_VERSION=`). AC0a pre-impl evidence in §9.1 matches disk.

### 2) CHANGELOG honesty

- Disk: `## [Unreleased]` (L8) immediately followed by `## [2.44.3] - 2026-09-08` (L10). Matches AC0b.
- Proposed §3.3 body names all three Gate 4 locks:
  - `brain-index.md` not synced (`TOP_DENY` / `TAD_TOP_DENY`)
  - Option A README-only at pk root (empty `patterns/` / `incidents/`; no `framework-principles.md`)
  - `tad.sh --quarantine-pk` opt-in; never auto on `tad.sh update`
- Honesty rules in §3.3 forbid auto-quarantine, distributing `brain-index.md`, and claiming fleet/live-model already upgraded.
- Gate 4 carriers confirm those locks (Option A + `--quarantine-pk` in Human Locks; `brain-index.md` in TOP_DENY / TAD_TOP_DENY AC1.1–1.2). Proposed CHANGELOG cites both Gate 4 paths.

P4 `--notes` also names the three locks (brain-index not synced; README-only Option A; `--quarantine-pk` opt-in). No overclaim vs Gate 4.

### 3) Sixteen pathspecs

§3.5 `git add --` list counted **exactly 16**:

1. `.tad/version.txt`  
2. `.tad/TAD-VERSION`  
3. `.tad/config.yaml`  
4. `package.json`  
5. `tad.sh`  
6. `README.md`  
7. `INSTALLATION_GUIDE.md`  
8. `PROJECT_CONTEXT.md`  
9. `docs/MULTI-PLATFORM.md`  
10. `.claude/skills/tad-help/SKILL.md`  
11. `.claude/skills/alex/SKILL.md`  
12. `.claude/skills/blake/SKILL.md`  
13. `.agents/skills/tad-help/SKILL.md`  
14. `.agents/skills/alex/SKILL.md`  
15. `.agents/skills/blake/SKILL.md`  
16. `CHANGELOG.md`

Equals Execution Mandate item 1 (12 primary + CHANGELOG + 3 `.agents` mirrors) and Gate 2 table “12 identity files + 3 mirrors + CHANGELOG”. AC4 verification is `git show --name-only` equals those 16; parent `65963d6b`. Forbidden: `git add -A`, `.`, directory adds, `-p`/`-i`. Reconstruction rule covers dirty `PROJECT_CONTEXT.md`. Spec is complete for pathspec isolation.

### 4) Sequential publish (P1–P4)

§3.6 lists **four separate commands** in four fenced blocks: P1 push main, P2 annotated tag, P3 push tag, P4 `gh release create`. Text requires a new shell invocation each; **no `&&` / `;` joining P1–P4**. Mandate Forbidden and §10 repeat the anti-pattern `git push && git tag && git push --tags`. P3 uses scoped `refs/tags/v2.44.4:refs/tags/v2.44.4` (not `--tags`). Recovery: ls-remote, no `--force`.

### 5) Gate 4 citation paths

Both load-bearing paths exist on disk:

- `/home/box/云同步/TAD/.tad/evidence/reviews/2026-09-09-gate4-acceptance-knowledge-seam-isolation.md` — Verdict **PASS → ACCEPTED**; SHAs `e6e2126e` + `65963d6b`
- `/home/box/云同步/TAD/.tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md` — same verdict and SHAs

Handoff §2 and design pointer cite the same paths. Feature Gate 4 still says “local only; do not push” for **that** task; §10 correctly re-scopes this mandate as authorization to publish those commits as `v2.44.4`. Not a spec contradiction if Blake follows §10.

### §9.1 / §4 / §5 alignment

- AC1–AC8 are post-impl-verifiable with verbatim commands and expected evidence.
- AC0a–AC0d are pre-impl; AC0a/AC0b re-verified here on disk.
- §5 OUT of scope matches design pointer (no feature work, no dirty-tree absorption, no force, no sync, no reopening locks).

---

## 1. Critical Issues (P0)

**P0 count: 0**

No blocking spec gaps on the 12 markers, CHANGELOG proposed honesty, 16-file pathspec, unchained P1–P4, or Gate 4 cite existence.

---

## 2. Recommendations (P1)

**P1 count: 1**

1. **Feature Gate 4 “do not push” vs this publish mandate.** Both Gate 4 files still say implementation is local-only / do not push. Handoff §10 already resolves this for Blake. Recommendation: when executing, treat §10 + Execution Mandate as the governing publish grant; do not treat the feature Gate 4 banner as a stop on P1–P4 after this handoff is `READY_FOR_BLAKE`. Not a design defect; operational confusion risk only.

---

## 3. Suggestions (P2)

**P2 count: 2**

1. **README L5 vs CHANGELOG §3.3 wording.** README proposed L5 uses “install pk README-only”; CHANGELOG uses “Option A: `README.md` only”. Both name the lock; AC3 checks CHANGELOG body. Fine as written; keep Option A in CHANGELOG (already present).
2. **AC0c/AC0d** (tip SHA / absent `v2.44.4` tag) are pre-impl and were **not** re-read from `.git/refs` in this bounded review (out of stated line list). Blake must still run §3.0 ls-remote before P1.

---

## 4. Overall Assessment

**VERDICT: PASS**

- P0 = 0  
- P1 = 1 (operational reminder only)  
- P2 = 2  

Spec is implementable: 12 OLD markers confirmed `2.44.3`; CHANGELOG head is Unreleased then `[2.44.3]`; proposed `[2.44.4]` names brain-index not synced, Option A README-only, and `--quarantine-pk` opt-in; exactly 16 pathspecs; P1–P4 are unchained; both Gate 4 citation files exist with PASS → ACCEPTED.
