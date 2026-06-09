# Migration Manifest Schema — Research Evidence
**Date**: 2026-06-09
**Handoff**: HANDOFF-20260609-migration-schema-phase1.md
**Task**: Task 1 — Evidence Gathering

---

## 1. Git Tag Full List (sort -V)

```
v1.0.0
v1.2.0
v1.3.0
v1.4.0
v1.4.1
v2.0.0
v2.4.0
v2.5.0
v2.6.0
v2.7.0
v2.8.2
v2.8.3
v2.8.4
v2.8.5
v2.9.0
v2.9.1
v2.10.0
v2.10.1
v2.10.2
v2.10.3
v2.10.4
v2.10.5
v2.11.0
v2.12.0
v2.13.0
v2.13.1
v2.14.0
v2.14.1
v2.15.0
v2.15.1
v2.16.0
v2.17.0
v2.18.0
v2.19.0
v2.19.1
v2.20.0
v2.21.0
v2.22.0
v2.22.1
v2.23.0
v2.23.1
v2.24.0
v2.24.1
v2.25.0
v2.26.0
v2.27.0
```

**Total**: 46 tags. **Adjacent pairs for migration**: 45 pairs (v1.0.0→v1.2.0, v1.2.0→v1.3.0, ..., v2.26.0→v2.27.0).

**Gap analysis**: v1.4.1→v2.0.0 and v2.0.0→v2.4.0 are large jumps (no intermediate patch tags). All v2.8+ have contiguous minor/patch tags.

---

## 2. Real Diff: v2.26.0 → v2.27.0 (git diff --name-status)

```
A	.agents/skills/alex/SKILL.md
A	.agents/skills/alex/references/handoff-creation-protocol.md
A	.agents/skills/blake/SKILL.md
M	.claude/skills/alex/SKILL.md
M	.claude/skills/alex/references/handoff-creation-protocol.md
M	.claude/skills/blake/SKILL.md
D	.claude/skills/blake/references/completion-protocol.md
D	.claude/skills/blake/references/execution-checklist.md
D	.claude/skills/blake/references/ralph-loop.md
M	.tad/active/dream-state.yaml
A	.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md
A	.tad/active/handoffs/COMPLETION-20260609-codex-native-runtime-policy.md
A	.tad/active/handoffs/COMPLETION-20260609-dual-platform-docs-upgrade.md
A	.tad/active/handoffs/COMPLETION-20260609-dual-platform-runtime-architecture-phase1.md
A	.tad/archive/handoffs/COMPLETION-20260609-runtime-freshness-loop.md
A	.tad/archive/handoffs/HANDOFF-20260609-runtime-freshness-loop.md
M	.tad/codex/README.md
M	.tad/config.yaml
A	.tad/evidence/designs/codex-native-runtime-policy.md
A	.tad/evidence/designs/codex-runtime-candidates/agents/code-reviewer.toml.draft
A	.tad/evidence/designs/codex-runtime-candidates/agents/spec-compliance-reviewer.toml.draft
A	.tad/evidence/designs/codex-runtime-candidates/agents/test-runner.toml.draft
A	.tad/evidence/designs/codex-runtime-candidates/config.toml.draft
A	.tad/evidence/designs/dual-platform-docs-upgrade.md
A	.tad/evidence/designs/dual-platform-native-runtime-architecture.md
A	.tad/evidence/ralph-loops/TASK-20260609-002_state.yaml
A	.tad/evidence/ralph-loops/TASK-20260609-004_state.yaml
A	.tad/evidence/ralph-loops/TASK-20260609-005_state.yaml
A	.tad/evidence/ralph-loops/TASK-20260609-006_state.yaml
A	.tad/evidence/reviews/blake/codex-native-runtime-policy/code-review-r2.md
A	.tad/evidence/reviews/blake/codex-native-runtime-policy/code-review.md
A	.tad/evidence/reviews/blake/codex-native-runtime-policy/spec-compliance-review.md
A	.tad/evidence/reviews/blake/dual-platform-docs-upgrade/code-review.md
A	.tad/evidence/reviews/blake/dual-platform-docs-upgrade/spec-compliance-review.md
A	.tad/evidence/reviews/blake/dual-platform-runtime-architecture-phase1/code-review-r2.md
A	.tad/evidence/reviews/blake/dual-platform-runtime-architecture-phase1/code-review.md
A	.tad/evidence/reviews/blake/dual-platform-runtime-architecture-phase1/spec-compliance-review.md
A	.tad/evidence/reviews/blake/runtime-freshness-loop/code-review-r2.md
A	.tad/evidence/reviews/blake/runtime-freshness-loop/code-review-r3.md
A	.tad/evidence/reviews/blake/runtime-freshness-loop/code-review.md
A	.tad/evidence/reviews/blake/runtime-freshness-loop/spec-compliance-review.md
M	.tad/hooks/lib/release-verify.sh
A	.tad/hooks/lib/runtime-freshness-verify.sh
A	.tad/hooks/lib/skill-body-verify.sh
M	.tad/project-knowledge/patterns/shell-portability.md
M	.tad/project-knowledge/principles.md
A	.tad/runtime-compat/claude-code.md
A	.tad/runtime-compat/codex.md
M	.tad/sync-registry.yaml
M	.tad/version.txt
M	AGENTS.md
M	CHANGELOG.md
M	docs/MULTI-PLATFORM.md
M	tad.sh
```

### Categorized for Migration Manifest

**Deleted (D) — candidates for manifest `delete` section**:
- `.claude/skills/blake/references/completion-protocol.md` (file)
- `.claude/skills/blake/references/execution-checklist.md` (file)
- `.claude/skills/blake/references/ralph-loop.md` (file)

**Renamed (R) — none**: No renames in this version pair.

**Added (A)**: 33 files. Not relevant to migration manifest (new files are installed by normal sync/copy).

**Modified (M)**: 14 files. Not relevant to migration manifest (modified files are overwritten by sync/copy).

**Note**: The manifest is a "批准删除的 allow-list" — it captures files the upgrade should actively remove, not the complete diff. Added and modified files are handled by the existing copy mechanism.

---

## 3. In-the-Wild Version Evidence

### Evidence Source 1: sync-registry.yaml (2026-06-09)
- **Source**: .tad/sync-registry.yaml
- **Finding**: All 14 registered projects are at v2.27.0 (latest)
- **Implication**: No registered project would need a migration from an older version TODAY, but new projects could be initialized from cached/offline older sources

### Evidence Source 2: principles.md tad.sh version-string bug (2026-06-01)
- **Source**: .tad/project-knowledge/principles.md line 72
- **Finding**: "tad.sh stuck at 2.19.1 (not in the 18-item version-string list)" — the hardcoded version-string list in tad.sh failed to include v2.19.1, meaning tad.sh's TARGET_VERSION was stuck at that version for downstream projects until the self-deriving release sync Epic fixed it
- **Implication**: v2.19.1 is the known furthest-back version that could have persisted in the wild due to the version-string bug

### Evidence Source 3: deprecation.yaml historical entries
- **Source**: .tad/deprecation.yaml
- **Finding**: Earliest deprecation entry is v2.3.0 (2026-02-17, multi-platform cleanup). Files from v2.3.0 deprecation could still exist on projects that never ran apply_deprecations (the mechanism was broken until v2.8.2)
- **Implication**: Projects stuck at any version before v2.8.2 never had apply_deprecations run, so even v2.3.0 deprecated files (AGENTS.md, GEMINI.md, .codex/, .gemini/) could still be present

### Evidence Source 4: Tag gap analysis
- **Source**: git tag -l | sort -V (this evidence file §1)
- **Finding**: Major gaps exist at v1.4.1→v2.0.0 and v2.0.0→v2.4.0. The pre-v2.0 structure was fundamentally different (no .tad/ directory). Migration from v1.x would essentially be a clean reinstall, not a file-level migration
- **Implication**: Practical backfill should start from v2.0.0 at the earliest; v1.x→v2.0 should be documented as "clean reinstall required"

---

## 4. NotebookLM Query: External Schema Design Precedents

**Notebook**: "AI Agent Framework Installers" (id: agent-framework-installers, 31445e5a)
**Query**: "How do mainstream AI agent framework installers handle version upgrades with file deletion, renaming, and migration manifests?"
**Result** (2026-06-09):

No direct migration manifest schema precedents found in indexed sources. Related approaches:
- **Containerized rollbacks** (Cursor 3.4): immutable container states, no file-level migration
- **Git-native versioning** (GitClaw): standard git operations for file changes
- **Manifest registries** (BMad Method): bmad-modules.yaml as module registry, but no declarative migration schema documented

**Conclusion**: TAD's migration manifest is a novel approach in the AI agent framework space. No established schema to follow — design from first principles based on the problem domain (declarative file operations tied to semver bumps).

---

## 5. apply_deprecations Analysis (for DR-3)

### Current Implementation (tad.sh L676-737)

**Call site**: tad.sh:474 (`apply_deprecations "$src"`) — runs DURING upgrade, AFTER core framework copy but BEFORE root files copy (L476-479 ordering fix for AGENTS.md)

**Mechanism**:
1. Reads `.tad/deprecation.yaml` from source
2. Simple line-by-line YAML parser (not yq)
3. For each version entry where `version_le "$dep_version" "$current_version"`:
   - Extracts file path from YAML list item
   - Runs `rm -rf -- "$target"` on the path

**Version comparison**: Uses `version_le()` (tad.sh L740-745) which calls `sort -V` — this is correct semver comparison, NOT lexicographic despite L721 comment saying "lexicographic is fine for semver with fixed digits"

**Path safety gap**: `rm -rf -- "$target"` (L726) takes the YAML value directly with NO path validation:
- No prefix check (could delete outside .tad/)
- No symlink check (rm -rf through symlink escapes repo)
- No realpath containment check
- Only protection: `--` prevents leading-dash interpretation

**Scope**: Currently handles 6 version entries (v2.3.0, v2.8.1, v2.8.2, v2.8.4, v2.17.0, v2.26.0), totaling ~50 file paths

**Execution order dependency**: apply_deprecations runs BEFORE platform-specific root file copies (tad.sh:476-479 comment documents this ordering is intentional for AGENTS.md)

---

## 6. ZERO_TOUCH Directory List (live-verified)

```
active
archive
decisions
evidence
github-registry
pair-testing
project-knowledge
research-notebooks
skillify-candidates
```

**Count**: 9 (live `derive-sync-set.sh --zero-touch | wc -l` = 9, matching AC12 exact assertion)

**Source**: `.tad/hooks/lib/derive-sync-set.sh` L53-61 (ZERO_TOUCH array)

**Contract**: These directories contain project-specific data that MUST NEVER be deleted, overwritten, or renamed by any migration operation. The manifest `delete`/`rename` sections must reject any path starting with these prefixes.
