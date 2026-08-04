Model: harness=codex | model=unknown | route=unknown

# Blake Layer 2 独立 Acceptance / Repro Review

**Verdict: FAIL**
P0 = 0 · **P1 = 3** · P2 = 0

审查依据：handoff `.tad/active/handoffs/HANDOFF-20260803-model-vocabulary-universalization.md`
指定的 §2、§3、§5、§6、§7；基线
`39ba1c1c0fc1a92b373331d23553794dd54da135`；以及
`.tad/evidence/acceptance-tests/model-vocab-universalization/` 下全部 AC 脚本、baseline、
AC9 raw、parity raw。未修改产品文件。

## 独立运行结果

AC1–AC10 原脚本全部 exit 0。AC5 sentinel/SAFETY 邻区、AC6 parity + skill-body +
runtime freshness、AC8 当前注册集、AC9 本机 `codex-cli 0.146.0`、AC10 三处校准
标记均通过。正常工作树的 40 个 tracked diff 文件与 §2 清单相符；`.claude`/`.agents`
镜像 parity 通过。

AC3 的 live governance set 与逐文件 `平台绑定交互决策` 术语循环本身通过；AC8 的
正向/反向未注册行负向探针也确实返回 FAIL（`forward-missing=1 reverse-added=1`）。

## P1 findings

### P1-1 — AC1/AC2/AC3 的关键断言不是 section-scoped，可被尾部文本伪绿

`.tad/evidence/acceptance-tests/model-vocab-universalization/AC-01-capability-tier.sh:16`
及 `:33-38`、AC2 `:16-38`、AC3 `:27-32` 对整文件做 `grep -F`，没有锚定 handoff
§A 的 `### Reviewer 档位规则`、§B 的 Model 捕获段，或 §C 要求的“激活协议/正文早段”。
AC8 的 `registered_line()` 也按宽泛 substring 归因，未补回位置约束。

在隔离临时 clone（不是工作树）中，我把 `.claude/skills/alex-lite/SKILL.md` 的真实
Reviewer 档位块移除，将所需 AC1 术语追加到文件末尾；再把真实 §C 条款移到文件末尾。
结果分别为：

```text
misplaced AC1: AC1 rc=0; AC8 rc=0
misplaced AC3: AC3 rc=0; AC8 rc=0
```

因此实现即使把条款放错位置/只留下尾部注释，当前 AC 仍可报告 PASS。AC3 的 set
equality 与 per-term 循环是对的，但没有覆盖 §3 的位置与每文件一次约束；这违反本次
验收要求的 section-scoped binary check 纪律。

### P1-2 — AC7 的“真实重验证”绑定可被 active handoff 自身触发

`.tad/evidence/acceptance-tests/model-vocab-universalization/AC-07-ledger-binding.sh:30-35`
只要任一 `.tad/active/handoffs` 或 `.tad/archive/handoffs` 文件含有
`真实重验证` 就接受 `last_verified` 变化；它没有要求 Completion 文件、当日日期、
当前 handoff slug 或实际重验证命令。当前 active handoff 本身已命中该词：

```text
.tad/active/handoffs/HANDOFF-20260803-model-vocabulary-universalization.md
```

在隔离 clone 中仅把 `ask_user_question_hook` 的 `last_verified` 从 `2026-08-03`
改成 `2026-08-04`，不添加 Completion 或重验证证据，AC7 仍返回：
`AC7 PASS ...` / `MUTATED_AC7_RC=0`。这不满足 §5 AC7 的
“last_verified 变更 ⇔ Completion 含当日真实重验证据”双向绑定。

### P1-3 — AC9 原样打印 OPENAI_BASE_URL/base_url，违反“不落 key”

`.tad/evidence/acceptance-tests/model-vocab-universalization/AC-09-codex-key-reprobe.sh:22-23`
直接打印 `env | grep '^OPENAI_BASE_URL='`，`:29-31` 直接打印 `config.toml` 的完整
`base_url` 行。§B2 明确要求只记录变量名与 host、不落 key；当前脚本却把 userinfo、
query 参数及潜在 token 一并写入 raw evidence。

独立输入复现（脚本仍 exit 0）：

```text
OPENAI_BASE_URL=https://review-user:SECRET_KEY@relay.example.invalid/v1?token=SECRET_QUERY
```

输出原样包含 `SECRET_KEY` 与 `SECRET_QUERY`。隔离 `CODEX_HOME/config.toml` 的
`base_url = "https://cfg-user:CFG_SECRET@...?...CFG_QUERY"` 也被原样输出；复现输出
见 `/tmp/model-vocab-ac9-secret-repro.txt` 与 `/tmp/model-vocab-ac9-config-secret-repro.txt`。

## 通过项与范围核对

- AC3 live set 使用 `LC_ALL=C sort` + `comm -3`，逐文件逐术语检查通过；旧
  `Codex: ask_user_question` 注释、AGENTS 指针、portable-rules L27 断言通过。
- AC5 sentinel MD5 与 SAFETY 邻区内容守护通过；blake/handoff 的安全块及 reviewer
  数量/VIOLATION 行未发现变更。
- AC8 baseline commit 有效，当前 diff 中未注册的新增/删除行会分别被捕获；但它仍不
  能补救 P1-1 的位置假绿。
- AC9 正常本机复跑输出见
  `.tad/evidence/acceptance-tests/model-vocab-universalization/ac9-key-reprobe-raw.txt`；
  `parity-fix-raw.txt` 与当前 AC6 parity 结果一致。
- 当前产品 diff 限于 handoff §2 文件集（`.agents` 仅镜像），未见额外产品文件漂移。

**结论：** 当前实现的正常路径与多项 SAFETY 回归通过，但验收脚本仍允许条款错位、
伪造台账重验证证据，并会泄漏凭据型 URL。修复上述 3 个 P1 后再重新执行独立 Layer 2
验收；本轮不得标记 PASS 或 Gate 3 完成。
