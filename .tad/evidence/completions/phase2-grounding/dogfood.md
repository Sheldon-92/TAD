# Phase 2 Dogfood Evidence

**Purpose**: Demonstrate that Phase 2's two new conventions (`Grounded in` knowledge bullet + `Grounded Against` handoff bullet) are actually used in practice — starting with the work that ships them.

## Dogfood #1: Handoff §6 has `Grounded Against`

`HANDOFF-20260424-phase2-grounding.md` lines 369–377:

```
**Grounded Against** (Alex step1c 实际 Read 过的源文件 — dogfood):
- `.claude/skills/alex/SKILL.md` (head 50 — 验证 step0_5 / step1b 现有结构)
- `.tad/project-knowledge/README.md` (head 50 — 验证 Entry Format 现状)
- `.tad/templates/handoff-a-to-b.md` (head 50 — 验证 §6 当前 frontmatter / structure)
- `.tad/project-knowledge/architecture.md` (head 50 — 验证现有 entry 格式无 Grounded in)
- `.tad/hooks/lib/layer2-audit.sh` (head 50 — Phase 1 BSD shell precedent)
- `.tad/hooks/lib/drift-check.sh` (head 50 — Phase 1 reference for shell 风格 + 配置加载 + cwd 处理)
- `.tad/hooks/lib/stale-knowledge-check.sh` (new — will be created)
- `.tad/evidence/completions/phase2-grounding/fixtures/**` (new — will be created)
```

Includes 6 existing files (Alex actually Read them per step1c), plus 2 `(new — will be created)` markers — exact pattern the spec describes.

## Dogfood #2: Template ships the format

`.tad/templates/handoff-a-to-b.md` §7.3:

```bash
grep -A 3 'Grounded Against' .tad/templates/handoff-a-to-b.md
```

Expected: the new section with `Alex step1c 强制填写` comment + filled-in placeholder lines.

## Dogfood #3: Knowledge Assessment entry uses `Grounded in` + `Revalidated`

`.tad/project-knowledge/architecture.md` last entry (`### Revalidated State Defeats Alarm Fatigue ... - 2026-04-24`):

```bash
grep -A 1 '^- \*\*Grounded in\*\*' .tad/project-knowledge/architecture.md | tail -2
grep '^- \*\*Revalidated\*\*' .tad/project-knowledge/architecture.md | tail -1
```

Expected:
- `- **Grounded in**: .tad/hooks/lib/stale-knowledge-check.sh, .tad/project-knowledge/README.md`
- `- **Revalidated**: 2026-04-24`

## Dogfood #4: stale-knowledge-check.sh validates the meta-trifecta

```bash
bash .tad/hooks/lib/stale-knowledge-check.sh --json 2>/dev/null \
  | jq -rc 'select(.title | contains("Revalidated State Defeats")) | {title, status, path}'
```

Output (verified during Gate 3):

```
{"title":"Revalidated State Defeats Alarm Fatigue ...","status":"OK","path":".tad/hooks/lib/stale-knowledge-check.sh"}
{"title":"Revalidated State Defeats Alarm Fatigue ...","status":"OK","path":".tad/project-knowledge/README.md"}
```

Both Grounded in paths exist and are fresh — the new tool verifies the new convention on the new entry that documents the new tool. **Triple meta-trifecta.**

## Forward-compatibility proof

- Future handoffs copying the template inherit §7.3 Grounded Against.
- Future knowledge entries copying the README format will include `Grounded in` + `Revalidated`.
- Alex SKILL step0_5 #9 ensures stale-check is auto-invoked at handoff drafting.
- Alex SKILL step1c ensures grounding pass happens before expert review.

The work that ships these conventions uses them on itself.
