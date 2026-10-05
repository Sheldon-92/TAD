# Security Audit — KEEP11 Knife 1 (impl commit 63cf6291)

- Commit: `63cf62912131d1f40273d54b0e6456aad9ba33af` — "feat(packs): KEEP11 knife 1 CLI/SHA refresh for code-security + web-deployment (TASK-20260911-KEEP11-KNIFE1)"
- Scope: NARROW — CLI/supply-chain safety of this commit only. No pack code modified.
- Method: measured (`git show`, parent-diff comparison, upstream web check). No assumptions.
- Files touched: 41 × `M`, all `*.md` (md-only; no code, no workflow files, no live-scan artifacts).

## Q1 — Unsafe copy-paste commands / live-scan artifacts

- `git show --name-status 63cf6291`: all 41 entries `M *.md` (`.agents/`, `.claude/`, `.tad/capability-packs/` mirrors). No added `.json/.sarif/.log`, no workflow files. **No live-scan artifacts.**
- Scan-verb grep over diff (`nuclei -t`, `semgrep --config prod`, `trufflehog/gitleaks prod`, `curl|sh`, `wget|sh`, exfil, `--insecure`): no hits. Only matches are benign context lines:
  - `http://prometheus:9090` — internal Docker-DNS datasource example; PRE-EXISTING (parent `.tad/capability-packs/web-deployment/references/monitoring-rules.md:78`).
  - `$SENTRY_AUTH_TOKEN` — env-var placeholder, not a hardcoded secret.
  - `res.cookie('session', token, ...)` — code-variable example in added hardening text, not a credential.
- Destructive/privileged verbs: none (`rm -rf`, `chmod 777`, `--insecure`, `curl … | sh` absent).
- Result: **clean**.

## Q2 — Checkout SHA pin + re-resolve caveat + find-action-sha.sh + CI2 anti-pattern

- SHA refresh `b4ffde65…` → `692973e3d937129bcbf40652eb9f2f61becf3332 # v4.1.7`: 40-char hex + `# v4.1.7` comment, applied consistently in `ci-cd-pipeline-rules.md` (×3 mirrors), `SKILL.md`/`CAPABILITY.md` finding-template blocks. Evidence: `git show 63cf6291 | grep checkout@` lines 318–344 / 736–762.
- Re-resolve caveat PRESENT and new in this commit (`.tad/capability-packs/web-deployment/references/ci-cd-pipeline-rules.md:1333`): "> ⚠️ **The SHAs above are illustrative, not authoritative.** … Always **re-resolve** … with `scripts/find-action-sha.sh <owner/repo> <tag>` (or the `git ls-remote` below) before committing — never copy a SHA from a doc." Plus `git ls-remote … refs/tags/v4.1.7` retained alongside. This is the correct anti-rot posture (post CVE-2025-30066/CI9).
- `find-action-sha.sh` guidance: script EXISTS at `.agents/skills/web-deployment/scripts/find-action-sha.sh` and `.claude/skills/web-deployment/scripts/find-action-sha.sh` (pack-relative `scripts/` path; no repo-root `scripts/` copy — expected, not a gap). Banner wording "via scripts/find-action-sha.sh" resolves pack-relatively. Verified via `git ls-files | grep find-action`.
- CI2 `@v4`-as-anti-pattern INTACT: `ci-cd-pipeline-rules.md:10` index row "SHA-pin all third-party actions — never use `@latest` or `@v4` tags", §CI2 "NEVER reference actions by tag … compromised maintainer can push malicious code to `@v4`", WRONG example `- uses: actions/checkout@v4 # mutable tag` retained, and CI6 row fixed to drop the `@v4` pin ("pinned to the current v4-line SHA").
- SHA liveness claim ("re-resolved live") could not be independently re-resolved here (no network assertion attempted), but format + caveat + dual-resolve path (`find-action-sha.sh` / `git ls-remote`) make stale-copy risk explicitly handled rather than hidden.
- Result: **pass**, with one exception documented under Findings (new unpinned example in a different file, not in CI2 itself).

## Q3 — Flag changes vs upstream (new forms correct? old forms dead? silent no-op risk?)

- TruffleHog `--only-verified` → `--results=verified` (7 call sites + SE7 row + anti-pattern line, ×3 mirrors).
  - Upstream (measured 2026-09-11): pkg.go.dev `trufflehog v3@v3.97.4` quick-start uses `--results=verified` exclusively; `--results` spec "verified (confirmed valid by API), unknown …, unverified …, filtered_unverified … Defaults to verified,unverified,unknown". `main.go @ main` shows `only-verified = cli.Flag("only-verified", …).Hidden().Bool()` with shim `if *onlyVerified { r := "verified"; results = &r }`.
  - Assessment: NEW form is the documented canonical form — correct, cannot silently no-op. OLD form was NOT hard-dead (still works as a hidden alias), so banner wording "GONE" is overstated; but migrating to the canonical flag is the right hardening (a future removal of the hidden shim would turn every old call site into a hard CLI error, and on some versions unknown-flag handling differs). No silent-verification-bypass introduced: `--results=verified` narrows output to verified-only, matching the file's stated SE7 intent.
- `flyctl certs show` → `flyctl certs check` (`domain-dns-rules.md`, ×3 mirrors).
  - Upstream (measured): `fly.io/docs/flyctl/certs` lists subcommands `add | check | import | list | remove | setup` — there is NO `show`. `check` = "Show certificate and DNS status".
  - Assessment: OLD form was dead (unknown subcommand → CLI error, i.e. a DNS-validation step that never runs). NEW form is correct and cannot silently no-op (valid subcommand; failure surfaces as non-zero exit).
- `certbot --nginx` / `certbot renew --dry-run` correctly left unchanged (no upstream change).
- Result: **both flag changes verified correct; no silent no-op introduced**.

## Q4 — Secrets/credentials in the diff

- Precise grep over full diff for `AKIA[0-9A-Z]{10,}`, `ghp_/gho_[A-Za-z0-9]{10,}`, `BEGIN .*PRIVATE KEY`, `xox[bap]-`, `password\s*=\s*['"][^'"]+['"]`: **zero matches**.
- Loose grep hits reviewed and dismissed: `$SENTRY_AUTH_TOKEN` (placeholder), `token` (cookie-var example), `id-token: write` / `attestations: write` (OIDC least-privilege scopes, desirable), `http://prometheus:9090` (pre-existing internal example).
- Result: **no leaked secrets**.

## Pre-existing vs introduced (verified via `git show 63cf6291^:<path>`)

- `actions/checkout@v4` in `sast-rules.md`: INTRODUCED by this commit (parent file has zero `checkout` matches; current `.tad/capability-packs/code-security/references/sast-rules.md:184` adds `- uses: actions/checkout@v4` inside the new "GitHub Actions — current recommended setup" YAML). → Finding F1.
- `semgrep/semgrep` container image unpinned (`image: semgrep/semgrep` + `# official image; pin a digest/tag in prod`): INTRODUCED by same block, but the pinning obligation is stated inline → note only, not a finding.
- Unpinned install verbs (`pip install semgrep/checkov/zizmor`, `brew install`, `npx tsc`, `npm install` prose, `npx pin-github-action`, `uvx zizmor`): all PRE-EXISTING context lines (same in parent; only version-string/table deltas in this commit) → notes at most, not findings.
- `actions/cache@0c45773… # v4.0.2` unpinned-SHA-stale reference: PRE-EXISTING (parent `ci-cd-pipeline-rules.md:141`), untouched → not a finding.

## Findings

- **P1 — F1 (introduced, docs-level supply-chain anti-pattern): new SAST example uses an unpinned tag, contradicting the pack's own CI2 MANDATORY rule.** Files (×3 mirrors, same block): `.tad/capability-packs/code-security/references/sast-rules.md:184`, `.agents/skills/code-security/references/sast-rules.md` (same S5 block), `.claude/skills/code-security/references/sast-rules.md` (same S5 block) — `- uses: actions/checkout@v4` with no SHA and no adjacent re-resolve pointer. A reader copy-pasting this "current recommended setup" gets exactly the mutable-tag posture CI2 forbids (`ci-cd-pipeline-rules.md:52-58`), and `sast-rules.md` carries no illustrative-SHA caveat to redirect them. Fix (suggested, not applied — do NOT modify pack code per review scope): pin to the same `692973e3… # v4.1.7` SHA with a `# v4.1.7 — re-resolve via scripts/find-action-sha.sh before committing` comment, or add an inline `> ⚠️ re-resolve` pointer to `ci-cd-pipeline-rules.md` CI2.
- P0: **none**. No live exploit, no secret leak, no destructive command, no silently-disabled security gate.

## Verdict

- **CONDITIONAL PASS** — CLI refresh (TruffleHog, flyctl) and SHA-pin hygiene (CI2 intact, re-resolve caveat, CI6 `@v4` removal) are sound and upstream-verified; no secrets, no unsafe copy-paste, md-only with no scan artifacts. One introduced P1 docs inconsistency (F1: unpinned `actions/checkout@v4` in the new SAST YAML example, ×3 mirrors) should be fixed before Gate 3 sign-off.
- Counts: **P0: 0, P1: 1**.
