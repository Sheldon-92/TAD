# Codex Manual Gates Guide

Replaces Claude Code automatic gate hooks with equivalent manual bash commands.

---

## Gate 3 v2 — Manual Steps

### Layer 1: Self-Check

Run the appropriate checks for your task_type (from handoff frontmatter):

**task_type: code**
```bash
npm run build      # or: python setup.py build / cargo build
npm test           # or: pytest / cargo test
npm run lint       # or: eslint . / flake8
npx tsc --noEmit   # TypeScript projects only
```

**task_type: yaml**
```bash
python3 -c 'import yaml, sys; yaml.safe_load(open(sys.argv[1]))' <file.yaml>
```

**task_type: mixed** — run applicable checks per sub-task

All checks must PASS before proceeding to Layer 2.

---

### Layer 2: Expert Review

Run TWO separate reviewer sessions. See `.tad/codex/sequential-review.md` for full prompts.

**Step 1 — Code Reviewer**
```bash
codex exec "$(cat .tad/codex/sequential-review.md)" \
  "Review as code-reviewer. Handoff: <slug>. Report P0/P1/P2 findings."
```

Save output: `.tad/evidence/reviews/blake/<slug>/code-reviewer.md`

**Step 2 — Domain Expert** (pick by task type)
```bash
codex exec "Review as backend-architect. Examine blast radius and cross-file refs."
```

Save output: `.tad/evidence/reviews/blake/<slug>/backend-architect.md`

---

### Layer 2 Audit (MANDATORY after saving reviews)

```bash
bash .tad/hooks/lib/layer2-audit.sh <slug>
# Exit 0 = PASS (≥2 distinct reviewers found)
# Exit 1 = FAIL (missing reviewer artifacts)
```

Where `<slug>` is the handoff filename without date prefix and `.md` suffix.
Example: handoff `HANDOFF-20260501-codex-phase1-build.md` → slug = `codex-phase1-build`

---

### Evidence Collection Check

```bash
ls -la .tad/evidence/reviews/blake/<slug>/
# Must contain: code-reviewer.md + at least 1 domain expert .md
```

---

### Git Tracked Dirs Check (if declared in handoff frontmatter)

```bash
bash .tad/hooks/lib/gate3-git-tracked-check.sh .tad/active/handoffs/HANDOFF-<slug>.md
# Exit 0 = PASS or skip (no git_tracked_dirs declared)
# Exit 1 = FAIL (declared dirs have untracked files)
```

If FAIL: run `git add <dir>` then re-run check.

---

### Drift Check (optional — run before major commits)

```bash
bash .tad/hooks/lib/drift-check.sh <slug>
```

---

### Stale Knowledge Check (optional — run during knowledge assessment)

```bash
bash .tad/hooks/lib/stale-knowledge-check.sh --json
```

---

## Gate 3 v2 Checklist

Copy and fill this table in your completion report:

```
| Check | Status | Notes |
|-------|--------|-------|
| Layer 1 build | ✅/❌ | |
| Layer 1 tests | ✅/❌ | |
| Layer 1 lint | ✅/❌ | |
| Layer 2 spec-compliance | ✅/❌ | NOT_SATISFIED=0 |
| Layer 2 code-reviewer | ✅/❌ | P0=0, P1=0 |
| Layer 2 domain expert | ✅/❌ | Expert type: |
| layer2-audit.sh | ✅/❌ | Exit code: |
| Evidence files | ✅/❌ | ls output |
| git_tracked_dirs | ✅/❌/SKIP | |
| git commit | ✅/❌ | hash: |
| Knowledge Assessment | ✅/❌ | Yes/No |
```

---

## Gate 4 v2 — Business Acceptance (Alex-side)

Gate 4 is owned by Alex. After Blake's Gate 3 PASS:

1. Blake generates Message to Alex (see completion_protocol.step8)
2. Human copies message to Terminal 1 (Alex session)
3. Alex runs `/gate 4` or reads handoff + verifies business requirements
4. Alex archives handoff to `.tad/archive/handoffs/`

Blake's role in Gate 4: answer questions, provide clarifications if Alex requests.
