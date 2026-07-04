# HANDOFF: Release 全量版本扫描 Gate

**Date:** 2026-07-04
**Priority:** P1
**Scope:** small (1 file modify + 1 protocol update + fixtures)
**Express:** yes
**Epic:** none (standalone improvement)
**Supersedes:** IDEA-20260703-release-full-version-sweep.md

---

## §1 Problem Statement

### §1.1 Background
`release-verify.sh version` 只检查相邻版本 ($OLD → $NEW) 的残留。如果一个文件在几个版本前就漏掉了（如 PROJECT_CONTEXT.md 卡在 2.27.0），后续所有 release 都检测不到。

v2.33.0 发布前发现 6 个文件落后 3-22 个版本。根因：**一旦漏掉一次，永远漏。**

### §1.2 Solution Direction
给 `release-verify.sh` 新增 `version-sweep` 模式：扫描全仓库所有类似版本号的字符串，排除已知历史引用，报出任何不等于当前版本的活引用。

### §1.3 Intent Statement
让 release 流程能抓到所有版本漂移，不管是漏了一个版本还是漏了二十个版本。同时检查 README "What's New" 和 SKILL.md 版本注释是否跟上。

---

## §2 Scope

### 修改文件
1. `.tad/hooks/lib/release-verify.sh` — 新增 `version-sweep` mode (~80-120 lines)
2. `.claude/skills/alex/references/publish-protocol.md` — step3c 后新增 step3c2 调用 version-sweep
3. `.agents/skills/alex/references/publish-protocol.md` — 同步
4. `.claude/skills/release-runbook/SKILL.md` — Phase 2 新增 version-sweep 说明
5. `.agents/skills/release-runbook/SKILL.md` — 同步

### 不修改
- 不修改现有 `version` mode 的行为（保持向后兼容）
- 不自动修复任何文件（只检测并报告）
- 不触碰 archive/、evidence/、CHANGELOG.md 里的历史版本引用

---

## §3 Technical Design

### 双层架构（Expert Review P0 修复后）

Expert review (code-reviewer + backend-architect) 发现裸 semver regex 会产生 ~1,500 假阳性。
redesign 为双层：Primary (must-version registry, blocking) + Secondary (narrow sweep, advisory).

---

### Layer 1: Must-Version Registry (PRIMARY — ALWAYS blocking)

**概念**：维护一份 8-12 行的"必须包含当前版本"的文件+模式列表。正向验证（assert presence），不是搜全仓库。

**Registry 定义**（hardcoded in script, ~10 entries）：
```bash
MUST_VERSION_PATTERNS=(
  ".tad/version.txt|^${VER}$"
  ".tad/config.yaml|version: ${VER}"
  ".tad/config.yaml|# TAD Configuration v${VER}"
  "README.md|Version ${VER}"
  "INSTALLATION_GUIDE.md|Version ${VER}"
  ".claude/skills/tad-help/SKILL.md|Version: v${VER}"
  ".claude/skills/alex/SKILL.md|<!-- TAD v${VER} Framework -->"
  ".claude/skills/blake/SKILL.md|<!-- TAD v${VER} Framework -->"
  "tad.sh|TARGET_VERSION=\"${VER}\""
  "package.json|\"version\": \"${VER}\""
  "PROJECT_CONTEXT.md|Version.*: ${VER}"
  "docs/MULTI-PLATFORM.md|Version.*: ${VER}"
)
```

**算法**：
```
for each entry in MUST_VERSION_PATTERNS:
  file = entry.split('|')[0]
  pattern = entry.split('|')[1]
  if file doesn't exist → WARN (file missing)
  elif ! grep -q "$pattern" "$file" → FAIL (stale version in $file)
  else → PASS
```

**Exit codes**：
- exit 0 = all patterns found
- exit 1 = ≥1 pattern missing (each NAMED with file + expected pattern)
- exit 2 = usage/wiring error

**Blocking**：ALWAYS blocking regardless of release type (patch/minor/major)。
理由：这些是 identity markers — 任何 release 都不能让它们 stale。

---

### Layer 2: Narrow Drift Sweep (SECONDARY — advisory only, never blocking)

**概念**：搜索可能遗漏的 TAD 版本引用，但只作为 advisory 报告。

**算法**：
```
1. git ls-files | grep -v binary 排除二进制
2. grep -InE '2\.[0-9]+\.[0-9]+' (限定 major version = 2，排除第三方)
3. 排除规则：
   a. 路径 archive/|evidence/|migrations/|node_modules/|package-lock.json
   b. 路径 skills/*/references/ (pack 内容引用第三方版本)
   c. 路径 _archived/
   d. 路径 .tad/active/ideas/ (idea 里的历史引用)
   e. CHANGELOG.md 的 markdown 表格行
   f. 行匹配 added_in:|deprecated_in:|since_version:
   g. 匹配结果 == $expected_version → 排除
   h. IP 地址过滤：匹配前后有数字/点的排除 (127.0.0 等)
4. 剩余的输出为 ADVISORY（永不 blocking）
```

**Output 格式（分层报告）：**
```
VERSION-SWEEP REPORT:
  ── Layer 1: Must-Version Registry ──
  ✅ .tad/version.txt ............... 2.33.0
  ✅ .tad/config.yaml ............... version: 2.33.0
  ❌ PROJECT_CONTEXT.md ............. MISSING "Version.*: 2.33.0"  [BLOCKING]
  ...
  Layer 1 verdict: FAIL (1 stale)

  ── Layer 2: Drift Sweep (advisory) ──
  ⚠️  .tad/sync-registry.yaml:5: min_version: "2.30.0"
  ⚠️  docs/CODEX-USER-GUIDE.md:12: "compatible with TAD 2.31.0+"
  Layer 2 hits: 2 (advisory only, not blocking)
```

---

### Invocation

```bash
release-verify.sh version-sweep <repo_root> <expected_version>
```

**Publish protocol 接入位置**：step3c 之后，step3d 之前（新 step3c2）。
Layer 1 FAIL → exit 1 → publish BLOCKED。
Layer 2 hits → printed as advisory → publish proceeds。

---

## §4 Acceptance Criteria (§9)

### AC1: Layer 1 检测 registry 中的 stale 版本
验证：临时修改一个 tracked 文件的版本号为旧值（如 `sed -i '' 's/2.33.0/2.30.0/' PROJECT_CONTEXT.md`），运行 `version-sweep`，确认 Layer 1 报 FAIL 并 exit 1。测试后恢复。

### AC2: Layer 1 全 PASS 时 exit 0
验证：所有 registry 文件版本正确时，exit 0。

### AC3: Layer 2 排除规则正确
验证：archive/、evidence/、migrations/、skills/*/references/、CHANGELOG 表格行中的旧 TAD 版本号不被 Layer 2 报出。

### AC4: Layer 2 只作为 advisory，不影响 exit code
验证：即使 Layer 2 有 hits，只要 Layer 1 全 PASS，仍然 exit 0。

### AC5: Layer 2 IP 地址不误报
验证：包含 `127.0.0.1` 的文件不产生 Layer 2 hit。

### AC6: publish-protocol 接入
验证：publish-protocol.md step3c 之后有 step3c2 调用 `version-sweep`，Layer 1 FAIL = ALWAYS blocking。

### AC7: 现有 version mode 不受影响
验证：`release-verify.sh version` 的原有行为和 exit code 不变。

### AC8: parity
验证：`.claude/skills` 和 `.agents/skills` 的修改文件保持同步。

### AC9: usage() 和 CONTRACT 头注释更新
验证：`release-verify.sh` 的 usage 函数和头部 CONTRACT 注释包含 version-sweep 的说明。

---

## §5 Constraints

- 新 mode 必须遵循现有 exit code contract (0/1/2)
- 不能 break 现有的 `version`/`parity`/`structural`/`migration`/`freshness` modes
- grep 必须 scope 到 git ls-files（同现有 version mode）
- 排除规则必须是 deny-list 思路（新文件默认被检查，只排除明确的历史类路径）

---

## §6 Files to Read Before Implementation

- `.tad/hooks/lib/release-verify.sh` (816 lines — 理解现有结构)
- `.claude/skills/alex/references/publish-protocol.md` (step3c 位置)
- `.claude/skills/release-runbook/SKILL.md` (Phase 2 位置)

---

## §7 Estimation

- **Effort:** ~2-3 hours Blake time
- **Risk:** Low (新增 mode，不改现有逻辑)
- **Testing:** fixture-based（创建测试文件验证检测 + 排除）

---

## §8 Metadata

### §8.4 Friction Preflight
- 无外部依赖
- 需要 git, grep, bash 4+ (已有)

### §8.5 Feedback Collection
- feedback_required: false (纯工具脚本，无 UI)

---

## §9 Acceptance Criteria Summary

| # | Criterion | Verification |
|---|-----------|-------------|
| AC1 | Layer 1 检测 stale 版本 | 手动改旧版本 → FAIL + exit 1 |
| AC2 | Layer 1 全 PASS → exit 0 | 正常状态运行 → exit 0 |
| AC3 | Layer 2 排除规则正确 | archive/evidence/references 不报 |
| AC4 | Layer 2 不影响 exit code | Layer 2 有 hits + Layer 1 PASS → exit 0 |
| AC5 | IP 地址不误报 | 127.0.0.1 不触发 |
| AC6 | publish-protocol 接入 | step3c2 存在，Layer 1 FAIL = ALWAYS blocking |
| AC7 | 现有 mode 不受影响 | version mode 原行为不变 |
| AC8 | parity 同步 | .claude == .agents |
| AC9 | usage + CONTRACT 更新 | 头注释 + usage() 包含 version-sweep |

---

## §10 Expert Review Disposition

**Reviewers:** code-reviewer + backend-architect (2/2 completed)

### Review Results

| Reviewer | P0 | P1 | P2 | Status |
|----------|----|----|----|----|
| code-reviewer | 2 | 5 | 4 | ✅ P0 resolved |
| backend-architect | 1 | 2 | 3 | ✅ P0 resolved |

### P0 Resolutions (blocking — all fixed)
1. **False-positive storm** (both): 裸 semver regex 产生 ~1,500 假阳性 → **redesigned to dual-layer**: Must-Version Registry (primary, blocking) + narrow sweep (advisory only)
2. **No extraction logic** (code-reviewer): → Resolved by Layer 1 using positive assertion (`grep -q pattern file`) instead of regex extraction

### P1 Integrations
1. **Specific checks always blocking** (architect): → Layer 1 is ALWAYS blocking regardless of release type ✅
2. **Structured sub-verdicts** (architect): → Output format shows Layer 1 + Layer 2 separately ✅
3. **AC1 test fixture** (code-reviewer): → Fixed: uses tracked file with sed, not /tmp ✅
4. **Missing exclusions** (code-reviewer): → Added skills/*/references/, _archived/, .tad/active/ideas/ ✅
5. **IP address filtering** (code-reviewer): → Added to Layer 2 exclusions ✅

### P2 Acknowledged (Blake may address during implementation)
- CONTRACT header comment update → AC9
- Script self-exclusion → implementer discretion
- Performance (-I flag for binary skip) → implementer discretion
- version.txt sanity check before scan → nice-to-have

---

## §11 Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Blocking level | minor+ blocking, patch advisory | 与现有 version gate 行为一致 |
| 自动修复 vs 只报告 | 只报告 | 修复需要人类判断（有些版本引用可能是有意的） |
| 排除策略 | deny-list（默认检查） | 新文件自动被覆盖，不怕遗漏 |
| 独立 mode vs 合并到 version | 独立 mode | 职责不同：version 查 OLD 残留，sweep 查全量漂移 |
