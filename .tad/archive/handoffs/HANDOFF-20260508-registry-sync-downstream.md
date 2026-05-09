---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
gate4_delta: []
---

# Mini-Handoff: Sync pack-registry.yaml + GitHub Install
**From:** Alex | **To:** Blake | **Date:** 2026-05-08
**Type:** Express (skip Socratic, keep expert review)
**Priority:** P2

## Problem
After pack integration, `pack-registry.yaml` lives at `.tad/capability-packs/pack-registry.yaml` — but `.tad/capability-packs/` is in the PRESERVE (zero-touch) list, so `*sync` doesn't distribute it. Downstream projects have no idea what packs exist. Alex in menu-snap can't recommend "你应该装 web-backend pack"。

## Fix 0: Add GitHub source to pack-registry.yaml

scan-packs.sh must add top-level fields to pack-registry.yaml:

```yaml
source_repo: "Sheldon-92/TAD"              # auto-detected from git remote get-url origin
source_branch: "main"                       # auto-detected from git default branch
source_base_path: ".tad/capability-packs"   # path within repo
synced_from_version: "2.10.5"               # from .tad/version.txt
```

`source_repo` is auto-detected by scan-packs.sh via `git remote get-url origin | sed 's#.*/\([^/]*/[^/.]*\).*#\1#'` — NOT hardcoded. Works for forks and renames.

## Fix 1: Sync registry file only

Add `pack-registry.yaml` to *sync step3 framework file copy list. The registry is a lightweight index (~50 lines) — safe to distribute. Pack source code stays zero-touch.

In Alex SKILL `sync_protocol.execution.step3`, section "b. Framework files", add:
```
- .tad/capability-packs/pack-registry.yaml
```

Downstream project gets:
```
.tad/capability-packs/
└── pack-registry.yaml   # ← synced (index only, no pack source dirs)
```

## Fix 2: Alex step1_5b — GitHub-based install recommendation

Current step1_5b reads registry → matches packs → loads CAPABILITY.md. In downstream projects, registry exists (after Fix 1) but CAPABILITY.md is missing (pack not installed).

Update step1_5b logic:
```
After matching pack from registry:
  IF .tad/capability-packs/{pack}/CAPABILITY.md exists → load it (TAD project)
  ELIF .claude/skills/{pack}/SKILL.md exists → load it (already installed)
  ELSE → pack matched but not installed. AskUserQuestion:
    "检测到 '{pack_name}' pack 与你的任务相关，但未安装。要安装吗？"
    Options: "安装 (Recommended)" / "跳过"
    If install:
      → Read registry source_repo + source_branch + source_base_path
      → Read registry source_repo + source_branch + source_base_path
      → Construct install command using gh CLI (works for private repos with existing auth):
        gh api "repos/{source_repo}/contents/{source_base_path}/{pack_name}/install.sh?ref={source_branch}" --jq '.content' | base64 -d | bash -s -- --agent=claude-code
      → Alternative (if repo is public):
        curl -sSL "https://raw.githubusercontent.com/{source_repo}/{source_branch}/{source_base_path}/{pack_name}/install.sh" | bash -s -- --agent=claude-code
      → Display BOTH commands with note: "私有仓库用 gh 命令，公开仓库用 curl 命令"
      → Note: Alex CANNOT run the command (Alex doesn't execute scripts). User copies and runs it.
      → If source_repo missing: fallback message "请手动从 GitHub clone TAD 仓库后运行 install.sh"
```

## Files to Modify
- `.tad/scripts/scan-packs.sh` — add source_repo/source_branch/source_base_path/synced_from_version to output
- `.claude/skills/alex/SKILL.md` — sync_protocol step3 file list + step1_5b GitHub install fallback

## Acceptance Criteria
- [ ] **AC1**: `pack-registry.yaml` listed in sync_protocol step3 framework files
- [ ] **AC2**: step1_5b has 3-tier lookup: `.tad/capability-packs/` → `.claude/skills/` → "not installed" prompt
- [ ] **AC3**: "not installed" prompt displays both `gh api` (private repo) and `curl` (public repo) install commands
- [ ] **AC4**: Alex does NOT run install command itself (displays for user to copy-paste)
- [ ] **AC5**: scan-packs.sh adds `source_repo`, `source_branch`, `source_base_path`, `synced_from_version` to registry top-level
- [ ] **AC6**: Graceful fallback if source_repo missing in registry (display generic "从 GitHub 下载" message)
