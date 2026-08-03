# Lite Review Hardening — pre-edit baseline

Captured: 2026-08-03
Handoff: `HANDOFF-20260803-lite-review-hardening.md`

This baseline was collected before any product-file edit. Existing unrelated
untracked paths were: `.tad/active/handoffs/` and
`.tad/evidence/traces/2026-08-03.jsonl`.

## Product-file baseline

| File | Lines | Whole-file md5 |
|---|---:|---|
| `.claude/skills/blake-lite/SKILL.md` | 355 | `61eee8557a5e8fe7ef8ac844652f5535` |
| `.agents/skills/blake-lite/SKILL.md` | 355 | `61eee8557a5e8fe7ef8ac844652f5535` |
| `.claude/skills/alex-lite/SKILL.md` | 306 | `b2deb644018079a3760af38744c3f46d` |
| `.agents/skills/alex-lite/SKILL.md` | 306 | `b2deb644018079a3760af38744c3f46d` |
| `.tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh` | 125 | `2d1ec16b769fc51481b513efb29269c0` |

Both mirror pairs passed `cmp -s` (exit 0).

## Sentinel baseline

For each of the four lite SKILL files:

- `ESCALATION-LIST` block md5: `4c55bcb6563f24dc78449fb19ff76067`
- `ESCALATION-LIST-BEGIN` count: `1`
- `ESCALATION-LIST-END` count: `1`

## AC baseline measurements

The following are the literal pre-edit measurements using the handoff's
section-scoped anchors (zero results were normalized to numeric `0`):

| AC | Baseline measurement |
|---|---|
| AC1 | Blake L3 reviewer prompt: `执行验证义务=0`, `UNVERIFIED-BY-EXECUTION=0`, `执行实证\|阅读推断=0` |
| AC2 | Reviewer-title count: Blake `0`, Alex `0`; Blake rule-region `route_level=0`, `execution_depth=0`, `REVIEWER-TIER-DEGRADED=0`; Alex rule-region `route_level=0`, `execution_depth=0`, `REVIEWER-TIER-DEGRADED=0`; current section anchors: Blake L3 `206`, L3.5 `223`; Alex L2.5 `199`, L3 `225`; reviewer-rule title absent in both (`NA`) |
| AC3 | Cross-role section count: Alex `0`, Blake `0`; per-term counts in both sections: `触发消歧=0`, `逐字记录=0`, `拒绝执行=0`, `NOT_via_suggestion=0`, `cross_role_request=0`; exact protected anchors all exit `0` before edit: Alex Forbidden, Alex 精髓 #1, Blake Forbidden, Alex Stop |
| AC4 | Blake mirror `cmp` exit `0`; Alex mirror `cmp` exit `0` |
| AC5 | All four sentinel md5 values equal `4c55bcb6563f24dc78449fb19ff76067`; each BEGIN count `1`, END count `1` |
| AC6 | `grep -A3 'required_fields=' ... | grep -c '\\bmodel\\b'`: `0` |
| AC7 | Exact shim command exited `0`; baseline verifier output reported all existing checks PASS. The required-field list did not yet include `model`. |
| AC8 | L3 `## 执行证据` count: `0` (behavioral probe not yet applicable) |
| AC9 | Blake Completion `model={reviewer 自报}` count `0`; Alex Contract Review `Reviewer: {待填} | model=` count `0`; Alex L2.5 `自报` count `0` |

## Baseline command notes

- Sentinel extraction: `awk '/^<!-- ESCALATION-LIST-BEGIN -->$/,/^<!-- ESCALATION-LIST-END -->$/' <file> | md5 -q`
- Mirror check: `cmp -s <claude-file> <agents-file>`
- Verifier smoke check: `bash -c 'rg(){ grep -E "$@"; }; export -f rg; bash .tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh'`
- All section ACs were measured before the implementation patch; no product-file
  changes were present at capture time.
