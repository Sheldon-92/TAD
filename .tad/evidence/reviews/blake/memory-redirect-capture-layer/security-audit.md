# Security Audit — Memory Redirect Capture Layer (TASK-20260712-001)

**Auditor:** security-auditor (Blake Layer 2, independent)
**Date:** 2026-07-12
**Repo:** github.com/Sheldon-92/TAD (PUBLIC)
**Scope:** Sensitivity triage of 36 migrated memory files; .gitignore isolation; memory-redirect.sh injection/quoting; handoff §9.1 AC10 contract.
**Pass criteria:** critical (P0) = 0, high (P1) = 0.

---

VERDICT: PASS

---

## Executive Summary

The #1 audit target — the SAFE/SENSITIVE triage that decides what gets published to a public repo — is **correct**. I independently read all 29 files git would commit and re-derived the classification. Zero misclassifications: no emails, no credentials/tokens/keys, no personal identity, no verbatim private conversations, no unpublished non-TAD product strategy leaked in the 29 SAFE files. All 7 SENSITIVE files are provably git-ignored. The isolation mechanism is verified at the `git check-ignore` and `git add -n` level (ground truth, not paper). The shell script has no injection or path-quoting vulnerability and cannot clobber unrelated settings keys.

- **P0 (critical): 0**
- **P1 (high): 0**
- **P2 (hardening): 4**

---

## Target 1 — Sensitivity Triage (the #1 target)

### Method
Read all 29 files in `git status --porcelain -uall .tad/memory/` (the exact set git sees as untracked-committable). Re-derived SAFE/SENSITIVE per the report's R1–R4 rules, hunting for: emails, tokens/keys, personal identity, private third-party material, unpublished non-TAD product strategy, verbatim private conversations.

### Ground-truth verification (not paper)
```
git add -n .tad/memory/  → exactly the 29 SAFE files, none of the 7 SENSITIVE
git check-ignore <each of 7 SENSITIVE>  → all 7 IGNORED
git ls-files .tad/memory/  → empty (nothing committed to history yet; clean slate)
```

### Credential / email / identity sweep across all 29 SAFE files
Pattern set: `zhaos948|newschool|@gmail|@outlook|@qq.com|api_key|secret_key|-----BEGIN|ghp_|sk-…|xox[baprs]-|password[:=]`
**Result: zero hits.** The 4 mechanical grep hits noted in the report ("token cost", "header-token" CSP term, "token-burn", "args") are confirmed false positives — all are LLM-token or design-vocabulary usages, no credentials.

### Verbatim-conversation / home-path / friend-detail sweep across all 29 SAFE files
Pattern: `/Users/sheldonzhao|朋友|friend|co-thinking|SEED.md|leaked|泄露|newschool`
**Only one hit**, in `project_pack-quality-leveling-epic.md` line 43:
> 另：独立的"纯 skills 包给朋友"方向见 [[IDEA-20260613-tad-opt-in-mode-posture 文件内 Notes]]（未启动）

This is a bare direction-label ("a pure-skills pack for friends" idea, not started) with **no personal identity, no name, no private detail about any individual**. It is a TAD-scoped roadmap cross-reference. This matches the triage's own stated rationale for file #24 ("朋友" mention is a cross-reference to an idea name, no personal identity). **Correctly SAFE.** No re-classification needed.

Notably, the two SENSITIVE files that carry the actual private material — `project_co-thinking-workshop-seed.md` (contains the absolute home path `/Users/sheldonzhao/01-on progress programs/co-thinking-workshop/SEED.md` and the unpublished sibling-methodology core) and `project_tad-universal-method.md` (unpublished standalone-product strategy + "user's friends only use Codex, non-dev projects" personal context) — are both correctly gitignored, and **no SAFE file reproduces their sensitive content**. The wikilink references to them in SAFE files (`[[project_tad-universal-method]]`, `[[user_agent-builder-goals]]`) are just bracketed names; they leak the existence of a parked idea but no substance.

### Per-file re-classification of the 29 SAFE files
All 29 are TAD-framework-internal engineering records: Epic completion notes, pack build records, workflow/tooling lessons, TAD process/communication rules, and research methodology. None contain third-party private material or personal profile. Representative spot-checks:
- `feedback_no-sync-pull-based.md` — mentions the public repo install command `npx github:Sheldon-92/TAD` (already public) and a downgrade incident; framework-internal. SAFE.
- `feedback_plain-language-after-handoffs.md` / `plain-language-quality.md` — quote the user's *stated preference about communication style* ("我把内容交给 Blake…我还可以看一下你是怎么思考的"). This is a workflow-preference statement about the TAD tool itself, not a private third-party conversation or sensitive personal disclosure. Consistent with the triage's SAFE call for these (contrast with `feedback_share-mode-and-deflation.md`, which the triage conservatively marked SENSITIVE for carrying *interaction-style profiling* — a defensible finer-grained line). SAFE.
- `project_codex-adapter-validation.md`, `project_tad-next-direction.md`, `project_capability-packs.md` — TAD's own public-facing direction/architecture, already reflected in tracked OBJECTIVES/NEXT. SAFE.

**Conclusion: triage is correct. 0 misclassified-SAFE files.**

---

## Target 2 — .gitignore Isolation Robustness

Added block (additive, at end of .gitignore):
```
.tad/memory/user_*
.tad/memory/MEMORY.md
.tad/memory/feedback_share-mode-and-deflation.md
.tad/memory/project_co-thinking-workshop-seed.md
.tad/memory/project_tad-evolution-directions.md
.tad/memory/project_tad-universal-method.md
.tad/memory/reference_claude-code-source.md
```

Verified:
- All 7 SENSITIVE files → `git check-ignore` returns 0 (ignored). ✅
- `user_*` glob is future-proof: a hypothetical new `user_something-new.md` is caught (`.gitignore:62` matches). ✅ — this covers the R1 `type: user` class going forward without re-triage.
- `MEMORY.md` explicit entry covers the native ledger, which auto-absorbs future one-liner memories with no re-triage — correctly kept out of git. ✅
- The 5 per-file SENSITIVE entries are exact-path; no glob gap.

**Residual gap (P2, not P1):** The 6 non-`user_` SENSITIVE files are pinned by exact filename. A *newly created* SENSITIVE memory that is NOT `user_*`-prefixed (e.g. a future `reference_*` leaked-source analysis, or a `project_*` unpublished-strategy note) would default to SAFE/committable and require manual re-triage. This is inherent to a deny-list of individually-named files and is explicitly acknowledged by the handoff (T3d + runbook gotcha: pre-`*publish` re-scan is mandatory; push is out of scope for this handoff). Because push is gated behind a required re-scan, this does not rise to P1. See P2-1.

---

## Target 3 — memory-redirect.sh Injection / Quoting / Clobber Audit

`bash -n` clean. Reviewed against spaces-in-path (`/Users/sheldonzhao/01-on progress programs/TAD`), jq arg handling, mktemp, and settings clobber.

**No injection / no quoting bug:**
- `ROOT="$(pwd)"`, `TARGET_DIR="$ROOT/.tad/memory"`, `OLD_DIR="$HOME/.claude/projects/$SLUG/memory"` — every expansion that touches the space-containing path is double-quoted at every use site (`ls "$OLD_DIR"`, `cp -n "$OLD_DIR"/*.md "$TARGET_DIR"/`, `mkdir -p "$TARGET_DIR"`). The `*.md` glob sits outside the quotes correctly so it still expands, while the directory prefix stays quoted. Verified `cp` line handles spaces.
- `TARGET_DIR` is passed to jq via `--arg d "$TARGET_DIR"` — jq treats `--arg` values as literal strings, so no path content (spaces, quotes, `$`, backticks) can inject jq program code. This is the correct, injection-safe pattern.
- `SLUG` derivation `sed 's![/ ]!-!g'` verified against reality: produces `-Users-sheldonzhao-01-on-progress-programs-TAD`, and `$OLD_DIR` resolves to the real 36-file directory. The script also hard-checks `[ ! -d "$OLD_DIR" ]` and warns rather than silently proceeding (SEC P1-3 mitigation present).

**No settings.local.json clobber:**
- Enable path: `jq --arg d "$TARGET_DIR" '. + {autoMemoryDirectory: $d}'` — the `. + {…}` object-merge adds/overwrites ONLY the `autoMemoryDirectory` key; all sibling keys (notably the large `permissions.allow` list) are preserved untouched. Simulated the merge on the live file: `diff <(jq -S .permissions before) <(jq -S .permissions after)` → **empty (deep-equal)**. ✅ (satisfies AC1).
- Revert path: `jq 'del(.autoMemoryDirectory)'` deletes only that key. ✅
- Writes go through `tmp="$(mktemp)"` then `jq … > "$tmp" && mv "$tmp" …` — the `&&` guards `mv` behind jq success, so a jq failure cannot truncate/blank the real settings file (jq writes to tmp, not in place). `mktemp` files are mode 0600 by default. No fixed `/tmp/...` predictable filename → no symlink/race attack surface.

**Guards present:** run-from-root check (`.tad/config.yaml`), `set -euo pipefail`, `command -v jq`.

**SAFETY end-to-end (T2) re-verified live:**
- `derive-sync-set.sh --zero-touch | grep -cx memory` → 1 ✅
- `derive-sync-set.sh --dirs | grep -cx memory` → 0 (memory excluded from sync set) ✅
- `tad.sh --verify-denylist; echo $?` → 0 (lib==tad.sh set-equality holds; the duplicate hardcoded `TAD_ZERO_TOUCH` in tad.sh was updated in lockstep) ✅

So `.tad/memory/` (including any SENSITIVE files that live only on the origin machine) can never be carried to a downstream project by `*sync`/install at any copy granularity. This is a second independent containment layer beneath the .gitignore — good defense-in-depth for the exact "personal data escapes" threat.

---

## Findings

### P0 (critical) — none
### P1 (high) — none

### P2 (hardening)
- **P2-1 — Deny-list of named files needs a pre-publish gate that is enforced, not just documented.** New non-`user_*` SENSITIVE memories default to committable. Mitigation exists (runbook gotcha + T3d "push禁止, pre-*publish 复扫") but relies on operator discipline. Recommend the `*publish` runbook step be a hard checklist item / script that re-runs the sensitivity sweep against `git status` new `.tad/memory/` files and blocks on any `type: user` / leaked-source / unpublished-strategy hit. (Already the handoff's stated intent; this is about making it mechanical.)
- **P2-2 — Consider a broader defensive glob.** `.tad/memory/reference_*` (third-party/leaked-source analyses) and any future `user_*` are the two highest-risk auto-generated classes. `user_*` is already globbed; consider whether `reference_*` should be too, given the one existing `reference_claude-code-source.md` is SENSITIVE. Trade-off: a future benign `reference_*` would need a negative-override. Leave to human judgment.
- **P2-3 — `cp -n "$OLD_DIR"/*.md` only copies `*.md`.** If the native runtime ever writes a non-`.md` memory artifact it would be silently skipped by migration. AC2's `diff -rq` catches this as a content-completeness failure, so it is observable, not silent-in-practice. No action required.
- **P2-4 — `.tad/memory/` is world-readable on disk with SENSITIVE files present.** The SENSITIVE files are protected from *git* but sit in the working tree unencrypted. Acceptable for a single-user local machine (matches the project's single-user threat model, principles.md 2026-04-15); noting for completeness.

---

## AC10 Contract Check (handoff §9.1)

| AC10 clause | Result |
|---|---|
| Sensitivity report exists, 36 rows full coverage | ✅ (report present, 36-row table + summary) |
| Every SENSITIVE file `git check-ignore … = 0` | ✅ all 7 ignored |
| `git ls-files .tad/memory \| xargs grep -lEi '@…(edu\|com\|org)\|api…key\|password'` = empty | ✅ empty (ran the exact command) |
| No `user_*` tracked | ✅ (none tracked; `user_agent-builder-goals.md` ignored) |

AC10 PASS.

---

## Verdict Rationale

Critical = 0, High = 0 → **PASS** per stated criteria. The public-repo data-leak threat is closed by two independent layers (gitignore deny-list verified at `git check-ignore`/`git add -n` ground truth + zero-touch sync exclusion verified live), the triage is independently confirmed correct with zero misclassifications, and the redirect script is free of injection, quoting, and settings-clobber defects. The only residual risk (P2-1) is future-facing operator discipline on new SENSITIVE memories, already gated behind a mandatory pre-publish re-scan and out of scope for this commit-only handoff.
