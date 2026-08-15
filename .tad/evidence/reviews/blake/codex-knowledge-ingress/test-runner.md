# Layer 2 Test Runner Report — Codex knowledge ingress

Date: 2026-08-03 (America/New_York)

## 执行证据

实际执行了 `.tad/evidence/acceptance-tests/codex-knowledge-ingress/AC-*.sh` 套件。AC-00～AC-07 均返回 `exit=0`，原始结果分别为：

- `AC-00 PASS`: C/D/E probes recorded with honest no-delivery mappings.
- `AC-01 PASS`: scoped ingress/conditionals/critical rules/copy guard，`47 lines`。
- `AC-02 PASS`: per-event no-delivery observation and envelope mapping explicit.
- `AC-03 PASS`: Claude fixtures、Codex empty shape、empty input、jq fallback、TTY guard。
- `AC-04 PASS`: frozen same-basename Claude behavior matches；second trace runs each add `0` lines。
- `AC-04b PASS`: no-arg/invalid manual gate calls fail visibly；missing Completion blocks；valid Completion allows。
- `AC-05 PASS`: Spike D honest branch、untested fire remains partial、no wiring、snapshot contract。
- `AC-06 PASS`: Spike E `{}` signal set；override/fallback outputs are one clean word。

随后分别实际执行并观察到 `exit=0`：

- `bash AC-08-brain-index-fallback.sh` — `AC-08 PASS`；Codex-only `.agents/skills` fallback、missing-tree marker、repo brain index unchanged。
- `bash AC-09-regression.sh` — `AC-09 PASS`；套件内 parity、skill-body、runtime freshness `21/21 PASS, WARN: 0, BLOCK: 0`、accepted limitation、current hook schema 均通过。
- `bash AC-10a-startup-compact.sh` — `AC-10a PASS`；compact reminder 生效，缺失 source 不伪造 compact reminder。
- `bash AC-10b-notebook-fail-open.sh` — `AC-10b PASS`；absent source fail-open 并执行 body，`HOOK_SOURCE` 为空，compact source 被过滤。

这些是 acceptance scripts 的实际运行结果，不是对既有 report 的复述。AC-02/05/06/10b 保留了 measured no-delivery/empty harness signal/未测 wiring 的诚实限制；没有把 fixture、scratch tree 或 acceptance evidence 当成真实 Codex hook delivery。此次运行没有验证真实认证链路，也没有把可能的 HTTP 401/未授权情形改写成成功交付。

## 独立回归与范围核对

`PARTIAL`：用户要求的套件外独立回归命令（例如对变更 hooks/`tad.sh` 做 `bash -n`、独立 `jq` schema、独立 parity/runtime freshness 或独立 gate fixture）在本轮被中断前尚未执行；因此不能声称已完成该项。根目录 `.tad/evidence/traces` 与非目标 evidence 路径的“执行前后无新增/修改”核对也尚未完成。套件自身在临时目录中的写入由脚本清理，但这不等价于根目录范围核对。

## 结论

Acceptance suite: PASS (AC-00 through AC-10b observed passing).

Independent regression and evidence-scope audit: PARTIAL / not run.

Verdict: BLOCK

## R2 执行证据

R2 was interrupted by the user after checks 1–4 completed. The existing BLOCK section above is preserved. No implementation files were edited.

### (1) Shell syntax

```text
$ find .tad/hooks -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
exit=0
$ bash -n tad.sh
exit=0
```

Result: PASS.

### (2) Codex hooks JSON

```text
$ jq -e . .codex/hooks.json
exit=0
{
  "description": "TAD lifecycle hooks",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|compact",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/hooks/startup-health.sh",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "bash .tad/hooks/notebook-dormant-sync.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "^apply_patch$",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/hooks/post-write-sync.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "^ask_user_question$",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/hooks/lib/askuser-capture.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Result: PASS.

### (3) Parity

```text
$ bash .tad/hooks/lib/release-verify.sh parity .
exit=0
=========================================
PARITY VERIFY (.claude/skills <-> .agents/skills byte-identity)
  REPO: /path/to/TAD
=========================================
  ✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0)
```

Result: PASS.

### (4) Runtime freshness

```text
$ bash .tad/hooks/lib/runtime-freshness-verify.sh .
exit=0
=========================================
RUNTIME FRESHNESS VERIFY
  Repo:  .
  Today: 2026-08-03
=========================================
-----------------------------------------
Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0
VERDICT: runtime freshness PASS
```

Result: PASS.

### (5) Read-only worktree and decision-file audit

`git status --porcelain` before/after one read-only command was not run before interruption, so this check is `PARTIAL/BLOCK`. The pre-R2 decision-file observation was exact output `ABSENT`; a post-R2 verification was not completed.

### (6) Independent AC-04b gate fixture

```text
$ bash .tad/evidence/acceptance-tests/codex-knowledge-ingress/AC-04b-manual-gates.sh
aborted by user after 6.6s
```

No completed exit code or fixture output was captured. Result: `PARTIAL/BLOCK`.

No real Codex delivery is claimed; 401/no-delivery remains a limitation.

Verdict: BLOCK

## R3 执行证据

R3 closed the two remaining checks. The prior BLOCK history above is preserved. No implementation edits were made, and no real Codex delivery is claimed; 401/no-delivery remains a limitation.

### Worktree audit and decision-file check

```text
$ git status --porcelain (before)
exit=0
 M .agents/skills/alex/SKILL.md
 M .agents/skills/alex/references/accept-command.md
 M .agents/skills/alex/references/acceptance-protocol.md
 M .agents/skills/alex/references/adaptive-complexity-protocol.md
 M .agents/skills/alex/references/cancel-protocol.md
 M .agents/skills/alex/references/design-protocol.md
 M .agents/skills/alex/references/experiment-path-protocol.md
 M .agents/skills/alex/references/express-path-protocol.md
 M .agents/skills/alex/references/handoff-creation-protocol.md
 M .agents/skills/alex/references/intent-router-protocol.md
 M .agents/skills/alex/references/publish-protocol.md
 M .agents/skills/alex/references/research-decision-protocol.md
 M .agents/skills/alex/references/socratic-inquiry-protocol.md
 M .agents/skills/alex/references/sync-add-protocol.md
 M .agents/skills/alex/references/sync-list-protocol.md
 M .agents/skills/alex/references/sync-protocol.md
 M .agents/skills/alex/references/workflow-completion-trigger.md
 M .agents/skills/alex/references/yolo-execution-protocol.md
 M .agents/skills/blake/SKILL.md
 M .agents/skills/blake/references/cross-model-invocation.md
 M .agents/skills/blake/references/notebooklm-access.md
 M .claude/skills/alex/SKILL.md
 M .claude/skills/alex/references/accept-command.md
 M .claude/skills/alex/references/acceptance-protocol.md
 M .claude/skills/alex/references/adaptive-complexity-protocol.md
 M .claude/skills/alex/references/cancel-protocol.md
 M .claude/skills/alex/references/design-protocol.md
 M .claude/skills/alex/references/experiment-path-protocol.md
 M .claude/skills/alex/references/express-path-protocol.md
 M .claude/skills/alex/references/handoff-creation-protocol.md
 M .claude/skills/alex/references/intent-router-protocol.md
 M .claude/skills/alex/references/publish-protocol.md
 M .claude/skills/alex/references/research-decision-protocol.md
 M .claude/skills/alex/references/socratic-inquiry-protocol.md
 M .claude/skills/alex/references/sync-add-protocol.md
 M .claude/skills/alex/references/sync-list-protocol.md
 M .claude/skills/alex/references/sync-protocol.md
 M .claude/skills/alex/references/workflow-completion-trigger.md
 M .claude/skills/blake/SKILL.md
 M .claude/skills/blake/references/cross-model-invocation.md
 M .claude/skills/blake/references/notebooklm-access.md
 M .codex/hooks.json
 D .tad/active/handoffs/COMPLETION-20260803-lite-review-hardening.md
 M .tad/codex/README.md
 M .tad/guides/hooks-platform-mapping.md
 M .tad/hooks/lib/askuser-capture.sh
 M .tad/hooks/lib/brain-index-gen.sh
 M .tad/hooks/lib/detect-platform.sh
 M .tad/hooks/notebook-dormant-sync.sh
 M .tad/hooks/post-write-sync.sh
 M .tad/hooks/pre-accept-check.sh
 M .tad/hooks/pre-gate-check.sh
 M .tad/hooks/startup-health.sh
 M .tad/project-knowledge/patterns/ac-verification.md
 M .tad/project-knowledge/patterns/release-sync.md
 M .tad/project-knowledge/patterns/shell-portability.md
 M .tad/runtime-compat/codex.md
 M AGENTS.md
 M NEXT.md
 M tad.sh
?? .tad/active/handoffs/COMPLETION-20260803-codex-wiring-stopbleed.md
?? .tad/active/handoffs/HANDOFF-20260803-codex-knowledge-ingress.md
?? .tad/archive/handoffs/COMPLETION-20260803-lite-review-hardening.md
?? .tad/archive/handoffs/HANDOFF-20260803-codex-wiring-stopbleed.md
?? .tad/archive/handoffs/HANDOFF-20260803-lite-review-hardening.md
?? .tad/evidence/acceptance-tests/codex-knowledge-ingress/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-codex-home/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/
?? .tad/evidence/ralph-loops/codex-knowledge-ingress_state.yaml
?? .tad/evidence/reviews/blake/codex-knowledge-ingress/
?? .tad/evidence/traces/2026-08-03.jsonl
?? .tad/hooks/lib/hook-envelope.sh
$ git diff --check
exit=0
$ git status --porcelain (after)
exit=0
 M .agents/skills/alex/SKILL.md
 M .agents/skills/alex/references/accept-command.md
 M .agents/skills/alex/references/acceptance-protocol.md
 M .agents/skills/alex/references/adaptive-complexity-protocol.md
 M .agents/skills/alex/references/cancel-protocol.md
 M .agents/skills/alex/references/design-protocol.md
 M .agents/skills/alex/references/experiment-path-protocol.md
 M .agents/skills/alex/references/express-path-protocol.md
 M .agents/skills/alex/references/handoff-creation-protocol.md
 M .agents/skills/alex/references/intent-router-protocol.md
 M .agents/skills/alex/references/publish-protocol.md
 M .agents/skills/alex/references/research-decision-protocol.md
 M .agents/skills/alex/references/socratic-inquiry-protocol.md
 M .agents/skills/alex/references/sync-add-protocol.md
 M .agents/skills/alex/references/sync-list-protocol.md
 M .agents/skills/alex/references/sync-protocol.md
 M .agents/skills/alex/references/workflow-completion-trigger.md
 M .agents/skills/alex/references/yolo-execution-protocol.md
 M .agents/skills/blake/SKILL.md
 M .agents/skills/blake/references/cross-model-invocation.md
 M .agents/skills/blake/references/notebooklm-access.md
 M .claude/skills/alex/SKILL.md
 M .claude/skills/alex/references/accept-command.md
 M .claude/skills/alex/references/acceptance-protocol.md
 M .claude/skills/alex/references/adaptive-complexity-protocol.md
 M .claude/skills/alex/references/cancel-protocol.md
 M .claude/skills/alex/references/design-protocol.md
 M .claude/skills/alex/references/experiment-path-protocol.md
 M .claude/skills/alex/references/express-path-protocol.md
 M .claude/skills/alex/references/handoff-creation-protocol.md
 M .claude/skills/alex/references/intent-router-protocol.md
 M .claude/skills/alex/references/publish-protocol.md
 M .claude/skills/alex/references/research-decision-protocol.md
 M .claude/skills/alex/references/socratic-inquiry-protocol.md
 M .claude/skills/alex/references/sync-add-protocol.md
 M .claude/skills/alex/references/sync-list-protocol.md
 M .claude/skills/alex/references/sync-protocol.md
 M .claude/skills/alex/references/workflow-completion-trigger.md
 M .claude/skills/blake/SKILL.md
 M .claude/skills/blake/references/cross-model-invocation.md
 M .claude/skills/blake/references/notebooklm-access.md
 M .codex/hooks.json
 D .tad/active/handoffs/COMPLETION-20260803-lite-review-hardening.md
 M .tad/codex/README.md
 M .tad/guides/hooks-platform-mapping.md
 M .tad/hooks/lib/askuser-capture.sh
 M .tad/hooks/lib/brain-index-gen.sh
 M .tad/hooks/lib/detect-platform.sh
 M .tad/hooks/notebook-dormant-sync.sh
 M .tad/hooks/post-write-sync.sh
 M .tad/hooks/pre-accept-check.sh
 M .tad/hooks/pre-gate-check.sh
 M .tad/hooks/startup-health.sh
 M .tad/project-knowledge/patterns/ac-verification.md
 M .tad/project-knowledge/patterns/release-sync.md
 M .tad/project-knowledge/patterns/shell-portability.md
 M .tad/runtime-compat/codex.md
 M AGENTS.md
 M NEXT.md
 M tad.sh
?? .tad/active/handoffs/COMPLETION-20260803-codex-wiring-stopbleed.md
?? .tad/active/handoffs/HANDOFF-20260803-codex-knowledge-ingress.md
?? .tad/archive/handoffs/COMPLETION-20260803-lite-review-hardening.md
?? .tad/archive/handoffs/HANDOFF-20260803-codex-wiring-stopbleed.md
?? .tad/archive/handoffs/HANDOFF-20260803-lite-review-hardening.md
?? .tad/evidence/acceptance-tests/codex-knowledge-ingress/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-codex-home/
?? .tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/
?? .tad/evidence/ralph-loops/codex-knowledge-ingress_state.yaml
?? .tad/evidence/reviews/blake/codex-knowledge-ingress/
?? .tad/evidence/traces/2026-08-03.jsonl
?? .tad/hooks/lib/hook-envelope.sh
```

Status equality: PASS (the before and after `git status --porcelain` outputs are identical).

```text
$ test ! -e .tad/evidence/decisions/2026-08-03.jsonl
exit=0
```

Result: PASS.

### Independent AC-04b gate fixture

```text
$ bash .tad/evidence/acceptance-tests/codex-knowledge-ingress/AC-04b-manual-gates.sh
exit=0
AC-04b PASS: manual no-arg/invalid calls fail visibly; missing Completion blocks; valid Completion allows.
```

Result: PASS.

Verdict: PASS (R3)
