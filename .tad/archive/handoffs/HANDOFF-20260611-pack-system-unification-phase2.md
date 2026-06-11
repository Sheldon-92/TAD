---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs:
  - ".tad/capability-packs"
  - ".claude/skills"
  - ".agents/skills"
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)  
**To:** Blake (Agent B - Execution Master)  
**Date:** 2026-06-11  
**Project:** TAD Framework  
**Task ID:** TASK-20260611-002  
**Handoff Version:** 3.1.0  
**Epic:** EPIC-20260611-pack-system-unification.md (Phase 2/3)  
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-11 04:40 UTC / 2026-06-11 00:40 EDT

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 2 target is installer output determinism: prebuilt `SKILL.md` source truth + platform-aware copy to `.claude/skills` and `.agents/skills`. Standing drift verification remains Phase 3. |
| Components Specified | ✅ | Target packs are explicit: six measured transform packs plus `ml-training`; flag compatibility additionally covers `research-methodology`. |
| Functions Verified | ✅ | Existing installer scripts were grounded by reading representative scripts and dry-running current flag behavior. No new runtime hook is designed. |
| Data Flow Mapped | ✅ | Source flow changes from install-time `CAPABILITY.md -> target/SKILL.md` synthesis to prebuilt `.tad/capability-packs/{pack}/SKILL.md -> target/SKILL.md` copy. |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解 Phase 2 不包含 standing post-sync verifier；那是 Phase 3
- [ ] 理解 source-of-truth 是 prebuilt `.tad/capability-packs/{pack}/SKILL.md`
- [ ] §9.1 commands are the source of truth for Gate 3 verification

❌ 如果任何部分不清楚，立即返回 Alex 要求澄清，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Normalize Capability Pack installer output for the packs that currently diverge between source, `.claude/skills`, and `.agents/skills`. Phase 2 creates prebuilt `SKILL.md` files for seven target packs, updates their installers to copy that prebuilt file instead of generating `SKILL.md` from `CAPABILITY.md`, makes Claude Code and Codex project-local installs explicit, and fixes the two known installer flag outliers.

Target packs for single-sourcing:

```text
academic-research
ai-agent-architecture
ai-voice-production
video-creation
web-frontend
web-ui-design
ml-training
```

Additional flag-only target:

```text
research-methodology
```

### 1.2 Why We're Building It

**业务价值**: Remove the second active pack-distribution failure mode identified by the Pack System Unification idea: install-time transformations produce Claude-only or divergent pack content.  
**用户受益**: Claude Code and Codex users see the same framework-owned pack content after install/sync, and installer behavior becomes simple enough for Phase 3 to verify mechanically.  
**成功的样子**: Running a target pack installer in a temp project writes `SKILL.md` bytes equal to the prebuilt source file, and both `.claude/skills/{pack}/SKILL.md` and `.agents/skills/{pack}/SKILL.md` match that same source.

### 1.3 Intent Statement

**真正要解决的问题**: Installer-time `CAPABILITY.md -> SKILL.md` synthesis and Claude-only target paths make Codex pack content raw, missing, or unverifiable. Phase 2 turns pack installs into deterministic copy semantics.

**不是要做的（避免误解）**:
- ❌ 不是 quality-upgrade the seven packs' content; copy the current accepted content unless a frontmatter/parser fix is required.
- ❌ 不是 build a standing cross-project verifier; that is Phase 3.
- ❌ 不是 rewrite all 25 installers. Keep scope to the seven target packs plus the `research-methodology` flag fix unless a shared helper is demonstrably smaller and safer.
- ❌ 不是 revive Domain Packs or change `.tad/domains`.

**Blake请确认理解**:
```text
在开始实现前，请用你自己的话回答：
1. What is the source of truth for target pack SKILL.md content after Phase 2?
2. Which packs are in scope, and which installer is flag-only?
3. Which verification work is deliberately deferred to Phase 3?

Only Human confirmation is needed if your understanding differs from this handoff.
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - pack distribution and copy semantics
- [x] code-quality - shell installer edits and drift prevention
- [x] testing - AC command dry-run and byte-equality checks
- [x] shell-portability - installer flag parsing and temp-project tests
- [x] pack-build-rules - Capability Pack SKILL frontmatter and source rules

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**:

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| `.tad/project-knowledge/principles.md` | 4 | Existing tools over hand-written copies; deny-list/copy granularity; verifier must match write granularity; mechanical hooks rejected. |
| `.tad/project-knowledge/patterns/pack-build-rules.md` | 4 | SKILL frontmatter is load-bearing; Codex editions must avoid drift; pack content changes need provenance. |
| `.tad/project-knowledge/patterns/ac-verification.md` | 4 | ACs are operational contract; dry-run commands; include undecidable/fail-safe cases when relevant. |
| `.tad/project-knowledge/patterns/shell-portability.md` | 4 | macOS shell portability, env/flag conventions, copy-after-deprecation, frontmatter YAML quoting. |

**⚠️ Blake 必须注意的历史教训**:

1. **Deny-List Must Be Applied at EVERY Copy Granularity** (`principles.md`)
   - 问题: fixing one copy path leaves a sibling copy/install path silently divergent.
   - 解决方案: Phase 2 must verify the exact granularity being changed: `SKILL.md` bytes from source pack to `.claude` and `.agents`.

2. **Never Hand-Write What an Existing Tool Already Does** (`principles.md`)
   - 问题: ad-hoc installer logic from memory repeatedly missed directories/files.
   - 解决方案: prefer the existing installer shape and make its source/target mapping deterministic; do not invent a separate manual sync script for this phase.

3. **Capability Pack: YAML Frontmatter is Load-Bearing** (`pack-build-rules.md`)
   - 问题: installs can "succeed" while the skill loader ignores malformed or missing frontmatter.
   - 解决方案: every new prebuilt `SKILL.md` must preserve valid `name:` and `description:` frontmatter, and Codex-strict YAML must parse.

4. **Capability Pack: Design and Build Rules** (`pack-build-rules.md`)
   - 问题: Codex edition drift happens when generated/stripped artifacts become a separate source.
   - 解决方案: do not create a second Codex-specific content source. `.agents/skills/{pack}/SKILL.md` must match the same prebuilt source file as `.claude`.

5. **AC Verification Drift Pattern** (`ac-verification.md`)
   - 问题: grep/find commands that look correct often fail in Blake's literal runtime.
   - 解决方案: Blake must record raw outputs for every §9.1 command; if a command needs adjustment, document it in Friction Status and keep the same acceptance intent.

6. **YAML Frontmatter description Fields Must Quote Colons** (`shell-portability.md`)
   - 问题: Codex's skill loader is stricter than Claude Code around YAML frontmatter.
   - 解决方案: when copying current CAPABILITY content into prebuilt SKILL files, quote `description` fields containing colons or other YAML-special characters.

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work

Phase 1 retired YAML Domain Packs as an active runtime/sync mechanism and was accepted at Gate 4 on 2026-06-11.

The original idea measured that Capability Pack installs are still platform-blind:

- six packs produce `.claude/skills/{pack}/SKILL.md` through install-time transformation while `.agents/skills/{pack}/SKILL.md` keeps the raw master copy
- `ml-training` has no prebuilt `.claude/.agents` SKILL output
- two installers reject common sync flags (`academic-research`, `research-methodology`)

### 2.2 Current State

Current target source state:

- `.tad/capability-packs/product-thinking/SKILL.md` exists and can serve as the local pattern for prebuilt source files.
- The seven Phase 2 target packs do not all have `.tad/capability-packs/{pack}/SKILL.md`.
- `.claude/skills/ml-training/` and `.agents/skills/ml-training/` are absent.
- Current dry-run behavior:
  - `academic-research`: `bash install.sh --dry-run --force` fails with `Unknown option: --dry-run`
  - `research-methodology`: `bash install.sh --dry-run --force` fails with `Unknown argument: --force`

### 2.3 Dependencies

- No external network dependency.
- No package install dependency.
- Keep Claude/Codex skill trees paired where a target pack is updated.
- If a shared helper is introduced, it must be local to `.tad/capability-packs/` and covered by the same §9.1 installer-output ACs. Do not add hooks/settings.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: For each target pack, create `.tad/capability-packs/{pack}/SKILL.md` as the source-of-truth skill file.
- FR2: For each target pack, ensure `.claude/skills/{pack}/SKILL.md` and `.agents/skills/{pack}/SKILL.md` exist and are byte-identical to `.tad/capability-packs/{pack}/SKILL.md`.
- FR3: Update target pack installers so the installed `SKILL.md` is copied from prebuilt `SKILL.md`, not synthesized from `CAPABILITY.md`.
- FR4: Target pack installers must support project-local Claude Code and Codex outputs:
  - `--agent=claude-code` or equivalent writes `.claude/skills/{pack}/`
  - `--agent=codex` writes `.agents/skills/{pack}/`
- FR5: Normalize flag handling for the target installers: `--dry-run` must not write, and `--force` must be accepted where overwriting is possible.
- FR6: Fix `research-methodology` so `--force` is accepted as a no-op/overwrite flag and does not fail.
- FR7: Preserve pack auxiliary files (`references`, `scripts`, `checklists`, `tools`, examples, license files) according to existing installer behavior; Phase 2's byte-equality requirement is specifically for `SKILL.md`.

### 3.2 Non-Functional Requirements

- NFR1: Do not perform broad pack content rewrites. Content edits should be limited to prebuilding current accepted content and frontmatter validity.
- NFR2: Do not add permanent hooks, settings entries, or SessionStart checks.
- NFR3: Keep Phase 3 clean: do not claim cross-project standing verification is complete in Phase 2.
- NFR4: Shell must remain macOS/BSD compatible; avoid `grep -P`, GNU-only `readlink -f`, and fragile temp paths.
- NFR5: Every implementation commit must include enough evidence to distinguish "installer copied bytes" from "installer printed success".

---

## 4. Technical Design

### 4.1 Architecture Overview

Old flow:

```text
.tad/capability-packs/{pack}/CAPABILITY.md
  -> install.sh transforms/copies as target SKILL.md
  -> usually .claude/skills only
  -> .agents/skills can remain raw, missing, or stale
```

Phase 2 target flow:

```text
.tad/capability-packs/{pack}/SKILL.md  # source of truth
  -> install.sh copies bytes to .claude/skills/{pack}/SKILL.md
  -> install.sh copies bytes to .agents/skills/{pack}/SKILL.md when --agent=codex
  -> committed .claude and .agents outputs match the same source
```

### 4.2 Component Specifications

#### Source SKILL files

For each target pack:

- create `.tad/capability-packs/{pack}/SKILL.md`
- initialize it from the currently accepted installed/source content
- preserve YAML frontmatter with valid `name:` and quoted `description:` where needed
- do not introduce new capability rules unless needed for loader validity

#### Installer behavior

For each target pack installer:

- use `PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` or current equivalent
- copy `${PACK_DIR}/SKILL.md` to target `SKILL.md`
- choose target root by agent:
  - Claude Code: project `.claude/skills/{pack}` by default, with existing `--global` behavior preserved if already present
  - Codex: project `.agents/skills/{pack}` by default
- `--dry-run` prints planned writes and exits 0 without creating files
- `--force` allows overwrite; if an existing script's semantics are already "always overwrite", accepting `--force` as a no-op is acceptable and must be documented in help text

#### Installed tree updates

For each target pack:

- ensure `.claude/skills/{pack}/SKILL.md` exists and matches source
- ensure `.agents/skills/{pack}/SKILL.md` exists and matches source
- update auxiliary files only when needed to keep existing installer outputs coherent; `SKILL.md` equality is mandatory

### 4.3 Files to Modify / Create

Expected create/modify:

- `.tad/capability-packs/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/SKILL.md`
- `.tad/capability-packs/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/install.sh`
- `.tad/capability-packs/research-methodology/install.sh`
- `.claude/skills/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/SKILL.md`
- `.agents/skills/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/SKILL.md`

Possible if needed:

- `.tad/capability-packs/*/README.md` or installer help text for the target packs only
- `.tad/evidence/pack-system-unification-phase2/*` for AC outputs and installer matrix

Do not modify in Phase 2:

- `.tad/domains/**`
- `.tad/hooks/startup-health.sh`
- `.tad/hooks/lib/derive-sync-set.sh`
- standing release/sync verifier wiring for `.claude` vs `.agents` parity (Phase 3)

**Grounded Against**:

- `.tad/capability-packs/academic-research/install.sh` (head/read at 2026-06-11 04:35 UTC)
- `.tad/capability-packs/research-methodology/install.sh` (head/read at 2026-06-11 04:35 UTC)
- `.tad/capability-packs/web-frontend/install.sh` (head/read at 2026-06-11 04:35 UTC)
- `.tad/capability-packs/ai-agent-architecture/install.sh` (head/read at 2026-06-11 04:35 UTC)
- `.tad/capability-packs/web-ui-design/install.sh` (head/read at 2026-06-11 04:38 UTC)

### 4.4 Implementation Notes

- Prefer a simple copy plan over content generation.
- If using `mktemp -d` in tests, clean it with a trap in the same shell process.
- Avoid `rm -rf` in implementation scripts except temp cleanup under a clear trap. Gate AC commands may use temp cleanup only for their own temporary directory.
- For Codex target path, use project-local `.agents/skills/{pack}` because TAD's Codex adapter consumes `.agents/skills`.
- Preserve existing auxiliary install behavior for references/checklists/scripts; do not drop files silently.

---

## 5. Required Evidence Manifest

Blake must produce:

```yaml
required_evidence:
  implementation_commit: "git commit hash after Phase 2 implementation"
  ac_outputs: ".tad/evidence/pack-system-unification-phase2/ac-outputs.txt"
  installer_matrix: ".tad/evidence/pack-system-unification-phase2/installer-matrix.tsv"
  blake_reviews:
    - ".tad/evidence/reviews/blake/pack-system-unification-phase2/spec-compliance-review.md"
    - ".tad/evidence/reviews/blake/pack-system-unification-phase2/code-review.md"
  completion_report: ".tad/active/handoffs/COMPLETION-20260611-pack-system-unification-phase2.md"
  knowledge_updates: "Completion report must say whether KA created/updated project knowledge, with paths if yes."
```

---

## 6. Friction Preflight

| Potential Friction | Expected Handling |
|--------------------|-------------------|
| Existing installers have inconsistent flag grammar (`--agent value` vs `--agent=value`) | Preserve backward compatibility where practical; document any intentionally unsupported form. |
| Some target scripts currently treat `codex` as a Claude install alias | Fix for target packs: Codex project-local install must write `.agents/skills`. |
| Installer dry-runs can accidentally write if a script ignores flags | Verify `--dry-run` in a temp project and record no target files were created. |
| Pack content frontmatter parse differences between Claude and Codex | Validate YAML frontmatter for all new source and installed SKILL files. |

If blocked, use Friction Status in the completion report rather than silently narrowing scope.

---

## 7. Acceptance Criteria

### 7.1 Spec Compliance Checklist

Blake must run the raw §9.1 command block below at Gate 3 and paste output to `ac-outputs.txt`.

### 7.2 Raw §9.1 Verification Commands

```bash
set -euo pipefail

TARGET_PACKS="academic-research ai-agent-architecture ai-voice-production video-creation web-frontend web-ui-design ml-training"
mkdir -p .tad/evidence/pack-system-unification-phase2

echo "=== AC1: source SKILL.md exists for every target pack ==="
for p in $TARGET_PACKS; do
  test -f ".tad/capability-packs/$p/SKILL.md"
  printf 'PASS\t%s\tsource-skill\n' "$p"
done

echo "=== AC2: .claude and .agents SKILL.md match source bytes ==="
for p in $TARGET_PACKS; do
  cmp -s ".tad/capability-packs/$p/SKILL.md" ".claude/skills/$p/SKILL.md"
  cmp -s ".tad/capability-packs/$p/SKILL.md" ".agents/skills/$p/SKILL.md"
  printf 'PASS\t%s\tinstalled-byte-match\n' "$p"
done

echo "=== AC3: installer writes source-identical SKILL.md in temp Claude project ==="
repo="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
for p in $TARGET_PACKS; do
  rm -rf "$tmp/.claude" "$tmp/.agents"
  mkdir -p "$tmp/.claude"
  (
    cd "$tmp"
    bash "$repo/.tad/capability-packs/$p/install.sh" --agent=claude-code --force >/tmp/tad-p2-install.out 2>/tmp/tad-p2-install.err
  )
  cmp -s "$repo/.tad/capability-packs/$p/SKILL.md" "$tmp/.claude/skills/$p/SKILL.md"
  printf 'PASS\t%s\tclaude-installer-byte-match\n' "$p"
done

echo "=== AC4: installer writes source-identical SKILL.md in temp Codex project ==="
repo="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
for p in $TARGET_PACKS; do
  rm -rf "$tmp/.claude" "$tmp/.agents"
  mkdir -p "$tmp/.agents"
  (
    cd "$tmp"
    bash "$repo/.tad/capability-packs/$p/install.sh" --agent=codex --force >/tmp/tad-p2-install.out 2>/tmp/tad-p2-install.err
  )
  cmp -s "$repo/.tad/capability-packs/$p/SKILL.md" "$tmp/.agents/skills/$p/SKILL.md"
  printf 'PASS\t%s\tcodex-installer-byte-match\n' "$p"
done

echo "=== AC5: dry-run does not write target files ==="
repo="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
for p in $TARGET_PACKS research-methodology; do
  rm -rf "$tmp/.claude" "$tmp/.agents"
  mkdir -p "$tmp/.claude" "$tmp/.agents"
  (
    cd "$tmp"
    bash "$repo/.tad/capability-packs/$p/install.sh" --agent=claude-code --dry-run --force >/tmp/tad-p2-dryrun.out 2>/tmp/tad-p2-dryrun.err
  )
  test ! -e "$tmp/.claude/skills/$p/SKILL.md"
  test ! -e "$tmp/.agents/skills/$p/SKILL.md"
  printf 'PASS\t%s\tdry-run-no-write\n' "$p"
done

echo "=== AC6: no target installer copies CAPABILITY.md directly as SKILL.md ==="
if rg -n -e 'CAPABILITY\.md"?[[:space:]]+"?\$?\{?[^[:space:]]*SKILL\.md|CAPABILITY\.md.*->.*SKILL\.md|CAPABILITY\.md.*:.*SKILL\.md' \
  .tad/capability-packs/{academic-research,ai-agent-architecture,ai-voice-production,video-creation,web-frontend,web-ui-design,ml-training}/install.sh; then
  echo "FAIL: target installer still maps CAPABILITY.md directly to SKILL.md" >&2
  exit 1
fi
echo "PASS"

echo "=== AC7: research-methodology accepts --force ==="
repo="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.claude"
(
  cd "$tmp"
  bash "$repo/.tad/capability-packs/research-methodology/install.sh" --agent=claude-code --dry-run --force >/tmp/tad-p2-rm.out 2>/tmp/tad-p2-rm.err
)
echo "PASS"

echo "=== AC8: YAML frontmatter parses for source and installed target SKILL.md files ==="
python3 - <<'PY'
from pathlib import Path
import sys
try:
    import yaml
except Exception as exc:
    print(f"PyYAML unavailable: {exc}", file=sys.stderr)
    sys.exit(2)
packs = "academic-research ai-agent-architecture ai-voice-production video-creation web-frontend web-ui-design ml-training".split()
paths = []
for p in packs:
    paths.extend([
        Path(".tad/capability-packs") / p / "SKILL.md",
        Path(".claude/skills") / p / "SKILL.md",
        Path(".agents/skills") / p / "SKILL.md",
    ])
for path in paths:
    text = path.read_text()
    if not text.startswith("---\n"):
        raise SystemExit(f"missing frontmatter: {path}")
    end = text.find("\n---", 4)
    if end == -1:
        raise SystemExit(f"unterminated frontmatter: {path}")
    data = yaml.safe_load(text[4:end]) or {}
    if not data.get("name") or not data.get("description"):
        raise SystemExit(f"missing name/description: {path}")
    print(f"PASS\t{path}")
PY

echo "=== AC9: Phase 2 did not change Domain Pack retirement surfaces ==="
test "$(find .tad/domains -maxdepth 1 -type f ! -name 'README-retired.md' | wc -l | tr -d ' ')" = "0"
echo "PASS"

echo "=== AC10: evidence and completion report exist ==="
test -f .tad/evidence/pack-system-unification-phase2/ac-outputs.txt
test -f .tad/evidence/pack-system-unification-phase2/installer-matrix.tsv
test -f .tad/evidence/reviews/blake/pack-system-unification-phase2/spec-compliance-review.md
test -f .tad/evidence/reviews/blake/pack-system-unification-phase2/code-review.md
test -f .tad/active/handoffs/COMPLETION-20260611-pack-system-unification-phase2.md
echo "PASS"
```

### 7.3 Alex Step1d Dry-Run Log

Pre-implementation checks actually run by Alex:

- Current flag baseline: `academic-research` fails `--dry-run --force`; `research-methodology` fails `--force`; other packs in the baseline loop exited 0, though Phase 2 must still verify dry-run no-write behavior because some older scripts may ignore flags.
- AC1/AC2/AC3/AC4/AC5/AC8/AC10 are post-implementation checks and must be run by Blake at Gate 3.
- AC6 is post-implementation grep guard. The pattern is intentionally narrow to target direct `CAPABILITY.md -> SKILL.md` mappings in target installers, not historical docs.
- AC9 is pre-implementation verifiable and currently passes after Phase 1: `.tad/domains` contains no active YAML files.

---

## 8. Layer 2 Review Requirements

Blake must run at least two independent review passes before Gate 3:

1. **spec-compliance-review**: Check implementation against this handoff, especially target-pack scope, source-of-truth semantics, and Phase 3 deferral.
2. **code-review**: Check shell portability, flag parsing, temp-dir safety, and byte-equality verification strength.

Both review reports must be saved under:

```text
.tad/evidence/reviews/blake/pack-system-unification-phase2/
```

---

## 9. Completion Report Requirements

Create:

```text
.tad/active/handoffs/COMPLETION-20260611-pack-system-unification-phase2.md
```

It must include:

- `gate3_verdict: pass|partial|fail` frontmatter
- commit hash
- AC1-AC10 summary with path to raw `ac-outputs.txt`
- installer matrix summary
- Layer 2 review summary
- Friction Status table
- Knowledge Assessment
- explicit statement that Phase 3 standing verification is still pending

---

## 10. Handoff to Blake

When ready, send Blake:

```text
Blake, please implement Pack System Unification Phase 2.

Handoff:
.tad/active/handoffs/HANDOFF-20260611-pack-system-unification-phase2.md

Key constraints:
- Source of truth is prebuilt .tad/capability-packs/{pack}/SKILL.md.
- Target packs: academic-research, ai-agent-architecture, ai-voice-production, video-creation, web-frontend, web-ui-design, ml-training.
- research-methodology is flag-only: accept --force and preserve dry-run.
- Do not build the standing .claude/.agents verifier; that is Phase 3.
- Gate 3 must run the raw §9.1 AC block and produce the required evidence manifest.
```
