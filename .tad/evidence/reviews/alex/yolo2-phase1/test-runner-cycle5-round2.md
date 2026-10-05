# YOLO 2.0 Phase 1 — Cycle 5 Round 2 Final Test Review

Date: 2026-08-24
Mode: read-only, incremental, final round

VERDICT: FAIL
P0_COUNT: 1
P1_COUNT: 1
P2_COUNT: 0

## Verified positives

- Current author/receipt pins and the nine-direct plus 26-negative assertion manifest are internally consistent.
- Host `eval`/`Function` and VM string code generation throw `EvalError`; ordinary VM code succeeds; VM WebAssembly compilation is blocked.
- T=0 author verifier remains non-PASS because implementation evidence is absent.

## P0 — allowed `vm.Script` binding can be aliased

The author verifier counts only direct `new Script(...)` and direct `script.runInContext(context)`. It does not close all other uses of the imported `Script` capability. This additional source preserves every required statement yet executes a second host-realm script:

~~~js
const S = Script
const extra = new S('40 + 2')
extra.runInThisContext()
~~~

`--disallow-code-generation-from-strings` deliberately does not block the `vm` API, so the probe executes and returns `42`. This violates FR12's claimed single VM boundary and restores arbitrary host-realm string execution.

Required future repair: make `Script` and `createContext` closed capabilities. Permit their identifiers only in the exact import and exact normative AST nodes; reject aliases and every other use, including `runInThisContext`, `runInNewContext`, and other VM compilation APIs. Preserve the exact alias bypass as a permanent committed-clone negative control.

## P1 — missing-flag assertion is not receipt-bound

AC14 says an invocation without the CLI flag is separately proven non-PASS, but its command includes the flag and neither the direct IDs nor negative controls contain that assertion. T=0 cannot demonstrate `E_CODEGEN_FLAG` because the author verifier reads missing evidence before checking the flag.

Required future repair: make the runner reject a missing flag before suite/evidence work, add a closed `missing-codegen-flag` assertion with an unflagged command, and decide explicitly whether author-verifier flag precedence must also be moved before evidence parsing.
