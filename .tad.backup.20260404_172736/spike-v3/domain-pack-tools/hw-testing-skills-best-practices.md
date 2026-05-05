# Hardware Testing Skills — Best Practices Research

> Research date: 2026-04-03
> Purpose: Inform hw-testing Domain Pack capability design with real-world patterns from open-source repos and industry guides.

---

## Search Log

| Search Term | Results Found | Repos Selected |
|------------|--------------|----------------|
| GitHub hardware testing verification SKILL.md | 10 results; 1 directly relevant repo | ben-marshall/awesome-open-hardware-verification |
| GitHub electronics testing checklist QA | 10 results; mostly software QA, no hardware-specific repos selected | (none — software-focused) |
| GitHub EMC compliance testing guide | 10 results; no GitHub repos, but 1 excellent GitHub Pages blog | krishnawa.github.io EMC-Testing-in-GTEM-Cell |
| GitHub hardware power measurement profiling | 10 results; 1 repo selected | IRNAS/ppk2-api-python |
| hardware product testing best practices 2026 | 10 results; 1 industry article with 10-step procedure | (supplementary — Epsilon3 article) |
| awesome-hardware-testing github | 10 results; 1 comprehensive repo | sschaetz/awesome-hardware-test |
| hardware validation verification github | 10 results; 2 repos selected | google/openhtf, openhwgroup/core-v-verif |

---

## Selected Repositories

### 1. google/openhtf — The Open-Source Hardware Testing Framework

- **URL**: https://github.com/google/openhtf
- **Stars**: ~651
- **Language**: Python (85.6%)
- **Latest Release**: v1.6.0 (March 2025)

#### Step Depth
OpenHTF defines a clear 4-layer abstraction for hardware tests:
1. **Test** — top-level container; a series of phases executed against a DUT (Device Under Test)
2. **Phase** — a Python callable with metadata; ordered sequence defining logical blocks of work (setup, measure, teardown)
3. **Measurement** — data gathered about the DUT, declared with specifications (validators) defining "passing" values
4. **Plug** — hardware interaction code enabling communication with DUT or test equipment; supports built-in and custom implementations

A typical test flow: import openhtf -> define phases as decorated functions -> declare measurements with specs -> instantiate Test with phases -> call Execute().

#### Source Lists
- No formal standards cited directly (IEC, ISO)
- References Python ecosystem (pip, virtualenv, protobuf compiler)
- Designed to be general enough for "lab bench to manufacturing floor"

#### Analysis Frameworks
- **Measurement validators**: automatic pass/fail evaluation against declared specs (range, regex, custom callable)
- **Test outcomes**: PASS (all measurements in spec), FAIL (one or more out of spec), ERROR (exception during phase)
- **Phase results**: CONTINUE, REPEAT, STOP, SKIP — enabling conditional test flow

#### Quality Standards
- Tests fail if "one or more measurements were out of that spec" — binary pass/fail per measurement
- Framework enforces measurement declaration before execution (no ad-hoc data capture)
- Test records capture full provenance: DUT ID, phase timing, measurement values, outcome

#### Anti-patterns
- Mixing test logic with infrastructure code (OpenHTF exists to separate these)
- Ad-hoc measurement without declared specs (framework forces spec-first approach)
- Tight coupling to specific hardware (Plug abstraction enables swappable backends)

---

### 2. sschaetz/awesome-hardware-test — Curated List of HW Test Projects

- **URL**: https://github.com/sschaetz/awesome-hardware-test
- **Stars**: ~130
- **License**: GPL-3.0

#### Step Depth
Categorizes hardware testing into 7 functional layers:
1. **Test Execution Engines** — frameworks running test sequences (openhtf, htf, exclave, HardPy, mats, robotframework, pytest-embedded)
2. **Instrument Interface** — controlling measurement devices (pyvisa, Test controller for DMMs/power supplies)
3. **Hardware Devices** — physical test equipment (NanoVNA spectrum analyzer, ppk2 power profiler, Red Pitaya DAQ, tinySA)
4. **Hardware Mocking** — simulation for CI (pyvisa-sim, umockdev for Linux device mocking)
5. **Test Database & Analytics** — result storage (TofuPilot, yieldHUB semiconductor analytics)
6. **Wafer Maps** — semiconductor-specific visualization (stdf2map, wafermap Kibana plugin)
7. **Test Suites for Specific Hardware** — reference implementations (HTX for OpenPOWER, hwtests for GameCube/Wii)

#### Source Lists
- **htf** explicitly certified for ISO/TR 80002-2 (medical device software lifecycle)
- References STDF (Standard Test Data Format) for semiconductor testing
- Links to educational resources: danafosmer.com (medical device testing), testview.wordpress.com (electronics testing)

#### Analysis Frameworks
- Implicit taxonomy: test execution vs. instrumentation vs. analytics vs. mocking
- Each tool described with primary use case (lab bench, manufacturing floor, semiconductor, embedded)
- Tool selection criteria emerge from descriptions: language (Python/Rust/C++), domain (medical/semiconductor/general), deployment (factory/lab)

#### Quality Standards
- htf: ISO/TR 80002-2 compliance for medical device testing
- STDF format for semiconductor test data exchange
- Pytest integration pattern (HardPy, pytest-embedded) as de-facto standard

#### Anti-patterns
- Using paper checklists / Excel for production testing (explicitly called out in linked Epsilon3 article)
- Tight coupling to specific instruments without abstraction layer (pyvisa-sim exists to solve this)
- No hardware mocking in CI pipeline (umockdev and pyvisa-sim listed as solutions)
- Missing test database — running tests without persistent result storage

---

### 3. ben-marshall/awesome-open-hardware-verification

- **URL**: https://github.com/ben-marshall/awesome-open-hardware-verification
- **Stars**: ~200+ (well-established, frequently cited)
- **License**: MIT

#### Step Depth
Organized into 6 verification categories with specific tool chains:
1. **Formal Verification** — mathematical proof of correctness (SymbiYosys, EBMC/CBMC model checkers, MCY mutation coverage)
2. **Simulation** — behavioral verification (Verilator for fast C++ simulation, Icarus Verilog for 4-state X/Z support)
3. **Build & CI** — reproducible verification (FuseSoC package manager, LibreCores CI for hardware projects)
4. **Code Generation** — test stimulus creation (riscv-dv instruction generator, AAPG assembly program generator, rggen register generator)
5. **Coverage & Analysis** — completeness metrics (covered for Verilog code coverage, svlint SystemVerilog linter, Surelog parser)
6. **Testbench Frameworks** — reusable environments (cocotb Python cosimulation, python-uvm, UVVM/OSVVM for VHDL, VUnit)

#### Source Lists
- UVM (Universal Verification Methodology) — industry-standard verification methodology
- SystemVerilog IEEE 1800 standard (implicit through tool support)
- RISC-V ISA specification (through riscv-dv, riscv-formal)
- Verification IPs for standard bus protocols: AXI, PCIe, Ethernet, APB, USB

#### Analysis Frameworks
- **Mutation testing** (MCY): measures testbench quality by injecting faults and checking detection rate
- **Code coverage**: line, branch, toggle coverage via Verilator and covered
- **Functional coverage**: cocotb-coverage extends cocotb with SystemVerilog-style functional coverage bins
- **Formal vs. simulation tradeoff**: formal for exhaustive proof of small properties, simulation for system-level behavior

#### Quality Standards
- Key principle: entries must be "open source themselves AND usable by people developing open source hardware using open source tools"
- Verification IP completeness: pre-built models for AXI, PCIe, Ethernet, APB, USB protocols
- Coverage-driven verification: tests are not complete until coverage targets are met

#### Anti-patterns
- Design tools claiming verification benefits without concrete verification capability (explicitly filtered out)
- Incomplete testbenches without coverage metrics (mutation testing via MCY catches this)
- Relying solely on simulation without formal verification for critical properties
- Not using linting (svlint) before simulation — catches syntax/style issues early

---

### 4. IRNAS/ppk2-api-python — Power Profiler Kit II Python API

- **URL**: https://github.com/IRNAS/ppk2-api-python
- **Stars**: ~221
- **License**: GPL-2.0

#### Step Depth
Provides a 4-step power measurement workflow:
1. **Initialize** — connect to PPK2 via serial, set source meter mode, configure voltage (mV)
2. **Sample** — poll `get_data()` at configurable intervals, parse raw bytes to microampere values
3. **Process** — use `get_samples()` to convert raw data; multiprocessing version recommended for completeness
4. **Analyze** — compute average current, peak current, energy consumption over time window

#### Source Lists
- Nordic Semiconductor PPK2 hardware specification
- Serial communication protocol (undocumented, reverse-engineered from official nRF Connect app)
- No formal measurement standards (IEC, NIST) referenced

#### Analysis Frameworks
- Data unit: microamperes (uA) — suitable for low-power IoT device profiling
- Buffer capacity: 10 seconds default in multiprocessing version
- Sampling completeness: standard version "will struggle to get all samples" — quantitative data loss acknowledged

#### Quality Standards
- No explicit accuracy specifications or measurement thresholds documented
- Relies on Nordic PPK2 hardware calibration (factory-calibrated)
- GPL-2.0 license: derivative work must maintain same license

#### Anti-patterns
- Using standard (non-multiprocessing) polling for production measurements — documented data loss
- Not configuring voltage before sampling — undefined behavior
- Assuming serial port stability without error handling
- Missing calibration verification step before measurement campaign

---

### 5. openhwgroup/core-v-verif — CORE-V RISC-V Verification

- **URL**: https://github.com/openhwgroup/core-v-verif
- **Stars**: ~671
- **License**: Apache-2.0

#### Step Depth
Implements UVM (Universal Verification Methodology) verification with structured phases:
1. **Environment Setup** — UVM testbench with SystemVerilog agents, scoreboards, coverage collectors
2. **Stimulus Generation** — constrained-random test generation + directed tests (Assembly 64.6% of codebase)
3. **Coverage Collection** — functional coverage bins for ISA compliance, code coverage via simulation
4. **Regression** — automated regression suites with pass/fail tracking

#### Source Lists
- RISC-V ISA specification (primary compliance target)
- UVM 1.2 methodology (IEEE 1800.2)
- OpenHW Group governance and contribution guidelines
- SV/UVM coding style guidelines (project-specific)

#### Analysis Frameworks
- Coverage reports stored in `/docs` directory
- ISA compliance verification against RISC-V specification
- Functional coverage model based on instruction types, privilege modes, exception scenarios

#### Quality Standards
- UVM-based pass/fail: scoreboard comparison of expected vs. actual behavior
- Coverage closure targets (not publicly specified but implied by coverage report infrastructure)
- Contribution quality: "avoid mixing unrelated changes into single commits"

#### Anti-patterns
- Mixing unrelated changes into single commits (explicitly warned)
- Writing vague commit messages
- Creating large, monolithic contributions
- Self-checking tests without coverage metrics (coverage reports are mandatory infrastructure)

---

### Supplementary: EMC Pre-Compliance Testing (krishnawa.github.io)

- **URL**: https://krishnawa.github.io/posts/EMC-Testing-in-GTEM-Cell/
- **Not a GitHub repo** but hosted on GitHub Pages; extremely detailed EMC testing reference.

#### Step Depth (4 test types, each with specific procedure)
1. **Radiated Emission (RE)**: place EUT inside GTEM cell on non-conductive support -> measure with spectrum analyzer 30 MHz-1 GHz -> apply correction factors for 3m/10m distance correlation -> use quasi-peak detector
2. **Radiated Immunity (RI)**: per IEC 61000-4-3 -> expose EUT to RF field 80 MHz-6 GHz -> 0.8m above ground plane -> test both horizontal and vertical polarization -> 1 kHz sine, 80% AM modulation
3. **Conducted Emission (CE)**: use LISN (50uH/50ohm) -> measure RF voltage on AC power lines 150 kHz-30 MHz
4. **Conducted Immunity (CI)**: per IEC 61000-4-6 -> inject 1 kHz sine 80% AM via current injection probe 150 kHz-80 MHz

#### Source Lists (Comprehensive Standards)
- **FCC**: Title 47 CFR Part 15 (Subparts B, C, E), Class A (industrial) vs. Class B (residential)
- **CISPR**: CISPR 11, 22, 32, 14
- **IEC**: IEC 61000-4 series (immunity testing methods)
- **EU**: EN 55032, EN 55024, EN 61000-4-x series

#### Quality Standards (Specific Numeric Thresholds)

Radiated emission limits (FCC):
| Frequency | Class A (10m) | Class B (3m) |
|-----------|---------------|-------------|
| 30-88 MHz | 39.1 dBuV/m | 40.0 dBuV/m |
| 88-216 MHz | 43.5 dBuV/m | 43.5 dBuV/m |
| 216-960 MHz | 46.4 dBuV/m | 46.0 dBuV/m |
| >960 MHz | 49.5 dBuV/m | 54.0 dBuV/m |

Conducted emission limits (FCC):
| Frequency | Class A (QP) | Class B (QP) |
|-----------|-------------|-------------|
| 150 kHz-500 kHz | 79 dBuV | 66->56 dBuV |
| 500 kHz-5 MHz | 73 dBuV | 56 dBuV |
| 5-30 MHz | 73 dBuV | 60 dBuV |

Radiated immunity test levels: Level 1 (1 V/m), Level 2 (3 V/m), Level 3 (10 V/m), Level 4 (30 V/m, military: up to 200 V/m)

#### Anti-patterns
- Testing without chamber calibration (must verify 16 points in 1.5m x 1.5m area first)
- Skipping dual-polarization antenna testing (both H and V required)
- Frequency step size >1% of current frequency (insufficient resolution)
- Dwell time <0.5 seconds per frequency (insufficient settling)
- EUT cables touching reference ground plane (must be elevated 30mm)
- Missing decoupling networks on untested cables

---

## Synthesis

### Pattern 1: Layered Test Architecture
All mature frameworks separate concerns into layers: **execution engine** (openhtf, htf, robotframework) -> **instrument abstraction** (pyvisa, plugs) -> **measurement declaration** (specs, validators) -> **result storage** (database, reports). Domain packs should mirror this layering.

### Pattern 2: Spec-First Measurement
OpenHTF's strongest pattern: measurements MUST be declared with pass/fail specifications BEFORE execution. This prevents ad-hoc "measure and decide later" approaches that lead to ambiguous test outcomes. The hw-testing domain pack should enforce spec-first measurement declaration in every test capability.

### Pattern 3: Coverage as Completeness Metric
Both awesome-open-hardware-verification and core-v-verif use coverage metrics (code coverage, functional coverage, mutation testing) as the primary measure of verification completeness — not "number of tests." The domain pack should include coverage analysis as a mandatory step.

### Pattern 4: Hardware Mocking for CI
The awesome-hardware-test list explicitly includes hardware mocking tools (pyvisa-sim, umockdev) as a distinct category. This acknowledges that hardware tests MUST have a simulation path for CI/CD pipelines where physical hardware is unavailable.

### Pattern 5: Standards-Driven Thresholds
EMC testing demonstrates the gold standard: every test has numeric pass/fail thresholds derived from international standards (FCC, CISPR, IEC). Power measurement (ppk2) shows the opposite — no thresholds, leaving pass/fail to the user. Domain pack capabilities should require explicit threshold sources (standard, datasheet, or engineering specification).

### Pattern 6: Anti-Pattern Awareness
Across all repos, the most common anti-patterns are:
- Testing without declared pass/fail criteria (measurement without spec)
- No hardware abstraction (tests coupled to specific equipment)
- Missing test database (results lost after execution)
- Paper/Excel-based test management (no traceability)
- Skipping calibration verification before measurement campaigns
- Self-assessment without external coverage metrics

### Pattern 7: Medical/Safety Domain Requires Certification
htf's ISO/TR 80002-2 certification shows that regulated domains need framework-level compliance, not just test-level. The domain pack should flag when a project's domain (medical, automotive, aerospace) requires certified test frameworks.
