# Final independent Blake Layer 2 test-runner

Handoff: `HANDOFF-20260803-codex-wiring-stopbleed.md`
Run date: 2026-08-03
Scope: bounded local verification only; the only review artifact written was this report.

## Verdict

**PASS — AC0–AC9 and both AC7 delta branches are valid.** The alpha exit 0 is legitimate: the `codex_cloud` row has an allowed official-source URL and retrieval date, not a date/status-only green-light.

## Checks and results

- `bash .tad/evidence/acceptance-tests/codex-wiring-stopbleed/AC-00-spike-b-reference.sh` through `AC-09-codex-only.sh`: **all rc=0**.
  - AC0/AC1: recorded direct-read Spike B and real old/new-schema Spike A evidence.
  - AC2/AC3: repository hooks JSON, isolated candidate session, and `tad.sh` `HOOKS_EOF` heredoc all compare/pass.
  - AC4: `claude: coupled=0 missing=0`; `codex: coupled=0 missing=0`.
  - AC5: exact line-set result, 72 replacements plus four maintainer notes.
  - AC6: three quote forms (double, single, bare) simultaneously injected into both trees each produced the specialized platform-coupled parity FAIL; single-tree injection produced the existing byte-parity FAIL; pristine state restored.
  - AC7: alpha/beta delta contract passed.
  - AC8/AC9: regression and Codex-only resolution passed.
- `bash -n .tad/evidence/acceptance-tests/codex-wiring-stopbleed/AC-*.sh`: **rc=0**.
- `bash -n tad.sh .tad/hooks/lib/release-verify.sh`: **rc=0**.
- `bash .tad/hooks/lib/release-verify.sh parity .`: **PASS, rc=0**; both mirrors are byte-identical.
- `bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-08-03`: **PASS, rc=0**; `Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0`.
- `bash .tad/hooks/lib/skill-body-verify.sh`: **PASS, rc=0**; mirror identity and non-circular `load_when` checks pass.

## AC7 provenance and delta evidence

The exact current ledger row is:

`| codex_cloud | codex_adapter | ... | .tad/codex/README.md + https://developers.openai.com/codex/cloud/ (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | ... | accepted_limitation |`

The source is the required official URL with the required retrieval date. A read-only request returned HTTP 200 (the URL redirects to the current official Cloud documentation page). Therefore `codex_cloud` is not an unproven date/status refresh, and alpha exit 0 satisfies the handoff reconciliation rule.

The isolated beta mutation changed only a temporary ledger copy:

```text
BLOCK [codex] ask_user_question_hook: unknown_current_behavior on safety/quality surface
Total: 21 entries | PASS: 20 | WARN: 0 | BLOCK: 1
VERDICT: runtime freshness BLOCK
beta_rc=1
```

This is the single pre-registered beta escalation, below the baseline five BLOCKs, with no verified row blocked. The shipped ledger and verifier were not changed for the simulation; `runtime-freshness-verify.sh` is unchanged from the pre-edit baseline.

## Review hygiene

`git diff --check` passed. AC6 temporary mutation was restored: Alex mirror MD5 was `47c3b3b0eb144ef62eca7be2fa08ddb9` before and after the probe, with zero `x.md` probe residue; Blake mirrors also remained byte-identical. No product-file change was made by this final review beyond restoring the temporary probe state.
