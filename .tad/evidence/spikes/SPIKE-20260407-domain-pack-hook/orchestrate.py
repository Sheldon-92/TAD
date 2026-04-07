#!/usr/bin/env python3
"""SPIKE-20260407 orchestrator — runs all 18 cases through run-spike.sh
and assembles results.json per HANDOFF Component 5 schema.

This is intentionally a separate script (not embedded in run-spike.sh) to keep
the bash runner shell-pure and BSD-portable. Python handles the JSON assembly,
metric calculation, and per-case loop.
"""

import json
import subprocess
import sys
import time
from pathlib import Path

import yaml

SPIKE_DIR = Path(__file__).resolve().parent
RUNNER = SPIKE_DIR / "run-spike.sh"
TEST_CASES = SPIKE_DIR / "test-cases.yaml"
RESULTS = SPIKE_DIR / "results.json"


def run_single_case(message: str) -> dict:
    """Invoke run-spike.sh single <message>; parse JSON output."""
    result = subprocess.run(
        [str(RUNNER), "single", message],
        capture_output=True,
        text=True,
        timeout=120,
    )
    if result.returncode != 0:
        return {
            "subprocess_error": True,
            "stderr": result.stderr[:500],
            "stdout": result.stdout[:500],
        }
    # The runner prints JSON on the last non-empty line
    lines = [ln for ln in result.stdout.strip().splitlines() if ln.strip()]
    if not lines:
        return {"subprocess_error": True, "reason": "empty stdout"}
    try:
        return json.loads(lines[-1])
    except Exception as e:
        return {
            "subprocess_error": True,
            "parse_error": str(e),
            "raw_stdout": result.stdout[:1000],
        }


def evaluate_case(case: dict, response: dict) -> dict:
    """Build the per-case results.json record."""
    expected = case["expected"]
    parsed = response.get("parsed_envelope") or {}
    matched_packs = parsed.get("matched_packs") or []
    actual_match = bool(matched_packs)

    # If parsing failed, treat as a parse_failure (not classification error per AC13)
    parse_ok = response.get("parse_ok", False)
    if response.get("subprocess_error"):
        parse_ok = False
        actual_match = False

    correct = (actual_match == expected) if parse_ok else None  # None = parse failure

    # Cost via OAuth proxy is inflated; record it as-is and document caveat in report
    return {
        "id": case["id"],
        "message": case["message"],
        "expected": expected,
        "label_confidence": case.get("label_confidence", "high"),
        "category": case["category"],
        "raw_response": response.get("raw_result_text", ""),
        "parse_ok": parse_ok,
        "matched_packs": matched_packs,
        "actual_match": actual_match,
        "latency_ms": response.get("duration_ms"),
        "api_latency_ms": response.get("duration_api_ms"),
        "wall_latency_ms": response.get("wall_ms_external"),
        "input_tokens": response.get("input_tokens"),
        "output_tokens": response.get("output_tokens"),
        "cache_creation_tokens": response.get("cache_creation"),
        "cost_usd": response.get("cost_usd"),
        "correct": correct,
        "subprocess_error": response.get("subprocess_error", False),
    }


def compute_metrics(records: list) -> dict:
    """Per HANDOFF AC4 — 11 fields including parse_failures + max_latency_ms."""
    total = len(records)
    parse_failures = sum(1 for r in records if not r["parse_ok"])
    correct_records = [r for r in records if r["correct"] is True]
    incorrect_records = [r for r in records if r["correct"] is False]
    high_conf = [r for r in records if r["label_confidence"] == "high"]
    high_conf_correct = [r for r in high_conf if r["correct"] is True]

    false_positives = sum(
        1 for r in records if r["correct"] is False and r["actual_match"] and not r["expected"]
    )
    false_negatives = sum(
        1 for r in records if r["correct"] is False and not r["actual_match"] and r["expected"]
    )

    latencies = [r["latency_ms"] for r in records if isinstance(r["latency_ms"], (int, float))]
    api_latencies = [
        r["api_latency_ms"] for r in records if isinstance(r["api_latency_ms"], (int, float))
    ]
    costs = [r["cost_usd"] for r in records if isinstance(r["cost_usd"], (int, float))]

    return {
        "total_cases": total,
        "path_b_correct": len(correct_records),
        "path_b_accuracy_all": round(len(correct_records) / total, 4) if total else 0,
        "path_b_accuracy_high_confidence_only": (
            round(len(high_conf_correct) / len(high_conf), 4) if high_conf else 0
        ),
        "false_positives": false_positives,
        "false_negatives": false_negatives,
        "parse_failures": parse_failures,
        "mean_latency_ms": round(sum(latencies) / len(latencies)) if latencies else None,
        "max_latency_ms": max(latencies) if latencies else None,
        "mean_api_latency_ms": round(sum(api_latencies) / len(api_latencies)) if api_latencies else None,
        "mean_cost_usd": round(sum(costs) / len(costs), 6) if costs else None,
        "total_cost_usd": round(sum(costs), 6) if costs else None,
        "high_confidence_count": len(high_conf),
        "low_confidence_count": total - len(high_conf),
    }


def main():
    if not TEST_CASES.exists():
        print("ERR: test-cases.yaml not found", file=sys.stderr)
        sys.exit(1)

    with open(TEST_CASES) as f:
        cases = yaml.safe_load(f)["test_cases"]

    print(f"Running {len(cases)} cases via run-spike.sh single (proxy mode)...")
    start = time.time()
    records = []
    for i, case in enumerate(cases, 1):
        t0 = time.time()
        response = run_single_case(case["message"])
        record = evaluate_case(case, response)
        records.append(record)
        elapsed = time.time() - t0
        verdict = "✓" if record["correct"] else ("✗" if record["correct"] is False else "?")
        print(
            f"  [{i:2d}/{len(cases)}] {case['id']} {verdict} "
            f"actual={record['actual_match']} expected={record['expected']} "
            f"({elapsed:.1f}s, {record['output_tokens']}tok out)"
        )

    total_elapsed = time.time() - start
    print(f"\n✅ All cases done in {total_elapsed:.1f}s")

    metrics = compute_metrics(records)

    # Get claude version
    try:
        cv = subprocess.run(["claude", "--version"], capture_output=True, text=True).stdout.strip()
    except Exception:
        cv = "unknown"

    output = {
        "spike_id": "SPIKE-20260407-domain-pack-hook",
        "ran_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "claude_code_version": cv,
        "anthropic_model": "claude-haiku-4-5-20251001",
        "path_b_mode": "proxy_via_claude_p",
        "path_b_mode_caveat": (
            "ANTHROPIC_API_KEY not set; Path B used `claude -p` instead of direct curl. "
            "Latency includes claude CLI process spawn (~300-500ms) and OAuth-tier "
            "prompt-cache creation (~19000 tokens of CLAUDE.md/skills metadata). "
            "Cost figures are OAuth tier accounting, not raw per-token Haiku-4.5 API price. "
            "Accuracy is canonical (same model invoked)."
        ),
        "path_b_results": records,
        "path_a_integration": {
            "executed": False,
            "note": "filled in after Phase 1 manual hook test",
        },
        "metrics": metrics,
        "hook_existence": {
            "user_prompt_submit_event_recognized": None,
            "user_prompt_submit_actually_fires": None,
            "evidence": "filled in after Phase 1 manual hook test",
        },
    }

    with open(RESULTS, "w") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(f"\n📝 Wrote {RESULTS}")
    print("\n=== METRICS ===")
    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
