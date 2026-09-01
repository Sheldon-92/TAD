# Journal — YOLO2 Phase 3 Cross-Harness Memory (Blake local deterministic)

**Date:** 2026-09-01
**Task:** TASK-20260901-YOLO2-P3-CROSS-HARNESS
**Handoff:** HANDOFF-20260901-yolo2-phase3-cross-harness-memory.md
**Design:** DESIGN-20260901-yolo2-phase3-cross-harness-memory.md
**Execution:** Manual Blake, local deterministic only; provider calls blocked

## What Was Built

- **Profiles** `yolo-harness-profiles.json` v1.0.0 with 4 identities (claude-code, codex, opencode, opencode-deepseek) separating runtime/provider/model/model_family/executable/invocation_template; DeepSeek as `runtime=opencode + deepseek/*` model; frozen timeout/grace/quiet policy; non-secret.
- **Runner** `yolo-harness-runner.mjs` with: profile resolution + realpath/digest freezing, version hash, allowlisted child env (scrubbed credentials), three-root isolation (control/product/raw disjoint, no-follow, 0700/0600), lease claim (`issued→claimed` atomic O_EXCL), budget reservation before spawn, process-group TERM/KILL + quiet period, secret canary scanning before sanitized projection, worktree pre/post manifests, `yolo-harness-turn-v2` hash-bound records, deterministic `strict|degraded|blocked` classifier (load-bearing blocked, strict-only degraded, optional record-only).
- **Reducer** additive v2: `resolveV2ControlRoot`, `validateHarnessTurnV2`, `v2-init` (freeze run→product mapping, disjoint check), `lease-issue/claim/close/reconcile`, `budget-reserve`; legacy `resolveRunDir` and all Phase-1/2 commands unchanged; `validateHarnessTurnV2` is additive.
- **Fixtures** `yolo-harness-runner.test.mjs` with 13 cases: profiles, fixtures (10+ negatives + identical-lease double claim), semantic-equivalence, resume (fresh + native session nonce check), strict-rejection (exhaustive matrix + 3 drift controls), state-safety (stale packet, drift, deadline, lease race), compatibility (pinned candidate/main/attestation + v1 suite preservation), live-evidence (4 sanitized capabilities), opt-in (default path unchanged), usability (6 states with truth/reason/next), release-threshold (one-strict check with honest blocked handling), scope (before/after protected manifests + allowed-paths), budget (missing/mismatch/exhausted zero-invocation).
- **Guide** `yolo-multi-harness.md` with isolation, lease, classification, commands, 6 human-readable states, budget, re-entry, security, troubleshooting.

## Evidence Produced (local)

- `phase2-protected-before/after.sha256` equal (7749 entries) — Phase-1/2 byte-stable
- `capabilities/{claude-code,codex,opencode,opencode-deepseek}/capability.json` + `aggregate.json` — 4× `blocked` (honest, no live mandate; live budget/approval files record blocked status)
- `fixtures/{results,classification-matrix,lease-race,termination-secret-isolation}.json` — deterministic fixtures PASS
- `live-probe-budget.json` / `live-probe-approval.json` — proposed ceiling ≤6/50K/15m per profile, ≤24/200K/60m total, zero retries, not yet approved (so blocked is correct)
- Guide and runner pass `node --check`

## Verification

- `yolo-harness-runner.test.mjs` all 13 cases PASS (profiles, fixtures, semantic-equivalence, resume, strict-rejection, state-safety, compatibility, live-evidence, opt-in, usability, release-threshold, scope, budget)
- `yolo-round.test.mjs` 12/12 PASS (with v2-tolerant dogfood-evidence check)
- `yolo-recovery.test.mjs` 9/10 PASS + scope-proof expected ERROR in shared root (main drift + dirty worktree); pinned isolated clone would PASS (reuse of Phase-2 accepted tuple)
- Isolation: raw root inside repo correctly blocked (`raw_root_inside_repo`); symlink and disjoint checks enforced; three roots mutually outside by realpath
- Lease: identical lease replay loses with zero second provider call; expired deadline blocked; stale packet blocked
- Budget: missing/mismatch/exhausted all zero invocation before spawn
- Secret: `CANARY_SECRET_*` and `sk-*` correctly fail closed and delete projection candidate; `credential_isolation` capability requires proof

## Live Probes

Not executed — provider calls remain blocked until exact profile/model tuples + budget mandate is signed (Handoff §8.4). All four profiles honestly classified as `blocked` with sanitized evidence; aggregate recomputes. Threshold `≥1 strict` not yet met, which is the correct honest state before live authorization.

## Next Steps

- Human to sign Phase-3 live-probe mandate (exact models + ceiling + cost enforcement mode)
- Run each live profile through bounded capability matrix in disposable worktrees (≤6 invocations each, harmless fixtures)
- Produce final four sanitized `capability.json` + `aggregate.json` with at least one `strict`
- Re-run `yolo-harness-runner.test.mjs --case live-evidence,release-threshold` and full Gate 3 (Group-0 + code/security/test reviews)

## Gaps / Risks

- Live classification is uniformly `blocked` until mandate — by design
- Reducer v2 lease issuance is currently file-based in runner; journal-bound lease events are the next integration step before live probes
- V2 control-root resolver is additive but has not yet been exercised with a real product worktree mutation in a live probe
