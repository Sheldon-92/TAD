# Local Wiki Native Capture — Correction Journal

The first Phase 3 implementation treated a separate browser extension as the runtime capture
boundary. The user corrected the requirement: the useful behavior could inform the design, but
Local Wiki had to own the capability and remain operational when that project was absent.

The replacement uses Node built-ins and Chrome CDP inside TAD, keeps the external project
byte-restored and untouched, and adds a source scan plus executable tests proving no runtime
reference remains. Two later review rounds closed dynamic-port, transport, byte-bound, profile,
localhost-contract, and failure-cleanup gaps without reintroducing the dependency.

Reusable lesson: when a requirement says to internalize a capability, acceptance must prove
both positive behavior and negative independence from the cited prior-art implementation.
