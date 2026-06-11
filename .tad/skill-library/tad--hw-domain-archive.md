# T2 Reference: Hardware Domain Pack Archive

> Source: TAD project, 2026-06-11. Archived from `.tad/domains/` during Pack System Unification Phase 1.

## Archived Source Files

- `.tad/archive/domains/2026-06-11-domain-pack-retirement/hw-circuit-design.yaml`
- `.tad/archive/domains/2026-06-11-domain-pack-retirement/hw-enclosure.yaml`
- `.tad/archive/domains/2026-06-11-domain-pack-retirement/hw-firmware.yaml`
- `.tad/archive/domains/2026-06-11-domain-pack-retirement/hw-testing.yaml`

## What to Reuse

- Circuit design capability workflows (schematic → PCB → DRC → manufacturing)
- Firmware development step models (init → drivers → protocols → OTA)
- Hardware testing validation frameworks (bench → environmental → compliance)
- Enclosure design patterns (thermal → IP rating → DFM)
- Tool registry entries for hardware-specific CLIs (KiCad, PlatformIO, etc.)

## What NOT to Reuse

- YAML step model format (use SKILL.md reference-based architecture instead)
- Keyword routing hooks (retired; Capability Packs auto-detect via registry)
- SessionStart injection pattern (packs load on demand now)

## Criteria for Upgrading to Capability Pack

1. A real hardware project needs these workflows (not speculative)
2. Run the `/capability-upgrade` flow with the archived YAML as source material
3. Research current tools (the archived tool versions may be outdated)
4. Validate with a real task before registering
