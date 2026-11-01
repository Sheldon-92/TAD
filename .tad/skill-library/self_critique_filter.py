#!/usr/bin/env python3
"""Self-critique pipeline filter + run log (see self-critique-pipeline.md).

Usage:
    python3 self_critique_filter.py --batch <run-dir> --ship-dir <dir>

The batch dir must contain:
    candidates/<slug>.md   one file per generated candidate
    critiques.json         {"rubric_version": "v1",
                            "candidates": {"<slug>": {"criteria":
                              {"C1": {"verdict": "pass"|"fail",
                                      "finding": "..."}, ...}}}}

The script validates the batch, applies the pass rule (all criteria pass),
copies passing candidates to the ship dir, and writes run-log.json and
run-log.md into the batch dir. It never edits candidates or critiques.

Exit codes: 0 = batch processed (drops are a normal outcome);
            2 = batch malformed (nothing shipped).
"""
import argparse
import json
import shutil
import sys
from pathlib import Path

CRITERIA = ["C1", "C2", "C3", "C4", "C5", "C6"]


def fail(msg):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(2)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--batch", required=True, help="run directory")
    ap.add_argument("--ship-dir", required=True,
                    help="directory passing candidates are copied to")
    args = ap.parse_args()

    batch = Path(args.batch)
    cand_dir = batch / "candidates"
    crit_path = batch / "critiques.json"
    if not cand_dir.is_dir():
        fail(f"missing candidates dir: {cand_dir}")
    if not crit_path.is_file():
        fail(f"missing critiques file: {crit_path}")

    candidates = sorted(p.stem for p in cand_dir.glob("*.md"))
    if not candidates:
        fail("no candidate files found")
    critiques = json.loads(crit_path.read_text(encoding="utf-8"))
    rubric_version = critiques.get("rubric_version", "unknown")
    crit = critiques.get("candidates", {})

    errors = []
    for slug in candidates:
        entry = crit.get(slug)
        if entry is None:
            errors.append(f"{slug}: no critique entry")
            continue
        scored = entry.get("criteria", {})
        for c in CRITERIA:
            cell = scored.get(c)
            if cell is None:
                errors.append(f"{slug}: criterion {c} not scored")
            elif cell.get("verdict") not in ("pass", "fail"):
                errors.append(f"{slug}: criterion {c} verdict malformed: "
                              f"{cell.get('verdict')!r}")
            elif not str(cell.get("finding", "")).strip():
                errors.append(f"{slug}: criterion {c} finding empty")
    for slug in crit:
        if slug not in candidates:
            errors.append(f"critique for unknown candidate: {slug}")
    if errors:
        for e in errors:
            print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(2)

    ship_dir = Path(args.ship_dir)
    ship_dir.mkdir(parents=True, exist_ok=True)

    results = {}
    shipped = []
    for slug in candidates:
        scored = crit[slug]["criteria"]
        verdicts = {c: scored[c]["verdict"] for c in CRITERIA}
        passed = all(v == "pass" for v in verdicts.values())
        results[slug] = {
            "passed": passed,
            "criteria": {c: {"verdict": scored[c]["verdict"],
                             "finding": scored[c]["finding"]}
                         for c in CRITERIA},
        }
        if passed:
            shutil.copy2(cand_dir / f"{slug}.md", ship_dir / f"{slug}.md")
            shipped.append(slug)

    n, m = len(candidates), len(shipped)
    log = {
        "batch": batch.name,
        "rubric_version": rubric_version,
        "generated": n,
        "shipped": m,
        "keep_ratio": round(m / n, 3) if n else 0,
        "ship_list": shipped,
        "results": results,
    }
    (batch / "run-log.json").write_text(
        json.dumps(log, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8")

    lines = [f"# Run log — {batch.name}", "",
             f"Rubric: {rubric_version}  ·  generated: {n}  ·  "
             f"shipped: {m}  ·  keep ratio: {m}/{n} = {m / n:.2f}", ""]
    for slug in candidates:
        r = results[slug]
        lines.append(f"## {slug} — {'SHIP' if r['passed'] else 'DROP'}")
        for c in CRITERIA:
            cell = r["criteria"][c]
            lines.append(f"- {c} {cell['verdict']}: {cell['finding']}")
        lines.append("")
    (batch / "run-log.md").write_text("\n".join(lines), encoding="utf-8")

    print(f"batch={batch.name} rubric={rubric_version} generated={n} "
          f"shipped={m} keep_ratio={m}/{n}={m / n:.2f}")
    print("ship_list: " + (", ".join(shipped) if shipped else "(none)"))
    for slug in candidates:
        if not results[slug]["passed"]:
            fails = [c for c in CRITERIA
                     if results[slug]["criteria"][c]["verdict"] == "fail"]
            print(f"drop: {slug} (failed: {', '.join(fails)})")


if __name__ == "__main__":
    main()
