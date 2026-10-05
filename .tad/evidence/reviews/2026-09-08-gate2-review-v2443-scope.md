---
gate: 2
handoff: .tad/active/handoffs/HANDOFF-20260908-release-v2443.md
reviewer: Reviewer 2 — Safety & Blast Radius Auditor (independent, OpenCode)
date: 2026-09-08
channel: OpenCode
model: opencode-go/muse-spark-1.3-contributor
scope: dirty-tree isolation, forbid --force/--tags, rollback, remote safety
counts: {P0: 0, P1: 2, P2: 1}
verdict: PASS
---

harness=OpenCode | model=opencode-go/muse-spark-1.3-contributor | route=local

# Gate 2 Review — Reviewer 2 (Safety & Blast Radius Auditor) — HANDOFF-20260908-release-v2443

## Scope

- Target: `/home/box/云同步/TAD/.tad/active/handoffs/HANDOFF-20260908-release-v2443.md` (status `READY_FOR_GATE2`, Express patch publish v2.44.3, publish-only NO sync, remote `https://github.com/Sheldon-92/TAD.git`).
- Scope limited to: (1) dirty-tree isolation, (2) `--force`/`--tags` prohibition + scoped refspecs, (3) rollback/recovery + pre/post verification, (4) remote safety & blast radius + Execution Mandate Blake-start gate.
- Read-only review. No commit/push/tag/add, no implementation, no remote mutation. No files written.
- Classification: P0 = blocks Gate 2; P1 = advisory; P2 = nit.

## Method (commands run)

1. `read` handoff file (283 lines, full content inspection).
2. `git status --porcelain | head -n 60` + `git status --porcelain | wc -l` → 227 dirty entries; staged nothing.
3. `git status | head -n 80` → branch `main` ahead of `origin/main` by 3 commits; large unstaged modified/deleted set.
4. `rg -n` contract-text inspection for `--force|--tags|git add|git push|git tag|gh release|ls-remote|git show --stat|refs/heads/main|refs/tags/v2.44.3|sync|STOP|abort|reset|Recovery|Blast radius|Consequence|Target|READY_FOR|dual.*carrier` (evidence lines cited below).
5. `rg -n --fixed-strings -- "--force"` and `"--tags"` separately to enumerate every occurrence and its context.
6. `git diff --stat | tail -n 5`, `git log --oneline -4`, `git diff --cached --name-only | wc -l` (staged=0), porcelain deleted-file sample.
7. `python3` count of §3.5 pathspec block → exactly 16 files, enumerated.

## Findings table

| # | Severity | Check | Evidence |
|---|---|---|---|
| 1 | PASS (P0 gate satisfied) | Dirty-tree isolation: §3.5 WARNING + §1 Blast radius/Recovery require STRICT PATHSPEC-ONLY staging of exactly 16 files | §1 L37-39: "Working tree: MUST NOT absorb dirty/mode noise. Working tree has large unrelated dirty/mode noise — staging is strictly pathspec-only."; §3.5 L158-160: "MUST NOT use `git add -A`, `git add .`, or directory adds"; §3.5 block L163-179 enumerates exactly 16 pathspecs (verified by script count=16: `.tad/version.txt`, `.tad/TAD-VERSION`, `.tad/config.yaml`, `package.json`, `tad.sh`, `README.md`, `INSTALLATION_GUIDE.md`, `PROJECT_CONTEXT.md`, `docs/MULTI-PLATFORM.md`, 3× `.claude/skills/*/SKILL.md`, 3× `.agents/skills/*/SKILL.md`, `CHANGELOG.md`); §3.5 L186-190 pre-push guard `git show --stat HEAD` requires exactly 16 files, version+CHANGELOG only, zero unrelated/deleted files |
| 2 | PASS (P0 gate satisfied) | Ban on `git add -A` / `git add .` / directory adds / mass mode-chmod staging / uncommitted research files | Forbidden L47: "`git add -A`, `git add .`, or directory adds (`git add .claude/skills/`)"; Forbidden L48: "Staging mass mode changes (`chmod` script noise) or uncommitted research files."; repeated §3.5 L159 + §3.2 L112 note "Do NOT run broad directory copies or permissions modifications"; §5 L253 restates ban incl. "staging of mode noise / deleted research files" |
| 3 | PASS (P0 gate satisfied) | Pre-push guard `git show --stat HEAD` (exactly 16 files, version+CHANGELOG only) + abort/reset on absorption | §1 L45: "If `git show --stat R` contains any file other than the designated 16 version/CHANGELOG files, abort/reset before pushing."; §3.5 L186-190: "Run `git show --stat HEAD` and confirm: Exactly 16 files changed / ONLY version string bumps and CHANGELOG / Zero unrelated script files or deleted research files" |
| 4 | PASS (P0 gate satisfied) | `--force` appears ONLY in Forbidden/Recovery/STOP contexts, never in executable publish command | `--force` hits: L43 "Remote-ahead: STOP immediately, never `--force`." (Recovery); L49 "`--force`, `--tags`, unscoped refspecs." (Forbidden); L254 "No `--force` or `--tags` flags." (OUT OF SCOPE); L273 scope description. Zero hits in P1-P4 command blocks (L202, L206, L210, L214-227) |
| 5 | PASS (P0 gate satisfied) | `--tags` (push-flag sense) never in executable publish command; P1-P4 use scoped refspecs only | `--tags`-flag hits: L49 Forbidden list, L254 OUT OF SCOPE ban. P1 L202 `git push origin <commit_R>:refs/heads/main` (fully scoped); P2 L206 `git tag -a v2.44.3 <commit_R> -m ...` (no `--force`); P3 L210 `git push origin refs/tags/v2.44.3:refs/tags/v2.44.3` (fully scoped, no `--tags` flag); P4 L214 `gh release create v2.44.3 --title/--notes` (no `--force`/`--tags`). No `git push --all/--tags/--mirror`, no `git push origin main`, no unscoped refspec |
| 6 | PASS (P0 gate satisfied) | Recovery covers ambiguous push/tag, remote-ahead STOP (never --force), tag collision STOP, dirty absorption abort/reset | §1 L41-45 Recovery policy: "Ambiguous push/tag: `git ls-remote` check before any retry." / "Remote-ahead: STOP immediately, never `--force`." / "Tag collision: STOP." / "Dirty tree absorption: ... abort/reset before pushing." All four required branches present |
| 7 | PASS (P0 gate satisfied) | Pre-conditions §3.6 (ls-remote heads==7c1eb5a8, tags absent) + post-publish verification §3.7 (ls-remote heads/tags + gh release view + completion report path) | §3.6 L195-196: `git ls-remote --heads origin refs/heads/main` must be `7c1eb5a8` + `git ls-remote --tags origin refs/tags/v2.44.3` must be empty; §2 L65-67 corroborates `origin/main=7c1eb5a8`, `HEAD=c0184e13` ahead by 3, tag absent. §3.7 L231-234: heads==`<commit_R>`, tags + `^{}` both resolve to `<commit_R>`, `gh release view v2.44.3`, completion report `.tad/active/handoffs/COMPLETION-20260908-publish-v2443.md`. AC5-AC8 (L244-248) mirror these |
| 8 | PASS (P0 gate satisfied) | Remote safety & blast radius: Target only refs/heads/main + refs/tags/v2.44.3; Consequence 7c1eb5a8→c0184e13→R (4 commits), one tag, one release, NO sync; OUT OF SCOPE bans sync/feature code; Mandate forbids Blake before Gate 2 PASS with dual disk carriers | Target L30-32: `https://github.com/Sheldon-92/TAD.git` + `refs/heads/main` + `refs/tags/v2.44.3` only. Consequence L33-36: `7c1eb5a8 → c0184e13 (3 accepted commits) → commit R (total 4 new commits)`, new tag on R, public GitHub Release. Blast radius L37-40: remote main + one tag + release entry; no downstream sync/registry. Mode L16+L29 "publish-only ... NO downstream sync". OUT OF SCOPE L255-256: "No downstream project sync (`*sync` is retired). No new feature code or framework logic changes in commit R." Forbidden L50 bans chaining (`&&`/`;`) across push/tag; §3.6 L198 restates sequential NO chaining. Mandate L51: "Starting Blake before Gate 2 PASS with dual disk carriers." + §6 L262-278 STOP POINT, dual disk carriers (spec L269-273, scope L271-273), PM must verify both PASS then flip `READY_FOR_GATE2`→`READY_FOR_BLAKE` (L278) before `当 Blake` (L279-283) |
| 9 | P1 | Clarification: `ls-remote --tags` (read-only flag) shares the `--tags` substring but is NOT the forbidden `push --tags` | L196 `git ls-remote --tags origin refs/tags/v2.44.3` (pre-condition emptiness check) and L232 `git ls-remote --tags origin refs/tags/v2.44.3 "refs/tags/v2.44.3^{}"` (post-verify) are read-only verification commands, correctly scoped. They do not violate the §5/L49/L254 `--tags` ban (which targets push fan-out). Suggest future handoffs annotate "(`--tags` here is `ls-remote` read-only filter, not `git push --tags`)" to avoid false-positive greps. No action required for Gate 2 |
| 10 | P1 | Live dirty-tree characterization confirms isolation claim is plausible AND high-risk; guard is load-bearing | `git status --porcelain` = 227 lines, staged = 0. Top lines: `M .agents/skills/*/scripts/*`, `M .claude/skills/*/scripts/*` (mode/mode-churn pattern: `git diff --stat` tail shows `0`-delta mode-only entries e.g. `scripts/archive/upgrade-to-v1.3.sh | 0`, `tad | 0`, `tad.sh | 0`; total `205 files changed, 3 insertions(+), 4076 deletions(-)`). Deleted-file sample includes paired `.agents/`+`.claude/` research/reference deletions (`cost-token-economics.md`, `secret-detection-rules.md`, `design-tokens.md`, `starter-tokens.json`, `tokens-to-css.sh`) plus `.tad/active/research/...` deletions. Branch `main` ahead of `origin/main` by 3 (`7c1eb5a8 → fc2c07ce → d23f78ab → c0184e13`), matching §2. Nothing staged — any `git add -A`/`.` or directory add would absorb ~227 noise files into R, so the pathspec-only + `show --stat` abort gate is essential and correctly specified |
| 11 | P2 | Nit: P1 uses `<commit_R>` placeholder; P4 `gh release create` omits explicit `--target` | P1 L202 `git push origin <commit_R>:refs/heads/main` requires Blake to substitute the real R SHA (R does not exist until §3.5 commit; §3.7 defines `<commit_R>` binding). Acceptable but a reminder line ("resolve `<commit_R>` via `git rev-parse HEAD` after §3.5, use the literal SHA in P1-P3") would reduce substitution error. P4 creates release from tag `v2.44.3` without `--target`; default behavior is fine given tag==R, no safety impact |

## Counts

- P0: 0
- P1: 2 (items #9, #10 — advisory only, no Gate 2 block)
- P2: 1 (item #11 — nit)

## VERDICT

VERDICT: PASS
