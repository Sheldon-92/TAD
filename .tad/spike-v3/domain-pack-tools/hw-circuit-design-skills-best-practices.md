# Hardware Circuit Design — Skills & Best Practices Research

> Research date: 2026-04-03
> Purpose: Inform hw-circuit-design Domain Pack capability design with real-world best practices from open-source projects.

---

## Search Log

| Search Term | Results Found | Repos Selected |
|------------|--------------|----------------|
| GitHub KiCad skills PCB schematic SKILL.md | 10 results | aklofas/kicad-happy, drandyhaas/KiCadRoutingTools |
| GitHub AI agent electronics design EDA automation | 10 results | Thinklab-SJTU/awesome-ai4eda, assalas/pcb-designer-ai-agent, NellyW8/MCP4EDA |
| GitHub hardware design review checklist DRC ERC | 10 results | jak-services.github.io (PCB design rules checklist) |
| GitHub ESP32 circuit design best practices | 10 results | espressif/esp-hardware-design-guidelines |
| PCB design checklist manufacturing 2026 | 10 results | (industry articles, no new GitHub repos) |

**Total unique repos/resources selected: 7** (5 GitHub repos + 2 structured web resources)

---

## Repo 1: aklofas/kicad-happy

- **URL**: https://github.com/aklofas/kicad-happy
- **Stars**: ~127
- **Description**: AI coding agent skills for KiCad — 10 integrated skills that turn an AI agent into an electronics design assistant.

### 1. Step Depth

Documented 10-step workflow:
1. Design board in KiCad
2. Sync datasheets to local library
3. Analyze schematic and PCB (automated subcircuit detection)
4. Simulate detected subcircuits via SPICE (ngspice/LTspice/Xyce)
5. Run 42-rule EMC pre-compliance assessment
6. Perform thermal analysis (hotspot estimation, via adequacy)
7. Cross-reference findings with agent review
8. Source components from distributors (DigiKey/Mouser/LCSC/Element14)
9. Export per-supplier order files
10. Order from JLCPCB or PCBWay with DRC validation

Each skill has its own SKILL.md with activation triggers, input/output contracts, and step sequences.

### 2. Source Lists

- **EMC standards**: FCC, CISPR, CISPR 25 (automotive), MIL-STD-461G (military)
- **Textbooks**: Ott, Paul, Bogatin (EMI analytical formulas)
- **Behavioral opamp models**: ~100 parts with real GBW, slew rate, output swing from datasheets
- **Derating profiles**: Commercial, military, automotive temperature grades
- **Validation corpus**: 1,035 open-source KiCad projects; 6,853 EMC analyses

### 3. Analysis Frameworks

- **EMC risk scoring**: 0-100 scale with CRITICAL / HIGH / MEDIUM / INFO severity levels
- **Power tree analysis**: Traces full power distribution from input to every rail
- **Protocol validation**: I2C rise time check, CAN termination verification
- **Lifecycle auditing**: Component obsolescence tracking across BOM
- **Monte Carlo spread**: 3-sigma bounds for component value variation
- **SPICE tolerance**: <0.3% error considered "confirmed match"

### 4. Quality Standards

| Metric | Threshold |
|--------|-----------|
| Ceramic capacitor voltage derating | max 50% of rated |
| Electrolytic capacitor voltage derating | max 80% of rated |
| Thermal via count (STM32 QFN-48) | 16 recommended (14 = WARNING) |
| Differential pair skew | max 25 ps |
| Decoupling cap distance from IC | max 7 mm |
| SPICE simulation match | <0.3% error |
| 96 equations verified against primary sources | 100% pass |
| 520K+ regression assertions | 100% pass |

### 5. Anti-patterns

- Insufficient thermal vias on high-current components (e.g., inductor with 4 vias, needs 9)
- Unprotected interfaces: CAN_H/CAN_L without TVS, I2C without ESD diodes
- Ground plane voids crossing high-speed signals
- Decoupling capacitors placed >7mm from target IC power pins
- Clock routing on outer layers without via stitching
- Bias current paths unaccounted for in op-amp feedback circuits
- Over-designed components that inflate BOM cost without benefit

---

## Repo 2: drandyhaas/KiCadRoutingTools

- **URL**: https://github.com/drandyhaas/KiCadRoutingTools
- **Stars**: ~81
- **Description**: Rust-accelerated A* autorouter for KiCad with Claude Code skill integration.

### 1. Step Depth

Workflow sequence:
1. Build Rust router (`python build_router.py`)
2. Create power planes with Voronoi partitioning before signal routing
3. Route nets via CLI or KiCad GUI plugin
4. Run differential pair routing with Dubins path heuristic
5. Apply rip-up and reroute (progressive N+1 strategy) for failed routes
6. Length/time matching for DDR4 byte lanes
7. Target swap optimization (Hungarian algorithm) to minimize crossings
8. GND return via placement near signal vias
9. Verify connectivity + DRC

Includes Claude Code skills: `/plan-pcb-routing`, `/analyze-power-nets` with their own SKILL.md files.

### 2. Source Lists

- KiCad file format specs (kicad_pcb, kicad_sch)
- Dubins path theory for orientation-aware routing
- Hungarian algorithm for assignment optimization
- DDR4 signal integrity specs for length matching

### 3. Analysis Frameworks

- **Connectivity validation**: Detects unrouted nets, broken routes, T-junctions
- **Orphan stub detection**: Identifies traces ending without proper connection
- **Power net identification**: AI-driven lookup of component datasheets to classify power/ground nets
- **Voronoi partitioning**: Automated power plane region assignment for multi-net layers

### 4. Quality Standards

- Default DRC clearance: 0.2 mm
- Board edge compliance: Respects Edge.Cuts boundaries including curved edges
- Differential pair polarity validation required before routing
- BGA exclusion zones automatically enforced (no vias under BGA pads)

### 5. Anti-patterns

- Routing power/GND nets as regular signals instead of using planes
- Skipping differential pair polarity validation
- Placing vias under BGA components (tool auto-prevents this)
- Manual power/ground plane creation when automated Voronoi is available

---

## Repo 3: espressif/esp-hardware-design-guidelines

- **URL**: https://github.com/espressif/esp-hardware-design-guidelines
- **Stars**: ~5 (but backed by Espressif official; the documentation site gets massive traffic)
- **Description**: Official hardware design guidelines for ESP32 family SoCs — 9 chip series covered.

### 1. Step Depth

The schematic checklist alone has 150+ items across 15 categories:
- Power Supply (digital, RTC, analog, VDD_SDIO modes)
- Chip Power-up and Reset Timing (RC delay circuits)
- Flash and PSRAM (in-package vs off-package, pin mapping)
- Clock Source (40 MHz crystal + optional 32.768 kHz RTC)
- RF Circuit (matching network, antenna, tuning)
- UART / SPI / SDIO / Touch / Ethernet MAC interfaces
- Strapping Pins (boot mode control)
- GPIO Configuration (input-only pins, domain assignments)
- ADC (channel mapping, calibration accuracy)

### 2. Source Lists

- ESP32 Technical Reference Manual
- ESP32 Datasheet (pin functions, electrical characteristics)
- Crystal manufacturer datasheets (load capacitance specs)
- Specific component part numbers: GRM0335C1H1RXBA01D (RF cap), LQP03TN2NXB02D (RF inductor)
- IPC standards (referenced for PCB layout)

### 3. Analysis Frameworks

- **Power domain mapping**: VDD3P3_CPU vs VDD3P3_RTC vs VDD_SDIO with voltage/current constraints
- **Boot mode matrix**: GPIO0 x GPIO2 state table determines SPI Boot vs Download Boot
- **ADC accuracy table by attenuation level**: Calibrated error ranges for 4 attenuation settings
- **RF tuning targets**: S11 conjugate match to 25+j0, S21 < -35 dB at 4.8/7.2 GHz harmonics
- **VDD_SDIO dual-mode decision**: 1.8V (internal LDO, 40mA max) vs 3.3V (6ohm internal resistor)

### 4. Quality Standards

| Parameter | Requirement |
|-----------|-------------|
| Power supply output current | >= 500 mA |
| Crystal accuracy | within +/-10 ppm |
| RTC crystal ESR | <= 70 kohm |
| RC reset delay | R=10K, C=1uF (adjustable) |
| Power stabilization before CHIP_PU | >= 50 us (tSTBL) |
| Reset assertion time | >= 50 us at < 0.6V (tRST) |
| Strapping pin hold time | >= 3 ms after CHIP_PU high |
| ADC accuracy (ATTEN=0) | +/- 23 mV in 100-950 mV range |
| ADC accuracy (ATTEN=3) | +/- 60 mV in 150-2450 mV range |
| RF matching: S21 at harmonics | < -35 dB |
| Crystal amplitude | > 500 mV |
| PSRAM pull-up (low power) | max 1 Mohm |

### 5. Anti-patterns

- Leaving CHIP_PU pin floating (must have defined pull-up/RC)
- Using ADC2 channels when Wi-Fi is enabled (ADC2 unavailable)
- High-value capacitors on GPIO0 (risk entering download mode at reset)
- Operating RF without antenna connected (circuit damage risk)
- Using internal APLL clock for RMII when Wi-Fi + Ethernet simultaneous
- Ignoring 80 ns pull-down glitch on SENSOR_VP/SENSOR_VN during RTC startup
- Connecting external flash/PSRAM to Slot0 SPI pins (reserved for internal flash)

---

## Repo 4: Thinklab-SJTU/awesome-ai4eda

- **URL**: https://github.com/Thinklab-SJTU/awesome-ai4eda
- **Stars**: ~196
- **Description**: Curated collection of AI for EDA research papers and implementations.

### 1. Step Depth

Organized by EDA pipeline stages:
1. **Logic Synthesis**: Operator optimization, sequence scheduling (DRiLLS - RL approach)
2. **Placement**: Component positioning (DREAMPlace - GPU-accelerated deep learning)
3. **Routing**: Interconnect pathfinding (HubRouter, DSBRouter)
4. **PPA Prediction**: Performance/Power/Area estimation pre-silicon
5. **Floorplanning**: Graph attention networks for block placement
6. **Timing Analysis**: Pre-routing timing and slack prediction

### 2. Source Lists

- Papers from DAC, NeurIPS, ICCAD, DATE conferences
- DREAMPlace (DAC 2019) — seminal GPU placement paper
- Thinklab-SJTU own implementations: DeepPlace, PRNet, HubRouter, PreRoutGNN, FlexPlanner, DSBRouter
- Survey papers covering ML applications across full chip design flow

### 3. Analysis Frameworks

- **Cross-design generalization testing**: Models validated across different chip designs
- **PPA metric comparison**: Standardized Performance/Power/Area benchmarks
- **Congestion prediction accuracy**: Pre-routing congestion maps vs post-routing reality
- **Timing estimation**: Pre-routing slack prediction validated against signoff timing

### 4. Quality Standards

- Benchmarks referenced but specific thresholds are paper-dependent
- Focus on placement quality (wirelength), routing completion rate, timing closure

### 5. Anti-patterns

- Overfitting placement models to single design (cross-design validation essential)
- Ignoring routing congestion during placement (placement-routing co-optimization needed)
- Using timing estimates from early stages without calibration against signoff

---

## Repo 5: NellyW8/MCP4EDA

- **URL**: https://github.com/NellyW8/MCP4EDA
- **Stars**: ~75
- **Description**: MCP server for RTL-to-GDSII automation with LLM integration.

### 1. Step Depth

Automated RTL-to-GDSII flow:
1. Verilog synthesis via Yosys (multiple FPGA targets)
2. Simulation with Icarus Verilog (automated testbench execution)
3. Waveform visualization via GTKWave
4. Complete RTL-to-GDSII ASIC flow via OpenLane
5. Layout inspection via KLayout
6. PPA report analysis (timing, area, power)

### 2. Source Lists

- Yosys synthesis engine documentation
- Icarus Verilog simulation specs
- OpenLane RTL-to-GDSII flow (Google/Efabless)
- KLayout for physical verification

### 3. Analysis Frameworks

- **Backend-aware synthesis optimization**: Synthesis guided by downstream PPA feedback
- **PPA report analysis**: Automated extraction of timing/area/power metrics
- **Multi-target synthesis**: Same RTL compiled for different FPGA/ASIC targets

### 4. Quality Standards

- OpenLane flow timeout: 10 minutes for complex designs
- Requires correct PATH environment variables and absolute file paths
- Docker permission configuration validation

### 5. Anti-patterns

- Running OpenLane without adequate timeout configuration
- Incorrect PATH or relative file paths (must use absolute)
- Skipping Docker permission setup on Linux (GTKWave/KLayout need display access)
- macOS security approvals often block EDA tools silently

---

## Resource 6: JAK Services PCB Design Rules Checklist

- **URL**: https://jak-services.github.io/en/pcb-design-rules.html
- **Type**: Structured web checklist (GitHub Pages hosted), 140 rules across 12 categories.

### 1. Step Depth

140 rules organized in design-flow order:
1. Schematics (17 rules)
2. Manufacturability / DFMA (12 rules)
3. PCB Layout — Physical Constraints (10 rules)
4. Stack-up, Planes & EMI Control (13 rules)
5. Signal Integrity, EMI & Routing (25 rules)
6. Decoupling, Power Integrity & EMI (15 rules)
7. Vias (9 rules)
8. Voltage Transients & ESD Protection (5 rules)
9. Creepage & Clearance (5 rules)
10. High Current & Temperature (7 rules)
11. Design for Test (10 rules)
12. Pre-Submission Review & Documentation (13 rules)

### 2. Source Lists

- IPC-2221 (general PCB design standard)
- IPC-7351 (footprint standards)
- IPC trace width calculators (DigiKey reference)
- UL flammability ratings
- RoHS/REACH compliance

### 3. Analysis Frameworks

- **Signal integrity threshold**: Traces longer than 1/6 of signal rise time need simulation
- **High-frequency component threshold**: Through-hole concern above ~80 MHz
- **Plane split crossing rule**: Never cross plane splits with high-speed signals
- **Crosstalk spacing formula**: Parallel traces >= 3x trace width apart
- **Decoupling hierarchy**: 100 nF per pin + 1 uF + 10 uF bulk, placed < 15 mm

### 4. Quality Standards

| Metric | Threshold |
|--------|-----------|
| Minimum trace width | ~6 mil |
| Minimum clearance | ~6 mil |
| Via drill size | >= 0.30 mm |
| Solder mask expansion | 3-5 mil |
| Decoupling cap placement | < 15 mm from pin |
| Parallel trace spacing (crosstalk) | >= 3x trace width |
| Through-hole concern frequency | > 80 MHz |
| Creepage/clearance applies | > 30 V designs |

### 5. Anti-patterns

- Hidden power pins in schematics (make ALL connections explicit)
- Ignoring ERC warnings instead of fixing them
- Routing high-speed signals across plane splits
- Using via-in-pad without filled/plated-over (VIPPO) process
- Placing test pads on impedance-controlled nets (use buffer nodes)
- Leaving unused inputs floating (give defined logic state)
- 90-degree trace bends (prefer 45-degree or curves)
- Narrow copper neck-downs that increase impedance unexpectedly

---

## Resource 7: Schemalyzer — Schematic Review Guide

- **URL**: https://www.schemalyzer.com/en/blog/schematic-review/best-practices/how-to-review-schematic
- **Type**: Structured methodology guide with scoring framework.

### 1. Step Depth

4-phase systematic review:
1. **High-Level Architecture**: Power distribution, functional blocks, signal flow, external interfaces
2. **Block-by-Block Analysis**: Power supply, MCU, communication, analog conditioning, protection, connectors, UI
3. **Component-Level Verification**: Pinouts, values, tolerances, voltage ratings, footprint assignments
4. **Automated Checks**: ERC + DRC tool execution

### 2. Source Lists

- Component datasheets (for pinout and value verification)
- Regulator datasheets (for ESR and capacitor requirements)
- ERC/DRC tool documentation

### 3. Analysis Frameworks

- **Rule of 10**: Error cost multiplies 10x at each stage (schematic 1x -> layout 10x -> prototype 100x -> production 1000x)
- **Design Score Scale**: 1-3 Needs Work, 4-5 Fair, 6-7 Good, 8-10 Excellent
- **Issue Severity**: Critical (must fix) / Major (should fix) / Minor (nice to fix)
- **Time budget**: 2-4 hours for medium-complexity design review

### 4. Quality Standards

- Every IC power pin must have a decoupling capacitor
- All external interfaces must have ESD protection
- No floating inputs anywhere in design
- I2C/SPI buses properly terminated
- Level shifters present where voltage domains cross
- UART TX/RX correctly crossed between devices
- BOM complete with actual part numbers

### 5. Anti-patterns

- Missing decoupling capacitors on IC power pins
- Incorrect regulator capacitor ESR (stability risk)
- Net label typos causing silent disconnection
- Cross-sheet connection failures
- Wrong component values or reversed polarity
- Suppressing ERC warnings without investigation
- Inadequate voltage ratings on capacitors
- Obsolete parts in BOM

---

## Synthesis

### Pattern 1: Multi-Phase Review is Universal

Every resource follows a staged approach: Architecture -> Block-level -> Component-level -> Automated checks. The kicad-happy tool implements this as automated subcircuit detection -> per-circuit analysis -> cross-reference verification. The Schemalyzer guide formalizes it as a 4-phase methodology. Domain Pack capabilities should mirror this progression.

### Pattern 2: Quantified Thresholds Beat Vague Guidelines

The most useful resources define specific numeric thresholds:
- Voltage derating: 50% ceramic, 80% electrolytic (kicad-happy)
- Decoupling distance: < 7 mm (kicad-happy) or < 15 mm (JAK Services)
- Crystal accuracy: +/-10 ppm (Espressif)
- Differential pair skew: < 25 ps (kicad-happy)
- Crosstalk spacing: >= 3x trace width (JAK Services)

A Domain Pack should embed these thresholds as configurable defaults in its quality standards, not leave them as prose.

### Pattern 3: Anti-pattern Libraries are High-Value

Across all repos, the most actionable content is the anti-pattern warnings. Common themes:
- **Floating/unprotected pins**: Universally flagged (every resource)
- **Insufficient decoupling**: Distance, value, and count all matter
- **Ground plane integrity**: Never cross splits with high-speed signals
- **Thermal via adequacy**: Specific via counts per package type
- **ESD/TVS placement**: Must be between connector and circuit, not after

A Domain Pack "design review" capability should be structured as anti-pattern detection first, then positive verification.

### Pattern 4: Standards Layering (Component -> Board -> System -> Compliance)

Resources reference standards at four levels:
1. **Component**: Datasheets, derating profiles, behavioral models
2. **Board**: IPC-2221, IPC-7351, trace width calculators
3. **System**: Protocol specs (I2C timing, DDR4 signal integrity, USB impedance)
4. **Compliance**: FCC, CISPR, CISPR 25, MIL-STD-461G, RoHS/REACH

Domain Pack source lists should organize references by these four levels.

### Pattern 5: CLI Tool Integration is the Frontier

The newest repos (kicad-happy, KiCadRoutingTools, MCP4EDA) all integrate with AI coding agents:
- kicad-happy: Claude Code skills with SKILL.md files
- KiCadRoutingTools: Claude Code skills (`/plan-pcb-routing`, `/analyze-power-nets`)
- MCP4EDA: MCP server for Claude Desktop / Cursor IDE

This confirms that hardware EDA is moving toward AI-agent-assisted workflows. A Domain Pack should define capabilities that map to these emerging tool patterns.

### Pattern 6: Simulation Before Fabrication

Both kicad-happy (SPICE simulation with Monte Carlo) and Espressif (RF tuning with S-parameter targets) emphasize pre-fabrication verification. Key thresholds:
- SPICE match: < 0.3% error
- RF: S21 < -35 dB at harmonics
- Monte Carlo: 3-sigma bounds for component variation

Domain Pack capabilities should include a "simulate and verify" step before any "export for manufacturing" step.
