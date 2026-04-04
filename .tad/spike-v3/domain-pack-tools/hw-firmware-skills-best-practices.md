# HW Firmware Skills — Best Practices Research

> Research date: 2026-04-03
> Focus: Embedded firmware development best practices (ESP32/Arduino focus)

---

## Search Log

| Search Term | Results Found | Repos Selected |
|------------|--------------|----------------|
| GitHub firmware ESP32 arduino skills SKILL.md | 10 results, mostly espressif official repos | espressif/arduino-esp32 (context only) |
| GitHub AI agent embedded development PlatformIO | 10 results, MCP server + PlatformIO core | jl-codes/platformio-mcp, platformio/platformio-core |
| GitHub embedded code review checklist C C++ | 10 results, strong checklist repos + CMU resource | swomack/cpp-code-review-checklist, Koopman CMU checklist (non-GitHub) |
| GitHub ESP32 firmware best practices power management | 10 results, ESP-IDF official docs | espressif/esp-idf (power management docs) |
| embedded systems design patterns 2026 | 10 results, pattern books + Embedded Artistry | ksvbka/design_pattern_for_embedded_system, Embedded Artistry catalogue |
| awesome-embedded github firmware best practices | 10 results, curated lists | nhivp/Awesome-Embedded, memfault/awesome-embedded |

**Note:** Search 1 returned no "SKILL.md" files — this concept does not exist in the embedded GitHub ecosystem. All other searches produced actionable results.

---

## Selected Repositories

### 1. nhivp/Awesome-Embedded

- **URL:** https://github.com/nhivp/Awesome-Embedded
- **Stars:** ~8,300
- **Description:** Curated list of embedded programming resources covering MCUs, RTOS, bootloaders, Linux kernel, automotive, and ML on MCUs.

#### Step Depth
- No procedural steps — this is a reference index. Value is in the breadth of categorized resources.
- Categories: Interview prep, MCU programming (MSP430, TM4C123, STM32, ESP8266), RTOS (FreeRTOS, RT-Thread), bootloaders, peripherals (MPU, USB), embedded GUI, ML on MCUs.
- Each category links to tutorials with step-by-step learning paths (external).

#### Source Lists
- Books: "Exploring Raspberry Pi: Interfacing to the Real World with Embedded Linux"
- Courses: Stanford CS140e (OS), CS107e (Computer Systems), Modern Embedded Systems Programming Course
- Standards: AUTOSAR automotive standards
- Build systems: Yocto Project, Buildroot

#### Analysis Frameworks
- Implicit categorization scheme: MCU family → peripherals → RTOS → application domain
- No decision matrices or comparison tables provided.

#### Quality Standards
- No explicit quality thresholds. Resource is a curated link collection.
- Implicit quality gate: inclusion in the list itself (community curation).

#### Anti-patterns
- None documented. This is a gap — the list tells you what to use but not what to avoid.

---

### 2. ksvbka/design_pattern_for_embedded_system

- **URL:** https://github.com/ksvbka/design_pattern_for_embedded_system
- **Stars:** ~204
- **Description:** C implementations of patterns from Bruce Powel Douglass's "Design Patterns for Embedded Systems in C" book.

#### Step Depth
- Organized into chapter-based implementations (chap1, chap2, chap3) following the book structure.
- Each pattern has a C implementation demonstrating the pattern in embedded context.
- Patterns include: Hardware Proxy, Observer, State Machine, Mediator, and architectural patterns for resource-constrained systems.

#### Source Lists
- Primary source: "Design Patterns for Embedded Systems in C: An Embedded Software Engineering Toolkit" (Bruce Powel Douglass, ISBN 1856177076)
- Full PDF included in repo for reference.
- Secondary: Gang of Four patterns adapted for C (no C++ classes available).

#### Analysis Frameworks
- Pattern selection framework: choose pattern based on resource constraints (RAM/ROM), real-time requirements, and hardware abstraction needs.
- Chapter organization implies progression: basic patterns → architectural patterns → advanced patterns.

#### Quality Standards
- MIT License compliance.
- 90.1% C / 9.9% C++ code split — demonstrates patterns can work in pure C environments.
- No explicit testing framework or CI.

#### Anti-patterns
- Implicit: the book specifically addresses why OOP patterns from GoF fail in embedded C and how to adapt them.
- Using dynamic memory allocation patterns from desktop software in memory-constrained embedded systems.

---

### 3. platformio/platformio-core

- **URL:** https://github.com/platformio/platformio-core
- **Stars:** ~9,000
- **Description:** Cross-platform build system, debugger, static analyzer, and unit testing framework for embedded development. Supports 1,000+ boards across 30+ platforms.

#### Step Depth
- Complete firmware development workflow documented: init project → configure board → write code → build → upload → debug → test.
- Declarative project configuration via `platformio.ini` — board, framework, libraries, build flags all in one file.
- CI/CD integration documented for GitHub Actions, Travis CI, CircleCI.
- Remote unit testing workflow: write tests → run on target hardware → collect results.

#### Source Lists
- PlatformIO Registry: https://registry.platformio.org (libraries, platforms, tools)
- Official docs: https://docs.platformio.org
- Supported frameworks: Arduino, ESP-IDF, STM32Cube, Mbed, Zephyr, CMSIS
- Board database spanning ESP32, ESP8266, STM32, AVR, ARM, RISC-V

#### Analysis Frameworks
- Board compatibility matrix: framework × board × platform
- Library dependency resolver with semantic versioning
- Static code analysis integration (cppcheck, PVS-Studio compatible)
- Memory inspection: firmware size analysis, RAM/ROM usage breakdown

#### Quality Standards
- Static code analysis as built-in feature
- Unit testing with both native (host) and embedded (on-device) execution
- Build must pass without warnings (configurable strictness)
- Telemetry enabled by default (warning: privacy consideration)

#### Anti-patterns
- Hardcoding board-specific configurations instead of using `platformio.ini` abstraction
- Skipping the library dependency manager and manually copying source files
- Not using the built-in static analysis before code review
- Uploading firmware without verifying build output (size, memory usage)

---

### 4. espressif/esp-idf (Power Management Documentation)

- **URL:** https://github.com/espressif/esp-idf
- **Stars:** ~14,000+
- **Description:** Official Espressif IoT Development Framework for ESP32 family. Power management module provides DFS, Light-sleep, and power lock APIs.

#### Step Depth
- Configuration sequence: Enable `CONFIG_PM_ENABLE` → set `max_freq_mhz` / `min_freq_mhz` / `light_sleep_enable` → call `esp_pm_configure()` → acquire/release power locks as needed.
- Three power lock types with reference-counted acquire/release semantics:
  - `ESP_PM_CPU_FREQ_MAX` — forces max CPU frequency
  - `ESP_PM_APB_FREQ_MAX` — maintains APB at 80 MHz
  - `ESP_PM_NO_LIGHT_SLEEP` — prevents auto Light-sleep
- Debug workflow: `esp_pm_dump_locks()` → inspect lock status → `esp_pm_get_lock_stats_all()` → aggregate metrics.

#### Source Lists
- ESP-IDF Programming Guide (official): https://docs.espressif.com/projects/esp-idf/
- ESP32-C3 Wireless Adventure book (Espressif): https://espressif.github.io/esp32-c3-book-en/
- FreeRTOS tickless idle documentation
- Hardware Technical Reference Manuals for each ESP32 variant

#### Analysis Frameworks
- Power consumption analysis: active mode vs. light-sleep vs. deep-sleep current draw
- Frequency scaling trade-off matrix: frequency → power draw → interrupt latency
- Clock source selection: REF_TICK, XTAL, RC_FAST — immune to APB frequency changes

#### Quality Standards
- **Interrupt latency overhead:** 0.2 us minimum (240 MHz, no scaling) to 40 us maximum (40→80 MHz switch)
- **Minimum CPU frequency:** 10 MHz (ESP32/ESP32-S2, required for 1 MHz REF_TICK)
- **Tick overflow protection:** default 2 ticks before overflow triggers
- Power lock acquire/release must be balanced (reference-counted)

#### Anti-patterns
- Holding power management locks longer than necessary (increases current consumption)
- Enabling Light-sleep without `CONFIG_FREERTOS_USE_TICKLESS_IDLE` (returns `ESP_ERR_NOT_SUPPORTED`)
- Assuming GPIO state persists during sleep (IO_MUX doesn't maintain state — use `gpio_hold_en()`)
- Not using `skip_unhandled_events` for timers (causes unnecessary wakeups from sleep)
- Using APB-dependent clock sources for peripherals during DFS (frequency changes break timing)

---

### 5. Koopman & Khattak — Embedded System Code Review Checklist (CMU)

- **URL:** http://users.ece.cmu.edu/~koopman/essays/code_review_checklist.html
- **Stars:** N/A (academic resource, not a GitHub repo)
- **Description:** Comprehensive 8-category, 63+ item code review checklist for embedded systems by Philip Koopman (Carnegie Mellon University).

#### Step Depth
- 8 review categories with specific numbered items:
  1. **FUNCTION** (10 items): correctness, design alignment, simplification, building block reuse, control flow, variable init, function cohesion
  2. **STYLE** (10 items): style guide compliance, documentation, commenting, naming, magic numbers, dead code, assembly necessity
  3. **ARCHITECTURE** (8 items): function length (fit on one printed page), reusability, global variable minimization, portability (`int32` not `int`), nesting depth
  4. **EXCEPTION HANDLING** (10 items): input validation, error propagation, null pointer handling, switch defaults, array bounds, overflow detection
  5. **TIMING** (8 items): worst-case timing, race conditions, ISR constraints (half-page max), interrupt masking duration, priority inversion, watchdog config
  6. **VALIDATION & TEST** (9 items): testability, branch coverage (100% target), compilation warnings (zero), corner cases, fault injection
  7. **HARDWARE** (8 items): I/O correctness, multi-byte register safety, reset state, brownout handling, sleep mode config, EEPROM protection

- Review process: 100-400 lines per 1-2 hour session, 3 reviewers, issues logged as "Line X violates Item Y."

#### Source Lists
- CMU Embedded Systems curriculum
- MISRA C coding standard (referenced for compilation prerequisites)
- Phil Koopman's embedded systems lecture series
- "Better Embedded System SW" blog (companion resource)

#### Analysis Frameworks
- 3-reviewer responsibility matrix: Reviewer #1 (items 1-7), #2 (items 8-15), #3 (items 16-22), All (items 23-24)
- For 2-reviewer model: R#1 covers 1-11 + 23-24, R#2 covers 12-24
- Issue recording format: structured "Line X / Item Y / Reason" — no fix suggestions during review

#### Quality Standards
- **Code review size:** 100-400 lines per session, 100-200 lines/hour pace
- **Function length:** must fit on one printed page
- **If/else nesting:** maximum 2 levels deep
- **Switch nesting:** zero (never nested)
- **Branch coverage:** 100% target
- **Compilation warnings:** zero tolerance
- **Cyclomatic complexity:** below 10-15 (from companion checklist)
- **ISR length:** maximum half-page of code
- **Review duration:** maximum 2 hours

#### Anti-patterns
- Loops inside ISRs
- Masking interrupts for excessive durations
- Multi-byte variables modified by interrupts without atomic access
- Using `#define` instead of `const` / `inline` / `enum`
- Embedded assignments inside boolean conditions
- Missing default clauses in switch statements
- Single-purpose variable reuse (e.g., `temp16` for multiple purposes)
- Not kicking the watchdog timer from every task
- Magic numbers in code instead of named constants
- Commented-out "test" code left in production

---

### 6. Embedded Artistry — Design Pattern Catalogue

- **URL:** https://embeddedartistry.com/fieldatlas/design-pattern-catalogue/
- **Stars:** N/A (website resource, comprehensive catalogue)
- **Description:** Categorized catalogue of design patterns applicable to embedded systems, spanning architecture, concurrency, safety, security, and testing.

#### Step Depth
- Patterns organized by category with descriptions and usage guidance:
  - **Architectural:** Layered Architecture, Hexagonal (Ports & Adapters), Event-Driven, Pub-Sub, Pipes & Filters
  - **General Software:** Callback, Facade, Mediator, Template Method, Adapter
  - **Asynchronous:** Active Object, Message Passing, Event Loop
  - **Embedded-Specific:** Monitor-Actuator Pair, State Machines (Ultimate Hook, Reminder, Deferred Event, Transition to History), Memory Allocation (Fixed, Variable, Pooled)
  - **Safety:** Single-point-of-failure elimination, watchdog patterns
  - **Security:** Authentication over encryption prioritization

#### Source Lists
- "Design Patterns: Elements of Reusable Object-Oriented Software" (Gamma et al.)
- "Pattern-Oriented Software Architecture" (Buschmann et al.)
- "Practical UML Statecharts in C/C++" (Miro Samek)
- "Small Memory Software" (Weir & Noble)
- "xUnit Test Patterns" (Meszaros)
- Phil Koopman's CMU lectures on safety and security
- Martin Fowler's refactoring and distributed systems patterns

#### Analysis Frameworks
- Pattern selection by concern: architecture → concurrency → safety → security → testing
- Coupling analysis: loose coupling as primary quality metric
- Hardware independence evaluation: can the code run without the target hardware?
- Memory strategy decision tree: Fixed (deterministic) vs. Variable (flexible) vs. Pooled (compromise)

#### Quality Standards
- Loose coupling between components (measurable by dependency count)
- Hardware independence for testability
- No single points of failure in safety-critical paths
- "Authentication and integrity are more important than encryption" (Koopman's security principle)
- Dependency injection for testability

#### Anti-patterns
- "Top 16 Embedded Security Pitfalls" (Koopman) — choosing encryption when authentication is needed
- Tightly coupling code to frameworks (makes testing impossible)
- Creating single points of failure in critical systems
- Using dynamic memory allocation without pooling in real-time systems
- Ignoring the Monitor-Actuator Pair pattern in safety-critical hardware control

---

## Synthesis

### Key Patterns Across All Sources

**1. Layered Quality Enforcement**
Every mature embedded resource uses multiple quality layers: static analysis → code review → unit testing → integration testing → hardware validation. PlatformIO builds this into the toolchain. Koopman formalizes it into a 24-item checklist with assigned reviewers. The ESP-IDF enforces it through `CONFIG_` compile-time checks.

**2. Hard Numeric Thresholds**
Embedded best practices converge on specific numbers:
- Function length: fits on one page (~50 lines)
- Cyclomatic complexity: < 10-15
- ISR length: half a page max
- Branch coverage: 100% target
- Compilation warnings: zero tolerance
- Nesting depth: max 2 levels (if/else), 0 levels (switch)
- Code review pace: 100-200 lines/hour, max 2 hours

**3. Power Management as First-Class Concern**
ESP-IDF treats power management as an API-level concern, not an afterthought. The reference-counted lock system (acquire/release with three lock types) is a reusable pattern. Key lesson: power management must be designed in from the start, not bolted on.

**4. Pattern Adaptation for Resource Constraints**
GoF patterns do not directly apply to embedded C. The design_pattern_for_embedded_system repo and Embedded Artistry catalogue both demonstrate how to adapt Observer, State Machine, Mediator, and Facade patterns for systems without dynamic allocation, inheritance, or exceptions.

**5. Anti-Pattern Convergence**
The same anti-patterns appear across all sources:
- Loops / complex logic inside ISRs
- Global variable overuse
- Magic numbers
- Missing error handling (especially switch defaults)
- `#define` abuse instead of `const`/`inline`/`enum`
- Holding locks/disabling interrupts too long
- Assuming hardware state persists across power transitions
- Skipping static analysis before review

**6. Tool Chain Maturity**
PlatformIO (9K stars) has become the de facto cross-platform embedded toolchain, integrating build, upload, debug, static analysis, and unit testing. The platformio-mcp project shows AI agents can already interact with this toolchain programmatically.

### Gaps Identified

1. **No "SKILL.md" convention exists** in embedded firmware repos — this is a TAD/AI-agent concept, not an embedded community convention.
2. **Limited ESP32-specific best practices on GitHub** — most content lives in Espressif's official docs, not community repos.
3. **Security checklists are sparse** — Koopman and Embedded Artistry reference security pitfalls but no repo has a comprehensive firmware security checklist with specific items.
4. **OTA update best practices are underdocumented** — mentioned in awesome-embedded (RAUC, SWUpdate) but no GitHub repo provides a step-by-step OTA design pattern for ESP32.

### Implications for Domain Pack Design

The hw-firmware domain pack should:
- Embed Koopman's numeric thresholds as quality gates (function length, complexity, coverage, ISR size)
- Use PlatformIO as the assumed toolchain (build, test, upload, analyze)
- Include power management as a dedicated capability (not a sub-item)
- Provide pattern selection guidance adapted from Embedded Artistry's catalogue
- Define anti-pattern detection as a review step (the convergent anti-patterns listed above)
- Teach ESP-IDF APIs explicitly (Claude doesn't know these well — domain.yaml must include usage examples)
