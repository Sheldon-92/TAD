---
gate: 2
handoff: HANDOFF-20260911-release-v2445.md
reviewer: Gate 2 Reviewer (Spec & Pathspec Compliance) — independent; not Alex
date: 2026-09-11
verdict: PASS
counts:
  P0: 0
  P1: 1
  P2: 2
---

Model: harness=cursor | model=Cursor Grok 4.6 | NO Gemini | no Blake | no implementation

# Gate 2 Review — Spec & Pathspec Compliance (v2.44.5)

**Handoff:** `.tad/active/handoffs/HANDOFF-20260911-release-v2445.md`  
**Design pointer:** `.tad/evidence/designs/2026-09-11-release-v2445-scope.md`  
**Reviewer role:** independent SPEC & PATHSPEC; not the author; no implementation; no Blake dispatch

**Verdict: PASS** (P0 = 0). Human may promote after the dual-carrier bar; this file does not start Blake.

---

## Bound

Read: handoff §3 / §3.1–§3.6 / §5 / §6 / §9.1 (plus §2 Gate 4 cites needed to judge honesty), design pointer, HEAD identity markers, CHANGELOG Unreleased → `[2.44.4]`, `git rev-parse HEAD` / peeled `v2.44.4`. No bump. No publish. No Gemini.

Spot-check at review time:

| Fact | Observed |
|------|----------|
| `git rev-parse HEAD` | `63cf62912131d1f40273d54b0e6456aad9ba33af` |
| `git rev-parse v2.44.4^{}` | `83e2ff03f48b3510482192797fc7f06e634f425d` |
| `git rev-parse v2.44.4` (tag object) | `4a9d655d58315b7c52479100ea87ac00b4380cb1` |
| `.tad/version.txt` (HEAD + WT) | `2.44.4` |
| `tad.sh` L26 (HEAD) | `TARGET_VERSION="2.44.4"` |
| CHANGELOG | L8 `## [Unreleased]` then L10 `## [2.44.4] - 2026-09-09` |
| `v2.44.4..HEAD` | `7048b835` `9c33e2e5` `eb09597a` `63cf6291` |

---

## Per-check table

| # | Check | Result |
|---|--------|--------|
| C1 | 12 identity bump locations + 3 `cp` mirrors + CHANGELOG = 16 pathspecs, consistent in §3.1 / §3.2 / §3.5 / AC4 | **PASS** |
| C2 | Parent of R is `63cf6291`; full SHA in §9.1 AC4 | **PASS** |
| C3 | No `&&` or `;` chaining across P1–P4 push/tag/release | **PASS** |
| C4 | CHANGELOG honesty: four deltas only; remaining KEEP11 knives out; no overclaim | **PASS** |
| C5 | Four Gate 4 citations present; paths exist on disk | **PASS** |
| C6 | §9.1 Verification Methods runnable (not prose-only) for landing rows | **PASS** |
| C7 | `tad.sh` bump is only `TARGET_VERSION` L26 | **PASS** |
| C8 | HEAD identity still `2.44.4` at stated sites | **PASS** |
| C9 | §5 / design pointer OUT-of-scope alignment (no remaining knives, no dirty-tree absorption, no force, no sync) | **PASS** |

---

## Focus findings

### 1) Sixteen pathspecs (12 + 3 + CHANGELOG)

§3.1 lists these **12** primary paths (NEW=`2.44.5`, OLD=`2.44.4` at HEAD `63cf6291`):

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

§3.2 then `cp`s the three bumped `.claude/skills/{tad-help,alex,blake}/SKILL.md` onto `.agents/skills/...` (explicit `cp`; not `parity --fix`).

§3.5 `git add --` (and the matching `git diff HEAD --` detect list) enumerates **exactly 16**:

1–12 as above, plus  
13. `.agents/skills/tad-help/SKILL.md`  
14. `.agents/skills/alex/SKILL.md`  
15. `.agents/skills/blake/SKILL.md`  
16. `CHANGELOG.md`

Matches Execution Mandate item 1, Gate 2 table (“12 identity files + 3 mirrors + CHANGELOG”), §6.2 (“The 16 pathspecs in §3.5”), and §9.1 AC4 (“equals the 16 paths”). AC4 binds by reference to that list rather than re-pasting names; the set is the same.

HEAD line sites still carry `2.44.4` (including README L3/L5/L190/L506, INSTALLATION_GUIDE L3/L51, PROJECT_CONTEXT HEAD L4/L6, MULTI-PLATFORM L3, tad-help L17 leading space, alex L50, blake L166, config.yaml L1/L3, package.json L3).

### 2) Parent of R

§3.0 / §3.5 / §9.1 AC4 require parent `63cf62912131d1f40273d54b0e6456aad9ba33af`. Observed HEAD is that SHA. §4 AC4 summary uses short `63cf6291` (same object; see P2).

### 3) P1–P4 unchained

§3.6: four fenced commands, “new shell invocation each; no `&&` / `;` joining P1–P4”. P1 `git push origin <commit_R>:refs/heads/main`; P2 `git tag -a v2.44.5 <commit_R> …`; P3 scoped `refs/tags/v2.44.5:refs/tags/v2.44.5`; P4 `gh release create` with line-continuation `\` only (single command, not a chain). Mandate Forbidden + §10 forbid `git push && git tag && git push --tags`.

### 4) CHANGELOG honesty

Proposed §3.3 `[2.44.5] - 2026-09-11` names exactly four landed SHAs (`7048b835`, `9c33e2e5`, `eb09597a`, `63cf6291`) with matching titles. Knife 1 line: remaining KEEP11 knives are **not** in this patch. Honesty rules additionally forbid freeze/unfreeze of other packs, `experiment-path` `ai-evaluation` dump, AGENTS ACI leftover, fleet auto-upgrade, and claiming the gitignored verify-delta fixture is in the tag. P4 `--notes` repeats the four-commit payload and “Remaining KEEP11 knives are not in this patch.” Aligns with design pointer payload table and §5.

### 5) Four Gate 4 citations — on disk

| Cite | Disk |
|------|------|
| `.tad/evidence/reviews/2026-09-10-gate4-verify-delta.md` | EXISTS (Verdict PASS) |
| `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260910-verify-delta.md` | EXISTS (no `GATE4-*` twin; handoff states that) |
| `.tad/evidence/reviews/2026-09-10-gate4-pack-loader-thin-ondemand.md` + `.tad/archive/handoffs/GATE4-20260910-pack-loader-thin-ondemand.md` | EXISTS |
| `.tad/evidence/reviews/2026-09-10-gate4-pack-freeze-inventory.md` + `.tad/archive/handoffs/GATE4-20260910-pack-freeze-inventory.md` | EXISTS |
| `.tad/evidence/reviews/2026-09-11-gate4-rerun-keep11-knife1-cli-refresh.md` + `.tad/archive/handoffs/GATE4-20260911-keep11-knife1-cli-refresh.md` | EXISTS |

### 6) §9.1 landing Methods are runnable

| Row | Method shape |
|-----|----------------|
| AC1 | `bash .tad/hooks/lib/release-verify.sh parity .` — exit 0 |
| AC2 | `bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.5` — Layer 1 exit 0 |
| AC3 | `grep -n '## \[2.44.5\] - 2026-09-11' CHANGELOG.md` plus honesty expected-evidence (see P2) |
| AC4 | `git show --name-only --pretty=format: HEAD`; `git rev-parse HEAD^` == full parent SHA; `git diff <parent> HEAD -- PROJECT_CONTEXT.md` |
| AC5 | `git ls-remote --heads origin refs/heads/main` |
| AC6 | `git ls-remote --tags origin refs/tags/v2.44.5 refs/tags/v2.44.5^{}` |
| AC7 | `gh release view v2.44.5 --json tagName,isDraft,url` |
| AC8 | `test -f .tad/active/handoffs/COMPLETION-20260911-publish-v2445.md` |

No landing row is command-free. Pre-impl AC0a–AC0e are also command-shaped; AC0a/AC0b/AC0c/AC0e re-verified here.

### 7) `tad.sh` L26 only

§3.1 item 5: only `TARGET_VERSION="2.44.5"` at line 26. §10: do not bump other `TARGET_VERSION=` lines. HEAD has L26 literal plus dynamic assignments at L39, L54, L2524 (`TARGET_VERSION="$v"` / `$EXPECTED_VERSION`) — correctly excluded.

---

## P0 / P1 / P2

### P0 (would ship wrong tag / pathspec / overclaim)

**P0 count: 0**

No blocking defect on the 16 pathspecs, parent SHA, unchained P1–P4, CHANGELOG four-delta honesty, Gate 4 path existence, landing AC Methods, or tad.sh L26 scope.

If this review were FAIL, the section to fix would be listed here. **N/A.**

### P1

**P1 count: 1**

1. **Feature Gate 4 “local only; do not push/tag/release” vs this publish mandate.** Knife-1 re-run and verify-delta evidence still banner local-only. Handoff §10 already tells Blake this mandate **authorizes** publishing those four commits as `v2.44.5`. Operational confusion risk only; not a pathspec or overclaim defect. Governing grant = Execution Mandate + §10 after `READY_FOR_BLAKE`.

### P2

**P2 count: 2**

1. **AC3 honesty tail is expected-evidence, not a second command** (`body names four SHAs… remaining KEEP11…`). Heading grep is runnable; Blake still must read the body. Not prose-only (command exists). Optional later tighten: add `grep -E '7048b835|9c33e2e5|eb09597a|63cf6291'` and `grep -F 'Remaining KEEP11 knives'`.
2. **§4 AC4 parent is abbreviated `63cf6291`** while §3.5 / §9.1 AC4 use the full SHA. Same object; prefer full SHA in the §4 checkbox for copy-paste parity. Also: `git show --name-only --pretty=format: HEAD` can emit a blank first line; compare to the §3.5 name list, not raw line count blindly.

---

## Alignment notes (non-findings)

- Dirty-tree reconstruction for `PROJECT_CONTEXT.md` is specified in §3.5; OUT of scope §5 matches the design pointer.
- Preflight forbids starting if HEAD ≠ `63cf6291…`.
- Local `v2.44.5` tag file absent at review time (AC0d shape).
