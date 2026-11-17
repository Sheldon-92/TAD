#!/bin/bash
# intent-route-test.sh - registered regression test for the deterministic
# intent-router pre-pass (.tad/hooks/lib/intent-route.py, the mechanical
# form of intent-router-protocol steps 1 / 1.5 / 2).
#
# Registered by HANDOFF-20261106-sp2-row9-intent-router.md (TASK-20261106-019).
# Entry points: the `intent-route-test` block in .tad/tests/run-all.sh,
# or direct: bash .tad/tests/intent-route-test.sh   (no arguments)
#
# FIXTURE PROVENANCE AND UPDATE DISCIPLINE
#   The sample set is .tad/tests/fixtures/intent-route-samples.json, the
#   registered copy. It is a byte-identical copy of the evidence original
#   .tad/evidence/surplus-phase2-20261031/deterministic-rules-over-llm/samples.json
#   (sha256 prefix 43a76c3ab2dfdbf0, 4,380 bytes, 38 samples, dual labels
#   spec/semantic). The evidence original is the provenance record and is
#   never edited by this test; this registered copy is the consumed one.
#   Changing the samples requires a named reason inside the change chain
#   plus a sync of the HANDOFF anchor table and of the expected counts
#   below (38 samples / 30 deterministically decided; the semantic
#   baseline 32/35 is a recorded measurement, report-only). Never relabel
#   a sample to suit the implementation - the 2026-10-31 sample #21 label
#   correction is the precedent: a label change leaves a trace.
#
# WHY semantic IS REPORT-ONLY (HANDOFF A2 / D3)
#   The 3 semantic divergences in the baseline (#23/#37 single-signal
#   inputs under the threshold=2 line falling to fallback, #27 a relayed
#   feedback text pushed to a bug preselect by bug words) are the design
#   ceiling of threshold=2, adjudicated one by one in the 2026-10-31
#   REVIEW. Asserting the semantic count would hard-code that ceiling as
#   a gate and false-red on legitimate config evolution, so segment A
#   asserts spec conformance and the decided count only, and prints the
#   semantic agreement as a report line.
#
# SEGMENTS
#   A (baseline): intent-route.py consumed by module import, exactly as
#     the 2026-10-31 benchmark.py consumed it; samples x live
#     .tad/config-workflow.yaml x factory-default overrides (the script's
#     own default load paths - the shipped intent-overrides.yaml beside
#     the script, then <repo>/.tad/intent-overrides.yaml if it exists).
#   B (probes): the learning-filter reason rule through the real CLI
#     path, against sample 27, with throwaway overrides in a mktemp dir
#     outside the repo (shape carried from the 2026-10-31 REREVIEW
#     probes P1/P7): an entry without a reason must NOT take effect
#     (skip warning on stderr + override_skipped_missing_reason note in
#     the stdout JSON); the same entry with a reason must take effect
#     (force:discuss, listed in overrides_applied).
#
# EXIT CONTRACT
#   0 = every assertion passed (last line: INTENT-ROUTE-TEST: PASS)
#   1 = an assertion failed; the failing item is named on a MISMATCH or
#       PROBE-FAIL line and the last line is INTENT-ROUTE-TEST: FAIL
#   2 = environment missing (python3 / PyYAML / fixture / script /
#       config unreachable)
# The run writes nothing inside the repo (PYTHONDONTWRITEBYTECODE is set
# here and inside the embedded program); probe temp files live in a
# mktemp dir and are removed before exit.

HERE="$(cd "$(dirname "$0")" && pwd -P)"
ROOT="$(cd "$HERE/../.." && pwd -P)"
export PYTHONDONTWRITEBYTECODE=1

if ! command -v python3 >/dev/null 2>&1; then
  echo "intent-route-test: python3 not found" >&2
  exit 2
fi
for f in "$ROOT/.tad/hooks/lib/intent-route.py" \
         "$ROOT/.tad/tests/fixtures/intent-route-samples.json" \
         "$ROOT/.tad/config-workflow.yaml"; do
  if [ ! -f "$f" ]; then
    echo "intent-route-test: required file unreachable: $f" >&2
    exit 2
  fi
done

exec python3 - "$ROOT" <<'PYEOF'
import sys
sys.dont_write_bytecode = True
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(sys.argv[1])
SCRIPT = ROOT / ".tad/hooks/lib/intent-route.py"
FIXTURE = ROOT / ".tad/tests/fixtures/intent-route-samples.json"
CONFIG = ROOT / ".tad/config-workflow.yaml"
EXPECTED_N = 38
EXPECTED_DECIDED = 30

def env_fail(msg):
    sys.stderr.write("intent-route-test: %s\n" % msg)
    sys.exit(2)

try:
    import yaml
except ImportError:
    env_fail("PyYAML is required")

spec = importlib.util.spec_from_file_location("intent_route", SCRIPT)
ir = importlib.util.module_from_spec(spec)
try:
    spec.loader.exec_module(ir)
except SystemExit as e:
    # intent-route.py exits 2 itself when PyYAML is missing.
    sys.exit(e.code if isinstance(e.code, int) else 2)
except Exception as e:
    env_fail("cannot load intent-route.py: %s" % e)

try:
    cfg = yaml.safe_load(CONFIG.read_text(encoding="utf-8")) or {}
    samples = json.loads(FIXTURE.read_text(encoding="utf-8"))
except Exception as e:
    env_fail("cannot read config or fixture: %s" % e)

# Factory-default overrides via the script's own load caliber: the same
# default path list intent-route.py main() uses when --overrides is not
# given (shipped file beside the script, then the project-local file).
default_paths = [SCRIPT.parent / "intent-overrides.yaml",
                 ROOT / ".tad/intent-overrides.yaml"]
force, supp, _files = ir.load_overrides(default_paths)

def route_str(r):
    return r["route"] if r["mode"] is None else "%s:%s" % (r["route"], r["mode"])

failures = []

# --- Segment A: baseline over the registered fixture -------------------
spec_ok = 0
sem_ok = 0
sem_n = 0
decided = 0
for s in samples:
    r = ir.classify(s["input"], cfg, force, supp)
    got = route_str(r)
    if got == s["spec"]:
        spec_ok += 1
    else:
        failures.append("MISMATCH id=%s got=%s spec=%s" % (s["id"], got, s["spec"]))
    if s["semantic"] != "unclear":
        sem_n += 1
        sem_ok += (r["route"] == "idle") if s["semantic"] == "idle" \
            else (r["mode"] == s["semantic"])
    if r["route"] in ("explicit", "idle", "force", "preselect"):
        decided += 1
n = len(samples)
if n != EXPECTED_N:
    failures.append("MISMATCH fixture-count got=%d spec=%d" % (n, EXPECTED_N))
if decided != EXPECTED_DECIDED:
    failures.append("MISMATCH decided-count got=%d spec=%d"
                    % (decided, EXPECTED_DECIDED))
for line in failures:
    print(line)
print("spec-conformance: %d/%d" % (spec_ok, n))
print("semantic-agreement: %d/%d (report-only)" % (sem_ok, sem_n))
print("deterministically-decided: %d/%d" % (decided, n))

# --- Segment B: reason-rule probes through the real CLI ----------------
s27 = None
for s in samples:
    if s["id"] == 27:
        s27 = s
        break
probe_failed = False
tmp = tempfile.mkdtemp(prefix="intent-route-test-")
try:
    if s27 is None:
        print("PROBE-FAIL probe-noreason: sample id=27 not in fixture")
        print("PROBE-FAIL probe-withreason: sample id=27 not in fixture")
        probe_failed = True
    else:
        env = dict(os.environ)
        env["PYTHONDONTWRITEBYTECODE"] = "1"

        def run_cli(overrides_path):
            return subprocess.run(
                [sys.executable, str(SCRIPT), "--overrides",
                 str(overrides_path), s27["input"]],
                capture_output=True, text=True, encoding="utf-8",
                env=env, cwd=str(ROOT))

        entry = {"match": "用户反馈", "mode": "discuss"}
        p1 = Path(tmp) / "overrides-noreason.yaml"
        p1.write_text(yaml.safe_dump(
            {"version": 1, "force_routes": [entry], "suppress_words": []},
            allow_unicode=True), encoding="utf-8")
        try:
            cp1 = run_cli(p1)
            out1 = json.loads(cp1.stdout)
            notes1 = " ".join(out1.get("notes") or [])
            ok1 = (cp1.returncode == 0
                   and route_str(out1) == "preselect:bug"
                   and "override_skipped_missing_reason" in notes1
                   and "skipped" in cp1.stderr)
            why1 = ("rc=%d route=%s skip-note=%s stderr-skip=%s"
                    % (cp1.returncode, route_str(out1),
                       "override_skipped_missing_reason" in notes1,
                       "skipped" in cp1.stderr))
        except Exception as e:
            ok1 = False
            why1 = "unparsable CLI output: %s" % e
        if ok1:
            print("probe-noreason: OK (not applied, skip note present)")
        else:
            print("PROBE-FAIL probe-noreason: %s" % why1)
            probe_failed = True

        entry2 = dict(entry)
        entry2["reason"] = ("regression probe: relayed user feedback is "
                            "discussed, not filed as a bug")
        p2 = Path(tmp) / "overrides-withreason.yaml"
        p2.write_text(yaml.safe_dump(
            {"version": 1, "force_routes": [entry2], "suppress_words": []},
            allow_unicode=True), encoding="utf-8")
        try:
            cp2 = run_cli(p2)
            out2 = json.loads(cp2.stdout)
            applied2 = out2.get("overrides_applied") or []
            ok2 = (cp2.returncode == 0
                   and route_str(out2) == "force:discuss"
                   and any(o.get("type") == "force_route"
                           and o.get("mode") == "discuss"
                           for o in applied2))
            why2 = ("rc=%d route=%s applied=%s"
                    % (cp2.returncode, route_str(out2), applied2))
        except Exception as e:
            ok2 = False
            why2 = "unparsable CLI output: %s" % e
        if ok2:
            print("probe-withreason: OK (force:discuss applied)")
        else:
            print("PROBE-FAIL probe-withreason: %s" % why2)
            probe_failed = True
finally:
    shutil.rmtree(tmp, ignore_errors=True)

if failures or probe_failed:
    print("INTENT-ROUTE-TEST: FAIL")
    sys.exit(1)
print("INTENT-ROUTE-TEST: PASS")
sys.exit(0)
PYEOF
