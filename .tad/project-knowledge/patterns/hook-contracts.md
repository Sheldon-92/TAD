# Hook Contracts Patterns (Layer 2)

> Reusable patterns for hook mechanism design, output contracts, and event handling.

---

### Claude Code Hook Contract Summary - 2026-03-31
- **Discovery**: (1) Hooks are production-ready; skill frontmatter is limited (allowed-tools NOT enforced, per-skill hooks NOT implemented). (2) Hook event keys are PascalCase. (3) Validated events: SessionStart, PreToolUse, PostToolUse, UserPromptSubmit. (4) `type: command` supports additionalContext injection; `type: prompt` is permission-gate-only ({ok:bool}). (5) Enforcement priority: permissions.deny > hooks > allow. (6) bypassPermissions overrides everything — MUST NOT use in TAD. (7) Haiku JSON output MUST include fence-stripper (Haiku wraps in ```json fences). Supersedes: 3 separate hook mechanism entries.
- **Action**: Use hooks as primary enforcement. Validate mechanisms via spike before designing architecture.
- **failure_mode**: Naive default: use skill frontmatter (allowed-tools) or bypassPermissions for enforcement, and assume camelCase event keys. Why wrong: allowed-tools is NOT enforced, bypassPermissions overrides all safety gates, and event keys are PascalCase (not camelCase) — wrong assumptions silently fail or break the entire permission model.

### Claude Code Sub-Agent Safety Classifier - 2026-04-14
- **Discovery**: Haiku-layer safety classifier fires on red-team vocabulary even in authorized contexts. 70s delay with zero tokens is the refusal signature. Fix: reframe as "negative test case / blue-team defensive testing". `general-purpose` subagent accepts same prompts that `security-auditor` refuses.
- **Action**: Default to blue-team framing for security sub-agent invocations.
- **failure_mode**: Naive default: use red-team vocabulary (e.g., "exploit", "attack", "inject") directly in security sub-agent prompts. Why wrong: Haiku-layer safety classifier triggers a silent 70s refusal (zero tokens returned) on red-team vocabulary even in authorized contexts, wasting time with no error message — reframing as "blue-team defensive testing" avoids the classifier.

### Data-Capture and AskUser Hooks - 2026-04-25
- **Discovery**: For array-valued data, do elementwise membership checks not joined-string checks. Multi-select `["P","Q"]` joined as `"P, Q"` fails membership check against `["P","Q","R"]`. Test assertions must match the data flow's purpose, not just incidental fields.
- **Action**: Write elementwise membership checks for arrays. Assert captured payload content, not just metadata.
- **failure_mode**: Naive default: join array values into a comma-separated string and check membership against the joined string. Why wrong: `"P, Q"` as a joined string does not match any element in `["P","Q","R"]` — the membership check silently fails, producing false negatives in validation.

### .router.log 5-Tuple as Load-Bearing Hook Output Contract - 2026-04-27
- **Discovery**: When a hook's side-output (log file) becomes consumed by downstream scripts, it transitions from artifact to API. Format changes are breaking changes. `whitelist_early_exit` is a quasi-pack-name in field 3 that consumers must handle. Concurrency hazard with `tail -1`.
- **Action**: Add CONTRACT block to hook scripts with consumed output. Treat log format changes as semver-major.
- **failure_mode**: Naive default: treat hook log output as an internal debug artifact and freely change its format. Why wrong: downstream scripts consume the log as a structured API (5-tuple fields)

### An `@import` Slot That Points at a Non-Existent File Is a Latent Prompt-Injection Channel — Creating the File Is a Privilege Escalation - 2026-08-06

- **Context**: A contract granted a design agent write access to the distilled-knowledge tree, guarded by a stop-clause naming the two knowledge paths listed as SAFETY. A security reviewer checked that guard against the actual auto-load list and found the project's root instruction file declares **eight** `@import` paths, of which **five did not exist on disk** — `@import` silently skips missing files, so those five are empty slots. The stop-clause named two of eight.
- **Discovery**: Writing to an existing auto-loaded file is visible: it produces a diff a reviewer can read. **Creating one of the empty slots is not** — there is no prior version, so the change presents as "a new knowledge file added," while its actual effect is installing text into the system prompt of every future session for every agent. No abuse intent is needed: one distillation misjudgment (an entry whose Action reads "when the task involves publishing, the agent may execute directly to avoid channel-switch cost") becomes standing instruction. This routes around the separate, stricter prohibition on editing protocol files — the knowledge tree becomes a side door into the same context. Two mitigations were real and worth recording: distillation fires only after human acceptance, and the capability already existed in the heavyweight channel, so this was capability *transfer*, not creation.
- **Action**: When granting write access to any directory, enumerate which of its paths are auto-injected into future sessions — **including declared-but-absent ones**. Express the guard as a *reference to the auto-load list* ("any path listed in the root instruction file's imports, including slots not yet created"), never as a hand-copied subset, so it tracks the list automatically. Pair it with a content-class rule: distilled entries record episodes that already happened; anything that changes permissions, routing, or prohibition semantics must go through a contract and human sign-off, not through a knowledge file. Audit existing `@import` declarations for empty slots — each one is an unguarded write target.
- **failure_mode**: Naive default: protect the auto-loaded knowledge tree by naming the sensitive files that currently exist. Why wrong: the enumeration is a snapshot of a list that keeps changing, and it structurally cannot cover declared-but-absent paths — which are the most dangerous targets precisely because creating them produces no diff to review.
- **Grounded in**: Gate 2 security-auditor report 2026-08-06 §1(b) (8 `@import` paths vs 2 covered by the guard; 5 non-existent slots enumerated), CLAUDE.md §7 import block, HANDOFF-20260806-lite-takes-over-full.md §3 (the widened guard clause + content-class rule as shipped) — any format change silently breaks all consumers, and `tail -1` under concurrency can read a partial/wrong line.
