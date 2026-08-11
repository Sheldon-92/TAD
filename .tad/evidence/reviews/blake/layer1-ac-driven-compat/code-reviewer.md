# L3 独立实现审查报告 — LITE-20260810-1820-layer1-ac-driven-compat

**身份**: harness=Claude Code（Agent tool / code-reviewer route，只读）| model=deepseek-v4-flash | role=L3 独立实现审查

**Verdict: CONDITIONAL**（首轮）→ 增量复核后见文末。

## 🔴 P0-1｜verify.sh AC14 摘要半恒真死代码（verify.sh:291-301，缺陷行 :295）

**执行实证**（三项探针）：
1. `grep -F "  path1$"` 在 /usr/bin/grep（BSD 2.6.0）与 ugrep 7.5.0 上均 **rc=1 无匹配**——`$` 在 `-F` 固定串模式下是**字面量**不是行尾锚。故 `bsha=$(grep -F "  ${p}$" ...)` 对任何路径恒空。
2. 突变探针（/tmp 构造）：伪造 now.digests 把 NEXT.md 摘要改为全 0（模拟越界编辑），逐行执行 verify.sh:291-301 的精确逻辑 → `bsha` 空 → 无条件 `continue` → **a14ok=1 判 PASS**。摘要半对所有路径无条件跳过，"dirty digests unchanged" 从未被实际评估。
3. 附带发现（设计层）：即使修好锚，该半段在**正确实现下也会假 FAIL**——`.tad/evidence/traces/2026-08-10.jsonl` 是实现期被框架 hook 追加的遥测（基线 1500f1e9→现在 b25661c6，7 行 `evidence_created` 事件全部在基线之后，是证据文件创建触发的自写）。契约第二半未排除遥测路径，是**按原文不可满足**的断言；实现的 bug 恰好掩盖了这一点。

**修复建议**（粘贴即用）：
```bash
# :295 改为（无正则、无锚歧义的精确后缀匹配）
bsha=$(awk -v p="$p" 'index($0, "  " p) > 0 && substr($0, length($0) - length(p) + 1) == p {print $1; exit}' "$TMP/base.digests")
# 并在摘要比对循环中排除框架遥测路径（实证：traces 日文件在证据创建时被 hook 追加）
case "$p" in .tad/evidence/traces/*) continue;; esac
```

## 🟢 P2（5 条）

- **P2-1**（执行实证）：清单第 12 项 `.tad/evidence/reviews/blake/layer1-ac-driven-compat/` **尚未创建**。L4/L5 归档前需将本审查报告落盘至此，否则 Completion 缺审查载体。
- **P2-2**（阅读推断+执行实证）：verify.sh 头注释声称「AC17 自验见 results.txt」，但 results.txt **无 AC17 行**。已独立复跑 5 项（均过），建议提交后重跑时并入 results.txt。
- **P2-3**（阅读推断）：verify.sh manifest 未含 Completion 文件路径，而 mandate pathspec 含「本契约文件自身与其 Completion」——若 Completion 纳入提交，AC16 会误报越界。（处置：Completion 追加到 handoff 同一文件，handoff 已在 manifest，P2-3 前提不成立。）
- **P2-4**（阅读推断）：`docs/RALPH-LOOP.md` 命令表以「§9.1 声明的技术检查行 1/2/3/N」占位（AC10 合规，用户文档略显机械）。
- **P2-5**（阅读推断）：`1_5_context_refresh` 步骤 10「If handoff has no Project Knowledge section」在新有界读取流程下成为死条件；AC 合规，语义上留待后续单微调。

## AC 逐条核验（独立执行，非读代验）

全部 19 条 PASS（AC16 按设计 PENDING，HEAD==base_sha 未提交属实）。

## 执行证据

1. `bash .tad/evidence/acceptance-tests/layer1-ac-driven-compat/verify.sh` → 29 PASS/0 FAIL/1 PENDING。
2. AC17 五项全过。
3. `printf 'abc123  path1\n...' | /usr/bin/grep -F "  path1$"` → 无输出 rc=1；去 `$` 后 rc=0 命中。
4. 突变探针：伪造 now.digests → 无条件跳过、a14ok=1（恒真 PASS）。
5. 修正逻辑全量摘要比对：`same=865 changed=1 no-baseline=0`；changed 唯一项 `.tad/evidence/traces/2026-08-10.jsonl`。
6. comm -13 → 9 个新增路径全部在 manifest。
7. AC19 独立复算：`┌.*┐`=94,104 / `└.*┘`=102,120，单调 rc=0，区域 [94,102] L1=1 §9.1=2。
8. 范围扫描：残留 npm/npx 命中集与「不做什么」清单一致。
9. `git rev-parse HEAD` = ae3485f == 基线 base_sha（提交未发生属实）。

---

## 增量复核（2026-08-10，reviewer 本人确认）

**P0-1: CLOSED（执行实证）｜Verdict: PASS**（首轮 CONDITIONAL 升格——实现与验证器均合规，可放行 scoped-local-commit；AC16 提交后重跑得真 PASS 即可）

修复闭合核验（reviewer 执行实证）：
1. verify.sh 两处修复已落盘（:295 traces 排除 + :297 awk index 行尾后缀）。
2. `bash` 与 `/bin/bash`（3.2.57）双运行时均 29 PASS / 0 FAIL / 1 PENDING，exit 0。
3. 突变探针（证明非死代码）——复制 verify.sh:291-303 精确逻辑到 /tmp 三场景：
   - 场景1 真实 now.digests → a14ok=1（traces 被排除，无假 FAIL）
   - 场景2 REGISTRY.yaml 摘要改全 0 → **抓到** `dirty path digest changed: .tad/research-notebooks/REGISTRY.yaml` → a14ok=0 ✓ 变异可检测
   - 场景3 前缀陷阱（LITE-…md vs LITE-…md.txn-lock/owner 严格前缀重叠）→ substr 行尾后缀各自返回正确基线摘要，无串扰
4. 证据载体闭合：results.txt 已含 AC17 五项 + P0 修复记录；本报告已落盘。

遗留（均不阻塞放行）：P2-3（Completion 与 handoff 同文件，已在 manifest——前提不成立）；P2-4/P2-5 建议性文档措辞，留后续单。
