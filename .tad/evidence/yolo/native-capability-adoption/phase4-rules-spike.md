# Phase 4 B1 Spike — `.claude/rules` Path-Scoped Frontmatter (LOADED/INERT)

**Date**: 2026-07-13
**CLI version under test**: `2.1.172 (Claude Code)` (`claude --version`, local run 2026-07-13 — same version as the Phase 2 INERT finding, which is why this spike was mandatory)
**Executor**: Blake (YOLO Phase 4)

---

## Verdict line

Verdict: LOADED

---

## 1. Docs verification (FR5 — exact frontmatter key syntax)

### Source 1 — Official documentation (PRIMARY)

- **URL**: https://code.claude.com/docs/en/memory (section "Organize rules with `.claude/rules/`" → "Path-specific rules")
- **retrieval date**: 2026-07-13 (WebFetch)
- **Documented key**: `paths` — YAML frontmatter, list of quoted glob patterns:

  ```markdown
  ---
  paths:
    - "src/api/**/*.ts"
  ---
  ```

- **Documented load semantics** (verbatim): "Rules without a `paths` field are loaded
  unconditionally and apply to all files. Path-scoped rules trigger when Claude **reads**
  files matching the pattern, not on every tool use."
- **Version note in docs**: "As of v2.1.198, matching also works when Claude reaches a file
  through a symlinked path" — implies the feature predates 2.1.198; our CLI is 2.1.172
  (older), so behavior on THIS version cannot be assumed from docs alone → fire-test below.
- Glob semantics documented: `**/*.ts`, `src/**/*`, brace expansion `src/**/*.{ts,tsx}`;
  patterns must be quoted (YAML treats `*`/`{` as reserved indicators).

### Source 2 — Contradicting community report (checked, then adjudicated by fire-test)

- **URL**: https://github.com/anthropics/claude-code/issues/17204
- **retrieval date**: 2026-07-13 (WebFetch)
- **Claim**: documented `paths:` with quoted values / YAML list silently FAILS; undocumented
  `globs:` (comma-separated) works. CLI version not specified in issue; issue closed
  "not planned", no maintainer confirmation.
- **Adjudication**: empirical fire-test on OUR CLI version (below) shows the documented
  `paths:` YAML-list form DOES work on 2.1.172. The issue's claim does not reproduce here.
  Chosen syntax = documented `paths:` YAML list (official form, empirically verified locally).

## 2. Fire-test (raw records — anti-Validation-Theater)

Isolated fixture at `/tmp/rules-spike-JOwazn` (mktemp), so no TAD context contamination:

```
/tmp/rules-spike-JOwazn/
├── .claude/rules/unconditional.md   # control: NO frontmatter, token SENTINEL-ALPHA-9314
├── .claude/rules/pathscoped.md      # paths: [".tad/hooks/**"], token SENTINEL-BRAVO-6627
├── .tad/hooks/dummy.sh              # matching file
└── docs/readme.md                   # non-matching file
```

pathscoped.md frontmatter (documented syntax, exactly as shipped in B2):

```markdown
---
paths:
  - ".tad/hooks/**"
---
```

### Test 0 — Control (feature exists at all on 2.1.172?)

Command: `claude -p "Without reading any files: list every sentinel token (format SENTINEL-*) currently present in your context/instructions. If none, say NONE." --model claude-sonnet-4-5` (cwd = fixture)

Raw output (tail):
> 我在当前上下文中找到了一个 sentinel token：
> **SENTINEL-ALPHA-9314**
> 这个 sentinel 出现在项目指令文件 `/private/tmp/rules-spike-JOwazn/.claude/rules/unconditional.md` 中…

Result: ALPHA loaded at launch, BRAVO absent → `.claude/rules` live on 2.1.172; path-scoped
rule correctly NOT loaded before any matching read. **PASS**

### Test 1 — FIRE (read matching file → rule loads?)

Command: `claude -p "First use the Read tool to read the file .tad/hooks/dummy.sh. After reading it, list every sentinel token (format SENTINEL-*) present in your context/instructions at that point. If none, say NONE. Answer in English." --model claude-sonnet-4-5`

Raw output (tail):
> 1. **SENTINEL-ALPHA-9314** - from `/private/tmp/rules-spike-JOwazn/.claude/rules/unconditional.md` …
> 2. **SENTINEL-BRAVO-6627** - from `/private/tmp/rules-spike-JOwazn/.claude/rules/pathscoped.md` (hooks files are guarded by the bravo sentinel)

Result: path-scoped rule CONTENT entered context after reading a `.tad/hooks/**` file —
harness genuinely discovered and injected the rule (not merely "YAML parses"). **PASS**

### Test 2 — NO-FIRE (read non-matching file → rule stays out?)

Command: `claude -p "First use the Read tool to read the file docs/readme.md. After reading it, list every sentinel token (format SENTINEL-*) present in your context/instructions at that point. If none, say NONE. Answer in English." --model claude-sonnet-4-5`

Raw output (tail):
> **SENTINEL-ALPHA-9314** - This appears in the project instructions file at `/private/tmp/rules-spike-JOwazn/.claude/rules/unconditional.md` …
> That's the only sentinel token present in my current context.

Result: BRAVO absent after non-matching read → scoping is real, not "loads everything". **PASS**

## 3. Conclusion

- **Final call — LOADED** (3/3 tests; LOADED criterion = harness actually discovered and injected
  rule content on matching read, per arch P2-3 — satisfied by Test 1 vs Test 0/2 contrast).
- Syntax to use in B2: documented `paths:` YAML list with double-quoted glob:
  `paths:\n  - ".tad/hooks/**"`.
- **Known limitation carried into B2/B3**: rules trigger on file READS, not on writes/creation
  of new files (per official docs). A session that edits a hook without reading any
  `.tad/hooks/**` file first will not have the rule in context. Documented in the rule file
  and in the measurement evidence.
- Issue #17204's `paths:`-broken claim does not reproduce on 2.1.172 with the YAML-list form.
