# Capability Ownership Patterns

### Internalized Capability Requires an Absence Proof — 2026-09-02

- **Context**: A local research ingestion feature initially wrapped a separate browser-extension
  project after inspecting it as prior art. The behavior worked, but the product still depended
  on that project being installed, which contradicted the requirement to internalize the ability.
- **Discovery**: Positive end-to-end behavior does not distinguish an owned capability from a
  hidden adapter dependency. The distinction becomes testable only when the prior-art project is
  absent or unreachable and the product still succeeds.
- **Action**: For “internalize/reuse the capability, not the plugin” requirements, pair the normal
  behavioral AC with an absence proof: scan portable runtime/docs for the old boundary and run the
  core path using only repository-owned code and declared platform dependencies. Treat prior art
  as design input, never as an unstated runtime prerequisite.
- **failure_mode**: A wrapper around an external project passes the happy-path demo and is accepted
  as reuse. It later fails on another machine because the hidden sibling path or plugin is absent.
- **Grounded in**: Local Wiki native browser capture correction, commits `1f6b5d3a` through
  `7cce3f78`, and the 2026-09-02 user correction journal.
