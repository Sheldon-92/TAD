#!/usr/bin/env python3
"""P2+P3: cut routing machinery across 9 files.

Transformations per contract HANDOFF-20260805-cut-routing-machinery.md v2/v3.
Every operation asserts its anchor is unique before applying (fail-fast).
"""
import sys

def read(f): return open(f, encoding="utf-8").read().split("\n")
def write(f, lines): open(f, "w", encoding="utf-8", newline="").write("\n".join(lines))

def idx_exact(lines, anchor, label):
    hits = [i for i, l in enumerate(lines) if l == anchor]
    if len(hits) != 1:
        print(f"FAIL {label}: anchor 命中 {len(hits)} 次(期望1): {anchor!r}"); sys.exit(1)
    return hits[0]

def sub_once(lines, old, new, label):
    """replace first exact line matching old (full-line) with new; assert unique"""
    i = idx_exact(lines, old, label)
    lines[i] = new

def sub_str_once(text, old, new, label):
    """replace substring old in full text; assert exactly one occurrence"""
    n = text.count(old)
    if n != 1:
        print(f"FAIL {label}: 子串命中 {n} 次(期望1): {old!r}"); sys.exit(1)
    return text.replace(old, new, 1)

NEW_LIST = [
    "<!-- ESCALATION-LIST-BEGIN -->",
    "安全停清单（命中任一 → 停下来问人；不再有\"转 full\"分支）：",
    "1. 不可逆操作：支付/认证/批量数据删除/生产部署配置/依赖升级(lockfile、版本 pin)/release·publish·sync/破坏性 VCS(force-push、删分支、改历史)",
    "2. SAFETY 面：.tad/project-knowledge/principles.md、patterns/ 中标 SAFETY 的条目、patterns/_index.md、本清单自身",
    "3. 全局注册面：.tad/hooks/、.claude/settings*.json —— 注册后全 session 生效且无回滚验证",
    "兜底：无法确信影响面 → 停，请人裁定。",
    "<!-- ESCALATION-LIST-END -->",
]

def replace_sentinel(lines, label):
    """replace ESCALATION-LIST-BEGIN..END block (inclusive) with NEW_LIST"""
    b = idx_exact(lines, "<!-- ESCALATION-LIST-BEGIN -->", f"{label}:BEGIN")
    e = idx_exact(lines, "<!-- ESCALATION-LIST-END -->", f"{label}:END")
    assert b < e
    lines[b:e+1] = NEW_LIST

def del_section(lines, start_anchor, stop_prefix, label):
    """delete from line equal to start_anchor up to (not incl) first line starting with stop_prefix"""
    s = idx_exact(lines, start_anchor, f"{label}:start")
    e = None
    for i in range(s+1, len(lines)):
        if lines[i].startswith(stop_prefix):
            e = i; break
    if e is None:
        print(f"FAIL {label}: 找不到终止锚 {stop_prefix!r}"); sys.exit(1)
    del lines[s:e]

# ── 1. alex-lite（.claude 与 .agents 相同变换）──
def transform_alex(f):
    lines = read(f)
    # §3.1 整节删除 Route Contract
    del_section(lines, "## Route Contract（Lite / Standard / Full 三层路由）", "## ", f"{f}:RouteContract")
    # §3.3 哨兵块替换
    replace_sentinel(lines, f)
    # §3.4(a) frontmatter 删第 6 行
    line6 = "  仅升级清单命中或用户明确要求时转 full TAD（/alex）。"
    i = idx_exact(lines, line6, f"{f}:frontmatter6")
    del lines[i]
    # §3.4(b) L0 节替换（从 L0 标题到哨兵 BEGIN 前）
    s = idx_exact(lines, "### **L0 — Applicability and current-state check（适用性与现状检查）**", f"{f}:L0")
    e = idx_exact(lines, "<!-- ESCALATION-LIST-BEGIN -->", f"{f}:L0end")
    assert s < e
    lines[s:e] = [
        "### **L0 — Applicability and current-state check（适用性与现状检查）**",
        "",
        "- Input: 用户需求 + `.tad/active/handoffs/` 现状。",
        "- Action: 对照下方安全停清单判断；定位相关当前 handoff/状态；",
        "  不因篇幅、上下文引用数或\"想要更多细节\"而升级。",
        "- Output: 判定（继续 lite / 安全停）。",
        "- Stop: 命中安全停清单任一项 → **停下来问人**，说明命中了哪一条、建议怎么做；",
        "  得到人的明确指示后再继续。未命中 → 直接进 L1。",
        "",
    ]
    # §3.4(c) 哨兵块之后两整块删除（escalated_review 授权规则 → L1 Goal anchor 前）
    del_section(lines, "escalated_review 授权规则：", "### **L1 — Goal anchor", f"{f}:esc-auth")
    # §3.4(d) d1 整行替换
    sub_once(lines, "  **Date**: {date} | **escalated_review**: no | yes (用户原话: \"...\")",
             "  **Date**: {date}", f"{f}:d1")
    # d2 整行删除
    i = idx_exact(lines, "  - escalated 单追加：升级清单命中项是否被 AC 覆盖", f"{f}:d2")
    del lines[i]
    # d3 子串替换（在整行上操作）
    txt = "\n".join(lines)
    txt = sub_str_once(txt, "命中升级清单", "命中安全停清单", f"{f}:d3")
    # d4 整行替换
    lines = txt.split("\n")
    sub_once(lines, "- fatal 操作仍按升级清单第 4 类处理；普通局部修改继续留在 Lite。",
             "- 不可逆操作按安全停清单第 1 条处理（停下来问人）；普通局部修改继续留在 Lite。", f"{f}:d4")
    # d5 子串替换
    txt = "\n".join(lines)
    txt = sub_str_once(txt, "，格式同 Model 行}", "}", f"{f}:d5")
    # d6 子串删除
    txt = sub_str_once(txt, "，机械捕获同 Model 行纪律", "", f"{f}:d6")
    lines = txt.split("\n")
    # §3.4(e) Series 锚点整段替换
    sub_once(lines,
             "Series 锚点：多步任务不写 .tad/active/epics/（升级清单第 2 类）。锚点 = LITE 文件 header 追加 Series 行。Series 为文档性锚点，blake-lite 不消费。用户要求\"Epic\"→ 解释 lite 用 Series 行；用户仍坚持写正式 Epic → 即命中第 2 类，按升级清单/escalated 规则处理。",
             "Series 锚点：多步任务默认用 Series 行做轻量锚点（LITE 文件 header 追加，blake-lite 不消费）。确需正式 Epic → 可直接写 .tad/active/epics/（不再受清单限制）。",
             f"{f}:Series")
    # §3.4(f) Forbidden 删 3 行
    fb = idx_exact(lines, "## Forbidden", f"{f}:Forbidden")
    drops = [
        "  主动建议或默认 escalated_review /",
        "  在无用户明示坚持时设置 escalated_review: yes /",
    ]
    for d in drops:
        i = idx_exact(lines, d, f"{f}:fb-drop")
        del lines[i]
    # 第三行以「把额度出口句用于推荐/暗示 escalated」开头
    hits = [i for i, l in enumerate(lines) if l.startswith("  把额度出口句用于推荐/暗示 escalated")]
    if len(hits) != 1:
        print(f"FAIL {f}:fb-drop3 命中 {len(hits)} 次"); sys.exit(1)
    del lines[hits[0]]
    write(f, lines)

# ── 2. blake-lite ──
def transform_blake(f):
    lines = read(f)
    # §3.1 Route Contract 整节删除
    del_section(lines, "## Route Contract（Lite / Standard / Full 三层路由）", "## ", f"{f}:RouteContract")
    # §3.3 哨兵块替换
    replace_sentinel(lines, f)
    # §3.5(a) L0 step2 末条与 step3 替换
    s = idx_exact(lines, "   - 无 LITE 文件 → 停：\"请先用 /alex-lite 生成计划\"（口头需求不是契约）", f"{f}:L0step2")
    e = idx_exact(lines, "<!-- ESCALATION-LIST-BEGIN -->", f"{f}:L0end")
    assert s < e
    lines[s:e] = [
        "   - 无 LITE 文件 → 停：\"请先用 /alex-lite 生成计划\"（口头需求不是契约）",
        "3. 适用性复查（清单 = 下方哨兵块，与 alex-lite 逐字节相同）：",
        "   - 命中安全停清单任一项 → **停下来问人**，说明命中了哪一条；得到明确指示后再继续",
        "   - 未命中 → 进 L0.5",
        "",
    ]
    # §3.5(b) L0.5 删 2 行 + 不留连续双空行
    d1 = idx_exact(lines, "escalated 单追加：核对 escalated_review 用户原话存在且含实质理由；原话仅为\"好/继续/可以\"类无实质内容 → 停，请人补充理由。", f"{f}:L05d1")
    d2 = idx_exact(lines, "（escalated 的 2-reviewer 结构不变、位置前移：设计期契约审查（alex-lite）+ 实现后审查（L3）= 2 名）", f"{f}:L05d2")
    assert d2 == d1 + 1
    del lines[d1:d2+1]
    # 修双空行：若 d1 前一行与 d1 位置都为空 → 删一个
    if lines[d1-1] == "" and lines[d1] == "":
        del lines[d1]
    # §3.5(c) e1 整行替换
    sub_once(lines, "- fatal 操作仍按升级清单第 4 类处理；普通局部修改继续留在 Lite。",
             "- 不可逆操作按安全停清单第 1 条处理（停下来问人）；普通局部修改继续留在 Lite。", f"{f}:e1")
    # e2 整行替换（Forbidden）
    sub_once(lines, "  命中升级清单却不按 L0 step3 三分支处理 /",
             "  命中安全停清单却不停下来问人 /", f"{f}:e2")
    # e3 子串删除（单个前导空格）
    txt = "\n".join(lines)
    txt = sub_str_once(txt, " escalated_review: yes 却未核对用户原话 /", "", f"{f}:e3")
    # e4 子串删除
    txt = sub_str_once(txt, "，机械捕获同 Model 行纪律", "", f"{f}:e4")
    lines = txt.split("\n")
    # §3.2 Model 行捕获纪律整块 → 一行（到「学习捕获纪律：」前）
    s = idx_exact(lines, "Model 行捕获纪律（writer=角色身份 alex|blake，model=执行模型/harness 身份，两者不冗余）：", f"{f}:modelblk")
    e = idx_exact(lines, "学习捕获纪律：本角色只写原始 journal 材料（lite-discoveries.md 或 handoff 指定的", f"{f}:modelend")
    assert s < e
    lines[s:e] = ["Model 行按运行时自报填写，一行即可；无法判定的字段填 unknown，不得伪造。", ""]
    write(f, lines)

# ── 3. tad-help（两树相同：3 整行删 + 2 子串替换）──
def transform_help(f):
    lines = read(f)
    drops = ["- **Lite / Standard / Full routing profiles**:",
             "- **Shared route contract**:",
             "- **Independent depth selection**:"]
    keep = []
    for l in lines:
        if any(l.startswith(d) for d in drops):
            continue
        keep.append(l)
    txt = "\n".join(keep)
    txt = sub_str_once(txt, "risk and explicit routing rules do", "risk does", f"{f}:h1")
    txt = sub_str_once(txt, "escalation valve (SAFETY/protocol/fatal → full TAD, fail-closed)",
                       "safety stop (irreversible ops / SAFETY surface / global registration → stop and ask)", f"{f}:h2")
    write(f, txt.split("\n"))

# ── 4. AGENTS.md：删路由整节（到下一个 ## 前，含分隔线）──
def transform_agents(f):
    lines = read(f)
    s = idx_exact(lines, "## Lite / Standard / Full Routing（用户可读说明）", f"{f}:routing")
    e = None
    for i in range(s+1, len(lines)):
        if lines[i].startswith("## "):
            e = i; break
    assert e is not None
    del lines[s:e]
    # 修双空行（删除前是空行 + 删除后首行是空行的情况）
    if lines[s-1] == "" and lines[s] == "":
        del lines[s]
    write(f, lines)

# ── 5. INSTALLATION_GUIDE.md：删路由整节 ──
def transform_guide(f):
    lines = read(f)
    s = idx_exact(lines, "## Lite / Standard / Full 路由", f"{f}:routing")
    e = None
    for i in range(s+1, len(lines)):
        if lines[i].startswith("## "):
            e = i; break
    assert e is not None
    del lines[s:e]
    if lines[s-1] == "" and lines[s] == "":
        del lines[s]
    write(f, lines)

# ── 6. CLAUDE.md：两行整行替换 ──
def transform_claude(f):
    lines = read(f)
    sub_once(lines, "### 2.5 Lite 通道（用户显式选择，Alex 不自动推荐）",
             "### 2.5 Lite 通道（默认通道）", f"{f}:title")
    sub_once(lines, "`/alex-lite` → `/blake-lite`：≤5 文件、非协议契约的小任务，或额度紧张时。契约文件 `LITE-*.md`。",
             "`/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；仅命中 lite skill 内的「安全停清单」时停下来问人。契约文件 `LITE-*.md`。", f"{f}:body")
    write(f, lines)

# ── 执行 ──
if __name__ == "__main__":
    for p in (".claude/skills/alex-lite/SKILL.md", ".agents/skills/alex-lite/SKILL.md"):
        transform_alex(p); print(f"OK {p}")
    for p in (".claude/skills/blake-lite/SKILL.md", ".agents/skills/blake-lite/SKILL.md"):
        transform_blake(p); print(f"OK {p}")
    for p in (".claude/skills/tad-help/SKILL.md", ".agents/skills/tad-help/SKILL.md"):
        transform_help(p); print(f"OK {p}")
    transform_agents("AGENTS.md"); print("OK AGENTS.md")
    transform_guide("INSTALLATION_GUIDE.md"); print("OK INSTALLATION_GUIDE.md")
    transform_claude("CLAUDE.md"); print("OK CLAUDE.md")
    print("ALL TRANSFORMS DONE")
