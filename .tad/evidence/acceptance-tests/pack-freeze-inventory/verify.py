#!/usr/bin/env python3
"""Gate 3 Methods for TASK-20260910-PACK-FREEZE-INVENTORY. Run: python3 verify.py AC1"""
from __future__ import annotations

import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[4]
os.chdir(ROOT)

FREEZE = set(
    "academic-research agent-memory ai-guardrails ai-podcast-production ai-voice-production "
    "data-engineering knowledge-graph llm-observability ml-training product-thinking "
    "rag-retrieval research-methodology synthetic-data video-creation".split()
)
KEEP = set(
    "agent-orchestration ai-agent-architecture ai-evaluation ai-prompt-engineering "
    "ai-tool-integration code-security web-backend web-deployment web-frontend "
    "web-testing web-ui-design".split()
)
ALLOW = {f".tad/capability-packs/{n}/CAPABILITY.md" for n in FREEZE}
ALLOW.add(".tad/capability-packs/pack-registry.yaml")
AGENTS_FREEZE_ROWS = (
    "video-creation knowledge-graph academic-research ai-podcast-production "
    "ai-voice-production ml-training data-engineering product-thinking agent-memory "
    "llm-observability ai-guardrails rag-retrieval synthetic-data".split()
)


def first_fence(path: pathlib.Path) -> str:
    t = path.read_text()
    if not t.startswith("---\n"):
        raise SystemExit(f"no fm {path}")
    end = t.find("\n---\n", 4)
    return t[4:end], t[end + 5 :]


def impl_names() -> list[str]:
    sha = os.environ.get("IMPL_SHA") or subprocess.check_output(
        ["git", "rev-parse", "HEAD"], text=True
    ).strip()
    out = subprocess.check_output(
        ["git", "diff-tree", "--no-commit-id", "--name-only", "-r", sha], text=True
    )
    return [l for l in out.splitlines() if l]


def ac1() -> None:
    got = set()
    for p in pathlib.Path(".tad/capability-packs").glob("*/CAPABILITY.md"):
        fm, _ = first_fence(p)
        if re.search(r"^status: frozen$", fm, re.M):
            got.add(p.parent.name)
    print(sorted(got))
    print("OK" if got == FREEZE else "FAIL")
    raise SystemExit(0 if got == FREEZE else 1)


def ac2() -> None:
    bad = []
    for n in sorted(KEEP):
        fm, _ = first_fence(pathlib.Path(".tad/capability-packs") / n / "CAPABILITY.md")
        if re.search(r"^status: frozen$", fm, re.M):
            bad.append(n)
    print("bad", bad)
    print("OK" if not bad else "FAIL")
    raise SystemExit(0 if not bad else 1)


def ac3() -> None:
    y = pathlib.Path(".tad/capability-packs/pack-registry.yaml").read_text()
    names = re.findall(r'^\s+- name: "([^"]+)"', y, re.M)
    st = re.findall(r'^\s+status: "([^"]+)"$', y, re.M)
    fz = {n for n, s in zip(names, st) if s == "frozen"}
    ac = {n for n, s in zip(names, st) if s == "active"}
    print(len(names), len(st), len(fz), len(ac))
    ok = fz == FREEZE and ac == KEEP and len(names) == 25 and len(st) == 25
    print("OK" if ok else "FAIL")
    raise SystemExit(0 if ok else 1)


def ac4() -> None:
    y = pathlib.Path(".tad/capability-packs/pack-registry.yaml").read_text()
    a = len(re.findall(r"^\s+- name: ", y, re.M))
    b = len(re.findall(r"^\s+keywords: ", y, re.M))
    print(a, b)
    raise SystemExit(0 if (a, b) == (25, 25) else 1)


def ac5() -> None:
    names = impl_names()
    bad = [
        n
        for n in names
        if "/SKILL.md" in n or n.startswith(".claude/skills/") or n.startswith(".agents/skills/")
    ]
    print("BAD", bad)
    ok = bool(names) and not bad
    print("OK" if ok else "FAIL")
    raise SystemExit(0 if ok else 1)


def ac6() -> None:
    sha = os.environ.get("IMPL_SHA") or subprocess.check_output(
        ["git", "rev-parse", "HEAD"], text=True
    ).strip()
    d = subprocess.check_output(
        ["git", "diff-tree", "--diff-filter=D", "--no-commit-id", "--name-only", "-r", sha],
        text=True,
    ).splitlines()
    d = [x for x in d if x]
    print(d)
    print("OK" if not d else "FAIL")
    raise SystemExit(0 if not d else 1)


def ac7() -> None:
    names = impl_names()
    keep_paths = {f".tad/capability-packs/{k}/CAPABILITY.md" for k in KEEP}
    bad = [n for n in names if n in keep_paths]
    print("BAD", bad)
    print("OK" if not bad else "FAIL")
    raise SystemExit(0 if not bad else 1)


def ac8() -> None:
    names = impl_names()
    forb = (
        "scan-packs.sh",
        "AGENTS.md",
        "CLAUDE.md",
        "tad.sh",
        "principles.md",
        "experiment-path-protocol.md",
    )
    bad = [n for n in names if n.endswith(forb) or n.startswith(".tad/hooks/")]
    print("BAD", bad)
    print("OK" if not bad else "FAIL")
    raise SystemExit(0 if not bad else 1)


def ac9() -> None:
    text = pathlib.Path("AGENTS.md").read_text().splitlines()

    def hit(n: str) -> int:
        return sum(1 for l in text if l.startswith("| " + n + " "))

    print("rm", hit("research-methodology"), "aci", hit("agent-computer-interface"))
    ok = (
        all(hit(n) == 1 for n in AGENTS_FREEZE_ROWS + list(KEEP))
        and hit("research-methodology") == 0
        and hit("agent-computer-interface") == 1
    )
    print("OK" if ok else "FAIL")
    raise SystemExit(0 if ok else 1)


def ac10() -> None:
    names = impl_names()
    extra = [n for n in names if n not in ALLOW]
    missing = [p for p in sorted(ALLOW) if p not in names]
    print("extra", extra)
    print("missing", missing)
    ok = bool(names) and not extra and not missing
    print("OK" if ok else "FAIL")
    raise SystemExit(0 if ok else 1)


def ac11() -> None:
    needle = "equals " + chr(96) + "frozen" + chr(96)
    ps = [
        ".claude/skills/alex/references/intent-router-protocol.md",
        ".agents/skills/alex/references/intent-router-protocol.md",
    ]
    ok = all(needle in pathlib.Path(p).read_text() for p in ps)
    print("OK" if ok else "FAIL")
    raise SystemExit(0 if ok else 1)


def ac12() -> None:
    bad = []
    for n in FREEZE:
        _, body = first_fence(pathlib.Path(".tad/capability-packs") / n / "CAPABILITY.md")
        if re.search(r"^status: frozen$", body, re.M):
            bad.append(n)
    print("BAD", bad)
    print("OK" if not bad else "FAIL")
    raise SystemExit(0 if not bad else 1)


ACS = {
    "AC1": ac1,
    "AC2": ac2,
    "AC3": ac3,
    "AC4": ac4,
    "AC5": ac5,
    "AC6": ac6,
    "AC7": ac7,
    "AC8": ac8,
    "AC9": ac9,
    "AC10": ac10,
    "AC11": ac11,
    "AC12": ac12,
}


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in ACS:
        print("usage: verify.py AC1..AC12", file=sys.stderr)
        raise SystemExit(2)
    ACS[sys.argv[1]]()


if __name__ == "__main__":
    main()
