# Spec Compliance Review — KEEP11 Knife 1 CLI Refresh

- Task: TASK-20260911-KEEP11-KNIFE1 (handoff §6 + §9 ONLY — narrow scope)
- Handoff: `.tad/active/handoffs/HANDOFF-20260911-keep11-knife1-cli-refresh.md`
- Impl commit: `63cf62912131d1f40273d54b0e6456aad9ba33af`
- Date: 2026-09-11
- Reviewer: spec-compliance-reviewer (Layer 2, Group 0)
- Method: ran every AC command myself on the impl worktree; inspected `git diff-tree` / `git diff` of the impl commit. No pack code modified by this review.

## AC results table

All methods executed as specified in handoff §9.1. AC6/AC7 run with `IMPL_SHA=63cf62912131d1f40273d54b0e6456aad9ba33af`.

| # | Method (as run) | Actual stdout (verbatim, trimmed to signal lines) | Result |
|---|-----------------|----------------------------------------------------|--------|
| AC1 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC1` | `missing []` / `stale []` / `banners` / `OK`, exit 0 | PASS |
| AC2 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC2` | `drift []` / `parity` / `OK`, exit 0 | PASS |
| AC3 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC3` | `uses: actions/checkout@692973e3d937129bcbf40652eb9f2f61becf3332  # v4.1.7` / `old_sha []` / `live_sha 692973e3d937129bcbf40652eb9f2f61becf3332` / `missing_live_sha []` / `sha` / `OK`, exit 0 | PASS |
| AC4 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC4` | `ci6_bad []` / `CI6_ok` / `ci6` / `OK`, exit 0 | PASS |
| AC5 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC5` | `stale_deadline []` / `deadline` / `OK`, exit 0 | PASS |
| AC6 | `IMPL_SHA=63cf62912131d1f40273d54b0e6456aad9ba33af python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC6` | `names [41 files …]` / `extra []` / `pathspec` / `OK`, exit 0 | PASS |
| AC7 | `IMPL_SHA=63cf62912131d1f40273d54b0e6456aad9ba33af python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC7` | `forbidden []` / `forbidden` / `OK`, exit 0 | PASS |
| AC8 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC8` | `inventory_bytes 5691` / `inventory` / `OK`, exit 0 | PASS |
| AC9 | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC9` | `cappack_drift []` / `cappack` / `OK`, exit 0 | PASS |

9/9 AC rows PASS. No reruns needed; every command exited 0 on first execution.

## Scope discipline

- `git diff-tree --no-commit-id --name-only -r 63cf6291` lists 41 files. Every name falls under one of the six allow prefixes in handoff §7.2 (`.claude/skills/code-security/**`, `.agents/skills/code-security/**`, `.tad/capability-packs/code-security/**`, `.claude/skills/web-deployment/**`, `.agents/skills/web-deployment/**`, `.tad/capability-packs/web-deployment/**`). Consistent with AC6 `extra []`.
- Forbidden paths (§7.2 list: frozen 14 packs, other KEEP 9, `pack-registry.yaml`, loaders, `experiment-path-protocol.md`, `AGENTS.md`, `CLAUDE.md`, `tad.sh`, `.tad/hooks/**`, `principles.md`, CHANGELOG/version, `NEXT.md`, handoff, verify.py): none present in the impl commit name list. Consistent with AC7 `forbidden []`.
- CI2 `@v4` anti-pattern intact as the WRONG example: `.claude/skills/web-deployment/references/ci-cd-pipeline-rules.md:54` still reads "Tags are mutable — a compromised maintainer can push malicious code to `@v4`", with the WRONG block at L56–58 (`- uses: actions/checkout@v4  # mutable tag`). The commit did NOT convert CI2's anti-pattern into a recommendation; CI6 (L14) was the only index row reworded, and it no longer teaches `@v4` as the pin. Other `@v4` mentions (L269 upload-artifact v4 migration, L333 dead-v3 note) are unrelated upgrade guidance, not checkout tag pins.
- `examples/cicd-sha-pin-oidc.md` untouched: not in the impl commit name list; `git log` shows last touch `ba1fa9c6`, and its `@v4`-as-bad-input fixture lines (L27, L34–35) are preserved.
- `cli-inventory.md` exists on the worktree (`.tad/evidence/acceptance-tests/keep11-knife1/cli-inventory.md`, 5691 bytes, names gitleaks + checkout with ABSENT + PATH/http evidence columns) but is NOT in the impl commit (`grep -c cli-inventory` on the diff-tree output = 0), as required by §4.1 step 1 / §7.1.

## Hunk classes

Checked the `.claude`-side diff (`git diff 63cf6291^ 63cf6291 -- .claude/skills/code-security .claude/skills/web-deployment`) hunk by hunk against §4.2:

- HTML banners: added `Verified against … on 2026-09-11 …` comments on SKILL.md + all touched references files. Allowed.
- Command lines: TruffleHog `--only-verified` → `--results=verified` (secret-detection-rules.md); `flyctl certs show` → `flyctl certs check` (domain-dns-rules.md). Both are the subcommand-rename / dead-subcommand class. Allowed.
- SHA pins: `actions/checkout@b4ffde65…` → `@692973e3d937129bcbf40652eb9f2f61becf3332` (SKILL.md, ci-cd-pipeline-rules.md ×4, CAPABILITY.md). Matches AC3 live SHA. Allowed.
- Version tokens: semgrep v1.163.0→v1.176.0, nuclei v3.8.0→v3.11.1, osv-scanner v2.3.5→v2.5.1 in SKILL.md / sast-rules.md / dast-rules.md / vulnerability-triage-rules.md. Allowed.
- Retrieval dates: `retrieved 2026-06-13` → `retrieved 2026-09-11` on touched claims. Allowed.
- CI6 index wording: `with actions/cache@v4` → `with actions/cache, pinned to the current v4-line SHA`. Allowed.
- Triage example deadline: `2026-05-20` → `P0: 24h from detect (relative — never a fixed calendar date)`. Allowed.
- No new tools, no new capabilities, no frozen-pack touches, no eval-fixture edits, no essay rewrites beyond the retrieval-date bumps on pages already opened for a CLI check were observed on the `.claude` side.
- `.tad/capability-packs/**` hunks are larger (e.g. ci-cd-pipeline-rules.md +131, vulnerability-triage-rules.md +89, sast-rules.md +60): inspected and found to be backfill parity syncing content that already exists on the `.claude` SSOT side (CI9–CI13 incident/zizmor/attestation sections, semgrep `--pro` interfile prose) into previously drifted cap-pack files. FR7/AC9 explicitly require this lockstep, and AC9 now reports `cappack_drift []`. Not a new-capability violation.

## Findings

none — no P0, no P1 within the §6 + §9 narrow scope. All 9 AC methods PASS as-run, pathspec ⊆ allow prefixes, CI2 anti-pattern preserved, fixture file untouched, inventory present-but-unstaged, and every `.claude`-side hunk falls in a §4.2 allowed class.

## Verdict

PASS — impl commit `63cf62912131d1f40273d54b0e6456aad9ba33af` satisfies handoff §6 (FR1–FR8 via §9.1 AC1–AC9, all green as independently re-run) and §9 scope/hunk discipline. No blocking or advisory findings from this reviewer. (Out-of-scope areas — code style, security substance of SHAs/CLIs beyond what verify.py checks — are left to the code-reviewer / security-auditor sessions.)
