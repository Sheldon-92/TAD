#!/usr/bin/env python3
"""SkillOpt-inspired spike: harvest trace → mine pack-related signals → report.
This is a feasibility SPIKE — proving whether TAD traces contain usable signals
for automatic pack improvement. A negative result (no signal) is valid evidence."""

import json
import glob
import os
import sys
from collections import Counter, defaultdict

TRACE_DIR = ".tad/evidence/traces"
OUTPUT_DIR = ".tad/evidence/spikes/pack-evolve-spike"

# Real trace event types (from TAD trace v2 schema — verified against live traces)
PACK_EVENTS = {"domain_pack_step", "domain_pack_created"}
OUTCOME_EVENTS = {"gate_result", "tool_call_outcome", "task_completed"}
FEEDBACK_EVENTS = {"reflexion_diagnosis", "expert_review_finding"}

ALL_SIGNAL_EVENTS = PACK_EVENTS | OUTCOME_EVENTS | FEEDBACK_EVENTS


def harvest():
    """Read all trace JSONL, extract pack-related and outcome events."""
    events = []
    files_scanned = 0
    lines_scanned = 0
    parse_errors = 0

    for path in sorted(glob.glob(os.path.join(TRACE_DIR, "*.jsonl"))):
        files_scanned += 1
        with open(path) as f:
            for line in f:
                lines_scanned += 1
                line = line.strip()
                if not line:
                    continue
                try:
                    ev = json.loads(line)
                    ev_type = ev.get("type", "")
                    if ev_type in ALL_SIGNAL_EVENTS:
                        ev["_source_file"] = os.path.basename(path)
                        events.append(ev)
                except (json.JSONDecodeError, KeyError):
                    parse_errors += 1
                    continue

    return events, files_scanned, lines_scanned, parse_errors


def mine(events):
    """Analyze events: count by type, identify pack-specific patterns."""
    type_counts = Counter(ev["type"] for ev in events)

    # Extract pack names from domain_pack_step/created events
    # Real trace schema uses "domain" field for pack name (verified against live data)
    pack_mentions = Counter()
    for ev in events:
        if ev["type"] in PACK_EVENTS:
            pack_name = (ev.get("domain") or ev.get("context", {}).get("pack")
                         or ev.get("pack") or ev.get("slug", ""))
            if pack_name:
                pack_mentions[pack_name] += 1

    # Correlate: do outcome/feedback events temporally cluster near pack events?
    pack_dates = defaultdict(set)
    outcome_dates = defaultdict(set)
    for ev in events:
        date = ev.get("_source_file", "").replace(".jsonl", "")
        if ev["type"] in PACK_EVENTS:
            pack_dates[date].add(ev.get("context", {}).get("pack", "?"))
        elif ev["type"] in OUTCOME_EVENTS | FEEDBACK_EVENTS:
            outcome_dates[date].add(ev["type"])

    co_occurrence_days = set(pack_dates.keys()) & set(outcome_dates.keys())

    return {
        "type_counts": type_counts,
        "pack_mentions": pack_mentions,
        "co_occurrence_days": len(co_occurrence_days),
        "total_days_with_pack": len(pack_dates),
        "total_days_with_outcome": len(outcome_dates),
    }


def report(analysis, files_scanned, lines_scanned, parse_errors):
    """Write spike findings to markdown report."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    tc = analysis["type_counts"]
    pm = analysis["pack_mentions"]

    with open(os.path.join(OUTPUT_DIR, "spike-report.md"), "w") as f:
        f.write("# Pack-Evolve Spike Report\n\n")
        f.write(f"**Scan**: {files_scanned} trace files, {lines_scanned} lines, "
                f"{parse_errors} parse errors\n\n")

        if not tc:
            f.write("## Finding: NO pack-related signals in traces\n\n")
            f.write("The current trace schema (v2) does not emit pack-usage events.\n")
            f.write("**Prerequisite for auto-evolve**: add trace emission for "
                    "pack loading + outcome.\n")
        else:
            total = sum(tc.values())
            f.write(f"## Signal Summary ({total} relevant events)\n\n")

            f.write("### Event Type Distribution\n\n")
            f.write("| Event Type | Count | Category |\n")
            f.write("|-----------|-------|----------|\n")
            for t, c in tc.most_common():
                cat = ("pack" if t in PACK_EVENTS
                       else "outcome" if t in OUTCOME_EVENTS
                       else "feedback")
                f.write(f"| {t} | {c} | {cat} |\n")

            f.write("\n### Pack Mentions\n\n")
            if pm:
                for name, count in pm.most_common():
                    f.write(f"- **{name}**: {count} events\n")
            else:
                f.write("No pack names extracted from events "
                        "(events exist but lack pack identifier in context).\n")

            f.write(f"\n### Temporal Co-occurrence\n\n")
            f.write(f"- Days with pack events: {analysis['total_days_with_pack']}\n")
            f.write(f"- Days with outcome/feedback events: {analysis['total_days_with_outcome']}\n")
            f.write(f"- Days with BOTH (co-occurrence): {analysis['co_occurrence_days']}\n")

            # Feasibility assessment
            f.write("\n## Feasibility Assessment\n\n")
            pack_count = sum(1 for t in tc if t in PACK_EVENTS)
            outcome_count = sum(1 for t in tc if t in OUTCOME_EVENTS | FEEDBACK_EVENTS)

            if pack_count > 0 and outcome_count > 0 and analysis["co_occurrence_days"] > 0:
                f.write("**SIGNAL PRESENT**: Pack events and outcome/feedback events "
                        "co-occur on the same days. An auto-evolve pipeline could:\n")
                f.write("1. Identify which packs were active during failed/successful outcomes\n")
                f.write("2. Correlate expert_review_finding severity with pack rules in use\n")
                f.write("3. Generate candidate edits for packs with high failure correlation\n\n")
                f.write("**Next step**: Build a correlation engine that links "
                        "`domain_pack_step` → `gate_result`/`expert_review_finding` "
                        "chains and proposes rule modifications.\n")
            elif pack_count > 0 and outcome_count == 0:
                f.write("**PARTIAL SIGNAL**: Pack events exist but no outcome/feedback events "
                        "to correlate with. Cannot determine if pack rules helped or hurt.\n")
                f.write("**Prerequisite**: Ensure gate_result and expert_review_finding "
                        "events are emitted consistently.\n")
            elif pack_count == 0 and outcome_count > 0:
                f.write("**PARTIAL SIGNAL**: Outcome/feedback events exist but no pack events. "
                        "Cannot attribute outcomes to specific packs.\n")
                f.write("**Prerequisite**: Ensure domain_pack_step events are emitted "
                        "when packs are loaded.\n")
            else:
                f.write("**NO USABLE SIGNAL**: Neither pack nor outcome events found.\n")

    report_path = os.path.join(OUTPUT_DIR, "spike-report.md")
    print(f"Report written to {report_path}")
    return report_path


if __name__ == "__main__":
    events, files_scanned, lines_scanned, parse_errors = harvest()
    analysis = mine(events)
    report(analysis, files_scanned, lines_scanned, parse_errors)
