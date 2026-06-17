# Edit Safety (ES1–ES4)

> How to modify agent instructions without catastrophic forgetting.

---

### ES1: Edit Mode Selection — Safety Order

Three edit modes, in decreasing order of safety:

1. **Patch** (safest): Add, modify, or delete a specific rule by ID. Unchanged rules are preserved verbatim. SkillOpt's default mode — the optimizer produces a structured list of `{op: add|modify|delete, rule_id, content}` edits.
2. **Rewrite from suggestions**: The optimizer writes the full new skill text, but is prompted to preserve all unchanged rules. Still preserves most content, but has a ~5-15% chance of silently dropping a rule (catastrophic forgetting risk).
3. **Full rewrite** (riskiest): The optimizer writes the entire skill from scratch. Use only when the skill needs structural reorganization (e.g., splitting one file into multiple, reorganizing sections). The validation gate (VG1) catches regressions, but a rule dropped AND not covered by the held-out set is lost silently.

**Default to patch mode.** Switch to rewrite only when the plan explicitly calls for structural reorganization — and even then, compare the rewritten skill against the original to detect dropped rules (diff + coverage check).

> Source: SkillOpt `optimizer/` — patch mode is the default; paper §3.3 (edit mode taxonomy).

---

### ES2: Learning Rate Schedule — Cosine > Constant

The "learning rate" in text-space optimization is the edit budget — how many rules can change per step. SkillOpt evidence: **cosine schedule outperforms constant** (paper Table 3). The intuition:

- **Early epochs** (high LR): make big structural changes while the skill is far from optimal. More edits per step.
- **Late epochs** (low LR): fine-tune wording with small targeted patches. Fewer edits per step.

Practical guidance:
- **2-4 epochs** is sufficient for prompt convergence on most benchmarks. SkillOpt trains for 3 epochs by default.
- **Steps per epoch**: depends on training set size. ~10-20 steps per epoch for a 50-item training set.
- **Autonomous LR**: SkillOpt also supports `lr_control_mode: autonomous` where the optimizer decides the edit budget based on the current skill's performance. Use when you don't know the right budget.

> Source: SkillOpt paper Table 3 (cosine vs constant); `trainer.py` line 822 (`lr_scheduler`); `lr_autonomous.py`.

---

### ES3: Protected Regions — Marker-Based Write Isolation

Some parts of a skill must NEVER be modified by the optimizer — safety constraints, identity declarations, output format contracts. SkillOpt enforces this with a 4-layer protection scheme:

1. **Marker-based** (primary): Wrap protected content between explicit markers (e.g., `<!-- PROTECTED:BEGIN -->` and `<!-- PROTECTED:END -->`). The optimizer prompt is told to preserve these blocks verbatim.
2. **Prompt-level** (secondary): The edit prompt explicitly says "do NOT modify lines between PROTECTED markers."
3. **Post-edit verification** (tertiary): After the optimizer edits, diff the protected regions against the original. If any changed, revert the edit and log a violation.
4. **Gate-level** (quaternary): The validation gate's held-out set should include tasks that exercise the protected behaviors. A dropped safety constraint will cause gate failures.

**Why 4 layers**: No single layer is reliable enough alone. The optimizer may ignore prompt instructions (~5% of the time). Markers may be malformed. The gate's held-out set may not cover every protected behavior. Together, they provide defense-in-depth.

SkillOpt's `trainer.py` implements layers 1-3 explicitly. Layer 4 is implicit — the user designs the held-out set to cover safety-critical behaviors.

> Source: SkillOpt `trainer.py` `_update_skill()` with protected region enforcement; paper §5 (ablation of protection mechanisms).

---

### ES4: Lapse vs Defect Classification

Before modifying the skill in response to a failure, classify the failure:

- **EXECUTION_LAPSE**: The agent had the right instruction but didn't follow it. The skill text is correct; the execution was flawed (e.g., the agent ignored a formatting constraint, skipped a step, or hallucinated despite clear guidance). **Action**: Add the failure to the appendix as a lapse note (MT3), don't modify the skill body.
- **SKILL_DEFECT**: The instruction itself is wrong, incomplete, or ambiguous. The agent followed the skill faithfully but the skill led to the wrong outcome. **Action**: Modify the skill body via the edit pipeline (TL1-TL4).

**Why this matters**: Treating a lapse as a defect adds noise to the skill — "reminder" rules that clutter the instruction without fixing the root cause. Treating a defect as a lapse leaves the real problem unfixed.

SkillOpt implements this in `trainer.py` line 88: `_handle_appendix_notes()` separates lapse notes from skill-body edits. EmbodiSkill (arXiv 2605.10332) formalized this as the "execution lapse vs skill defect" classification for embodied agents.

> Source: SkillOpt `trainer.py` lines 88-121 (appendix lapse handling); EmbodiSkill paper §3 (EXECUTION_LAPSE / SKILL_DEFECT taxonomy).
