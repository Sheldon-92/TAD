# Gate 3 独立 SAFETY 评审 — Claude 路径彻底移除 (v3.0.0)

- **结论: CONDITIONAL** — 核心 SAFETY (用户数据零删除、tombstone、零运行时残留) 成立；4 项必须返工 (R1–R4) 后方可 Gate 4 / 发布。非 FAIL：未发现用户数据删除路径或静默回落。
- **评审身份**: Blake (Execution Master) Gate 3 独立评审。只评审不写代码；未 commit；未改 `docs/pm/`。
- **基线**: HEAD `c32bde27` (v2.44.6)；工作树 722 改动 (572 D / 143 M / 1 R / 6 ??，`main` 分支，未发布)。
- **Handoff**: `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md` (READY_FOR_GATE2，v3.0.0 一步落地)。
- **评审日期**: 2026-09-16。**真跑证据**: `installer-data-safety-fixture.sh --case ac2.13` **5/5 PASS**；`node bin/tad-install.mjs --platform both|claude-code` 均 exit 1；`migration-engine --from 2.26.0 --to 2.27.0 --dry-run` exit 0；`tad.sh --verify-denylist` PASS；`runtime-freshness` 见 R3。

---

## 必须返工项 (GATE 3 → GATE 4 前提)

### R1 — 恢复 `.gitignore` 机器本地 `.claude/*` 忽略规则 (over-strip 回归)
- 现状：S7 把 `.gitignore` 里全部 `.claude/*` 行清掉（含 parity 注释，一并去掉是对的），但连带删了机器本地保护规则。HEAD 曾忽略：`.claude/skills/local/` (:13)、`.claude/settings.local.json` (:10)、`.claude/projects/` (:19)、`.claude/worktrees/` (:20)、`.claude/settings.local.json.bak-*` (:78)、`.claude/commands/BMad/` (:7)；现工作树 `grep -n 'claude' .gitignore` = 空。
- 后果（已实证）：维护者本机用户资产现裸奔为 `?? .claude/` —— 内含 `.claude/skills/local/_index.md`、`settings.local.json`、`projects/-Users-…/memory`。一次 `git add -A` 即可把私机记忆与本地 skills 送进仓库。handoff 只要求“保留 `.agents/skills/local/`”，从未要求删除 `.claude` 机器本地忽略。
- 返工：恢复上述机器本地忽略行（`BMad/` 与 parity 注释保持删除）；另核 `.tad/memory/reference_claude-code-source.md` 的忽略行（HEAD :70）去留——该文件现也是 `??` 未跟踪。
- 附带：V-P2 `test ! -e .claude` 在本工作目录字面 FAIL（未跟踪目录存在）。V-P2 本意是 tracked 删除（`git ls-files '.claude/**'` = 0，已满足），建议 Alex 明确 V-P2 语义为 tracked-only，或要求工作目录无未跟踪 `.claude/` 残留说明。

### R2 — V-P1/AC6 字面 FAIL：4 处未列明 `claude-code` 残留需 Alex 裁决
- handoff V-P1 命令在活目录实际有输出（期望无输出），全部是**任务前已存在、one-byte 未动**（`git diff HEAD` 为空）的文本：
  1. `.agents/skills/agent-computer-interface/SKILL.md:110,115,116,118,145,147`（`claude-code-tools-rules.md` 路由 + "Claude in Chrome"；且该引用文件真实存在：`.agents/skills/agent-computer-interface/references/claude-code-tools-rules.md`）。
  2. `.agents/skills/alex/references/deps-protocol.md:132`（`claude-code-cli` 注册表示例）。
  3. `.agents/skills/dependency-ops/SKILL.md:67`（同上）。
  4. `.tad/capability-packs/ai-agent-architecture/CHANGELOG.md:24`（pack 历史条目 `--agent=claude-code`）。
- 定性：1–3 是野生命名（真实产品/包名），与 `ai-prompt-engineering`/`ai-evaluation` 豁免同类（§3.H 领域知识保留）；4 是历史记录（§3.K 不动类）。但 §3.H 保留清单未点名它们 → 按字面 AC5/V-P1 不通过。
- 返工：Alex 二选一并落字——(a) 把 1–4 追加进 §3.H/§3.K 保留清单并逐条 rationale（推荐，零代码改动）；或 (b) 改写。Blake 不得自行“解释通过”。

### R3 — AC21 `runtime-freshness` 当前 BLOCK (exit 1)，需真实处置
- 现状：`Total: 12 entries | PASS: 0 | WARN: 6 | BLOCK: 6`，BLOCK 全是 codex ledger 日期过期（last verified 2026-08-03，44 天 > 30；next_review 2026-09-02 已过期）。claude ledger 已正确 RETIRED 跳过（`INFO … skipping`），I18 实现正确。
- 定性：日期过期与移除无关（HEAD 同样 BLOCK）；codex.md 本批改动仅 J7 一行（source-of-truth 措辞），日期未动。但 AC21 字面要求 exit 0。
- 返工（二选一）：(a) 对 codex 条目做一次**真实** re-verification 后刷新日期（推荐——J7 恰好改了条目语义，重验名正言顺）；或 (b) Gate 4 书面 waiver（pre-existing date-staleness，另立单刷新）。**禁止空 bump 日期**（验证剧场）。

### R4 — 发布前补 V-P7 `tad.sh` 侧 zero-mutation 实证
- 已有证据：`validate_platform` 对 `both|*claude*` → 报错 + 3 条恢复命令 + `exit 1`（`tad.sh:519-536`）；调用序 `resolve_platform:2363` < `NEED_ROLLBACK=1:2571` < `take_rollback_snapshot:2575`，结构性 fail-before-mutation；`KNOWN_PLATFORMS="codex"`；node 侧真跑 `both`/`claude-code` 均 exit 1；`tad-update-fixture.sh:474-477` 含 `both → removed-error` 用例。
- 缺口：§6.3 V-P7 的 sandbox 全链证据（both 透传 → exit≠0 + `diff -rq` byte-identical + 文案含 `--platform codex`）尚未执行留证。
- 返工：发布前跑一次 V-P7（含负控：tombstone 后移 → zero-mutation 断言 FAIL）并贴证据；`tad-update-fixture.sh` 相关用例一并执行。

---

## 通过项 (关键发现摘要)

1. **升级安全核心成立（真跑）**：`ac2.13` 5/5 PASS——预置 `.claude/{skills,settings.json,settings.local.json,.mcp.json,commands}` → codex 升级后 `diff -r` byte-identical，且新 `.agents/skills/` 正确装上。`deprecation.yaml` 零新增（仅历史 `.claude/commands/tad-*.md` 单文件条目 + prose，属 L6 明确豁免）；`git diff` 为空。`tad.sh` 无任何 `.claude` 删除站点（仅注释 `:1163`“永不删除”）；rollback `snap_one` 只剩 AGENTS.md/GEMINI.md/.codex/hooks.json/.agents/skills；`rmdir` 仅 `.agents/skills` + `.opencode`；`rm -rf` 全带 `# RM-OK` 且无一指向用户树。
2. **无 3.0.0 删除 manifest**：`.tad/migrations/` 无 `*3.0.0*` 文件；`migration-draft.sh` scope 已去 `.claude/`/`CLAUDE.md`（grep 为空）；`migration-engine.sh:72` allow-list 保留 `.claude/*`。2.26→2.27 dry-run exit 0（`.claude/skills/**` 删除条目解析为 already-absent，无 REJECT）——历史回放兼容成立。
3. **零运行时残留**：`phase2-pair-driver.mjs` 无 `claude|sonnet`（`JUDGE_MODEL_FAMILY` 默认 `'opencode'`，无 claude 回落）；`yolo-harness-profiles.json` 零 claude；`teammate_model/lead_model: inherit`；haiku prompt hook 随 `settings.json` 删除；`.bak`（G6 点名）已删——残留 `.bak` 仅 evidence/negative-controls（测试负控本體，非 claude 残留）；无 `ANTHROPIC_API_KEY`/`spawn claude` 命中。`.claude/**` tracked = 0，`CLAUDE.md` 已删，`research/AGENTS.md` 就位。
4. **平台矩阵收敛**：`platform-codes.yaml` 仅 `codex`；`tad-update.sh detect_platform` 只认 `.agents/skills/alex`（注释明示 leftover `.claude` 永不重检、不删）；`detect-platform.sh` workflow 分支已删；`bin/tad-install.mjs` 平台列表动态读 + 自带 tombstone（`both|*claude*` → exit 1）。
5. **SSOT 消费者同批**：`SKILLS_DIR` 已切 `.agents/skills`（brain-index-gen/pack-registry-driftcheck/scan-collisions）；`pack-collisions.yaml` refs 全 `.agents/skills`；pack installers 零 `.claude/skills` 目标（含 `*claude*` tombstone）；`capability-skill.sh` 仅 tombstone 注释；`memory-redirect.sh` retire fail-closed（exit 2，无 mutation）；`release-verify.sh` 无 parity/platform-skills 且 `.agents/skills` 无 `parity` 调用方；`--verify-denylist` PASS；版本三处同步 3.0.0（version.txt/package.json/TARGET_VERSION）。
6. **破坏面文档充分**：CHANGELOG v3.0.0 块与 §5.3 一致（仅 `### Removed`，无 2.45.0 过渡）；§5.2 五点齐备（INSTALLATION_GUIDE 85–103：codex 默认 / 不删不写 + 手动 `rm -rf` 指引 / tombstone 三恢复命令 + 旧 updater 说明 / pack 目标变更 / 无删除 manifest 保证）；MULTI-PLATFORM 标 `Removed in v3.0.0`；AC8 双写零残留、AC5 标签改名、V-P3 一等平台断言清零（除 R2 点名范围外）；`.opencode/` 零改动；`docs/pm/` 本任务零改动（staged 的 intent.md/now.md 系任务前状态）。

## 观察项 (非阻塞)
- **O1**：2.42→2.43 dry-run REJECT（`reason: >-` 折叠 prose 行触发 strict parser）系 **pre-existing**——engine 与 manifest 均与 HEAD 字节一致（`git diff HEAD` 为空），与 `.claude` allow-list 无关。AC18 点名的 2.26 链回放通过。建议 Alex 在 AC18 备注该已知 parser-strictness；修 engine/manifest 需另立 migration SAFETY 单，不在本批。
- **O2**：`tad` 根 CLI 已切 `.agents/skills` 计数；`detect-state-fixture` 等 fixture 路径已迁（仅 1 个 unstaged 文件 `migration-fixtures/run-fixtures.sh`，属本批内改动）。
- **O3**：Codex/OpenCode/Cursor 现有用户影响：升级不丢文件（R1 修复后含 git 侧保护）；Codex 用户零操作；Cursor 用户无契约变更（AGENTS.md 中立路由保留）；仍用 Claude Code 者冻结在旧树、TAD 不代删——与 §5.2 一致。

## 评审方法
只读 grep/`git diff`/`git ls-files` + 4 次真跑（ac2.13、node tombstone×2、migration 2.26 回放、denylist、freshness）。未执行实现修改，未触发布（无 push/tag/bump 授权外动作）。
