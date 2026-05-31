# Code Review — release-hygiene-conventions (Debt Bundle H1)

**Reviewer:** code-reviewer (post-implementation, adversarial)
**Commit:** `ae387ef83c64330c05968a544dec9b417ed8ee2e`
**Spec:** HANDOFF-20260531-release-hygiene-conventions.md §6, §9.1
**Method:** Re-derived every AC result independently in the repo. Did NOT trust the COMPLETION report — re-ran each command and inspected the actual blobs (both the committed blob and the parent blob `ae387ef~1`).
**Date:** 2026-05-31

## Summary

A small, well-scoped release-hygiene + conventions debt bundle: a 3-part version-scheme unification in `tad.sh`, an unknown-flag guard, current-display version-string bumps across 5 doc/codex files (history preserved), two release-runbook rows, and a doc-only express-slug naming convention mirrored into the alex + blake SKILLs. Exactly 10 files changed (9 spec files + COMPLETION), no scope creep. Every acceptance criterion holds under independent re-derivation. The implementation correctly navigated the two genuine hazards in this handoff — the AR-001 phrase-displacement trap and the history-vs-current-display preservation trap — without tripping either.

---

## 1. Critical Issues (P-zero)

**None.** No issue with a concrete reproduction rises to blocking severity. All acceptance criteria were re-derived and pass.

---

## 2. Recommendations (P-one)

### P-one-1: AR-001 mechanical guard passes only by coincidence of a self-referential comment

The mechanical AR-001 anchor used historically (per `phase3-new-paths` evidence) is:

```
grep -A 30 'express_path_protocol:' alex/SKILL.md | grep -c 'expert review.*code-reviewer|code-reviewer.*expert review'   # expects >=1
```

The protocol header sits at L2133 and the guarded `step2 expert review ... code-reviewer` phrase sits at L2168 — that is 35 lines downstream, i.e. **outside** a literal 31-line `-A 30` window from the header. The guard nonetheless returns `2` (PASS) because the word "express_path_protocol:" appears a SECOND time at L2164 inside an explanatory comment ("...following `express_path_protocol:` header."). `grep -A 30` therefore matches twice and emits a second 31-line window (L2164–2194) which DOES contain the phrase at L2168.

This is not introduced by H1 — I confirmed the parent blob `ae387ef~1` returns `2` as well, and the H1 blob returns `2` — so there is no regression and AC9 holds. But the guard's pass is load-bearing on an incidental comment mention, not on the phrase being within 30 lines of the real header. If a future edit rewords that comment to drop the literal token `express_path_protocol:`, the guard would silently drop to `1`... still PASS at the >=1 threshold, but the safety margin is thinner than it looks. Recommend either (a) moving the guarded `step2` line back within 30 lines of the true header, or (b) documenting in the AR-001 anchor evidence that the count-of-2 depends on the comment token. Non-blocking; the >=1 contract is satisfied.

### P-one-2: `tad.sh:165` comment still says "MAJOR.MINOR" after the scheme switched to 3-part

Line 165 reads `# Read TARGET_VERSION (MAJOR.MINOR) and actual full version`. The whole point of this bundle was to move `TARGET_VERSION` to 3-part (`2.19.1` = MAJOR.MINOR.PATCH). The comment is now stale and mildly misleading to the next maintainer who reads it before the glob-arm next-bump debt is addressed. One-line comment fix; no behavioral impact.

---

## 3. Suggestions (P-two)

### P-two-1: `detect_state()` glob-arm latent hazard is correctly out of scope but worth a NEXT.md cross-check

The handoff and COMPLETION both correctly record (out of scope) that the `2.1*`/`2.2*` glob arms (L306–313) will misclassify a future 3-part `2.19.x` as `v2.0` once the L304 exact-match fails on the next bump. I confirmed L304–313 were NOT touched by this commit, which is correct per spec item 1. Just flagging for the Gate 4 owner to verify this actually lands in NEXT.md, since it is the real follow-up debt this scheme change surfaces.

### P-two-2: express-slug convention is a proxy, not the durable fix (already acknowledged)

The slug-naming convention is the cheap fix; the durable fix is a frontmatter `express: true` marker consumed by `layer2-audit.sh`. Both SKILL additions and the COMPLETION explicitly say so. No action — recording that the reviewer agrees the convention leaves a residual false-WARN risk for any express handoff that forgets the naming rule.

---

## 4. AC Re-Derivation Log (independent)

| AC | What I ran / inspected | Result |
|----|------------------------|--------|
| AC1 | `grep -c 'TARGET_VERSION="2.19.1"' tad.sh` = `1`; `grep -n 'TARGET_VERSION="2.19"' tad.sh` = no match (exit 1) | PASS |
| AC2 | `bash tad.sh --bogusflag` → `tad.sh: unknown option '--bogusflag' (use --help)`, exit `1`; `--help`/`-h` exit `0` with usage; simulated loop confirms `--yes`/`-y` set AUTO_YES=1 and no-arg leaves AUTO_YES=0 (no fall-through to `*)`) | PASS |
| AC3 | `grep -rn '2\.19\.0' README.md INSTALLATION_GUIDE.md tad-help/SKILL.md codex-alex codex-blake` → EXACTLY 1 line: `README.md:354` (version-history row, preserved). No stragglers | PASS |
| AC4 | `git show ae387ef -- CHANGELOG.md` empty; CHANGELOG `[2.19.0]` at L14 intact; README `v2.19.0.*Observational` history row present; codex `Generated: 2026-05-04` dates preserved on both files | PASS |
| AC5 | `grep -cE '855\|632' release-runbook/SKILL.md` = `2` (rows 17/18 cite literal line numbers) | PASS |
| AC6 | `grep -ci 'slug.*express\|express.*slug' alex/SKILL.md` = `6` (>=1) | PASS |
| AC7 | `bash -n tad.sh` exit `0` | PASS |
| AC8 | Throwaway dir `/tmp/tadtest_ac8/.tad/version.txt`=`2.19.1`, exercised `detect_state()` → `STATE=current` (L304 exact-equality fires before glob arms) | PASS |
| AC9 | `grep -n 'expert review\|slug_convention\|scope_constraints\|required_steps' alex/SKILL.md`: scope_constraints L2149, required_steps L2161, guarded `step2 expert review ... code-reviewer 必选` L2168, slug_convention L2207 (downstream). Guarded phrase at L2168 in BOTH parent and H1 blobs → not displaced. AR-001 guard returns 2 (>=1) | PASS |
| Item 5 | `tad.sh:172` fallback now `${TARGET_VERSION}` (no `.0`); detect_state glob arms L304–313 untouched | PASS |
| Item 7 | blake/SKILL.md `slug_convention` mirror at L1392 (sibling of `slug_detection`, structurally clean); blake diff purely additive (`forbidden:` block untouched, appeared only as context); release-runbook rows 17/18 cite 855/632 | PASS |
| Scope | `git show --name-only`: exactly 9 spec files + COMPLETION. No unintended files | PASS |
| Contract | No `forbidden_implementations` / `NOT_via_*` / AR-001 line added or removed in either SKILL (verified via `git show ... | grep`) | PASS |

---

## 5. Overall Assessment

**PASS**

Every acceptance criterion was independently re-derived and holds. The two real traps in this handoff — preserving historical version references while bumping current-display strings (AC3/AC4), and inserting the slug_convention downstream of `required_steps` so the AR-001 guarded phrase is not displaced upward (AC9) — were both handled correctly. The COMPLETION report's claims match the ground truth I recomputed; no inflation or theater detected. The two P-one items are non-blocking hardening notes (a coincidental-comment dependency in the AR-001 guard, and one stale "MAJOR.MINOR" comment) and can be folded into the next-bump NEXT.md debt rather than reworked now.

**Critical issue count: 0.**
