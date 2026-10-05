# Architecture Audit Report: YOLO 2.0 Phase 1 / Cycle 2 baseline, Cycle 5 amendment

Generated: 2026-08-24  
Scope: `.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md` and Phase 1 handoff v1.3 draft  
Mode: existing-system audit, not implementation

| Decision | Status | Finding |
|---|---|---|
| D1 — Need an Agent | Addressed | Long-horizon coding is Level 3/4 work, but certification is deliberately deterministic. The agent chooses actions; the reducer decides state. |
| D2 — Coordination | Addressed | Hub-spoke control plane, append-only events, one canonical reducer, candidate-bound one-use grants, and bounded evaluator rounds prevent flat-agent consensus and shared mutable state. |
| D3 — Memory | Addressed | Active task state is file-backed episodic/checkpoint state; durable project rules remain procedural in Git; compact summaries are never authoritative. No vector database is introduced. |
| D4 — Tools | Addressed | Phase 1 uses a narrow fixed CLI surface. The acceptance boundary uses exact `acorn@8.18.0` instead of maintaining a second JavaScript lexer; later adapters expose capability manifests and progressive routes rather than loading every harness tool into context. |
| D5 — Permissions | Partial by design | Executor and auditors are separated; grants are one-use and candidate-bound. Phase 1 bootstraps review provenance through live harness observation; cryptographic/capability attestation is deferred to Phase 4. Unknown capability blocks strict verification. |
| D6 — Compression | Addressed | Staged compaction may prune tool payloads and summarize history, but goal, contract digest, last verified event and next action are rehydrated from files after compact. Summary drift cannot advance state. |
| D7 — Cost | Addressed at Epic level | Bounded Manage–Execute–Audit rounds, no blind retries, and future per-run budgets prevent evaluator loops. Phase 1 measures control logic, not model-token economics. |
| D8 — Observability | Addressed | Append-only JSONL events plus derived state and audit receipts provide trace correlation and replay. Phase 1 freezes the record contracts before the kernel exists. |
| D9 — Testing | Addressed | Closed schemas, 24 transition cases, independent direct-API review, T=0 5×3 baseline, mutation killing, a five-assertion host/VM runtime boundary, and twenty-six false-green controls test invariants rather than exact model prose. Controls 10–26 preserve RegExp camouflage, hidden dynamic imports, constructor/reflection extraction, global aliases, fs object imports, and the two Cycle 5 computed-constructor bypasses as permanent regressions. Real stochastic Pass³ belongs to Phase 6. |
| D10 — Disasters | Addressed | Event sourcing counters stale/racing state; one-use IDs counter replay; deny-first capability modes counter overreach; bounded loops counter runaway cost; strict cannot be inferred from missing evidence. |

## Risk Assessment

### P0 — Blocking before Phase 1 handoff

- Bootstrap reviewer provenance must be observed live by the Gate 3 control plane. Artifact files prove integrity bindings, not that a reviewer was actually spawned. If the harness exposes no distinct actor/session/invocation, Gate 3 is BLOCKED.
- Live-surface negative control must first pass against a complete 120-file copied protected surface with the author baseline unchanged, then fail only after one copied protected-file byte changes.

### P1 — Required before Epic integration

- Phase 1 claims only `node14_static_compatible`; Phase 4 must execute the frozen suite on a real Node 14.0.x runtime.
- The static policy must reject external packages and run with `NODE_PATH` unset; the Gate 3 reviewer repeats this scan independently.
- Phase 4 must capability-probe reviewer isolation and resume/compact behavior on Claude Code, Codex and OpenCode. Missing capability produces `honest_partial`, never inferred strictness.

### P2 — Advisory

- Keep native provider context editing/compaction as an adapter optimization. The file ledger remains the cross-harness authority because service-managed summaries differ by provider.
- Later phases should record compression before/after token counts and stop compressing after two low-yield cycles to avoid thrashing.

## Memory & Context Review

### Memory Layer Map

| State | CoALA layer | YOLO 2 carrier | Rule |
|---|---|---|---|
| Current prompt tail and active tool call | Working | Harness context only | May be compacted; never authoritative |
| Contract, event log, checkpoints, audit receipts | Episodic | `.tad/evidence/yolo/<slug>/runs/<run-id>/` files | Append-only, replayable, survives crash/compact |
| Reusable project lessons | Semantic | `.tad/project-knowledge/` | Distilled separately; never stores current step |
| Role protocols, schemas, reducers, skills | Procedural | Git-tracked code and skills | Versioned; contract digest binds the active version |
| Harness capability/version facts | Organizational context | `.tad/runtime-compat/` ledger | Versioned evidence with freshness/review date |

Applied agent-memory rules: MA1/MA2 keep active progress out of volatile context; CC2 uses staged compaction; CC3 requires explicit thresholds in later adapters; SP1 checkpoints every certified boundary; SP3 preserves replay vs fork; SP5 keeps irreversible actions behind human authority; SP7 prevents confusing project knowledge with per-run checkpoints.

## Cycle 5 Amendment

Phase 1 remains file-native, but is no longer dependency-free at its acceptance boundary. The human explicitly authorized one exact dev-only dependency, `acorn@8.18.0`, after Cycle 3 proved the hand-written scanner could confuse RegExp and block-comment syntax. The implementation runtime graph remains dependency-free; the Alex verifier uses parser-produced AST/tokens and independently enforces the frozen parent manifest, exact child delta, exact npm lockfile v1, registry integrity, and absence of competing lockfiles. No fallback scanner is allowed.

Cycle 4 Round 1 exposed two additional parser-policy boundaries: fs aliases and dynamic code can hide forbidden APIs/imports even when the surface AST is valid. The then-current repair attempted to track bindings/member chains and reserve one exact wrapper exception; later review proved that approach was not a closed dynamic-code boundary. Live npm registry-signature verification plus installed-byte pins still closes the selected parser package's executable trust path.

Cycle 4 final review showed that general capability propagation in JavaScript is open-ended: inherited constructors can be destructured and global roots can be aliased before computed access. Cycle 5 initially reduced authority instead of extending a bespoke taint engine. Round 1 still found two computed constructor paths that escaped the enumerated AST policy, proving that syntax enumeration was not a closed security boundary.

The Cycle 5 final repair moves authority to execution. Every relevant Node process must receive `--disallow-code-generation-from-strings`. The sole legitimate execution of frozen workflow source uses one token-guarded `vm.Script` and a context created with `codeGeneration.strings=false` and `codeGeneration.wasm=false`; that context receives no host process, loader, filesystem, or global authority. Static Acorn checks remain for import closure, exact VM shape, least-privilege fs imports, and common forbidden constructs, but no longer claim to recognize every constructor alias. A five-assertion runtime suite and permanent controls for both Round-1 bypasses make this boundary directly falsifiable.

Static Node 14/API/import checks still run under the available host runtime and record that limitation explicitly. Phase 4 owns the real Node 14.0.x execution matrix and blocks Phase 5/6 if it cannot prove it. The parser package metadata indicates compatibility but is not accepted as runtime proof.
