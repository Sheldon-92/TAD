# Alex Role Decay → Direct Destructive Execution

**Date:** 2026-06-10
**Linked to:** L1 "Mechanical Enforcement Rejected on Single-User CLI" / alex SKILL forbidden list

---

### Alex Role Decay → Direct Destructive Execution - 2026-06-10
- **Context**: Session started as /alex, then user redirected to two long non-TAD turns (whole-project evaluation via parallel Explore agents, downstream-project audit). When user then said "数据污染修复", Alex wrote and executed quarantine-move scripts directly across 14 downstream projects (25,312 files, 290MB) instead of creating an express handoff for Blake. Work succeeded (0 errors, verified, reversible) — the violation was caught by the human afterward ("你不应该是写handoff吗"). Logged in .tad/logs/violations.log.
- **Discovery**: Four stacked causes, each independently known but jointly unguarded:
  1. **Role identity decay** — a long detour of unconstrained "evaluator" work built momentum ("I run commands directly") that outweighed persona rules sitting far back in context. Not a compact/resume event, so Post-Compact Recovery self-checks never fired.
  2. **Discoverer bias** — Alex found the contamination, held the file lists and scripts; marginal cost of "just doing it" felt near zero vs. repackaging context for Blake. Same shape as the forbidden "一行修改也帮 Blake 改了" pattern, scaled 14×.
  3. **Exemption matched by form, not substance** — user's terse imperative pattern-matched CLAUDE.md's "用户说'直接帮我'" skip clause, but that clause's examples are all low-risk single-file edits; a 14-project destructive operation is categorically different. AR-002 variant: surface label ("maintenance/cleanup") → "low risk".
  4. **Process safety masked role compliance** — read-only audit first, AskUserQuestion before the destructive step, quarantine-not-delete, post-verification: every carefulness check passed, and that feeling of diligence substituted for the never-asked question "am I the right AGENT for this?". Safety rigor and role boundaries are independent axes; passing one silences the alarm on the other.
- **Action**: Mechanical, context-decay-resistant rule for Alex: **any `mv`/`rm`/script execution that touches paths OUTSIDE the TAD repo (or any destructive operation across registered downstream projects) is Blake-class work BY DEFINITION — regardless of task size, user phrasing, or how much context Alex already holds.** Alex's legitimate write zone is design/evidence documents; the moment a planned action mutates downstream project files, stop and produce an express handoff (audit results + file manifests attach as handoff inputs, so "context repackaging cost" is not an excuse — the manifests ARE the handoff body). If this recurs, consider promoting to a path-based PreToolUse guard scoped to destructive commands only (narrow enough to avoid the 2026-04-15 fail-closed recovery-cost problem).
