#!/usr/bin/env python3
"""Alex-owned Gate 3 runner for TASK-20260911-KEEP11-KNIFE1. Not in Blake impl commit."""
from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(
    subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()
)
BANNER = re.compile(r"Verified against .+ on (20\d{2}-\d{2}-\d{2})")
MIN_DATE = "2026-09-11"
OLD_SHA = "b4ffde65f46336ab88eb53be808477a3936bae11"
STALE_DEADLINE = "2026-05-20"

ALLOW_PREFIXES = (
    ".claude/skills/code-security/",
    ".agents/skills/code-security/",
    ".tad/capability-packs/code-security/",
    ".claude/skills/web-deployment/",
    ".agents/skills/web-deployment/",
    ".tad/capability-packs/web-deployment/",
)

CS_REFS = [
    "references/sast-rules.md",
    "references/dast-rules.md",
    "references/secret-detection-rules.md",
    "references/iac-security-rules.md",
    "references/vulnerability-triage-rules.md",
]
WD_REFS = [
    "references/ci-cd-pipeline-rules.md",
    "references/environment-config-rules.md",
    "references/security-hardening-rules.md",
    "references/platform-selection-rules.md",
    "references/rollback-rules.md",
    "references/domain-dns-rules.md",
    "references/monitoring-rules.md",
]

BANNER_REL = (
    [".claude/skills/code-security/SKILL.md"]
    + [f".claude/skills/code-security/{r}" for r in CS_REFS]
    + [".claude/skills/web-deployment/SKILL.md"]
    + [f".claude/skills/web-deployment/{r}" for r in WD_REFS]
)

FORBIDDEN_SNIPS = (
    "experiment-path-protocol.md",
    "pack-registry.yaml",
    "intent-router-protocol.md",
    "AGENTS.md",
    "CLAUDE.md",
)


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)


def impl_sha() -> str:
    return os.environ.get("IMPL_SHA") or git("rev-parse", "HEAD").strip()


def fail(msg: str) -> None:
    print(msg)
    print("FAIL")
    sys.exit(1)


def ok(msg: str) -> None:
    print(msg)
    print("OK")


def live_checkout_sha() -> str:
    script = ROOT / ".claude/skills/web-deployment/scripts/find-action-sha.sh"
    out = subprocess.check_output(
        ["bash", str(script), "actions/checkout", "v4.1.7"],
        cwd=ROOT,
        text=True,
    )
    sha = out.strip().splitlines()[0]
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        fail(f"find-action-sha bad output {sha!r}")
    return sha


def ac1() -> None:
    missing = []
    stale = []
    for rel in BANNER_REL:
        p = ROOT / rel
        text = p.read_text(encoding="utf-8") if p.exists() else ""
        m = BANNER.search(text)
        if not m:
            missing.append(rel)
            continue
        if m.group(1) < MIN_DATE:
            stale.append(f"{rel}:{m.group(1)}")
    print("missing", missing)
    print("stale", stale)
    if missing or stale:
        fail("banner missing or older than MIN_DATE")
    ok("banners")


def ac2() -> None:
    twins = [
        (
            ".claude/skills/code-security/" + s,
            ".agents/skills/code-security/" + s,
        )
        for s in ["SKILL.md"] + CS_REFS
    ] + [
        (
            ".claude/skills/web-deployment/" + s,
            ".agents/skills/web-deployment/" + s,
        )
        for s in ["SKILL.md"] + WD_REFS
    ]
    bad = []
    for a, b in twins:
        pa, pb = ROOT / a, ROOT / b
        if not pa.is_file() or not pb.is_file():
            bad.append(f"missing:{a}")
            continue
        if pa.read_bytes() != pb.read_bytes():
            bad.append(a)
    print("drift", bad)
    if bad:
        fail("claude/agents drift")
    ok("parity")


def ac3() -> None:
    hits = []
    for prefix in (
        ".claude/skills/web-deployment/",
        ".agents/skills/web-deployment/",
        ".tad/capability-packs/web-deployment/",
    ):
        d = ROOT / prefix
        if not d.exists():
            continue
        for p in d.rglob("*.md"):
            if OLD_SHA in p.read_text(encoding="utf-8"):
                hits.append(str(p.relative_to(ROOT)))
    print("old_sha", hits)
    if hits:
        fail("rotten checkout SHA still present")
    want = live_checkout_sha()
    pin_files = [
        ".claude/skills/web-deployment/references/ci-cd-pipeline-rules.md",
        ".agents/skills/web-deployment/references/ci-cd-pipeline-rules.md",
        ".tad/capability-packs/web-deployment/references/ci-cd-pipeline-rules.md",
        ".claude/skills/web-deployment/SKILL.md",
        ".agents/skills/web-deployment/SKILL.md",
        ".tad/capability-packs/web-deployment/CAPABILITY.md",
    ]
    absent = []
    for rel in pin_files:
        p = ROOT / rel
        text = p.read_text(encoding="utf-8") if p.is_file() else ""
        if want not in text:
            absent.append(rel)
    print("live_sha", want)
    print("missing_live_sha", absent)
    if absent:
        fail("live checkout SHA not pinned")
    ok("sha")


def ac4() -> None:
    paths = [
        ".claude/skills/web-deployment/references/ci-cd-pipeline-rules.md",
        ".agents/skills/web-deployment/references/ci-cd-pipeline-rules.md",
        ".tad/capability-packs/web-deployment/references/ci-cd-pipeline-rules.md",
    ]
    bad = []
    for rel in paths:
        p = ROOT / rel
        if not p.is_file():
            bad.append(f"missing:{rel}")
            continue
        for line in p.read_text(encoding="utf-8").splitlines():
            if line.startswith("| CI6 |") and "@v4" in line:
                bad.append(rel)
    print("ci6_bad", bad)
    if bad:
        fail("CI6 still teaches @v4")
    print("CI6_ok")
    ok("ci6")


def ac5() -> None:
    paths = [
        ".claude/skills/code-security/references/vulnerability-triage-rules.md",
        ".agents/skills/code-security/references/vulnerability-triage-rules.md",
        ".tad/capability-packs/code-security/references/vulnerability-triage-rules.md",
    ]
    bad = []
    for rel in paths:
        p = ROOT / rel
        if not p.is_file():
            bad.append(f"missing:{rel}")
            continue
        n = p.read_text(encoding="utf-8").count(STALE_DEADLINE)
        if n:
            bad.append(f"{rel}:{n}")
    print("stale_deadline", bad)
    if bad:
        fail("2026-05-20 still in triage table")
    ok("deadline")


def ac6() -> None:
    sha = impl_sha()
    names = [
        n
        for n in git("diff-tree", "--no-commit-id", "--name-only", "-r", sha).splitlines()
        if n
    ]
    extra = [n for n in names if not n.startswith(ALLOW_PREFIXES)]
    print("names", names)
    print("extra", extra)
    if extra:
        fail("pathspec extra")
    if not names:
        fail("empty impl commit")
    ok("pathspec")


def ac7() -> None:
    sha = impl_sha()
    names = git("diff-tree", "--no-commit-id", "--name-only", "-r", sha)
    bad = [s for s in FORBIDDEN_SNIPS if s in names]
    print("forbidden", bad)
    if bad:
        fail("forbidden path")
    ok("forbidden")


def ac8() -> None:
    inv = ROOT / ".tad/evidence/acceptance-tests/keep11-knife1/cli-inventory.md"
    if not inv.is_file():
        fail("inventory missing")
    text = inv.read_text(encoding="utf-8")
    if "gitleaks" not in text or "actions/checkout" not in text:
        fail("inventory too thin")
    if "ABSENT" not in text:
        fail("inventory missing ABSENT column/status")
    if "http" not in text and "PATH" not in text:
        fail("inventory missing PATH or docs URL")
    print("inventory_bytes", inv.stat().st_size)
    ok("inventory")


def ac9() -> None:
    bad = []
    pairs = [
        (f".claude/skills/code-security/{r}", f".tad/capability-packs/code-security/{r}")
        for r in CS_REFS
    ] + [
        (f".claude/skills/web-deployment/{r}", f".tad/capability-packs/web-deployment/{r}")
        for r in WD_REFS
    ]
    for a, b in pairs:
        pa, pb = ROOT / a, ROOT / b
        if not pb.is_file():
            continue
        if not pa.is_file() or pa.read_bytes() != pb.read_bytes():
            bad.append(a)
    print("cappack_drift", bad)
    if bad:
        fail("capability-packs references drift")
    ok("cappack")


def main() -> None:
    ac = sys.argv[1] if len(sys.argv) > 1 else ""
    table = {
        "AC1": ac1,
        "AC2": ac2,
        "AC3": ac3,
        "AC4": ac4,
        "AC5": ac5,
        "AC6": ac6,
        "AC7": ac7,
        "AC8": ac8,
        "AC9": ac9,
    }
    if ac not in table:
        fail("usage: verify.py AC1..AC9")
    table[ac]()


if __name__ == "__main__":
    main()
