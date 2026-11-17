---
name: design-foundation
description: "Design foundation capability pack — the canonical source for presentation-surface parameters and conventions: design tokens (three-layer architecture + fixed parameter method), panel pattern recipes, and predictable component conventions. v0 scopes values, subsets and acceptance to the Space visual layer only; the architecture is general. Load when a task needs token values, visual parameters, pattern structure or component API conventions for a Space or another presentation surface — the token values live here, not in web-ui-design (which owns the UI task process)."
keywords: ["design tokens", "design foundation", "tokens", "visual parameters", "component conventions", "pattern recipes", "设计规范", "令牌", "底子", "呈现面", "Space 视觉"]
type: reference-based
---

<!-- CONSUMES/PRODUCES Interface (for multi-pack chaining) -->
<!-- consumes: a presentation-surface task (Space page build/revision, component API design, token question) -->
<!-- produces: canonical token names/values (draft values until human acceptance), pattern recipes, component conventions -->

# design-foundation Capability Pack

## What This Pack Does

design-foundation = the normative parameters and conventions for presentation surfaces:
which token values exist, how page patterns are structured, how component APIs behave.
It is NOT a process pack — the UI task workflow (Vision → Execution → Validation) lives in
web-ui-design; this pack is the parameter canon that workflow consumes.

**When to use:** building or revising a Space page; choosing token values; designing a component API; checking a presentation surface against the canon.
**When NOT to use:** UI task process questions (use web-ui-design); non-visual work.

**Value status (v0):** the token values in `references/token-values-space.md` are a **draft**
pending the human's Gate 4 verdict — never call them finalized or standing norms before that.

---

## Cross-Cutting Rules

> **1. One canon, kept in parity.** `tokens/tokens.css` is the only normative token source.
> Any edit to it must regenerate `tokens/tokens.json` in the same batch and pass
> `tools/check-token-parity.sh` (PARITY-OK) before the change counts as done. A locally
> edited installed copy is a fork, not the canon (see conventions 15–16).
>
> **2. Draft values stay draft.** Values are cited as "value draft" until the human accepts
> them; do not present draft values as settled norms in any artifact.
>
> **3. Borrow architecture, not values.** The reference source's architecture and parameter
> method are adopted; its colors, fonts and default look are not (see interface-index pin line).

---

## Step 0: Context Detection

Read the user's task. Match against the signal table below. Load the matching reference file(s).

| Signal in User Task | Reference to Load | What It Covers |
|---------------------|-------------------|----------------|
| token value, color, spacing, font stack, status color, 值 | `references/token-values-space.md` | v0 Space value draft + font-stack section |
| token architecture, parameter method, naming layers, 参数法 | `references/token-architecture-rules.md` | three-layer architecture + fixed parameter method + maintenance rules |
| page structure, dashboard, table, navigation, 配方 | `references/pattern-recipes-space.md` | 12 panel recipes + narrow-width rules |
| component API, props, slots, Switch, 约定 | `references/component-conventions-rules.md` | 16 conventions incl. the Switch precedent |
| full inventory, index, 清单 | `references/interface-index.md` | one-line-per-item index + reference-source pin |
| "review everything" / "audit" | Load ALL references | Full-scope review |

**If no signal matches:** Ask the user which capability they need.

## Step 1: Apply Rules

1. Read the matched reference file(s) from `references/`
2. Consume tokens by name from `tokens/tokens.css` (data form: `tokens/tokens.json`); never copy values into a second hand-maintained source
3. Apply applicable rules — cite the rule or token name in your output
4. Status is never carried by color alone: every status gets its text label + shape marker

## Files

- `tokens/tokens.css` — the token canon (see the `pack-version:` line in its header)
- `tokens/tokens.json` — derived mirror of the canon (parity-checked)
- `tools/check-token-parity.sh` — canon/mirror consistency check
- `examples/panel-status-build.md` — discriminative fixture (with-pack vs no-pack)
