# AC8 / AR-002 — CLAUDE.md §4.5 逐行变更清单 (written BEFORE applying the edit)

Scope: CLAUDE.md §4.5 only. Semantics additive-only; existing two layers get Layer
labels (bounded annotation); new Layer 0 (mechanical hook snapshot) added.

## MODIFIED lines (2) — bounded annotation / additive semantics

| # | Baseline line (FORWARD-missing) | Replacement (REVERSE-added) |
|---|--------------------------------|------------------------------|
| M1 | `**每次回复前自检（强制）：**` | `**每次回复前自检（Layer 1 自检，强制）：**` |
| M2 | `1. Read `.tad/active/session-state.md`（如果存在）` | `1. Read `.tad/active/session-state.md`（如果存在）+ 最新 `.tad/active/precompact/snapshot-*.md`（Layer 0 机械快照）` |

## ADDED lines (4 non-blank, inserted directly under the `## 4.5` heading; +1 blank separator)

| # | New line |
|---|----------|
| A1 | `三层防线：Layer 0 = PreCompact hook 机械快照（自动落盘），Layer 1 = agent 自检，Layer 2 = 用户手动触发。` |
| A2 | `**Layer 0（机械快照，自动）**：每次压缩前 PreCompact hook 写 `.tad/active/precompact/snapshot-*.md`` |
| A3 | `（newest-wins，保留最新 5 个；字段：When/Trigger/Session/Git HEAD/Git/Active handoffs/Active epics）；` |
| A4 | `压缩后 SessionStart(source==compact) 自动注入提醒行。` |

## UNCHANGED (explicitly)

- `- **Blake**：我知道当前 handoff 的完整文件路径吗？`
- `- **Alex**：我知道当前工作模式 + 正在处理的 handoff/草稿吗？`
- `**如果答案是 NO（或不确定）：**`
- `2. 重新运行 `/blake` 或 `/alex` 重载完整协议`
- `3. 从 session-state.md 的 `Current Position` 继续`
- `如果 self-check 没触发（Layer 1 失效），用户可手动说：` (already carries the Layer 1 label)
- `"Read .tad/active/session-state.md" 触发 Layer 2 恢复。` (already carries the Layer 2 label)
- Everything outside §4.5.

## Expected line-set diff (non-blank lines, `comm` on sorted sets)

- FORWARD-missing (in baseline, not in new) = exactly {M1, M2 baseline forms} → 2 lines
- REVERSE-added (in new, not in baseline) = exactly {M1, M2 replacements} ∪ {A1..A4} → 6 lines
