# Node 14 code-generation boundary for YOLO 2.0 Phase 1

Date: 2026-08-24

## Decision

Phase 1 must not claim that an enumerated AST blacklist can recognize every JavaScript route to a dynamic constructor. All Phase 1 runner, compatibility, baseline, author-verifier, and independent-review processes instead run with the explicit Node CLI flag `--disallow-code-generation-from-strings`. The flag is a required process invariant, not an optional environment setting.

The one legitimate need to execute the frozen YOLO v1 workflow source uses `vm.Script`. Its context is created with `codeGeneration: { strings: false, wasm: false }`, and receives only the deterministic adapter values required by the baseline. `vm` is allowed only as the exact named import `Script` plus `createContext` in `baseline-v1.mjs`.

## Primary-source findings

- Node 14.7 CLI documentation lists `--disallow-code-generation-from-strings` and records that it was added in Node 9.8.0. It disables `eval` and function constructors created from strings. Source: https://nodejs.org/download/release/v14.7.0/docs/api/cli.html#cli_disallow_code_generation_from_strings
- Node 14.17 VM documentation records `contextCodeGeneration.strings` and `.wasm`, both available since Node 10.0.0. Setting them to false makes `eval`/function constructors or WebAssembly compilation throw. Source: https://nodejs.org/download/release/v14.17.3/docs/api/vm.html#vm_vm_createcontext_sandbox_options
- The CLI flag does not itself prohibit the `vm` API. Therefore the host flag and the VM context option are both required; neither substitutes for the other.

Both controls predate Node 14.0.0, so they are compatible with the Phase 1 static Node 14 claim. A real Node 14.0.x execution remains the blocking Phase 4 proof.

## Local probes

On the available host runtime:

1. `node --disallow-code-generation-from-strings -e "Function('return 1')()"` threw `EvalError`.
2. An ordinary expression executed successfully in a `vm` context created with both code-generation switches false.
3. `Function('return 1')()` inside that context threw `EvalError`.

These probes validate the design mechanism on the current host; they do not replace Phase 4's real Node 14.0.x matrix.

## Acceptance consequence

The author verifier fails with `E_CODEGEN_FLAG` unless the CLI flag is present in `process.execArgv`. The runner exposes a `runtime-boundary` subcommand and `all` includes it. Independent Gate 3 review must reproduce host `eval`, host `Function`, VM `eval`, and VM `Function` rejection plus an ordinary VM execution positive control.
