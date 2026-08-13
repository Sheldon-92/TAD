#!/usr/bin/env python3
"""Discipline-inventory verifier — subcommands: cost class3 class2 carriers types single-type floor blindspot rows.

Runs read-only against the three artifacts under the same directory.
Python 3.9 compatible (no match statement). CJK string equality via Python (awk is broken on this host).
"""
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]  # .tad/evidence/designs/discipline-inventory -> repo root
FORM_A = HERE / "discipline-inventory.md"
FORM_B = HERE / "discipline-provenance.md"
BLINDSPOT = HERE / "shape-blindspot-review.md"

COST_BADWORDS = ["贵", "便宜", "值得", "划算", "繁琐", "沉重", "轻松"]
FLOOR_REASONS_MARK = "（理由："


def read(p):
    return p.read_text(encoding="utf-8")


def form_a_rows():
    """Return list of dicts for the 9-column table data rows."""
    rows = []
    header = None
    for line in read(FORM_A).splitlines():
        if line.startswith("|"):
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if header is None:
                header = cells
                continue
            if all(re.fullmatch(r"-{2,}", c) for c in cells):
                continue  # separator row
            if len(cells) == len(header):
                rows.append(dict(zip(header, cells)))
    return rows


def form_b_sections():
    """Return {discipline_name: section_text} for each '## Dxx Name' section."""
    text = read(FORM_B)
    parts = re.split(r"^## (?=D\d\d )", text, flags=re.M)
    out = {}
    for p in parts[1:]:
        title_line = p.splitlines()[0]
        m = re.match(r"(D\d\d)\s+(.*)", title_line)
        if m:
            out[m.group(2).strip()] = p
    return out


def form_b_sections_text(text):
    """Return {D-number: section_text} keyed by '## Dxx Name' (行序即 ID 连接键)."""
    parts = re.split(r"^## (?=D\d\d )", text, flags=re.M)
    out = {}
    for p in parts[1:]:
        title_line = p.splitlines()[0]
        m = re.match(r"(D\d\d)\s+(.*)", title_line)
        if m:
            out[m.group(1)] = p
    return out


def cmd_cost():
    rows = form_a_rows()
    if not rows or "成本" not in rows[0]:
        print("成本col=<missing> violations=<missing>")
        raise SystemExit(2)  # column missing -> FAIL
    bad = []
    for r in rows:
        cost = r.get("成本", "")
        for w in COST_BADWORDS:
            if w in cost:
                bad.append((r.get("纪律", "?"), w))
    print(f"成本col={len(rows)} violations={len(bad)} {bad}")


def cmd_class3():
    rows = form_a_rows()
    missing = []
    for r in rows:
        if r.get("三类判定", "") == "3-挂起":
            if not r.get("触发条件", "").strip() or r.get("触发条件", "").strip() == "-":
                missing.append(r.get("纪律", "?"))
    print(f"class3_missing_trigger={len(missing)} {missing}")


def cmd_class2():
    rows = form_a_rows()
    missing = []
    for r in rows:
        if r.get("三类判定", "") == "2-退场":
            # evidence is required in the 触发条件 or a form B "检索过的语料源" note
            trig = r.get("触发条件", "").strip()
            if not trig or trig == "-":
                missing.append(r.get("纪律", "?"))
    print(f"class2_missing_evidence={len(missing)} {missing}")


def cmd_carriers():
    text = read(FORM_B)
    pat = re.compile(r"载体：`([^`#]+)#L(\d+)`「(.+?)」")
    checked = ok = bad = 0
    bads = []
    for m in pat.finditer(text):
        checked += 1
        relpath, lineno_s, snippet = m.group(1), m.group(2), m.group(3)
        problems = []
        if not relpath.startswith(".tad/"):
            problems.append("path-not-under-tad")
        if ".claude/worktrees/" in relpath or ".tad.backup." in relpath:
            problems.append("forbidden-path")
        if len(snippet) < 12:
            problems.append("snippet<12")
        fp = REPO / relpath
        if not fp.exists():
            problems.append("file-missing")
        else:
            try:
                lineno = int(lineno_s)
                lines = fp.read_text(encoding="utf-8").splitlines()
                if lineno > len(lines):
                    problems.append("line-out-of-range")
                elif snippet not in lines[lineno - 1]:
                    problems.append("snippet-not-in-line")
            except (UnicodeDecodeError, ValueError):
                problems.append("unreadable")
        if problems:
            bad += 1
            bads.append((relpath + "#L" + lineno_s, problems))
        else:
            ok += 1
    print(f"checked={checked} ok={ok} bad={bad}")
    for b in bads:
        print("  BAD:", b[0], b[1])


def cmd_types():
    text = read(FORM_B)
    inst_lines = re.findall(r"^- 实例\d+（", text, flags=re.M)
    VALID_TYPES = {"缺席致害", "在场生效", "合成"}
    VALID_SEV = {"高", "中", "低"}
    typed = sev = 0
    for line in re.findall(r"^- 实例\d+（.*?）", text, flags=re.M):
        tm = re.search(r"类型=`([^`]+)`", line)
        sm = re.search(r"严重度=`([^`]+)`", line)
        if tm and tm.group(1) in VALID_TYPES:
            typed += 1
        if sm and sm.group(1) in VALID_SEV:
            sev += 1
    print(f"instances={len(inst_lines)} typed={typed} severity={sev}")


def cmd_empty():
    """AC10: class 2/3/4 rows must show all-empty 4-corpus search."""
    rows = form_a_rows()
    text = read(HERE / "search-log.md")
    violations = []
    for idx, r in enumerate(rows):
        cls = r.get("三类判定", "")
        if cls not in ("2-退场", "3-挂起", "4-威慑免死"):
            continue
        dnum = f"D{idx+1:02d}"
        m = re.search(rf"## {dnum} .*?(?=\n## D\d\d |\Z)", text, flags=re.S)
        if not m:
            violations.append((r.get("纪律", "?"), "no-search-block"))
            continue
        total = 0
        for line in m.group(0).splitlines():
            if line.startswith("|") and "关键词" not in line:
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if len(cells) >= 5:
                    try:
                        total += sum(int(cells[j]) for j in range(1, 5))
                    except ValueError:
                        pass
        if total > 0:
            violations.append((r.get("纪律", "?"), total))
    print(f"empty_missing={len(violations)} {violations}")


def cmd_single_type():
    rows = form_a_rows()
    only_absence = []
    for r in rows:
        inst = r.get("实例", "")
        has_inst = re.search(r"[0-9]+（", inst) is not None and not inst.startswith("0（")
        if has_inst and "缺席" in inst and "在场" not in inst and "合成" not in inst:
            only_absence.append(r)
    warned = [r for r in only_absence if "证据类型受限" in r.get("建议", "")]
    print(f"only_absence={len(only_absence)} warned={len(warned)}")


def cmd_floor():
    text = read(FORM_B)
    floor_lines = re.findall(r"^- 地板·可缩放：.*$", text, flags=re.M)
    missing = [l for l in floor_lines if FLOOR_REASONS_MARK not in l]
    print(f"floor_missing_reason={len(missing)} {missing}")


def cmd_blindspot():
    text = read(BLINDSPOT) if BLINDSPOT.exists() else ""
    def section(marker):
        m = re.search(re.escape(marker) + r"\n(.*?)(?=\n<!-- |\Z)", text, flags=re.S)
        return m.group(1).strip() if m else ""
    ident = section("<!-- REVIEWER-IDENTITY -->")
    prompt = section("<!-- PROMPT -->")
    answer = section("<!-- RAW-ANSWER -->")
    has_model = "model" in ident.lower() or "deepseek" in ident.lower() or "claude" in ident.lower() or "codex" in ident.lower() or "gpt" in ident.lower()
    prompt_has = "装不下" in prompt
    prompt_forbidden = ("对不对" in prompt) or ("是否正确" in prompt)
    answer_len = len(answer)
    print(f"has_model={has_model} / prompt_has_装不下={prompt_has} / prompt_has_forbidden={prompt_forbidden} / answer_len={answer_len}")


def cmd_rows():
    rows = form_a_rows()
    print(f"rows={len(rows)}")


# ---- Phase 1b 新子命令（§8.0 退出码契约：末行 RESULT=PASS/FAIL，FAIL 时 SystemExit(1)）----

SEV_VALID = {"高", "中", "低", "未知"}
SEV_ORDER = {"低": 0, "中": 1, "高": 2}
CRIT_VALID = {"C1", "C2", "C3", "C4"}
CLASS_TO_CRIT = {"1-留": "C1", "2-退场": "C2", "3-挂起": "C3", "4-威慑免死": "C4"}
TIER_VALID = {"零", "机械近零", "机械一次", "agent一次", "人一次", "人多轮"}
REBUTTAL = ["漏掉", "穿透", "不等价", "已证伪", "量化", "挡不住"]
BLINDSPOT_1B = HERE / "shape-blindspot-review-phase1b.md"


def _form_b_arg():
    """解析 --form-b <path>（AC13 源侧负控），返回 Path 或 None。"""
    if "--form-b" in sys.argv:
        idx = sys.argv.index("--form-b")
        return Path(sys.argv[idx + 1])
    return None


def cmd_severity():
    fb_path = _form_b_arg()
    rows = form_a_rows()
    fb_text = read(fb_path) if fb_path else read(FORM_B)
    secs = form_b_sections_text(fb_text)
    bad = []
    sevs = []
    for i, r in enumerate(rows, 1):
        dnum = f"D{i:02d}"
        cell = r.get("严重度", "").strip()
        if cell not in SEV_VALID:
            bad.append(f"{dnum} 严重度非法「{cell}」")
            continue
        sec = secs.get(dnum)
        if sec is None:
            bad.append(f"{dnum} 形态B无段")
            continue
        inst = re.findall(r"严重度=`([^`]+)`", sec)
        expected = "未知" if not inst else max(inst, key=lambda s: SEV_ORDER.get(s, -1))
        sevs.append(cell)
        if cell != expected:
            bad.append(f"{dnum} 表={cell} 形态Bmax={expected}")
    if not bad:
        from collections import Counter
        dist = Counter(sevs)
        if dist.get("高") != 7 or dist.get("中") != 5 or dist.get("未知") != 3 or dist.get("低", 0) != 0:
            bad.append(f"分布={dict(dist)} 要求 高=7 中=5 未知=3")
    if bad:
        for b in bad:
            print("  BAD:", b)
        print("RESULT=FAIL")
        raise SystemExit(1)
    print("RESULT=PASS")


def cmd_criterion():
    rows = form_a_rows()
    bad = []
    crits = []
    for i, r in enumerate(rows, 1):
        dnum = f"D{i:02d}"
        cell = r.get("判据", "").strip()
        cls = r.get("三类判定", "").strip()
        if cell not in CRIT_VALID:
            bad.append(f"{dnum} 判据非法「{cell}」")
            continue
        crits.append(cell)
        if CLASS_TO_CRIT.get(cls) != cell:
            bad.append(f"{dnum} 三类判定={cls} 应映射 {CLASS_TO_CRIT.get(cls)} 但判据={cell}")
    c2 = sum(1 for c in crits if c == "C2")
    if c2 != 0:
        bad.append(f"C2 计数={c2} 要求 0")
    if bad:
        for b in bad:
            print("  BAD:", b)
        print("RESULT=FAIL")
        raise SystemExit(1)
    print("RESULT=PASS")


def cmd_cost_tier():
    rows = form_a_rows()
    bad = []
    for i, r in enumerate(rows, 1):
        dnum = f"D{i:02d}"
        cell = r.get("成本量级", "").strip()
        main_tier = cell.split("（", 1)[0]
        if main_tier not in TIER_VALID:
            bad.append(f"{dnum} 成本量级非法「{cell}」")
            continue
        if dnum in ("D10", "D14"):
            if main_tier != "零":
                bad.append(f"{dnum} 应为 零 实为「{cell}」")
        else:
            if main_tier == "零":
                bad.append(f"{dnum} 不应为 零")
        if dnum == "D01" and cell != "人多轮（lite: 人一次）":
            bad.append(f"D01 应为「人多轮（lite: 人一次）」实为「{cell}」")
    if bad:
        for b in bad:
            print("  BAD:", b)
        print("RESULT=FAIL")
        raise SystemExit(1)
    print("RESULT=PASS")


def cmd_graph():
    rows = form_a_rows()
    fb_text = read(FORM_B)
    secs = form_b_sections_text(fb_text)
    bad = []
    names = {}
    cells = {}
    for i, r in enumerate(rows, 1):
        dnum = f"D{i:02d}"
        names[dnum] = r.get("纪律", "")
        cells[dnum] = r.get("防线关系", "").strip()
    edges = {}
    for dnum in names:
        cell = cells[dnum]
        if not cell:
            bad.append(f"{dnum} 防线关系空")
            edges[dnum] = []
            continue
        if cell.startswith("独立"):
            if "→" in cell or "->" in cell:
                bad.append(f"{dnum} 独立行同时有边")
            if "独立｜理由" not in cell:
                bad.append(f"{dnum} 独立未举证（缺 独立｜理由…「失败类」）")
            edges[dnum] = []
            continue
        parsed = []
        for p in [x.strip() for x in cell.split("；")]:
            m = re.search(r"(同根|互补|冗余)→\s*(D\d\d)", p)
            if not m:
                bad.append(f"{dnum} 边格式非法「{p}」")
                continue
            rel, tgt = m.group(1), m.group(2)
            if tgt not in names:
                bad.append(f"{dnum} 目标不存在「{tgt}」")
                continue
            if tgt == dnum:
                bad.append(f"{dnum} 自指「{tgt}」")
                continue
            parsed.append((rel, tgt))
        edges[dnum] = parsed
    for dnum, es in edges.items():
        for rel, tgt in es:
            if (rel, dnum) not in edges.get(tgt, []):
                bad.append(f"不对称：{dnum} {rel}→{tgt} 但 {tgt} 无反边")
    for dnum, es in edges.items():
        for rel, tgt in es:
            if rel != "冗余":
                continue
            hit = []
            for src in (dnum, tgt):
                sec = secs.get(src, "")
                for field in ("防住过什么", "删掉会怎样", "删之前先找什么反例"):
                    m = re.search(rf"^- {field}：(.+)$", sec, flags=re.M)
                    if m:
                        for w in REBUTTAL:
                            if w in m.group(1):
                                hit.append((src, w))
            if hit and "反证例外" not in cells[dnum] and "反证例外" not in cells[tgt]:
                bad.append(f"冗余反证：{dnum}↔{tgt} 命中反证词 {hit} 但无「反证例外」标注")
    if bad:
        for b in bad:
            print("  BAD:", b)
        print("RESULT=FAIL")
        raise SystemExit(1)
    print("RESULT=PASS")


def cmd_falsifier():
    fb_path = _form_b_arg()
    rows = form_a_rows()
    fb_text = read(fb_path) if fb_path else read(FORM_B)
    secs = form_b_sections_text(fb_text)
    bad = []
    verbatim = 0
    pending = 0
    for i, r in enumerate(rows, 1):
        dnum = f"D{i:02d}"
        cell = r.get("证伪条件", "").strip()
        if not cell:
            bad.append(f"{dnum} 证伪条件空")
            continue
        sec = secs.get(dnum, "")
        if cell.startswith("N/A（待判"):
            pending += 1
            if "不得拍板" not in cell or "｜前置：" not in cell:
                bad.append(f"{dnum} 待判格式不符")
            continue
        m = re.search(r"^- 地板·可缩放：.+$", sec, flags=re.M)
        if not m:
            bad.append(f"{dnum} 形态B地板行缺失")
            continue
        line = m.group(0)
        tail = line.rsplit("；", 1)[1] if "；" in line else line
        tail = tail.rstrip().rstrip("）").strip()
        if tail and tail in cell:
            verbatim += 1
        else:
            bad.append(f"{dnum} 非逐字：表「{cell[:16]}…」末句「{tail[:16]}…」")
    if verbatim != 10:
        bad.append(f"逐字命中={verbatim} 要求 10")
    if pending != 5:
        bad.append(f"待判={pending} 要求 5")
    if bad:
        for b in bad:
            print("  BAD:", b)
        print("RESULT=FAIL")
        raise SystemExit(1)
    print("RESULT=PASS")


def cmd_blindspot_1b():
    text = read(BLINDSPOT_1B) if BLINDSPOT_1B.exists() else ""

    def section(marker):
        m = re.search(re.escape(marker) + r"\n(.*?)(?=\n<!-- |\Z)", text, flags=re.S)
        return m.group(1).strip() if m else ""

    prompt = section("<!-- PROMPT -->")
    answer = section("<!-- RAW-ANSWER -->")
    bad = []
    if "装不下" not in prompt:
        bad.append("PROMPT 段缺「装不下」")
    if "对不对" in prompt or "是否正确" in prompt:
        bad.append("PROMPT 段含「对不对/是否正确」")
    if len(answer) < 500:
        bad.append(f"RAW-ANSWER 长度={len(answer)} < 500")
    if bad:
        print("RESULT=FAIL", bad)
        raise SystemExit(1)
    print("RESULT=PASS")


def main():
    if len(sys.argv) < 2:
        print("usage: verify.py {cost|class3|class2|carriers|types|single-type|floor|blindspot|rows|empty|severity|criterion|cost-tier|graph|falsifier|blindspot-1b}")
        raise SystemExit(2)
    sub = sys.argv[1]
    fn = {
        "cost": cmd_cost,
        "class3": cmd_class3,
        "class2": cmd_class2,
        "carriers": cmd_carriers,
        "types": cmd_types,
        "single-type": cmd_single_type,
        "floor": cmd_floor,
        "blindspot": cmd_blindspot,
        "rows": cmd_rows,
        "empty": cmd_empty,
        "severity": cmd_severity,
        "criterion": cmd_criterion,
        "cost-tier": cmd_cost_tier,
        "graph": cmd_graph,
        "falsifier": cmd_falsifier,
        "blindspot-1b": cmd_blindspot_1b,
    }.get(sub)
    if fn is None:
        print(f"unknown subcommand: {sub}")
        raise SystemExit(2)
    fn()


if __name__ == "__main__":
    main()
