---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: [".tad/cross-model/handlers"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Bilibili Handler Fix + Quality Probe Tuning

**From:** Alex | **To:** Blake | **Date:** 2026-05-09
**Type:** Standard (research + implementation)
**Priority:** P1

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Two-phase: research spike then fix |
| Components Specified | ✅ | 3 files to modify |
| Functions Verified | ✅ | Tested: B站 API returns 62002; yt-dlp returns empty metadata; AI subs not extractable |
| Data Flow Mapped | ✅ | bilibili URL → yt-dlp (CC subs) → B站 API (metadata) → Jina fallback → source add |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building

Fix the Bilibili handler to actually extract useful content from B站 videos, and tune the quality verification probe to better catch "false success" imports.

### 1.2 Why We're Building It

E2E testing (2026-05-09) revealed Bilibili handler produces near-zero value: yt-dlp can't extract AI subtitles (player-side only), B站 API is geo-restricted (error 62002), and title/description extraction returns empty. A 224-byte stub with just "No subtitles available" is useless for research.

### 1.3 Intent Statement

**真正要解决的问题**: 让 B 站内容可以被提取并导入 NotebookLM，即使没有字幕也要拿到有用的 metadata（标题、描述、标签）。同时修复质量探针对"假成功"判断过于宽容的问题。

**不是要做的**:
- ❌ 不做本地 Whisper 转录（CPU 太重）
- ❌ 不做 B 站登录 cookie 自动获取（隐私/安全风险）
- ❌ 不做全面的反地域限制方案

---

## 📚 Project Knowledge (Blake 必读)

**⚠️ Blake 必须注意的历史教训**:

1. **NotebookLM Source Import: False Success** (architecture.md, 2026-05-09)
   - 7/14 sources returned `ready` but had useless content. Always verify post-import.

2. **Hook Shell Portability: No grep -P on macOS** (architecture.md)
   - BSD sed/grep limitations apply to all handler scripts

---

## 2. Background — E2E Testing Findings

### Bilibili Specific Findings
- **AI subtitles**: B站大多数视频使用播放器端 AI 字幕，yt-dlp 无法提取。只有 UP 主手动上传的 CC 字幕可提取（极少数视频）。
- **B站 API**: `api.bilibili.com/x/web-interface/view?bvid=BVxxx` 从非中国 IP 返回 `{"code":62002,"message":"稿件不可见"}`
- **yt-dlp metadata**: `yt-dlp --print title` 对 B 站视频也返回空（可能需要 cookies）
- **danmaku**: 弹幕以 XML 格式可提取，但内容是用户短评，不是叙述性文本
- **Playlist hang**: 播放列表 URL 无 `--no-playlist` 导致 yt-dlp 尝试处理所有视频

### Quality Probe Finding
- AWS docs (已知假成功) 被质量探针判定为 `QUALITY:LOW` 而非 `QUALITY:NONE`
- `LOW` 保留源并警告，不触发 Jina 兜底 — 对已知垃圾源太宽容

---

## 3. Requirements

### Phase 1: Bilibili Handler Fix

- **FR1**: 添加 `--no-playlist` 到所有 yt-dlp 调用（**放在 `--` 之前**）[CR-P0-2]
- **FR2**: 重排 fallback 顺序：CC subs → B站 API（快）→ yt-dlp metadata（慢）→ Jina [BA-P0-1]
- **FR3**: B 站 API 失败时（62002 地域限制），使用 Jina Reader 作为最终 fallback
- **FR4**: 在 .md 输出中包含视频 metadata（标题、描述、UP 主、播放量、标签）即使没有字幕
- **FR5**: 所有 API/yt-dlp 提取的文本用 `printf '%s\n'` 不用 `echo`（防 shell 注入）[CR-P0-1]
- **FR6**: `jq` + `curl` 加入 preflight 依赖检查 [CR-P0-4]
- **FR7**: jina-handler.sh 调用用 `$SCRIPT_DIR/jina-handler.sh` 不用裸路径 [CR-P0-3]
- **FR8**: 合并 yt-dlp 调用（3 次 → 1 次：`--print title --print description --write-sub`）[CR-P2-5]
- **FR9**: `method:` frontmatter 动态反映实际提取方式 [BA-P1-3, CR-P1-5]
- **FR10**: 可选 `--cookies-from-browser` 支持（环境变量 `TAD_BILIBILI_BROWSER` 控制）[BA-P0-3]
- **FR11**: Phase B empty-metadata guard — title+description 都为空时 fall through [CR-P1-1]

### Phase 2: Quality Probe Tuning

- **FR12**: 在 QUALITY probe 之前加 content-length 预检（< 500 chars → 直接 NONE）[BA: structural > prompt]
- **FR13**: 调整 probe prompt — 增加 LOW vs NONE 判断标准："QUALITY:NONE if content consists PRIMARILY of navigation links, TOC entries, cookie banners, or site chrome with fewer than 3 substantive paragraphs"
- **FR14**: 创建 regression test fixture（3 known URLs + expected QUALITY labels）[BA-P1-4]

---

## 4. Technical Design

### 4.1 Bilibili Handler Revised Flow [BA-P0-1 reordered + CR fixes]

```
bilibili-handler.sh video <url> <output_dir>
  │
  ├─ Preflight: yt-dlp + jq + curl (all required)            [CR-P0-4]
  ├─ SCRIPT_DIR derivation for jina-handler.sh path           [CR-P0-3]
  ├─ b23.tv redirect resolution (if applicable)               [BA-P2-1]
  │
  ├─ Phase A: yt-dlp CC 字幕提取 (--write-sub --no-playlist, 去掉 --write-auto-sub)
  │   → --no-playlist BEFORE -- separator                     [CR-P0-2]
  │   → 合并为单次调用: --print title --print description --write-sub [CR-P2-5]
  │   → 成功(有字幕) → method: yt-dlp-cc-subtitles → exit 0
  │
  ├─ Phase A.5 (可选): --cookies-from-browser
  │   → 仅当 TAD_BILIBILI_BROWSER 环境变量设置时触发          [BA-P0-3]
  │   → yt-dlp --cookies-from-browser "$TAD_BILIBILI_BROWSER" --write-sub --no-playlist
  │   → 成功 → method: yt-dlp-cookies-subtitles → exit 0
  │
  ├─ Phase B: B 站 API metadata (快: ~200ms)                  [BA-P0-1 reorder]
  │   curl -s --connect-timeout 5 --max-time 10 \
  │     "https://api.bilibili.com/x/web-interface/view?bvid=${bv_id}"
  │   → Parse via jq (NOT grep/sed)                           [CR-P0-1]
  │   → 所有字段用 printf '%s\n' 写入 .md                     [CR-P0-1]
  │   → code==0 AND title 非空 → method: bilibili-api → exit 0
  │   → code!=0 (62002) → Phase C
  │
  ├─ Phase C: yt-dlp metadata fallback (慢: ~5-10s)
  │   → 仅当 Phase A 未取到 title 时执行
  │   → title+desc 都为空 → fall through (不 exit 0)          [CR-P1-1]
  │   → title 或 desc 非空 → method: yt-dlp-metadata → exit 0
  │
  ├─ Phase D: Jina Reader fallback                            [FR3]
  │   bash "$SCRIPT_DIR/jina-handler.sh" "$url" "$output_dir" [CR-P0-3]
  │   → 成功 → method: jina-reader-fallback → exit 0
  │   → 失败 → exit 1
  │
  └─ 每个 Phase 的 method: 字段不同                           [BA-P1-3]
```

### 4.2 Quality Probe Tuning

**Primary fix (structural — FR12)**: 在 LLM probe 前加 content-length 预检
```
verify_import_quality():
  ...existing 30s wait...
  source list --json → find newest source
  
  # NEW: structural pre-check (before LLM probe)
  # If source content < 500 chars → QUALITY:NONE directly (no LLM call needed)
  # Implementation: check if source list --json exposes content_length field.
  # If not available: skip this pre-check, fall through to LLM probe.
  
  # Existing LLM probe (with improved prompt — FR13):
  "QUALITY:NONE if content consists PRIMARILY of:
   - navigation menus, sidebar links, or footer elements
   - table-of-contents listings without article body text
   - cookie/privacy banners or login/paywall prompts
   - fewer than 3 substantive paragraphs of actual article/paper content
   QUALITY:LOW if there ARE substantive paragraphs but heavily mixed with navigation noise
   QUALITY:HIGH if content is predominantly substantive text"
```

**Regression fixture (FR14)**:
Blake creates `.tad/evidence/acceptance-tests/quality-probe-regression.sh` with 3 test cases:
- AWS docs URL → expected QUALITY:NONE (currently fails as LOW)
- arXiv PDF → expected QUALITY:HIGH (baseline sanity)
- Preprocessed Substack .md → expected QUALITY:HIGH

---

## 5. Files to Modify

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/cross-model/handlers/bilibili-handler.sh` | MODIFY | --no-playlist + B站 API fallback + Jina fallback |
| 2 | `.claude/skills/research-notebook/SKILL.md` | MODIFY | Quality probe prompt tuning (verify_import_quality section) |
| 3 | `.tad/cross-model/source-preprocessor.sh` | MODIFY (minor) | Bilibili dispatch 调用可能需要传 jina-handler 路径 |

**Grounded Against**:
- .tad/cross-model/handlers/bilibili-handler.sh (read 2026-05-09, 119 lines)
- .claude/skills/research-notebook/SKILL.md line 248-257 (QUALITY probe)

---

## 6. Acceptance Criteria

| # | AC | Verification |
|---|-----|-------------|
| AC1 | `--no-playlist` in bilibili-handler.sh | `grep -cE '\-\-no-playlist' handlers/bilibili-handler.sh` ≥ 1 |
| AC2 | B站 API fallback implemented | `grep -c 'api.bilibili.com' handlers/bilibili-handler.sh` ≥ 1 |
| AC3 | Jina fallback via SCRIPT_DIR | `grep -c 'SCRIPT_DIR.*jina-handler' handlers/bilibili-handler.sh` ≥ 1 |
| AC4 | jq + curl in preflight | `grep -cE 'command -v (jq\|curl)' handlers/bilibili-handler.sh` ≥ 2 |
| AC5a | Each phase emits correct stderr on failure | Phase B/C/D each print diagnostic when skipping |
| AC5b | Jina fallback produces ≥500 bytes for B站 URL | Functional test (from non-China IP) |
| AC5c | `method:` field reflects actual extraction phase | `grep -c 'method:.*yt-dlp-cc\|bilibili-api\|yt-dlp-metadata\|jina-reader' handlers/bilibili-handler.sh` ≥ 3 |
| AC6 | printf not echo for user content | `grep -c "printf.*%s" handlers/bilibili-handler.sh` ≥ 1 |
| AC7 | Quality probe content-length pre-check | `grep -c '500' .claude/skills/research-notebook/SKILL.md` in verify section |
| AC8 | Quality regression fixture exists | `test -f .tad/evidence/acceptance-tests/quality-probe-regression.sh` |
| AC9 | Phase B empty-metadata guard | title+desc empty → fall through, not exit 0 |

## Expert Review Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P0-1: Shell injection via API content | §4.1 printf + jq mandatory | Resolved |
| code-reviewer | P0-2: --no-playlist before -- separator | §4.1 Phase A explicit | Resolved |
| code-reviewer | P0-3: jina-handler path resolution | §4.1 SCRIPT_DIR + FR7 | Resolved |
| code-reviewer | P0-4: jq/curl dependency missing | §3 FR6 + §4.1 Preflight | Resolved |
| code-reviewer | P1-1: Empty metadata guard | §4.1 Phase C guard + FR11 | Resolved |
| code-reviewer | P1-5: method field per phase | §4.1 + FR9 | Resolved |
| code-reviewer | P1-6: 30s timeout too short | Deferred (Blake: internal phase timeouts) | Open |
| code-reviewer | P2-5: Consolidate yt-dlp calls | §4.1 Phase A + FR8 | Resolved |
| backend-architect | P0-1: Phase ordering wrong | §4.1 reordered: A→B(API)→C(yt-dlp)→D | Resolved |
| backend-architect | P0-2: AC5 untestable | AC5 decomposed to AC5a/5b/5c | Resolved |
| backend-architect | P0-3: cookies-from-browser | §4.1 Phase A.5 opt-in (TAD_BILIBILI_BROWSER) | Resolved |
| backend-architect | P1-3: method field per phase | §4.1 + FR9 | Resolved |
| backend-architect | P1-4: Quality regression test | §4.2 FR14 + AC8 | Resolved |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/bilibili-and-quality-fixes/code-reviewer.md
completion:
  - .tad/active/handoffs/COMPLETION-20260509-bilibili-and-quality-fixes.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md
```
