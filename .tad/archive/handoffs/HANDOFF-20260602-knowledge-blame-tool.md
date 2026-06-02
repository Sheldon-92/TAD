---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/blake", ".tad/hooks/lib", ".tad/guides"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-02
**Project:** TAD Framework
**Task ID:** TASK-20260602-002
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-02

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Bash script + SKILL protocol rule. No MCP, no hooks, no settings.json |
| Components Specified | ✅ | 3 files to modify, 1 new file, all paths confirmed |
| Functions Verified | ✅ | git blame / git log verified working on .tad/project-knowledge/ in current repo |
| Data Flow Mapped | ✅ | Blake encounters uncertain rule → calls knowledge-blame.sh → gets provenance → makes informed judgment |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

**Title:** In-Session Knowledge Provenance Tool (DiffMem-inspired git-blame)

**Summary:** Give Blake the ability to query WHY a project-knowledge rule exists during the same session it encounters the rule. When Blake reads a rule in `.tad/project-knowledge/` or `.claude/skills/*/SKILL.md` and is unsure whether it applies, it can run `knowledge-blame.sh` to see which commit added the rule, what handoff triggered it, and the original context — then make an informed judgment (follow, adapt, or flag).

**Business Value:** TAD 的学习循环目前是跨 session 的（trace → *optimize → 下次 session）。Blake 在当前 session 内无法理解规则的来龙去脉，只能盲从或忽略。这个工具让 Blake 从"遵守规则"升级到"理解规则后做判断"，减少无意义的 Layer 1 重试，提高决策质量。

**Origin:** AI Tinkerers #29 newsletter → DiffMem (Growth-Kinetics/DiffMem) research → idea IDEA-20260602-diffmem-git-blame-knowledge → promoted to handoff.

---

## 2. Requirements

### Functional Requirements

**FR1: knowledge-blame.sh Script**
A Bash script at `.tad/hooks/lib/knowledge-blame.sh` that accepts a file path + optional line number or search term, and returns structured provenance information:
- Which commit added/modified that content
- Commit message (should reference the handoff that created the rule)
- Date and author
- Surrounding context (2 lines before/after)

**FR2: Blake SKILL Protocol Rule**
Add a `knowledge_provenance_protocol` section to Blake's SKILL.md that describes:
- When to use: Layer 1 retry caused by a knowledge rule, OR Blake judges a rule may not apply
- How to use: call knowledge-blame.sh via Bash tool
- What to do with the result: cite provenance in decision, adapt rule if context differs, flag for Alex if rule is stale

**FR3: Layer 1 Retry Hint**
In Blake's `2_layer1_loop.on_failure` path, add an advisory hint: when a retry is caused by a pattern matching a project-knowledge rule, suggest running knowledge-blame.sh to understand the rule's origin before the next retry attempt.

### Non-Functional Requirements

**NFR1: Token Efficiency**
git-blame output can be verbose. The script must filter to relevant lines only (not dump the entire file blame). Target: <500 tokens per query.

**NFR2: No New Dependencies**
Only uses git commands (git blame, git log, git show) — already available in every TAD project.

**NFR3: Advisory Only**
The protocol rule is advisory — Blake decides when to use it. Never blocking, never automatic for every knowledge file read.

---

## 3. Technical Design

### Architecture

```
Blake encounters uncertain knowledge rule
  ↓
knowledge_provenance_protocol (SKILL rule) suggests: check provenance
  ↓
Bash: bash .tad/hooks/lib/knowledge-blame.sh <file> [--line N | --search "pattern"]
  ↓
Script runs: git blame -L <range> <file> → extract commit hash
             git log -1 --format='%H %ai %s' <hash> → date + message
  ↓
Returns structured output:
  Rule: "Recurring failure: tsc missing type"
  Added: 2026-05-19 by commit a1b2c3d
  Handoff: "feat(KA): Recurring failure: tsc missing type — 2026-05-19"
  Context: <2 lines before/after from that commit>
  ↓
Blake makes informed decision: follow / adapt / flag
```

### knowledge-blame.sh Interface

```bash
# Usage
knowledge-blame.sh <file> --line <N>        # blame specific line
knowledge-blame.sh <file> --search "pattern" # find line matching pattern, then blame it
knowledge-blame.sh <file>                    # summary: list all unique committers + dates for the file

# Output format (structured, grep-parseable)
RULE: <the content at that line>
COMMIT: <hash>
DATE: <YYYY-MM-DD>
AUTHOR: <name>
MESSAGE: <commit message first line>
```

### Scope

Files the tool can query:
- `.tad/project-knowledge/*.md` — knowledge rules
- `.claude/skills/*/SKILL.md` — protocol rules
- `.tad/hooks/lib/*.sh` — Blake-authored hook scripts (ARCH P1-4 widened)

Files the tool MUST NOT query (out of scope, prevent accidental scope creep):
- `.tad/active/` — transient handoff state
- `.tad/evidence/` — evidence artifacts
- `.tad/templates/` — static templates
- Any file outside the three allowed path patterns

### Relationship with stale-knowledge-check.sh

| Aspect | stale-knowledge-check.sh | knowledge-blame.sh |
|--------|-------------------------|-------------------|
| Who uses | Alex (step0_5 context refresh) | Blake (during implementation) |
| When | Every handoff creation | On-demand, when uncertain |
| What it does | Scan ALL entries for staleness | Query ONE specific rule's provenance |
| Output | Advisory warnings (STALE/INFO) | Structured provenance for decision-making |
| Scope | All project-knowledge files | Single file + line |

They are complementary: Alex catches stale rules before handoff; Blake investigates specific rules during implementation.

---

## 4. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Implementation form | MCP tool / Bash script / SKILL rule only | Bash script + SKILL rule | MCP is overkill for git commands. Bash script is portable, no dependencies, immediate. SKILL rule guides when to use. |
| 2 | Scope | project-knowledge only / + SKILL.md / + hooks/lib | project-knowledge + SKILL.md + hooks/lib | ARCH P1-4: Blake routinely modifies hooks/lib/*.sh (trace-writer, dream-scanner, layer2-audit). Excluding them would mean Blake can't blame its own authored code. |
| 3 | Trigger | Auto every read / Layer 1 hint / pure manual | Manual + Layer 1 hint | Auto = huge token waste. Pure manual = Blake forgets to use it. Hint on retry = right balance. |
| 4 | stale-check relationship | Replace / merge / complement | Complement | Different roles, different timing, different granularity. Alex scans breadth; Blake queries depth. |

---

## 5. Architecture & Data Flow

See §3 Technical Design for the architecture diagram.

Data flow: Blake reads knowledge rule → judges uncertainty → Bash calls knowledge-blame.sh → git blame + git log → structured provenance → Blake cites provenance in decision.

---

## 6. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/hooks/lib/knowledge-blame.sh` | CREATE | Git-blame wrapper script (~60 lines) with --line and --search modes |
| 2 | `.claude/skills/blake/SKILL.md` | MODIFY | Add `knowledge_provenance_protocol` section + Layer 1 retry hint |
| 3 | `.tad/guides/tool-quick-reference-alex.md` | MODIFY | Add knowledge-blame.sh reference (Blake tool but Alex should know it exists) |
| 4 | `.tad/guides/codebase-memory-integration.md` | MODIFY | Add cross-reference to knowledge-blame as complementary tool |

**Grounded Against** (Alex step1c read):
- `.claude/skills/blake/SKILL.md` lines 503-518 (1_5_context_refresh), lines 866-879 (2_layer1_loop)
- `.tad/hooks/lib/stale-knowledge-check.sh` head 50 (existing knowledge tool for reference)
- `.tad/guides/tool-quick-reference-alex.md` head 50 (format reference)

---

## 7. Implementation Steps

### Task 1: Create `.tad/hooks/lib/knowledge-blame.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# knowledge-blame.sh — Query provenance of a TAD knowledge or protocol rule
# Usage: knowledge-blame.sh <file> [--line N | --search "pattern"]
# Output: structured RULE/COMMIT/DATE/AUTHOR/MESSAGE fields (no context — use Read tool)

FILE="${1:-}"; shift || { echo "Usage: knowledge-blame.sh <file> [--line N | --search pattern]"; exit 1; }

# ── P0-4 fix: Path normalization (absolute → relative, reject traversal) ──
case "$FILE" in *..*) echo "ERROR: path traversal not allowed"; exit 2 ;; esac
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "ERROR: not a git repository"; exit 1; }
case "$FILE" in
  /*) FILE=$(python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$FILE" "$REPO_ROOT" 2>/dev/null) || { echo "ERROR: cannot resolve path"; exit 2; } ;;
esac

# ── Scope guard: project-knowledge + SKILL.md + hooks/lib (ARCH P1-4 widened) ──
case "$FILE" in
  .tad/project-knowledge/*|.claude/skills/*/SKILL.md|.tad/hooks/lib/*.sh) ;;
  *) echo "ERROR: out of scope. Allowed: .tad/project-knowledge/, .claude/skills/*/SKILL.md, .tad/hooks/lib/*.sh"; exit 2 ;;
esac

[ -f "$FILE" ] || { echo "ERROR: file not found: $FILE"; exit 1; }

MODE="summary"
LINE_NUM=""
PATTERN=""

while [ $# -gt 0 ]; do
  case "$1" in
    --line) LINE_NUM="$2"; MODE="line"; shift 2 ;;
    --search) PATTERN="$2"; MODE="search"; shift 2 ;;
    --help) echo "Usage: knowledge-blame.sh <file> [--line N | --search \"pattern\"]"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── P1-5 fix: validate --line is a positive integer ──
if [ "$MODE" = "line" ]; then
  [[ "$LINE_NUM" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --line requires a positive integer, got: $LINE_NUM"; exit 1; }
fi

# ── CR P0-1 fix: grep -Fn (fixed-string) + || true (no crash on no-match) ──
if [ "$MODE" = "search" ]; then
  LINE_NUM=$(grep -Fn "$PATTERN" "$FILE" | head -1 | cut -d: -f1) || true
  [ -z "$LINE_NUM" ] && { echo "PATTERN_NOT_FOUND: $PATTERN"; exit 0; }
fi

# ── ARCH P1-3 fix: summary mode capped at 5 lines (not 20) ──
if [ "$MODE" = "summary" ]; then
  git log --format='%ad %an: %s' --date=short -- "$FILE" | head -5
  exit 0
fi

# ── CR P0-2 fix: validate line number against file length ──
TOTAL_LINES=$(wc -l < "$FILE" | tr -d ' ')
if [ "$LINE_NUM" -gt "$TOTAL_LINES" ]; then
  echo "ERROR: line $LINE_NUM exceeds file length ($TOTAL_LINES lines)"
  exit 0
fi

# ── Blame the specific line ──
BLAME_LINE=$(git blame -L "${LINE_NUM},${LINE_NUM}" --porcelain "$FILE" 2>/dev/null | head -1) || true
COMMIT_HASH=$(echo "$BLAME_LINE" | awk '{print $1}')

[ -z "$COMMIT_HASH" ] && { echo "BLAME_FAILED: could not blame line $LINE_NUM"; exit 0; }

# ── CR P0-3 + ARCH P0-3 fix: handle uncommitted content (zero hash) ──
if [[ "$COMMIT_HASH" == 0000000* ]]; then
  RULE=$(sed -n "${LINE_NUM}p" "$FILE")
  printf 'RULE: %s\n' "$RULE"
  printf 'COMMIT: uncommitted\n'
  printf 'DATE: (working tree)\n'
  printf 'AUTHOR: (not yet committed)\n'
  printf 'MESSAGE: Content exists in working tree but has not been committed\n'
  exit 0
fi

RULE=$(sed -n "${LINE_NUM}p" "$FILE")
COMMIT_DATE=$(git log -1 --format='%ad' --date=short "$COMMIT_HASH" 2>/dev/null) || true
COMMIT_AUTHOR=$(git log -1 --format='%an' "$COMMIT_HASH" 2>/dev/null) || true
COMMIT_MSG=$(git log -1 --format='%s' "$COMMIT_HASH" 2>/dev/null) || true

# ── ARCH P0-1 fix: NO context output (Blake uses Read tool for surrounding lines) ──
printf 'RULE: %s\n' "$RULE"
printf 'COMMIT: %s\n' "$COMMIT_HASH"
printf 'DATE: %s\n' "$COMMIT_DATE"
printf 'AUTHOR: %s\n' "$COMMIT_AUTHOR"
printf 'MESSAGE: %s\n' "$COMMIT_MSG"
```

**Task 1 post-steps:**
1. `chmod +x .tad/hooks/lib/knowledge-blame.sh` (explicit — do NOT forget)
2. Verify: `bash .tad/hooks/lib/knowledge-blame.sh --help` exits 0

### Task 2: Modify `.claude/skills/blake/SKILL.md`

**2a. Add `knowledge_provenance_protocol` section** (insert after `1_5_context_refresh`, before `1_5a_pack_detection`).
⚠️ ARCH P1-2 clarification: This is a REFERENCE definition placed near related knowledge protocols. It does NOT auto-run at step 1_5. It fires on-demand DURING implementation (2_layer1_loop or general coding). Blake must not execute it at activation time.

```yaml
    1_5_knowledge_provenance:
      description: "On-demand knowledge rule provenance query (DiffMem-inspired)"
      trigger: |
        Blake uses this when:
        a. A .tad/project-knowledge/ rule seems inapplicable to the current task
        b. Layer 1 retry was caused by following a knowledge rule that produced an error
        c. Blake wants to understand WHY a constraint exists before deciding to follow or adapt it
      action: |
        1. Identify the specific rule line in the knowledge file
        2. Run: bash .tad/hooks/lib/knowledge-blame.sh <file> --search "<rule text snippet>"
           Or: bash .tad/hooks/lib/knowledge-blame.sh <file> --line <N>
        3. Read the COMMIT/DATE/MESSAGE output
        4. Use provenance to make an informed decision:
           - MESSAGE references a specific handoff → check if that handoff's context matches current task
           - DATE is recent (< 30 days) → rule is likely still relevant
           - DATE is old (> 90 days) → consider whether the codebase has changed since
           - AUTHOR is "Sheldon" → human-authored rule, higher weight
           - AUTHOR is agent → machine-derived rule, verify against current state
        5. Document the decision in completion report:
           "Knowledge rule '{rule}' from {date} ({message}): followed / adapted / flagged because {reason}"
      scope: ".tad/project-knowledge/*.md, .claude/skills/*/SKILL.md, and .tad/hooks/lib/*.sh"
      blocking: false
      advisory: true
      relationship_to_stale_check: |
        stale-knowledge-check.sh (Alex step0_5) scans ALL entries for staleness at handoff creation.
        knowledge-blame.sh (this protocol) queries ONE specific rule during implementation.
        They are complementary — Alex catches breadth, Blake investigates depth.
```

**2b. APPEND a 4th item** to the existing `2_layer1_loop.on_failure` list (do NOT replace the existing 3 items — only append):

```yaml
          - "Advisory: if this retry was caused by following a .tad/project-knowledge/ rule, consider running knowledge-blame.sh to check the rule's provenance before the next attempt (see 1_5_knowledge_provenance)"
```

### Task 3: Modify `.tad/guides/tool-quick-reference-alex.md`

Add after the Codebase-Memory-MCP section:

```markdown
### Knowledge-Blame (Rule Provenance Query)
- **Path:** `.tad/hooks/lib/knowledge-blame.sh`
- **Used by:** Blake (during implementation), Alex (during knowledge review)
- **Key commands:**
  - Blame a specific line: `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md --line 42`
  - Search and blame: `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/code-quality.md --search "tsc missing type"`
  - File summary: `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md`
- **Output:** Structured RULE/COMMIT/DATE/AUTHOR/MESSAGE/CONTEXT fields
- **Scope:** `.tad/project-knowledge/*.md` and `.claude/skills/*/SKILL.md` only
- **Relationship:** Complements stale-knowledge-check.sh (Alex scans breadth, Blake queries depth)
```

### Task 4: Modify `.tad/guides/codebase-memory-integration.md`

Add a brief cross-reference section at the end:

```markdown
## Related Tools

- **knowledge-blame.sh** — Query provenance of knowledge rules via git blame. Complements this tool: codebase-memory-mcp handles CODE structure (call graphs, blast radius), knowledge-blame handles KNOWLEDGE provenance (why a rule exists, who added it, when). See tool-quick-reference-alex.md for usage.
```

---

## 8. 📚 Project Knowledge — ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| Hook Shell Portability Rules | architecture.md | No `grep -P`, use `grep -E` for ERE. `sed` delimiter `#` not `\|` for paths |
| Shell Env-Var Convention | architecture.md | If function grows beyond 3 params, use env-var convention |
| Heredoc injection depends on SINK | code-quality.md | knowledge-blame.sh outputs via printf (file-write-safe), not eval |
| stale-knowledge-check.sh | architecture.md | Existing Alex-side tool — knowledge-blame is Blake-side complement, not replacement |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence |
|---|-----|-------------------|-------------------|
| AC1 | knowledge-blame.sh exists and is executable | `test -x .tad/hooks/lib/knowledge-blame.sh && echo 1` | = 1 |
| AC2 | Scope guard rejects out-of-scope relative paths | `bash .tad/hooks/lib/knowledge-blame.sh .tad/active/handoffs/foo.md 2>&1 \| grep -c 'out of scope'` | = 1 |
| AC3 | Scope guard rejects path traversal | `bash .tad/hooks/lib/knowledge-blame.sh '.tad/project-knowledge/../../etc/passwd' 2>&1 \| grep -c 'traversal'` | = 1 |
| AC4 | --search mode works (fixed-string, not regex) | `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md --search "Ralph Loop" \| grep -c 'COMMIT:'` | = 1 |
| AC5 | --line mode returns 5 structured fields (no CONTEXT) | `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md --line 10 \| grep -cE 'RULE:\|COMMIT:\|DATE:\|AUTHOR:\|MESSAGE:'` | = 5 |
| AC6 | Summary mode capped at ≤5 lines | `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md \| wc -l` | ≤ 5 |
| AC7 | Zero hash handled (uncommitted content) | Script does not crash on `0000000*` hash (verified by code-reviewer P0-3 fix presence: `grep -c '0000000' .tad/hooks/lib/knowledge-blame.sh`) | ≥ 1 |
| AC8 | Blake SKILL has knowledge_provenance_protocol | `grep -c 'knowledge_provenance_protocol\|1_5_knowledge_provenance' .claude/skills/blake/SKILL.md` | ≥ 1 |
| AC9 | Layer 1 retry hint references knowledge-blame | `grep -c 'knowledge-blame' .claude/skills/blake/SKILL.md` | ≥ 1 |
| AC10 | Tool quick reference has knowledge-blame section | `grep -c 'Knowledge-Blame' .tad/guides/tool-quick-reference-alex.md` | ≥ 1 |
| AC11 | Integration guide cross-references knowledge-blame | `grep -c 'knowledge-blame' .tad/guides/codebase-memory-integration.md` | ≥ 1 |
| AC12 | Token efficiency: output ≤ 7 lines for single-line query | `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md --line 10 \| wc -l` | ≤ 7 |
| AC13 | Scope includes hooks/lib | `grep -c 'hooks/lib' .tad/hooks/lib/knowledge-blame.sh` | ≥ 1 |

### 9.2 Expert Review Status

| Reviewer | Focus | P0 | P1 | P2 | Verdict |
|----------|-------|----|----|----|----|
| code-reviewer | Shell correctness, edge cases, AC runnability | 4 (all fixed) | 6 (5 fixed, 1 accepted) | 4 | CONDITIONAL PASS → fixed |
| backend-architect | Architecture, scope, token budget, *sync, staleness | 3 (all fixed) | 4 (all fixed) | 4 | CONDITIONAL PASS → fixed |

### 9.2.1 Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| CR P0-1 | grep no-match + pipefail → crash | Added `\|\| true` + `grep -Fn` (fixed-string) | Resolved |
| CR P0-2 | git blame out-of-range → crash | Added `wc -l` validation before blame | Resolved |
| CR P0-3 + ARCH P0-3 | Zero hash from uncommitted → git log crash | Added `0000000*` check with structured UNCOMMITTED output | Resolved |
| CR P0-4 + ARCH P0-2 | Path traversal + absolute path rejected | Added `..` rejection + `git rev-parse --show-toplevel` normalization | Resolved |
| ARCH P0-1 + CR P1-2 | CONTEXT multi-line breaks parsing + token explosion | Removed CONTEXT_BEFORE/AFTER entirely (Blake uses Read tool) | Resolved |
| CR P1-4 + ARCH | grep regex metacharacters in knowledge text | Changed to `grep -Fn` (fixed-string matching) | Resolved |
| CR P1-5 | --line value not validated as integer | Added `[[ =~ ^[1-9][0-9]*$ ]]` check | Resolved |
| ARCH P1-2 | 1_5 insertion is pre-impl but trigger is during-impl | Added REFERENCE clarification in Task 2a | Resolved |
| ARCH P1-3 | Summary 20 lines ≈ 1000 tokens, exceeds NFR1 | Capped at `head -5` + `--date=short` | Resolved |
| ARCH P1-4 | Scope missing hooks/lib (Blake-authored code) | Widened scope to include `.tad/hooks/lib/*.sh` + updated Decision #2 | Resolved |
| CR P1-3 | BSD sed edge case for LINE_NUM=1 | Implicit: line validation + no CONTEXT output = no sed edge case | Resolved |
| CR P1-6 | Task 2b unclear (replace vs append) | Reworded to "APPEND a 4th item" | Resolved |
| CR P2-2 + ARCH P2-2 | AC4 `grep -cE` with `\|` is ERE bug | ACs fully rewritten with correct syntax | Resolved |
| CR P2-4 | chmod +x not in task steps | Added as explicit Task 1 post-step | Resolved |

---

## 10. Important Notes

### 10.1 What NOT to Do
- Do NOT make knowledge-blame a hook (it's a tool Blake calls on-demand, not auto-triggered)
- Do NOT add to settings.json
- Do NOT auto-run on every knowledge file read (token waste)
- Do NOT expand scope beyond project-knowledge + SKILL.md without explicit handoff

### 10.2 Token Budget
Each knowledge-blame call should return < 500 tokens (~7-10 structured lines). The script filters to the specific line + 2 lines context. Summary mode caps at 20 lines of git log.

---

## 11. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/knowledge-blame-tool/code-reviewer.md
  - .tad/evidence/reviews/blake/knowledge-blame-tool/backend-architect.md
gate_verdicts:
  - gate3_verdict in COMPLETION frontmatter
completion:
  - .tad/active/handoffs/COMPLETION-20260602-knowledge-blame-tool.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new pattern discovered)
```
