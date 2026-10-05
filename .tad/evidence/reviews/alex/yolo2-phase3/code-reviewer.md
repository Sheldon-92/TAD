Model: harness=codex | model=gpt-5.6-terra | route=terra_reviewer

# YOLO2 Phase 3 — Code-Surface Design Review

**Reviewer:** independent `phase3_code_review` subagent  
**Scope:** revised Phase-3 design and handoff; read-only  
**Final verdict:** PASS  
**Remaining P0:** 0  
**Remaining P1:** 0 in focused closure scope

## Findings and closure

| Severity | Finding | Closure |
|---|---|---|
| P0 | workspace-write harness could reach in-repository authority | RESOLVED: control/product/raw roots are inaccessible and sentinel-tested; pre-spawn lease governs physical work |
| P1 | lease attempted to bind a runner nonce before the runner could mint it | RESOLVED: conductor nonce is issued first; native invocation ID is separately observed after spawn |
| P1 | live `probe` calls bypassed the lease lifecycle | RESOLVED: every physical probe subcall requires its own probe lease and budget reservation |
| P1 | external control root had no safe compatibility interface | RESOLVED: v2-only resolver freezes mapping and roots; legacy `resolveRunDir` remains unchanged |

The focused closure review explicitly returned PASS with zero remaining P0.
