# Fixture: *experiment harness syntax error → Gate 3 FAIL (P3.2 AC-P3.2-h, BA-P0-2)
# Purpose: Verify gate3_focus_AUGMENTATION semantics = AUGMENT not REPLACE.
#          Original Gate 3 v2 (build/test/lint) STILL applies to harness code.

# Scenario:
#   Blake completes experiment with all 5 experiment-validity checks passing:
#     1. Control variables clear ✅
#     2. Self-enhancement bias mitigated ✅
#     3. Baseline established ✅
#     4. Reproducibility ✅
#     5. Generator = production model ✅
#
#   BUT — the harness/runner code has a Python syntax error:

# .tad/evidence/experiments/{slug}/run.py
def run_experiment(rubric, fixtures):
    for fixture in fixtures
        # ↑ Missing colon on for loop — SyntaxError
        score = evaluate(fixture, rubric)
        yield score

# Layer 1 self-check (build/test/lint):
#   $ python3 -c "import ast; ast.parse(open('.tad/evidence/experiments/{slug}/run.py').read())"
#   File "<unknown>", line 2
#       for fixture in fixtures
#                              ^
#   SyntaxError: expected ':'
#
#   exit code: 1 → Layer 1 FAIL

# Expected Gate 3 verdict: FAIL
#   Reason: harness syntax error fails original Gate 3 v2 build/test/lint
#   Even though all 5 experiment_specific_gates checks PASS, the AUGMENT semantics
#   means BOTH layers must PASS. Original criteria are not bypassed.

# Counter-fixture (to confirm semantics):
#   If gate3_focus were REPLACE instead of AUGMENT, Gate 3 would only check
#   the 5 experiment items → would PASS incorrectly despite broken harness.
#   AUGMENT semantics catches this.

# Verification command (Blake should run during Gate 3):
#   python3 -c "import ast; ast.parse(open('.tad/evidence/experiments/{slug}/run.py').read())"
#   Must exit 0 (parse success). Failing exit → Gate 3 FAIL.
