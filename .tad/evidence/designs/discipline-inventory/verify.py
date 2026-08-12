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


def main():
    if len(sys.argv) < 2:
        print("usage: verify.py {cost|class3|class2|carriers|types|single-type|floor|blindspot|rows}")
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
    }.get(sub)
    if fn is None:
        print(f"unknown subcommand: {sub}")
        raise SystemExit(2)
    fn()


if __name__ == "__main__":
    main()
