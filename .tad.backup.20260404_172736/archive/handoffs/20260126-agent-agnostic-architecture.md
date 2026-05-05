# Handoff: TAD v2.1 Agent-Agnostic Architecture

**Created**: 2026-01-26
**Author**: Alex (Solution Lead)
**Status**: Expert Reviewed → Pending Gate 2
**Priority**: High
**Estimated Scope**: Large (多文件架构变更)
**Expert Review**: code-reviewer (CONDITIONAL PASS), backend-architect (7.5/10 CONDITIONAL)

---

## 1. Executive Summary

实现 TAD 框架的多 AI 工具支持，使 TAD 能在 Claude Code、OpenAI Codex CLI、Google Gemini CLI 等工具上运行，同时保持现有 Claude Code 用户的完全向后兼容。

### 核心目标
- **多平台支持**: Claude Code + Codex CLI + Gemini CLI
- **技能抽象层**: 8 个核心技能作为统一质量检查接口
- **向后兼容**: 现有 Claude Code 用户升级后无感知
- **降级策略**: 非 Claude 工具使用 Skills 替代 subagents

---

## 2. Background & Context

### 2.1 为什么需要 Agent-Agnostic

1. **减少单一依赖**: 不想只依赖 Claude Code
2. **混合使用场景**: 用户可能 Alex 用 Claude、Blake 用 Codex
3. **团队多样性**: 不同团队成员可能偏好不同工具

### 2.2 研究成果

#### BMAD 方法借鉴
- 17 个平台支持，通过 `platform-codes.yaml` 配置
- Custom Installer 处理特殊平台（Codex, Kilo）
- Config-Driven 处理标准平台
- 安装时生成平台特定文件

#### 三大工具配置对比

| 功能 | Claude Code | Codex CLI | Gemini CLI |
|------|-------------|-----------|------------|
| 项目指令 | `CLAUDE.md` | `AGENTS.md` | `GEMINI.md` |
| 用户配置 | `~/.claude/settings.json` | `~/.codex/config.json` | `~/.gemini/settings.json` |
| 命令目录 | `.claude/commands/*.md` | `.codex/prompts/*.md` | `.gemini/commands/*.toml` |
| 命令格式 | Markdown | Markdown | TOML |

---

## 2.3 Expert Review Findings (P0 Resolutions)

### P0-1: 技能目录关系 (RESOLVED)

**问题**: `.tad/skills/` 与现有 `.claude/skills/` 冲突

**解决方案**:
```yaml
目录职责划分:
  .tad/skills/:
    purpose: "平台无关的技能定义（checklist 格式）"
    content: "纯检查清单，任何 AI 都能理解执行"
    scope: "8 个核心技能"

  .claude/skills/:
    purpose: "Claude Code 增强技能（富文本格式）"
    content: "包含示例、反模式、深度指导"
    scope: "保持现有 43+ 技能不变"

执行优先级:
  Claude Code:
    1. 首先调用 subagent
    2. subagent 可参考 .claude/skills/ 增强内容
    3. 生成证据文件

  Other Platforms:
    1. 读取 .tad/skills/ 检查清单
    2. 自行执行检查
    3. 生成证据文件
```

### P0-2: SKILL.md 格式统一 (RESOLVED)

**问题**: 新格式与现有 `.claude/skills/` 格式不一致

**解决方案**: 采用兼容格式，包含 YAML frontmatter

```markdown
---
name: "{Skill Name}"
id: "{skill-id}"
version: "1.0"
claude_subagent: "{subagent-name}"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# {Skill Name}

## Purpose
{技能目的描述}

## When to Use
- {使用场景 1}
- {使用场景 2}

## Checklist

### Critical (P0) - Must Pass
- [ ] {检查项 1}
- [ ] {检查项 2}

### Important (P1) - Should Pass
- [ ] {检查项 3}

### Nice-to-have (P2) - Informational
- [ ] {检查项 4}

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max 1 failure |
| P2 | Informational |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-{skill-id}-{task}.md`

## Execution Contract
- **Input**: file_paths[], context{}
- **Output**: {passed: bool, issues: [], evidence_path: string}
- **Timeout**: 60s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `{subagent-name}` for deeper analysis.
Reference: `.claude/skills/{skill-id}/SKILL.md` for extended guidance.
```

### P0-3: 平台配置验证 (RESOLVED)

**问题**: Codex/Gemini CLI 配置格式需验证

**解决方案**: 添加 Phase 0 研究验证任务（见 Section 5）

### P0-4: 适配器接口契约 (RESOLVED)

**问题**: 缺少正式接口定义

**解决方案**: 添加 adapter-schema.yaml（见 Section 4.4.1）

### P0-5: 安装脚本健壮性 (RESOLVED)

**问题**: 缺少错误处理和回滚

**解决方案**: 更新 tad.sh 设计（见 Section 4.3）

---

## 3. Requirements

### 3.1 Functional Requirements

#### FR-1: 技能文件系统
- [ ] 创建 `.tad/skills/` 目录存放通用技能定义
- [ ] 8 个 P0 技能文件（SKILL.md 格式）
- [ ] 技能文件可被所有平台读取和执行

#### FR-2: 平台适配器
- [ ] 创建 `.tad/adapters/` 目录
- [ ] `platform-codes.yaml` 定义支持的平台
- [ ] 每个平台的适配器配置

#### FR-3: 安装脚本增强
- [ ] `tad.sh` 检测已安装的 CLI 工具
- [ ] 根据检测结果生成对应平台配置
- [ ] 保持现有 Claude Code 配置不变

#### FR-4: 项目指令文件转换
- [ ] `CLAUDE.md` → `AGENTS.md` 转换器
- [ ] `CLAUDE.md` → `GEMINI.md` 转换器
- [ ] 保持核心规则一致性

#### FR-5: 命令文件转换
- [ ] `.claude/commands/*.md` → `.codex/prompts/*.md`
- [ ] `.claude/commands/*.md` → `.gemini/commands/*.toml`
- [ ] 核心命令（alex, blake, gate, init）必须全平台可用

### 3.2 Non-Functional Requirements

#### NFR-1: 向后兼容
- 现有 Claude Code 用户升级后工作流不变
- 不修改任何现有 `.claude/` 文件结构
- subagent 调用逻辑保持不变

#### NFR-2: 性能
- 安装脚本执行时间 < 30 秒
- 不增加运行时开销

#### NFR-3: 可维护性
- 技能定义统一格式，便于新增
- 适配器配置驱动，便于新增平台

---

## 4. Technical Design

### 4.1 目录结构

```
.tad/
├── config.yaml                    # 主配置（新增 multi_platform 段）
├── version.txt                    # 2.1
├── skills/                        # NEW: 通用技能目录
│   ├── README.md
│   ├── testing/
│   │   └── SKILL.md
│   ├── code-review/
│   │   └── SKILL.md
│   ├── security-audit/
│   │   └── SKILL.md
│   ├── performance/
│   │   └── SKILL.md
│   ├── ux-review/
│   │   └── SKILL.md
│   ├── architecture/
│   │   └── SKILL.md
│   ├── api-design/
│   │   └── SKILL.md
│   └── debugging/
│       └── SKILL.md
├── adapters/                      # NEW: 平台适配器
│   ├── platform-codes.yaml        # 平台定义
│   ├── claude/
│   │   └── adapter.yaml           # Claude 特定配置
│   ├── codex/
│   │   └── adapter.yaml           # Codex 特定配置
│   └── gemini/
│       └── adapter.yaml           # Gemini 特定配置
└── templates/
    ├── AGENTS.md.template         # NEW: Codex 指令模板
    ├── GEMINI.md.template         # NEW: Gemini 指令模板
    └── command-converters/        # NEW: 命令转换模板
        ├── to-codex.template
        └── to-gemini.template

# Codex CLI 配置（安装时生成）
.codex/
├── config.json
└── prompts/
    ├── tad_alex.md
    ├── tad_blake.md
    ├── tad_gate.md
    └── tad_init.md

# Gemini CLI 配置（安装时生成）
.gemini/
├── settings.json
└── commands/
    ├── tad-alex.toml
    ├── tad-blake.toml
    ├── tad-gate.toml
    └── tad-init.toml

# 项目级指令文件
CLAUDE.md                          # 保持不变
AGENTS.md                          # NEW: 从 CLAUDE.md 转换
GEMINI.md                          # NEW: 从 CLAUDE.md 转换
```

### 4.2 技能文件格式 (SKILL.md)

```markdown
# {Skill Name} Skill

## Metadata
- ID: {skill-id}
- Version: 1.0
- Claude Subagent: {subagent-name}  # Claude 时使用
- Fallback: self-check              # 非 Claude 时使用

## Purpose
{技能目的描述}

## Checklist
When executing this skill, verify:

### Critical (P0)
- [ ] {检查项 1}
- [ ] {检查项 2}

### Important (P1)
- [ ] {检查项 3}

### Nice-to-have (P2)
- [ ] {检查项 4}

## Pass Criteria
- P0: All critical items pass
- P1: No more than 1 failure
- P2: Informational only

## Evidence Output
Save results to: `.tad/evidence/reviews/{date}-{skill-id}-{task}.md`

## Claude Enhancement
When running on Claude Code, call subagent `{subagent-name}` for deeper analysis.
```

### 4.3 平台检测与安装逻辑 (tad.sh) - 增强版

```bash
#!/bin/bash
set -euo pipefail  # 严格错误处理

# ============================================
# Phase 1: Environment Validation
# ============================================
validate_environment() {
  log_info "Validating environment..."

  # Check bash version
  if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
    log_warn "Bash 4+ recommended, current: $BASH_VERSION"
  fi

  # Check required tools
  for cmd in grep sed; do
    if ! command -v "$cmd" &> /dev/null; then
      log_error "Required command not found: $cmd"
      exit 1
    fi
  done
}

# ============================================
# Phase 2: Backup Existing Config
# ============================================
backup_existing() {
  local backup_dir=".tad.backup.$(date +%Y%m%d_%H%M%S)"

  if [ -d ".tad" ]; then
    log_info "Backing up existing .tad/ to $backup_dir"
    cp -r .tad "$backup_dir"
    BACKUP_PATH="$backup_dir"
  fi

  # Backup platform-specific dirs if they exist
  for dir in .codex .gemini; do
    if [ -d "$dir" ]; then
      cp -r "$dir" "${backup_dir}/${dir}" 2>/dev/null || true
    fi
  done
}

# ============================================
# Phase 3: Platform Detection
# ============================================
detect_installed_tools() {
  local tools=""

  # Claude Code
  if command -v claude &> /dev/null || [ -d "$HOME/.claude" ]; then
    tools="$tools claude"
    log_info "Detected: Claude Code"
  fi

  # Codex CLI
  if command -v codex &> /dev/null || [ -d "$HOME/.codex" ]; then
    tools="$tools codex"
    log_info "Detected: Codex CLI"
  fi

  # Gemini CLI
  if command -v gemini &> /dev/null || [ -d "$HOME/.gemini" ]; then
    tools="$tools gemini"
    log_info "Detected: Gemini CLI"
  fi

  if [ -z "$tools" ]; then
    log_warn "No AI CLI tools detected. Installing Claude Code configs only."
    tools="claude"
  fi

  echo "$tools"
}

# ============================================
# Phase 4: Generate Configs with Validation
# ============================================
generate_platform_configs() {
  local tools="$1"

  for tool in $tools; do
    log_info "Generating config for: $tool"

    case $tool in
      claude)
        # 保持现有逻辑不变
        generate_claude_config
        ;;
      codex)
        generate_codex_config || {
          log_error "Failed to generate Codex config"
          return 1
        }
        generate_agents_md
        convert_commands_to_codex
        validate_codex_config  # NEW: 验证生成的配置
        ;;
      gemini)
        generate_gemini_config || {
          log_error "Failed to generate Gemini config"
          return 1
        }
        generate_gemini_md
        convert_commands_to_gemini
        validate_gemini_config  # NEW: 验证生成的配置
        ;;
    esac
  done
}

# ============================================
# Phase 5: Validation
# ============================================
validate_generated_configs() {
  log_info "Validating generated configurations..."

  local errors=0

  # Check required files exist
  for file in ".tad/config.yaml" ".tad/version.txt"; do
    if [ ! -f "$file" ]; then
      log_error "Missing required file: $file"
      ((errors++))
    fi
  done

  # Check skills directory
  if [ ! -d ".tad/skills" ]; then
    log_error "Missing skills directory"
    ((errors++))
  fi

  if [ $errors -gt 0 ]; then
    return 1
  fi

  log_success "All configurations validated"
}

# ============================================
# Phase 6: Rollback on Failure
# ============================================
rollback_on_failure() {
  log_error "Installation failed. Rolling back..."

  if [ -n "${BACKUP_PATH:-}" ] && [ -d "$BACKUP_PATH" ]; then
    rm -rf .tad
    mv "$BACKUP_PATH" .tad
    log_info "Restored from backup: $BACKUP_PATH"
  fi

  # Clean up generated files
  for file in AGENTS.md GEMINI.md; do
    [ -f "$file" ] && rm -f "$file"
  done

  for dir in .codex .gemini; do
    [ -d "$dir" ] && rm -rf "$dir"
  done

  log_error "Rollback complete. Please check logs."
  exit 1
}

# Set trap for automatic rollback
trap 'rollback_on_failure' ERR

# ============================================
# Main Installation Flow
# ============================================
main() {
  log_info "TAD v2.1 Installation Starting..."

  validate_environment
  backup_existing

  local tools=$(detect_installed_tools)

  # Install core TAD (always)
  install_tad_core

  # Generate platform-specific configs
  generate_platform_configs "$tools"

  # Validate everything
  validate_generated_configs

  log_success "TAD v2.1 installed successfully!"
  log_info "Detected platforms: $tools"
}
```

### 4.4 适配器系统

#### 4.4.1 适配器接口契约 (NEW)

```yaml
# .tad/adapters/adapter-schema.yaml

adapter_interface:
  version: "1.0"

  required_properties:
    - name              # 平台显示名称
    - id                # 唯一标识符
    - skill_execution   # 技能执行策略
    - config_dir        # 配置目录
    - command_format    # 命令格式
    - project_instructions  # 项目指令文件名

  required_methods:
    detect_installation:
      description: "检测平台是否已安装"
      input: null
      output: boolean

    generate_config:
      description: "生成平台配置文件"
      input: "source_dir: string"
      output: "files: string[]"

    convert_command:
      description: "转换命令文件格式"
      input: "source_file: string, target_format: string"
      output: "content: string"

    execute_skill:
      description: "执行技能检查"
      input: "skill_id: string, context: object"
      output: "result: {passed: bool, issues: array, evidence_path: string}"

  skill_execution_modes:
    subagent:
      description: "使用平台原生 subagent"
      platforms: ["claude"]

    self-check:
      description: "读取 SKILL.md 自行执行"
      platforms: ["codex", "gemini"]

    hybrid:
      description: "部分 subagent + 部分 self-check"
      platforms: []  # 未来扩展
```

#### 4.4.2 平台定义

```yaml
# .tad/adapters/platform-codes.yaml

platforms:
  claude-code:
    skill_execution: subagent
    config_dir: .claude
    command_format: markdown
    project_instructions: CLAUDE.md

  codex-cli:
    skill_execution: self-check
    config_dir: .codex
    command_format: markdown
    command_prefix: "tad_"
    project_instructions: AGENTS.md

  gemini-cli:
    skill_execution: self-check
    config_dir: .gemini
    command_format: toml
    project_instructions: GEMINI.md

skill_execution_rules:
  subagent:
    description: "使用 Claude Code 原生 subagent"
    flow: "调用 Task tool → subagent 执行 → 返回结果"

  self-check:
    description: "读取 SKILL.md 自行执行检查"
    flow: "读取 SKILL.md → 按 checklist 执行 → 生成证据文件"
```

### 4.5 命令转换示例

**源文件**: `.claude/commands/tad-gate.md`

**转换为 Codex** (`.codex/prompts/tad_gate.md`):
```markdown
# TAD Gate Command

Execute quality gate verification.

## Usage
/tad_gate [gate_number]

## Gates
- Gate 1: Requirements clarity
- Gate 2: Design completeness
- Gate 3: Implementation quality
- Gate 4: Acceptance

## Execution
1. Read .tad/skills/{relevant-skill}/SKILL.md
2. Execute checklist items
3. Generate evidence file
4. Report pass/fail status
```

**转换为 Gemini** (`.gemini/commands/tad-gate.toml`):
```toml
description = "Execute TAD quality gate verification"

prompt = """
Execute TAD quality gate {{args}}.

Read the skill definition:
@{.tad/skills/code-review/SKILL.md}

Execute the checklist and generate evidence file at:
.tad/evidence/reviews/

Report pass/fail status with details.
"""
```

---

## 5. Implementation Tasks

### Phase 0: 研究验证 (BLOCKING)

> **重要**: 此 Phase 必须在其他 Phase 之前完成

| Task | Description | Acceptance |
|------|-------------|------------|
| 0.1 | 验证 Codex CLI 配置格式 | 确认 `.codex/prompts/*.md` 格式正确 |
| 0.2 | 验证 Gemini CLI 配置格式 | 确认 `.gemini/commands/*.toml` 格式正确 |
| 0.3 | 测试 Codex CLI 命令执行 | 基本命令可执行 |
| 0.4 | 测试 Gemini CLI 命令执行 | 基本命令可执行 |
| 0.5 | 记录官方文档链接 | 添加到本 Handoff |

**验证方法**:
```bash
# Codex CLI 验证
mkdir -p .codex/prompts
echo "Test prompt for TAD" > .codex/prompts/test.md
codex /test  # 应该执行

# Gemini CLI 验证
mkdir -p .gemini/commands
cat > .gemini/commands/test.toml << 'EOF'
description = "Test command"
prompt = "Say hello"
EOF
gemini /test  # 应该执行
```

---

### Phase 1: 技能文件系统 (P0)

| Task | Description | Files |
|------|-------------|-------|
| 1.1 | 创建 skills 目录结构 | `.tad/skills/` |
| 1.2 | 编写 testing SKILL.md | `.tad/skills/testing/SKILL.md` |
| 1.3 | 编写 code-review SKILL.md | `.tad/skills/code-review/SKILL.md` |
| 1.4 | 编写 security-audit SKILL.md | `.tad/skills/security-audit/SKILL.md` |
| 1.5 | 编写 performance SKILL.md | `.tad/skills/performance/SKILL.md` |
| 1.6 | 编写 ux-review SKILL.md | `.tad/skills/ux-review/SKILL.md` |
| 1.7 | 编写 architecture SKILL.md | `.tad/skills/architecture/SKILL.md` |
| 1.8 | 编写 api-design SKILL.md | `.tad/skills/api-design/SKILL.md` |
| 1.9 | 编写 debugging SKILL.md | `.tad/skills/debugging/SKILL.md` |

### Phase 2: 适配器系统 (P0)

| Task | Description | Files |
|------|-------------|-------|
| 2.1 | 创建 adapters 目录结构 | `.tad/adapters/` |
| 2.2 | 编写 platform-codes.yaml | `.tad/adapters/platform-codes.yaml` |
| 2.3 | 编写 Claude adapter | `.tad/adapters/claude/adapter.yaml` |
| 2.4 | 编写 Codex adapter | `.tad/adapters/codex/adapter.yaml` |
| 2.5 | 编写 Gemini adapter | `.tad/adapters/gemini/adapter.yaml` |

### Phase 3: 安装脚本增强 (P0)

| Task | Description | Files |
|------|-------------|-------|
| 3.1 | 添加平台检测函数 | `tad.sh` |
| 3.2 | 添加 Codex 配置生成 | `tad.sh` |
| 3.3 | 添加 Gemini 配置生成 | `tad.sh` |
| 3.4 | 添加命令转换函数 | `tad.sh` |

### Phase 4: 项目指令转换 (P1)

| Task | Description | Files |
|------|-------------|-------|
| 4.1 | 创建 AGENTS.md 模板 | `.tad/templates/AGENTS.md.template` |
| 4.2 | 创建 GEMINI.md 模板 | `.tad/templates/GEMINI.md.template` |
| 4.3 | 实现 CLAUDE→AGENTS 转换 | `tad.sh` |
| 4.4 | 实现 CLAUDE→GEMINI 转换 | `tad.sh` |

### Phase 5: 命令转换 (P1)

| Task | Description | Files |
|------|-------------|-------|
| 5.1 | 创建 to-codex 转换模板 | `.tad/templates/command-converters/to-codex.template` |
| 5.2 | 创建 to-gemini 转换模板 | `.tad/templates/command-converters/to-gemini.template` |
| 5.3 | 转换 tad-alex 命令 | `.codex/prompts/`, `.gemini/commands/` |
| 5.4 | 转换 tad-blake 命令 | `.codex/prompts/`, `.gemini/commands/` |
| 5.5 | 转换 tad-gate 命令 | `.codex/prompts/`, `.gemini/commands/` |
| 5.6 | 转换 tad-init 命令 | `.codex/prompts/`, `.gemini/commands/` |

### Phase 6: 配置更新 (P1)

| Task | Description | Files |
|------|-------------|-------|
| 6.1 | 更新 config.yaml 添加 multi_platform | `.tad/config.yaml` |
| 6.2 | 更新 version.txt 到 2.1 | `.tad/version.txt` |
| 6.3 | 更新 README.md | `README.md` |
| 6.4 | 更新 INSTALLATION_GUIDE.md | `INSTALLATION_GUIDE.md` |

---

## 6. Acceptance Criteria

### AC-1: 技能系统
- [ ] 8 个 SKILL.md 文件存在且格式正确
- [ ] 每个技能包含 checklist、pass criteria、evidence output
- [ ] 技能可被 Blake 在 Gate 3 中调用

### AC-2: 多平台安装
- [ ] `tad.sh` 能检测已安装的 CLI 工具
- [ ] Codex 安装生成 `.codex/` 和 `AGENTS.md`
- [ ] Gemini 安装生成 `.gemini/` 和 `GEMINI.md`

### AC-3: 向后兼容
- [ ] 现有 Claude Code 项目升级后无任何变化
- [ ] `.claude/` 目录结构保持不变
- [ ] subagent 调用逻辑保持不变

### AC-4: 命令可用
- [ ] `/alex`, `/blake`, `/gate`, `/init` 在三个平台都可用
- [ ] 命令功能等价（虽然实现方式不同）

---

## 7. Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Codex/Gemini 无法正确理解 SKILL.md | 质量下降 | Medium | 详细的 checklist、示例、Phase 0 验证 |
| 命令转换丢失功能 | 功能不完整 | Low | 完整性检查清单 |
| 向后兼容破坏 | 用户体验差 | Low | 严格测试现有流程、备份机制 |
| 平台 API 变更 | 配置失效 | Low | 版本锁定、适配器抽象层 |
| 安装脚本失败 | 用户体验差 | Medium | 自动回滚、详细错误日志 |

### 7.1 回滚策略 (NEW)

```yaml
rollback_strategy:
  before_install:
    - 备份 .tad/ 目录
    - 备份 .codex/, .gemini/ 目录（如存在）
    - 备份 CLAUDE.md, AGENTS.md, GEMINI.md

  on_failure:
    - 自动触发回滚（trap ERR）
    - 恢复所有备份文件
    - 清理部分生成的文件
    - 输出详细错误日志

  manual_rollback:
    command: "./tad.sh rollback"
    action: "恢复最近一次备份"
```

---

## 8. Testing Strategy

### 8.1 单元测试
- 技能文件格式验证
- 命令转换正确性

### 8.2 集成测试
- Claude Code: 完整 Gate 3/4 流程
- Codex CLI: 基本命令执行
- Gemini CLI: 基本命令执行

### 8.3 回归测试
- 现有 TAD v2.0 所有功能

---

## 9. Dependencies

- 无外部依赖
- 基于现有 TAD v2.0 架构

---

## 10. Notes for Blake

1. **先完成 Phase 1-2**（技能和适配器），这是核心
2. **Phase 3 谨慎修改 tad.sh**，确保不破坏现有逻辑
3. **测试优先**：每个 phase 完成后都要测试
4. **证据文件**：所有技能执行都要生成证据文件到 `.tad/evidence/`

---

## Appendix A: P0 技能与 Claude Subagent 对应

| Skill | Claude Subagent | Gate |
|-------|-----------------|------|
| testing | test-runner | Gate 3 |
| code-review | code-reviewer | Gate 2, 3 |
| security-audit | security-auditor | Gate 3, 4 |
| performance | performance-optimizer | Gate 3, 4 |
| ux-review | ux-expert-reviewer | Gate 2, 4 |
| architecture | backend-architect | Gate 2 |
| api-design | api-designer | Gate 2 |
| debugging | debugging-assistant | Gate 3 |

---

## Appendix B: Expert Review Summary

### code-reviewer (CONDITIONAL PASS)
- **P0 Resolved**: 技能目录关系、SKILL.md 格式、平台配置验证
- **P1 Addressed**: Subagent 映射、向后兼容证据、TOML 转换规范
- **Positive**: 清晰的 Phase 划分、适配器模式、证据系统

### backend-architect (7.5/10 CONDITIONAL)
- **P0 Resolved**: 适配器接口契约、安装脚本健壮性
- **P1 Addressed**: 技能执行上下文、配置验证
- **Positive**: 架构模式合理、扩展性好、向后兼容正确

---

**Handoff Status**: Ready for Implementation
**Expert Review**: ✅ PASS (with amendments)
**Gate 2**: Pending Execution
**Next Step**: Gate 2 → Blake Implementation
