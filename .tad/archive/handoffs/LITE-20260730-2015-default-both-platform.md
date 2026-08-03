# LITE Handoff: Default dual-platform installation and upgrade
**Date**: 2026-07-30 | **escalated_review**: yes (用户原话: "I insist you continue to follow the Lite rules.")

## 目标（2-3 句，含“为什么”）
让 TAD 在未指定 `--platform` 时默认同时安装 Claude Code 与 Codex 所需的运行入口，避免项目在使用 Codex 时只得到 `.claude/` 文件。该默认行为必须同时覆盖首次安装和后续升级：例如“全屋智能化”这类历史上只有 Claude Code 版本的项目，升级后应自动补齐 Codex 文件而不丢失现有项目数据。显式指定 `--platform claude-code`、`codex` 或 `both` 仍保留原有覆盖语义。

## 不做什么
- 不改变显式 `--platform` 参数的选择语义。
- 不迁移或删除项目自身的 `.tad/active/`、`.tad/archive/`、`.tad/evidence/`、`.tad/project-knowledge/` 数据。
- 不修改 Claude/Codex skill 的业务协议内容；本单只调整安装器默认路由、相关说明和验证。

## 文件清单（创建/修改，逐个路径）
- 修改 `tad.sh`：无 `--platform` 时将默认平台从 `claude-code` 改为 `both`，同步更新帮助/日志中的默认值说明；保持显式平台覆盖和升级路径使用同一默认值。
- 修改 `bin/tad-install.mjs`：无 `--platform` 时将 npx/Node 安装入口的默认平台从 `claude-code` 改为 `both`，同步更新帮助文本。
- 修改 `README.md`：说明默认安装/升级为双平台，并保留单平台命令示例。
- 修改 `INSTALLATION_GUIDE.md`：说明新安装与升级在未传平台参数时均安装双平台入口。

## AC
- AC1: 由独立 reviewer 在临时目录执行 `tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT; cd "$tmp"; bash "/Users/sheldonzhao/01-on progress programs/TAD/tad.sh" --yes; test -f .claude/skills/alex-lite/SKILL.md; test -f .agents/skills/alex-lite/SKILL.md; test -f AGENTS.md; test -f .codex/hooks.json`；所有命令成功，证明无 `--platform` 的全新安装同时落地两套入口。
- AC2: 由独立 reviewer 执行 `tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/.tad/active" "$tmp/.claude/skills/alex-lite"; printf '2.35.0\n' > "$tmp/.tad/version.txt"; printf 'keep-me\n' > "$tmp/.tad/active/user-sentinel"; printf 'legacy\n' > "$tmp/.claude/skills/alex-lite/SKILL.md"; cd "$tmp"; bash "/Users/sheldonzhao/01-on progress programs/TAD/tad.sh" --yes; test "$(cat .tad/active/user-sentinel)" = keep-me; test -f .agents/skills/alex-lite/SKILL.md; test -f AGENTS.md; test -f .codex/hooks.json`；所有命令成功，证明仅 Claude Code 的旧项目升级后补齐 Codex 且保留项目数据。
- AC3: 由独立 reviewer 在 TAD 仓库根目录执行 `bash "/Users/sheldonzhao/01-on progress programs/TAD/tad.sh" --help | rg -q 'claude-code, codex, both.*Default: both'`; `node "/Users/sheldonzhao/01-on progress programs/TAD/bin/tad-install.mjs" --help | rg -q 'claude-code, codex, both.*Default: both'`; `rg -q 'PLATFORM="both"' tad.sh`; `rg -q "argPlatform \|\| 'both'" bin/tad-install.mjs`；四项均成功，证明 shell 与 npx 安装入口的有效平台列表、帮助和默认路由一致。
- AC4: 由独立 reviewer 执行 `for platform in claude-code codex both; do tmp="$(mktemp -d)"; (cd "$tmp" && bash "/Users/sheldonzhao/01-on progress programs/TAD/tad.sh" --platform "$platform" --yes && case "$platform" in claude-code) test -f .claude/skills/alex-lite/SKILL.md && test ! -e .agents/skills && test ! -e AGENTS.md && test ! -e .codex;; codex) test -f .agents/skills/alex-lite/SKILL.md && test ! -e .claude/skills && test -f AGENTS.md && test -f .codex/hooks.json;; both) test -f .claude/skills/alex-lite/SKILL.md && test -f .agents/skills/alex-lite/SKILL.md && test -f AGENTS.md && test -f .codex/hooks.json;; esac); status="$?"; rm -rf "$tmp"; test "$status" -eq 0 || exit "$status"; done`；命令成功退出，证明三个显式平台值均保持原有覆盖语义且 `both` 同时落地两套入口。
- AC5: 由独立 reviewer 在 TAD 仓库根目录执行 `for file in README.md INSTALLATION_GUIDE.md; do rg -q -i 'default.*both|默认.*双平台|双平台.*默认' "$file"; rg -q -i 'fresh install|new install|首次安装|全新安装' "$file"; rg -q -i 'upgrade|升级' "$file"; for platform in claude-code codex both; do rg -q -- "--platform $platform" "$file"; done; done`；命令成功退出，证明两份文档都明确覆盖首次安装、后续升级、默认双平台及三个显式覆盖值。
- AC6: 由独立 reviewer 执行 `tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/.tad/active" "$tmp/.claude/skills/alex-lite"; printf '2.35.0\n' > "$tmp/.tad/version.txt"; printf 'keep-me\n' > "$tmp/.tad/active/user-sentinel"; printf 'legacy\n' > "$tmp/.claude/skills/alex-lite/SKILL.md"; cd "$tmp"; node "/Users/sheldonzhao/01-on progress programs/TAD/bin/tad-install.mjs"; test "$(cat .tad/active/user-sentinel)" = keep-me; test -f .agents/skills/alex-lite/SKILL.md; test -f AGENTS.md; test -f .codex/hooks.json`；所有命令成功，证明 npx/Node 入口的无参数升级同样补齐 Codex 且保留项目数据。

## Contract Review (2026-07-30)
Reviewer: 独立 Codex reviewer（只读、独立上下文）
首轮 verdict: FAIL
最终 verdict: PASS
P0=0 (fixed), P1=0, P2=0; 已审 AC 条数: 6
关键发现: 首轮 reviewer 指出 npx 入口 `bin/tad-install.mjs` 也有独立的 Claude-only 默认值，并指出升级 fixture、隔离 platform override fixture、显式 `both` 与文档覆盖不够具体；已全部补入并通过增量复核。

增量复核 (2026-07-30): PASS，覆盖 `bin/tad-install.mjs`、可执行升级 fixture、三组隔离平台 fixture、显式 `both`、npx 升级路径及文档精确匹配。UNVERIFIED: 尚未执行网络依赖的真实安装验收。

## 风险与注意
- 安装器会从 GitHub 下载 TAD source；AC 执行需要网络可用，若网络不可用必须标记 `UNVERIFIED`，不得用静态文件存在替代安装验收。
- 升级 fixture 必须包含可识别的现有 `.tad/version.txt`，并验证项目数据未被覆盖。
- `both` 路径会生成 `.codex/hooks.json`；Codex 当前版本若报告 hooks schema warning，应区分 hooks warning 与 skill 文件是否成功安装。

## Completion (2026-07-30)
**Commit**: uncommitted（是否 commit 由人决定）
- 改动文件：`tad.sh`、`bin/tad-install.mjs`、`README.md`、`INSTALLATION_GUIDE.md`（全部在清单内，无清单外改动）
- escalated_review 用户原话（逐字）：handoff 记录 "I insist you continue to follow the Lite rules."；2026-07-30 人补充裁定（逐字）："范围包括：tad.sh 默认改为双平台 / bin/tad-install.mjs 默认改为双平台 / 新安装和升级均覆盖 / Claude-only 旧项目（如"全屋智能化"）升级后自动补齐 Codex / 保留显式 claude-code、codex、both 覆盖 / AC 已覆盖真实临时安装、升级哨兵数据和三种平台模式"
- AC 结果：
  - AC1 ✅ 全新临时目录 `bash tad.sh --yes`：日志 "No platform specified. Using default platform: both (Claude Code + Codex)"；`.claude/skills/alex-lite/SKILL.md`、`.agents/skills/alex-lite/SKILL.md`、`AGENTS.md`、`.codex/hooks.json` 全部存在
  - AC2 ✅ Claude-only 升级 fixture（version.txt=2.35.0 + sentinel）：`user-sentinel` 内容保持 `keep-me`，新增 `.agents/skills/alex-lite/SKILL.md`、`AGENTS.md`、`.codex/hooks.json`
  - AC3 ✅ 四项静态检查全过：两个 `--help` 均命中 `claude-code, codex, both.*Default: both`；`rg 'PLATFORM="both"' tad.sh` 命中默认分支；`rg "argPlatform \|\| 'both'" bin/tad-install.mjs` 命中
  - AC4 ✅ 三平台隔离 fixture：`claude-code` 无 `.agents/skills`/AGENTS.md/`.codex`；`codex` 无 `.claude/skills` 且有 AGENTS.md + `.codex/hooks.json`；`both` 双落地；三者均 exit 0
  - AC5 ✅ README.md 与 INSTALLATION_GUIDE.md 均命中默认双平台、首次安装、升级及 `--platform claude-code|codex|both` 全部显式值
  - AC6 ✅ `node bin/tad-install.mjs` 无参数升级：sentinel 保留 + Codex 补齐，exit 0
  - 网络真实安装已执行，无 UNVERIFIED 项
- Reviewer: PASS, P0=0, P1=0, P2=3。关键发现原文摘录："改动严格落在 handoff 清单内，spec 的目标/不做什么/AC 与 diff 完全一致，默认值同时覆盖新安装与升级路径，显式覆盖语义经 AC4 实跑确认无损；6/6 AC 全部由本 reviewer 独立实跑通过（含真实网络安装）。"
- 意外发现：升级路径日志出现既有 warning "REJECT: chain gap at 2.35.0 — no manifest from 2.35.0"（migration engine 对 2.35.0 无 manifest，跳过迁移；与本次默认值改动无关，安装与数据保留均正常）
- follow-up：
  1. P2：`tad.sh:1389` 注释 `# Resolve platform (from --platform flag or auto-detect)` 已过时（auto-detect 逻辑本单已删）｜证据：L3 reviewer 发现 #1｜不阻塞：纯注释，行为正确｜建议 owner：下次改 tad.sh 的人顺手修
  2. P2：`tad.sh:1401-1413` Codex CLI 检测提示只在 `PLATFORM="codex"` 触发，`both`（现为默认）不触发，未装 Codex CLI 的用户不再收到提示｜证据：L3 reviewer 发现 #2｜不阻塞：既有行为，不影响文件安装｜建议 owner：Alex 评估是否把条件改为 `codex|both`
  3. P2：`tad.sh:1382` 启动 banner 仍写 "Claude Code Integration"，与默认双平台不再相称｜证据：L3 reviewer 发现 #3｜不阻塞：纯装饰文案｜建议 owner：下次发布顺手改
  4. 可观测性缺口：migration engine 对 2.35.0 报 chain gap（fixture 从 2.35.0 升级时迁移被跳过）｜证据：AC2/AC6 日志 "Migration skipped: manifest invalid or chain gap (exit 2)"｜不阻塞：数据保留与文件补齐均正常，属既有迁移链覆盖问题｜建议 owner：Alex 评估 migration manifest 链覆盖范围
