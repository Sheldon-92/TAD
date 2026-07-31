# Journal: lite-capability-complete (2026-07-31)

- Negative-pattern ACs (e.g. `! rg -q '直接.*project-knowledge'`) constrain the *phrasing* of prohibitions, not just behavior: writing "禁止直接写 project-knowledge" in a skill file would fail the very AC that mandates the prohibition. Safe phrasings keep the trigger words on separate lines from the banned substring, or use different vocabulary (e.g. "成品蒸馏归 Alex-Lite / 验收知识闭环"). When a handoff specifies negative regex ACs, dry-run the regex against candidate wording *before* writing the file — AC dry-run discipline applies to the contract author's own verification commands.

- Naive substring negative checks are double-edged: they catch reintroduced old language reliably, but they cannot distinguish "the rule" from "a mention of the rule". This handoff's AC set worked because the forbidden literals were chosen from genuinely retired phrasings (`一页纸 handoff`, `预计总改动 > 5 个文件`) — a lesson for future negative AC design: pick literals that only appear in the old behavior, never in legitimate new prose.

- Cross-platform mirror discipline: editing `.claude/skills/` first and `cp` to `.agents/` immediately after each change (not batching at the end) kept `cmp` green at every checkpoint, including mid-fix during reviewer follow-ups.
