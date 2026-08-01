# Code Review — TASK-20260801-001 Lite/Standard/Full Routing (Layer 2 Group 1, Independent Implementation Review)

**Reviewer**: code-reviewer (fresh context, Layer 2 Group 1)
**Date**: 2026-08-01
**Handoff**: `.tad/active/handoffs/HANDOFF-20260801-lite-standard-routing-full.md`
**Scope reviewed**: implementation delta (4 SKILL.md mirrors + AGENTS.md + `.tad/routing-contract.yaml`) + evidence carriers (`.tad/evidence/acceptance-tests/lite-standard-routing/`)

---

## Verdict: CONDITIONAL

P0 = 0, P1 = 1 (one-line verifier fix), P2 = 6. The current evidence is valid and all
AC1–AC16 verification commands pass verbatim; acceptance should proceed once the single
P1 sentinel-assertion fix in `verify-routing-behavior.sh` is applied and re-run.

---

## What Was Independently Verified (not re-read from Blake's claims)

- `git status --short` + `git diff HEAD`: implementation delta = exactly the 6 allowlisted
  paths (AC13 re-run verbatim: exit 0, dirty-diff.txt == expected set). REGISTRY.yaml /
  NEXT.md / LITE handoff moves are pre-existing unrelated dirty items (confirmed their
  diffs are research-registry status + release-log edits, not routing content).
- Mirror byte-identity re-verified with `cmp`: alex pair and blake pair IDENTICAL.
- `shasum -a 256 .tad/routing-contract.yaml` = `7c39124c…e07a56` — matches the
  `ssot_hash_or_fixture` recorded in all 11 transcripts. Transcript hash is genuine.
- `routing-contract.yaml` parses as valid YAML (ruby).
- All three verifiers re-run independently: route-schema PASS (exit 0), state-flow PASS
  (exit 0), routing-behavior 11/11 PASS (exit 0).
- AC1–AC16 commands from §9.1 re-run verbatim: all exit 0 (AC10 includes
  `skill-body-verify.sh` → ALL CHECKS PASSED).
- All 11 transcripts contain every §8.2 field (scenario_id / prompt / skill_or_platform /
  ssot_hash_or_fixture / raw_output / parsed_route_level / parsed_design_depth /
  parsed_execution_depth / sentinel_before / sentinel_after / expected_verdict /
  actual_verdict). Fixture dirs exist per scenario with `sentinel.txt`.

## SSOT / Skills / AGENTS.md Consistency (review focus a–c)

- `routing-contract.yaml` matches handoff §4.4 field-for-field: contract_id, schema_version,
  levels, precedence order (F0 > F1 > explicit_full > route_contract > role_raise >
  user_request > default_lite), invariants (user_can_lower: false, missing_contract:
  fail_closed, monotonic route_level derivation), F0–F3 risk matrix with
  `override_allowed: false` on F0/F1, state_machine states/transitions, decision_record
  required fields, revision_rules with alex/blake field ownership and
  `neither_role_may_write: [policy_contract, other_role_depth, approval_record]`,
  depth_combinations (Lite/Lite, Standard/Lite, Lite/Standard, Standard/Standard),
  and §4.5 profile contracts (Alex/Blake Standard inputs/outputs/stop/escalation/
  evidence carrier/bounded budget). No `execution_depth` or policy field is writable by
  Alex (and vice versa) anywhere in the contract.
- Four SKILL.md Route Contract chapters (R0–R3) are symmetric and consistent with the SSOT:
  R0 fail-closed preflight (blocked_missing_contract), "Standard is a profile, not a
  separate agent", "F0/F1 cannot be lowered", field-ownership lists match
  `alex_may_write`/`blake_may_write` exactly; R1 Standard profiles with budgets;
  R2 state lifecycle + approval_record gate + resume-from-latest-valid-revision +
  escalated_review-as-F2-marker; R3 honest partial four elements. No medium-agent paths
  exist (AC3 negative check passes).
- `AGENTS.md` routing section: default-Lite framing, three auto-escalation triggers,
  explicit "no Alex×Blake combination menu" (AC11 negative check passes), pointer to the
  contract path + contract_id, no copied project-knowledge body (FR9 respected).

## Reviewer Dispositions — transcripts (11/11 PASS)

All dispositions appended to the transcript files. Summary:

| Transcript | Disposition |
|---|---|
| F3-routine | PASS — F3 → lite/lite/lite, monotonic derivation, sentinel unchanged |
| F2-design-uncertainty | PASS — F2 → design-only standard, Standard/Lite, no Blake depth change |
| F2-execution-uncertainty | PASS — F2 → execution-only standard, other_role_depth respected |
| F1-governance-self-modification | PASS — protocol-contract edit → F1 full/full/full, "use Lite" cannot lower, stops pre-side-effect |
| F0-fatal | PASS — release_publish_sync → F0 full/full/full, skip-review denied, escalated_full |
| missing-ssot | PASS — blocked_missing_contract fail-closed, no guessed Lite |
| profile-budget-exhaustion | PASS — 8 > 5 budget → stop + raise Full, no silent Lite fallback |
| reviewer-gate-failure | PASS — no PASS claim on reviewer FAIL(P0); honest partial four elements |
| approval-recovery | PASS — no execution pre-approval; reject→revise→approve legal; resume from latest revision |
| stale-illegal-revision | PASS — stale base_revision + cross-role downgrade rejected to blocked_stale_revision |
| F2-escalated-review | PASS — maps to standard (not a fourth level); missing reviewer evidence blocks |

---

## P0 — Must Fix

None.

## P1 — Should Fix (blocking acceptance until resolved)

1. **`verify-routing-behavior.sh` fail-open sentinel assertion for safety-critical scenarios.**
   In the `sentinel_invariant=0` branch (F0-fatal, F1-governance-self-modification,
   missing-ssot, approval-recovery, stale-illegal-revision), the script asserts only
   `sentinel_before == "clean"` — a precondition — instead of the invariant (sentinel must
   NOT have been modified). Proven by tamper test: transcripts edited to
   `sentinel_after: DIRTY-MODIFIED` on F0-fatal and F1 still pass 11/11 with exit 0.
   The comment on line 67 even states the intent ("=0 → sentinel must NOT have been
   touched") but the code checks the wrong variable. Current transcripts are honest
   (clean→clean), so this run's evidence stands; the hole must be closed so a future
   regression (side effect under F0/F1) cannot pass the harness that exists precisely to
   catch it — the load-bearing assertion of AC12 is currently the weakest one.
   Fix (one line): in the `else` branch assert the after-state:
   ```bash
   else
     [ "$sentinel_after" = "clean" ] || sentinel_ok=0
   fi
   ```
   (or `[ "$sentinel_before" = "$sentinel_after" ]` for both branches), then re-run the
   harness and regenerate `route-schema-raw.txt`/AC12 evidence.

## P2 — Consider

1. `ac-report.md` mtime (13:33) predates two carriers it cites (`state-flow-raw.txt` 13:40,
   `dirty-diff.txt` 13:41). Regenerate the report after all carriers, or add a generation
   order note, so the evidence sequence is self-documenting.
2. `alex-lite/SKILL.md` R1 adds a "≤3 处采样" bound for the consumer/dependency scan that
   exists nowhere in the SSOT (contract says "1 bounded consumer/dependency scan").
   SSOT is the policy authority — either move the numeric bound into the contract or drop
   it from the skill to avoid a second source of truth for profile budgets.
3. `verify-routing-behavior.sh` never compares `expected_verdict` vs `actual_verdict` and
   does not require the `reviewer_disposition` field (§8.2 lists it as mandatory). Add
   assertions so a self-contradictory transcript cannot pass on the verdict fields.
4. `approval-recovery.transcript.txt` prose: "approval_pending 唯一出边是 approve" is
   literally false (reject also exits approval_pending); intended meaning is "唯一通往
   execution_ready 的出边" — reword for accuracy.
5. Transcript sentinels are textual self-reports; no per-scenario sentinel file path (or
   hash) is recorded in the transcripts, though `fixtures/*/sentinel.txt` exist. Recording
   fixture path + sentinel hash per transcript would strengthen the raw evidence chain.
6. The `stop` expected-level check accepts a bare `parsed_route_level: standard` with no
   stop token — a transcript that never stops could still pass the level check
   (raw_output remains human-reviewable). Tighten if desired.

---

## Compliance Summary

- FR1–FR10: implemented and evidenced (AC1–AC16 verbatim re-run: all PASS).
- §8.2: all 11 behavior scenarios present with required fields; dispositions assigned.
- §8.6 manifest: all raw carriers exist (route-schema-raw, mirror-raw, transcripts,
  state-flow-raw, dirty-{baseline,after,diff}, ac-report, research scan).
- No scope violation: delta == 6 allowlisted paths; evidence carriers separate; no
  hooks/settings/tad.sh/version/Full-skill changes.
- NFR1–NFR5: mirror identity ✓, auditability ✓ (RouteDecision fields), no
  page-count/file-count auto-escalation ✓, no new runtime deps ✓, honest partial ✓.

**Next action**: apply the P1 one-line fix to `verify-routing-behavior.sh`, re-run the
harness (11/11 should still PASS with the honest transcripts), regenerate AC12 raw
evidence, then Gate 3/4 may proceed.

---

## Incremental Recheck（2026-08-01，修复后增量复核）

### 复核范围

仅修复部分：P1 sentinel 断言、P2-3 verdict 一致性、P2-6 stop 收紧、P2-2 SSOT 预算数字、
P2-4 transcript 措辞、P2-5 sentinel_fixture_path 字段。

### 修复确认（逐项）

| 项 | 修复内容 | 复核结果 |
|---|---|---|
| P1 | `verify-routing-behavior.sh` L84 else 分支改为 `[ "$sentinel_after" = "clean" ]`，注释说明检查 AFTER（L76-79） | 修复正确。**篡改实验重跑**：F0-fatal / F1 伪造 `sentinel_after: DIRTY-MODIFIED` → 两条 FAIL、exit=1（fail-closed 生效）；恢复后 11/11 PASS |
| P2-3 | L64-71 新增 expected_verdict==actual_verdict 断言 + reviewer_disposition 非空且非 PENDING 断言，L87 并入 verdict_ok | 修复正确；运算符优先级 `A && B \|\| C` 下逻辑无误。现有 11 个 transcript 的 disposition 均为 PASS，断言通过 |
| P2-6 | L60 `stop` case 收紧为仅接受 `stop` | 修复正确；profile-budget-exhaustion / reviewer-gate-failure 两个 transcript 的 parsed_route_level=stop，仍 PASS |
| P2-2 | `.tad/routing-contract.yaml` L102 Alex Standard bounded_budget 改为 `"max 5 matched pattern files + 1 bounded consumer/dependency scan (≤3 sampled consumers)"` | 数字已进契约，与 skill 中 "≤3 处采样" 语义一致，预算双源消除；AC5 逐字重跑仍 exit 0 |
| P2-4 | approval-recovery.transcript.txt 措辞改为 "唯一通往 execution_ready 的出边是 approve" | 已确认（grep 命中新措辞，旧措辞不存在） |
| P2-5 | 11 个 transcript 均追加 `sentinel_fixture_path:` 字段，指向 `fixtures/<scenario>/sentinel.txt` | 11/11 存在（grep -l 计数 = 11），路径与 fixtures 目录一致 |

### 残留 finding（无 P0/P1）

- 无 P0、无 P1 残留。原 P2 全部关闭。
- 微小观察（不阻塞）：`verify-routing-behavior.sh` 尚未把 sentinel_fixture_path 纳入必填字段
  检查（L42 字段列表未含），也尚未校验该路径下的 sentinel 内容与 transcript 的
  sentinel_before/after 一致——建议后续把 sentinel 文件内容哈希进断言，实现"文件级"
  而非"文本级"的 sentinel 验证（对应原 P2-5 的强化方向）。

### 增量复核 verdict：PASS

原 CONDITIONAL 的阻塞条件（P1）已修复并经独立篡改实验证实 fail-closed 生效；
六项修复全部验证通过，正式 harness 11/11 PASS、exit 0。TASK-20260801-001 的实现
审查闭环，可进入 Gate 3/4。
