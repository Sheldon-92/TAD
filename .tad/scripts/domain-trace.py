#!/usr/bin/env python3
# ===========================================================================
# domain-trace.py — Stage 1 execution-trace recorder for Domain Pack runs
# ===========================================================================
# Origin: IDEA-20260402-self-evolving-domain-pack, Stage 1 ONLY
# (trace recording infrastructure). Stage 2 (failure-pattern aggregation)
# and Stage 3 (step-design auto-optimization) are NOT implemented here.
#
# What it does:
#   Records one JSONL event per executed pack step to
#     .tad/evidence/domain-traces/{domain}/{YYYY-MM-DD}.jsonl
#   (repo root is derived from this file's location, never from CWD).
#
# Event schema (one JSON object per line):
#   ts             UTC ISO-8601, second precision ("2026-10-31T10:12:00Z")
#   domain         pack slug (e.g. "hw-testing", "agent-memory")
#   run_id         groups the steps of one run
#   step_id        step / fixture / assertion identifier within the run
#   tool_calls     list of strings: the tool/command invocations of the step
#   duration_ms    integer wall-clock duration of the step
#   success        boolean (true only when status == "success")
#   status         "success" | "failure" | "skipped"
#   failure_reason string for failure/skipped, null for success
#
# Subcommands:
#   run    --domain D --step S [--run-id R] -- <cmd...>
#          Execute <cmd> timed, record the step, exit with <cmd>'s code.
#          This is the wired path for shell-executed pack steps.
#   record --domain D --step S --status success|failure|skipped
#          --duration-ms N [--run-id R] [--tool CALL]... [--failure-reason X]
#          Append one event directly (used by pack-eval-runner.sh, which
#          emits observationally per assertion — the agent does not have
#          to remember anything).
#   validate [--domain D]
#          Check every recorded line parses and carries the schema fields
#          with consistent values. Exit 0 = all conform, 1 = violations.
#
# Stdlib only. Recording NEVER raises into a caller's run: `record` exits
# non-zero on bad input (a programming error), but wired callers invoke it
# guarded (`|| true`) so a recorder fault cannot fail a pack run.
# ===========================================================================

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone

STATUSES = ("success", "failure", "skipped")
REQUIRED_FIELDS = (
    "ts", "domain", "run_id", "step_id", "tool_calls",
    "duration_ms", "success", "status", "failure_reason",
)


def repo_root():
    # <root>/.tad/scripts/domain-trace.py -> <root>
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.dirname(os.path.dirname(here))


def traces_root(root):
    return os.path.join(root, ".tad", "evidence", "domain-traces")


def utc_now():
    return datetime.now(timezone.utc)


def iso_z(dt):
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def default_run_id():
    return "run-%s-%d" % (utc_now().strftime("%Y%m%dT%H%M%SZ"), os.getpid())


def append_event(root, event):
    day = event["ts"][:10]
    path = os.path.join(traces_root(root), event["domain"], day + ".jsonl")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(event, ensure_ascii=False) + "\n")
    return path


def make_event(domain, run_id, step_id, tool_calls, duration_ms, status,
               failure_reason):
    if status not in STATUSES:
        raise ValueError("status must be one of %s" % (STATUSES,))
    success = status == "success"
    if success:
        failure_reason = None
    elif not failure_reason:
        failure_reason = "unspecified"
    return {
        "ts": iso_z(utc_now()),
        "domain": domain,
        "run_id": run_id,
        "step_id": step_id,
        "tool_calls": list(tool_calls),
        "duration_ms": int(duration_ms),
        "success": success,
        "status": status,
        "failure_reason": failure_reason,
    }


def cmd_record(args):
    event = make_event(
        domain=args.domain,
        run_id=args.run_id or default_run_id(),
        step_id=args.step,
        tool_calls=args.tool or [],
        duration_ms=args.duration_ms,
        status=args.status,
        failure_reason=args.failure_reason,
    )
    path = append_event(repo_root(), event)
    print(path)
    return 0


def cmd_run(args):
    if not args.cmd:
        print("error: run requires -- <cmd...>", file=sys.stderr)
        return 2
    tool_str = " ".join(args.cmd)
    start = time.monotonic()
    proc = subprocess.run(args.cmd, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE)
    duration_ms = int((time.monotonic() - start) * 1000)
    # Replay the wrapped command's streams verbatim (transparency).
    sys.stdout.write(proc.stdout.decode("utf-8", "replace"))
    sys.stdout.flush()
    sys.stderr.write(proc.stderr.decode("utf-8", "replace"))
    sys.stderr.flush()
    if proc.returncode == 0:
        status, reason = "success", None
    else:
        tail = proc.stderr.decode("utf-8", "replace").strip().splitlines()
        detail = tail[-1][:300] if tail else ""
        reason = "exit_code %d" % proc.returncode
        if detail:
            reason += ": " + detail
        status = "failure"
    event = make_event(
        domain=args.domain,
        run_id=args.run_id or default_run_id(),
        step_id=args.step,
        tool_calls=[tool_str],
        duration_ms=duration_ms,
        status=status,
        failure_reason=reason,
    )
    append_event(repo_root(), event)
    return proc.returncode


def validate_file(path, problems):
    n = 0
    with open(path, encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            line = line.strip()
            if not line:
                continue
            n += 1
            where = "%s:%d" % (path, lineno)
            try:
                ev = json.loads(line)
            except json.JSONDecodeError as exc:
                problems.append("%s: unparseable JSON (%s)" % (where, exc))
                continue
            for field in REQUIRED_FIELDS:
                if field not in ev:
                    problems.append("%s: missing field %r" % (where, field))
            if not isinstance(ev.get("tool_calls"), list):
                problems.append("%s: tool_calls is not a list" % where)
            if not isinstance(ev.get("duration_ms"), int) \
                    or ev.get("duration_ms", -1) < 0:
                problems.append("%s: duration_ms not a non-negative int"
                                % where)
            if ev.get("status") not in STATUSES:
                problems.append("%s: status %r not in %s"
                                % (where, ev.get("status"), STATUSES))
            if ev.get("success") != (ev.get("status") == "success"):
                problems.append("%s: success flag inconsistent with status"
                                % where)
            if ev.get("status") == "success" \
                    and ev.get("failure_reason") is not None:
                problems.append("%s: success event carries failure_reason"
                                % where)
            if ev.get("status") in ("failure", "skipped") \
                    and not ev.get("failure_reason"):
                problems.append("%s: non-success event lacks failure_reason"
                                % where)
    return n


def cmd_validate(args):
    root = traces_root(repo_root())
    problems = []
    total = 0
    files = []
    if not os.path.isdir(root):
        print("no domain-traces directory yet: %s" % root)
        return 0
    for dirpath, _dirnames, filenames in os.walk(root):
        for name in sorted(filenames):
            if not name.endswith(".jsonl"):
                continue
            if args.domain and os.path.basename(dirpath) != args.domain:
                continue
            files.append(os.path.join(dirpath, name))
    for path in sorted(files):
        n = validate_file(path, problems)
        total += n
        print("%s: %d events" % (os.path.relpath(path, repo_root()), n))
    if problems:
        for p in problems:
            print("VIOLATION: " + p)
        print("validate: FAIL (%d events, %d violations)"
              % (total, len(problems)))
        return 1
    print("validate: OK (%d events, %d files, 0 violations)"
          % (total, len(files)))
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="domain-trace.py",
        description="Stage 1 execution-trace recorder for Domain Pack runs")
    sub = parser.add_subparsers(dest="subcommand", required=True)

    p_rec = sub.add_parser("record", help="append one trace event")
    p_rec.add_argument("--domain", required=True)
    p_rec.add_argument("--step", required=True)
    p_rec.add_argument("--status", required=True, choices=STATUSES)
    p_rec.add_argument("--duration-ms", required=True, type=int)
    p_rec.add_argument("--run-id")
    p_rec.add_argument("--tool", action="append", default=[])
    p_rec.add_argument("--failure-reason")
    p_rec.set_defaults(func=cmd_record)

    p_run = sub.add_parser("run", help="execute a step timed and record it")
    p_run.add_argument("--domain", required=True)
    p_run.add_argument("--step", required=True)
    p_run.add_argument("--run-id")
    p_run.add_argument("cmd", nargs=argparse.REMAINDER)
    p_run.set_defaults(func=cmd_run)

    p_val = sub.add_parser("validate", help="schema-check recorded traces")
    p_val.add_argument("--domain")
    p_val.set_defaults(func=cmd_validate)

    args = parser.parse_args(argv)
    if args.subcommand == "run" and args.cmd and args.cmd[0] == "--":
        args.cmd = args.cmd[1:]
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
