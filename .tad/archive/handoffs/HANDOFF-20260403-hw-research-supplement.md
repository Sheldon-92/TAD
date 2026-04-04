# Handoff: Hardware Domain Pack — 补 Phase 1 研究 + YAML 迭代

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-007

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Problem

4 个 Hardware Domain Pack 全部跳过了 Phase 1 研究。AC1 要求"≥3 仓库 × 5 维度"，0 个满足。现有 YAML 基于 LLM 知识，不是基于真实仓库最佳实践。

**这不是可选的补充 — 这是 AC 未完成的修复。**

---

## 2. 必须完成的 4 个研究（BLOCKING — 全部做完才算完成）

### 2.1 hw-circuit-design 研究

**搜索词（必须全部执行，不能只搜一两个）**：
```
"GitHub KiCad skills PCB schematic SKILL.md"
"GitHub AI agent electronics design EDA automation"
"GitHub hardware design review checklist DRC ERC"
"GitHub ESP32 circuit design best practices"
"PCB design checklist manufacturing 2026"
```

**必须产出**：`.tad/spike-v3/domain-pack-tools/hw-circuit-design-skills-best-practices.md`

**文件内容必须包含**：
- **Search Log 表**（证明每个搜索词都执行了）：
  ```
  ## Search Log
  | Search Term | Results Found | Repos Selected |
  |------------|--------------|----------------|
  | "GitHub KiCad skills..." | 12 | repo-A, repo-B |
  ```
- ≥3 个仓库的名称 + URL + Stars（每个 pack 至少 2 个是该领域专有的，不能所有 pack 共用同一批仓库）
- 每个仓库提取 5 维度（步骤深度 / 来源清单 / 分析框架 / 质量标准 / 反模式）
- 每个维度必须有具体内容（不是"步骤较深"这种空话）
- **如果前 5 个搜索词找到 <3 个有价值的仓库**，执行这些后备搜索：
  ```
  "awesome-electronics github"
  "KiCad design rules checklist"
  "PCB review github"
  ```

**验证**：`wc -l` ≥80 行 + `grep -c 'github.com/'` ≥3 个 URL

### 2.2 hw-firmware 研究

**搜索词（全部执行）**：
```
"GitHub firmware ESP32 arduino skills SKILL.md"
"GitHub AI agent embedded development PlatformIO"
"GitHub embedded code review checklist C C++"
"GitHub ESP32 firmware best practices power management"
"embedded systems design patterns 2026"
```

**必须产出**：`.tad/spike-v3/domain-pack-tools/hw-firmware-skills-best-practices.md`（≥80 行）

### 2.3 hw-enclosure 研究

**搜索词（全部执行）**：
```
"GitHub OpenSCAD 3D design skills SKILL.md"
"GitHub AI agent mechanical design CAD enclosure"
"GitHub 3D printing design checklist DFM"
"GitHub enclosure design electronics housing"
"product enclosure design best practices tolerances 2026"
```

**必须产出**：`.tad/spike-v3/domain-pack-tools/hw-enclosure-skills-best-practices.md`（≥80 行）

### 2.4 hw-testing 研究

**搜索词（全部执行）**：
```
"GitHub hardware testing verification SKILL.md"
"GitHub electronics testing checklist QA"
"GitHub EMC compliance testing guide"
"GitHub hardware power measurement profiling"
"hardware product testing best practices 2026"
```

**必须产出**：`.tad/spike-v3/domain-pack-tools/hw-testing-skills-best-practices.md`（≥80 行）

---

## 3. 基于研究的 YAML 迭代（BLOCKING — 研究完必须改）

对每个 pack，读研究文档，对比现有 YAML：

**必须做的对比**：
```
对每个 capability：
  1. 研究里有什么分析框架是 YAML 里没有的？→ 加到 steps 的 action 里
  2. 研究里有什么质量标准是 YAML 里没有的？→ 加到 quality_criteria
  3. 研究里有什么反模式是 YAML 里没覆盖的？→ 加到 anti_patterns
  4. 研究里有什么来源清单可以加到 queries？→ 加到 search step 的 queries
```

**必须产出对比文档**（明确路径）：
```
.tad/spike-v3/domain-pack-tools/before-after-hw-circuit-design.md
.tad/spike-v3/domain-pack-tools/before-after-hw-firmware.md
.tad/spike-v3/domain-pack-tools/before-after-hw-enclosure.md
.tad/spike-v3/domain-pack-tools/before-after-hw-testing.md
```

格式：

```markdown
## hw-circuit-design 迭代记录

### 来自研究的改进
| 来源仓库 | 发现 | 改进了什么 | 改进前 | 改进后 |
|---------|------|-----------|--------|--------|
| {repo} | {finding} | {what changed} | {before} | {after} |

### 改动统计
- 新增 steps: N
- 新增 quality_criteria: N
- 新增 anti_patterns: N
- 修改 existing steps: N
```

---

## 4. AC（全部 BLOCKING — 缺一个都不算完成）

- [ ] AC1: 4 个 best-practices.md 全部存在
- [ ] AC2: 每个 ≥80 行（不是 20 行凑数的空文件）
- [ ] AC3: 每个包含 ≥3 个仓库（有 URL + Stars）
- [ ] AC4: 每个仓库有 5 维度提取（具体不笼统）
- [ ] AC5: 4 个 YAML 有基于研究的改动（git diff 可见，每个 pack ≥3 个实质改动 — 新 step/quality_criteria/anti_pattern，不算空白或注释）
- [ ] AC6: 4 个 before-after 对比文档存在
- [ ] AC7: 改动后 YAML 语法仍然正确
- [ ] AC8: 必须走 Ralph Loop + Gate 3

**验证命令（Gate 3 前全部跑，任何一个 FAIL 就不能过 Gate）**：
```bash
# 1. 文件存在 + 行数
for f in hw-circuit-design hw-firmware hw-enclosure hw-testing; do
  file=".tad/spike-v3/domain-pack-tools/${f}-skills-best-practices.md"
  if [ -f "$file" ]; then
    lines=$(wc -l < "$file")
    [ "$lines" -ge 80 ] && echo "✅ $f: $lines lines" || echo "❌ FAIL $f: only $lines lines (need ≥80)"
  else
    echo "❌ MISSING: $f"
  fi
done

# 2. 每个研究文件有 ≥3 个 GitHub URL（防编造）
for f in hw-circuit-design hw-firmware hw-enclosure hw-testing; do
  file=".tad/spike-v3/domain-pack-tools/${f}-skills-best-practices.md"
  count=$(grep -c 'github.com/' "$file" 2>/dev/null || echo "0")
  [ "$count" -ge 3 ] && echo "✅ $f: $count GitHub URLs" || echo "❌ FAIL $f: only $count URLs (need ≥3)"
done

# 3. 每个研究文件有 Search Log 表（证明搜索词全部执行）
for f in hw-circuit-design hw-firmware hw-enclosure hw-testing; do
  file=".tad/spike-v3/domain-pack-tools/${f}-skills-best-practices.md"
  grep -q "Search Log" "$file" 2>/dev/null && echo "✅ $f: has Search Log" || echo "❌ FAIL $f: missing Search Log"
done

# 4. before-after 文件存在
for f in hw-circuit-design hw-firmware hw-enclosure hw-testing; do
  file=".tad/spike-v3/domain-pack-tools/before-after-${f}.md"
  [ -f "$file" ] && echo "✅ $f: before-after exists" || echo "❌ MISSING: before-after-$f"
done

# 5. YAML 有 ≥3 个实质改动
for f in .tad/domains/hw-*.yaml; do
  hunks=$(git diff -U0 "$f" 2>/dev/null | grep -c '^@@')
  [ "$hunks" -ge 3 ] && echo "✅ $f: $hunks changes" || echo "❌ FAIL $f: only $hunks changes (need ≥3)"
done

# 6. YAML 合法
for f in .tad/domains/hw-*.yaml; do
  python3 -c "import yaml; yaml.safe_load(open('$f'))" && echo "✅ $f: OK" || echo "❌ $f: INVALID"
done
```

---

## 5. Notes

- ⚠️ **不能跳过任何 AC** — 上次 4 个 pack 全跳了研究，这次是修复
- ⚠️ **搜索词全部执行** — 不能只搜前 1-2 个就说"找不到"
- ⚠️ **如果硬件领域 SKILL.md 仓库确实少** — 搜 checklist、guide、best-practices 类仓库替代，但必须有 ≥3 个有价值的来源
- ⚠️ **≥80 行不是凑行数** — 是确保提取了足够具体的内容
- ⚠️ **4 个研究可以并行 spawn agent** — 但每个 agent 的产出必须独立验证

**Handoff Created By**: Alex
