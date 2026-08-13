---
name: hw-circuit-design
description: "Hardware circuit design capability pack. Covers component selection with supply-chain risk rating, KiCad schematic design with ERC, PCB layout/routing with DRC and manufacturing export, dual-supplier BOM management with cost analysis, power architecture and battery-life budgeting, 4-phase design review with anti-pattern scanning, and design documentation with decision records. Use for any circuit design, schematic, PCB layout, BOM, power budget, or hardware design review task."
version: 0.1.0
type: reference-based
keywords: ["circuit design", "电路设计", "hardware", "硬件", "schematic", "原理图", "PCB", "PCB 布局", "layout", "routing", "布线", "KiCad", "kicad-cli", "ERC", "DRC", "Gerber", "BOM", "料号", "MPN", "component selection", "元器件选型", "供应链", "power design", "电源设计", "功耗预算", "battery life", "电池续航", "LDO", "DCDC", "ESP32", "E-ink", "OLED", "decoupling", "去耦电容", "EMC", "ESD", "天线净空", "design review", "设计评审", "设计文档", "制造文件"]
---

# Hardware Circuit Design Capability Pack

> From requirements to manufacturing-ready design — schematic, PCB, BOM, power analysis as real artifacts, not paper advice.
> Scope: ESP32-family MCUs (C3/S3 primary), low-power IoT devices, battery powered, E-ink/OLED displays. NOT covered: high-frequency RF design (>2.4GHz, antennas excepted) and high-voltage circuits (>48V).
> Every parameter comes from a datasheet or supplier page. 编造数据 = FAIL — mark guesses [INFERRED], missing [NOT FOUND], prices [ESTIMATED], compromises [TRADEOFF].

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| pick MCU/display/power IC, 选型, candidate comparison, 替代器件, supply chain risk, 停产, datasheet compare | `references/component-selection.md` |
| draw schematic, 原理图, KiCad sheet, net label, decoupling, 去耦, boot pins, reset circuit, ERC errors | `references/schematic-design.md` |
| board layout, 布局布线, trace width, 线宽, ground plane, antenna keepout, 天线净空, DRC, Gerber export, 制造文件 | `references/pcb-layout.md` |
| BOM, 物料清单, MPN, LCSC/DigiKey part numbers, cost estimate, 成本, dual supplier, 采购清单, MOQ | `references/bom-management.md` |
| power architecture, 电源架构, LDO vs DCDC, charging, 充电, power budget, 功耗, battery life, 续航估算 | `references/power-design.md` |
| review the design, 设计评审, pre-fab check, ERC/DRC final run, anti-pattern scan, 投产前检查 | `references/design-review.md` |
| design spec, 设计文档, decision records, DDR, GPIO table, manufacturing guide, 制造指导, file package | `references/design-documentation.md` |
| before gate review / accepting circuit design work, persona checklist, 专家评审清单, acceptance | `references/review-checklist.md` |

**Multi-signal**: load all matched references. Before declaring ANY deliverable complete, read its Quality Bar (pass/fail) section in the matched reference — those are the acceptance rules — then run the matching persona checklist in `references/review-checklist.md`.

---

## Step 2: Decision Entry Point

**Q1 — What stage is the request?**
- New design from requirements → `component-selection.md` first (candidates → analysis → primary+backup), then `schematic-design.md`
- Schematic exists, going to board → `pcb-layout.md` (parameters from manufacturer capability, then place → route → DRC)
- Need purchasable parts list / cost → `bom-management.md`
- Battery/power questions (topology, budget, runtime) → `power-design.md`
- Ready for fab / "is this design OK?" → `design-review.md` + `review-checklist.md` — full ERC/DRC + anti-pattern scan + 4-phase expert review BEFORE ordering
- Handing over / archiving the design → `design-documentation.md`

**Q2 — Which regulator?** (from power-design)
- LDO: dropout <1V, current <500mA, low-noise required
- DCDC Buck: large dropout, high current, efficiency first (switching saves 10-20% over LDO at high dropout)
- Charge pump: negative rail or low-current boost only

**Q3 — Board stackup?** (from pcb-layout)
- 2-layer: simple design, cost first (ESP32 module-based OK)
- 4-layer: complex design or high EMC demands (ESP32 bare-chip recommended)

**Q4 — Error caught late costs more (Rule of 10)**: schematic 1x → layout 10x → prototype 100x → production 1000x. Front-load review effort accordingly.

---

## Step 3: Core Judgment Rules

### Component Selection (`references/component-selection.md`)
- ≥3 candidates per functional module; every selected part gets a primary + backup with pin-compatibility level (drop-in / PCB change / firmware change).
- Every parameter cites datasheet page or URL. Power data must include BOTH active and sleep currents.
- Supply-chain risk rated LOW/MEDIUM/HIGH (multi-supplier+in-stock / single channel / EOL-warning or >12-week lead). Require at least one non-LCSC channel.
- Capacitor derating: ceramic rated ≥2× working voltage (50%), electrolytic ≥1.25× (80%). Crystal for ESP32: ±10ppm across temperature range.
- Check device lifecycle status (Active/NRND/EOL) before committing.

### Schematic Design (`references/schematic-design.md`)
- Modular split by function + electrical isolation (power / MCU core / display / sensor-comm / connectors); >50 components → hierarchical sheets.
- Every IC's peripheral circuit follows its datasheet typical-application. Self-invented circuits = risk.
- Decoupling: 100nF per VDD pin + shared 10uF. ESP32 boot strapping (GPIO0 + EN) handled. Unused GPIOs never floating.
- Net naming: UPPERCASE_UNDERSCORE, one convention (VCC_3V3, never mixed 3V3/3.3V/VCC).
- ERC gate: 0 ERROR; every WARNING gets an explicit fix/waive decision with reason.

### PCB Layout (`references/pcb-layout.md`)
- Placement order: connectors (enclosure-driven) → key ICs → decoupling caps tight to VDD pins (≤7mm, ideally ≤3mm) → crystal tight to MCU.
- Trace widths: power ≥20mil, high current ≥40mil, signal 8-10mil; USB differential pair 90Ω ±10%, skew <25ps; crosstalk spacing ≥3× trace width.
- ESP32 antenna keepout: no copper or traces within 15mm. Ground plane integrity >80%; high-speed signals never cross plane splits; nothing routes under the crystal.
- DRC gate: 0 violations against the target fab's rules (嘉立创/PCBWAY capability, not arbitrary values). Antenna keepout and cap placement need manual re-check — DRC can't see them.

### BOM Management (`references/bom-management.md`)
- 100% coverage (every schematic component has a BOM row) with MPN + at least one supplier PN; "TBD" ≤10%.
- Dual-supplier coverage ≥80% overall, 100% for key ICs. Flag single-source, long-lead (>8 weeks), EOL/NRND parts.
- Prices from real supplier quotes with date and quantity tier; unify passive footprints to cut part-number count.

### Power Design (`references/power-design.md`)
- Budget every module's current in every mode (active/sleep) from datasheets with duty cycle → average + peak current; include regulator efficiency (LDO ~90%, DCDC ~85-95%).
- Battery runtime = capacity / avg current × 0.8 derating; account self-discharge (LiPo ~3%/mo) and cold-temperature capacity loss (10-30%). Estimate ≥3 usage scenarios.
- Regulator headroom: LDO max output > 1.5× peak load, DCDC > 1.3×; thermal check P=(Vin−Vout)×I, Tj <125°C.
- Verify power-up sequencing, USB-unplug battery switchover, and low-battery cutoff vs MCU minimum voltage.

### Design Review (`references/design-review.md`)
- Sequence: automated ERC/DRC + BOM/netlist consistency → anti-pattern scan (derating, decoupling distance, missing protection, signal integrity — with numeric evidence, not "looks OK") → 4-phase expert review (architecture → module → component → automated; Schemalyzer methodology) → report.
- ≥20 checklist items each judged PASS/FAIL/NA; every FAIL gets a concrete fix. CRITICAL issues = 0 to release; >0 blocks fab.
- Tool outputs attach verbatim. Faking a PASS = severe violation.

### Design Documentation (`references/design-documentation.md`)
- Documents cover WHY (decision records: background/options/decision/reason/impact), not just WHAT.
- GPIO allocation table complete and matching the schematic; doc version tracks schematic version.
- Manufacturing guide concrete enough to hand a factory directly (PCB spec + SMT + test procedure + pass thresholds). Record known issues for the next revision.

### Review Personas (`references/review-checklist.md`)
- Before gate review / accepting any capability's circuit design output: run the two matching personas' checklists (supply-chain/hardware, EE/EMC, PCB/manufacturing, procurement/cost, power/reliability, chief-HW/quality, doc/PM). Every item answered with evidence — no vague "OK".

---

## Anti-Patterns

### Component Selection
- ❌ 只看一个供应商就选型 = 供应链风险
- ❌ 不查 datasheet 就写功耗数据 = 编造
- ❌ 选最便宜的不考虑供货 = 断供风险
- ❌ 不考虑封装兼容性（QFN vs WLCSP 对手焊影响完全不同）
- ❌ 忽略 GPIO 数量限制导致后期改 MCU = 返工
- ❌ 不做电容降额直接用额定值 = 寿命和可靠性风险（陶瓷电容 DC bias 效应导致实际容值下降）
- ❌ 忽略器件生命周期状态（Active/NRND/EOL）= 量产时断供 — 来源: Espressif guidelines

### Schematic Design
- ❌ 不看 datasheet 典型电路就画原理图 = 电气风险
- ❌ 去耦电容省略或随意放 = EMI/稳定性问题
- ❌ ESP32 未处理 GPIO0/EN 的 boot 模式 = 无法下载
- ❌ 未使用 GPIO 悬空 = 噪声和功耗
- ❌ 电源网络命名不一致（混用 3V3/3.3V/VCC）= 连接错误
- ❌ 忽略 FPC 连接器 pin 序号方向 = 显示屏接反

### PCB Layout
- ❌ 去耦电容远离 IC = 形同虚设（>7mm 等于没放 — kicad-happy）
- ❌ 天线区域下方铺铜 = WiFi/BLE 信号严重衰减
- ❌ 电源走线太细承载大电流 = 发热甚至烧毁
- ❌ 地平面被走线割裂 = EMI 问题（高速信号绝不能跨越地平面分割 — 多个 PCB review repo 共识）
- ❌ 忽略制造商最小工艺能力 = 无法生产
- ❌ 不检查 FPC 连接器方向 = 显示屏插反
- ❌ ESD/TVS 放在电路后面而非连接器处 = 保护无效（必须在连接器和电路之间 — Schemalyzer review guide）
- ❌ 热焊盘 via 数量不足 = 散热不良（QFN exposed pad 需要 ≥4 个 via — kicad-happy thermal check）

### BOM Management
- ❌ BOM 缺少 MPN（只写 '10kΩ 电阻' 无法采购）
- ❌ 单一供应商无备选 = 断供风险
- ❌ 价格编造（不查供应商网站就写价格）= 成本失控
- ❌ 不合并相同器件 = 料号种类过多增加管理成本
- ❌ 忽略 MOQ（最小起订量）= 原型阶段买不到

### Power Design
- ❌ 用 datasheet typical 值当 max 用 = 余量不足
- ❌ 忘记稳压器自身功耗和效率 = 实际续航比计算短
- ❌ 不考虑峰值电流只看平均 = 稳压器过载
- ❌ 电池续航不降额 = 过于乐观
- ❌ 不考虑温度对电池容量的影响 = 冬天没电
- ❌ LDO 压差 >1V 且电流 >100mA 不考虑散热 = 过热

### Design Review
- ❌ 跳过 ERC/DRC 直接说'设计没问题' = 纸面验收
- ❌ FAIL 项没有修复建议 = 无用评审
- ❌ 只做自动检查不做人工评审 = 遗漏设计缺陷
- ❌ 评审报告模板化不关联实际设计 = 走过场
- ❌ 不检查 BOM 一致性 = 采购错误器件
- ❌ 压制 ERC 警告不调查原因 = 隐藏错误（Schemalyzer anti-pattern — net label typos 导致静默断连）
- ❌ 忽略错误成本乘数效应：原理图阶段 1x → 布局 10x → 打样 100x → 量产 1000x（Schemalyzer Rule of 10）

### Design Documentation
- ❌ 只有原理图没有设计说明 = 后人无法理解设计意图
- ❌ 设计决策不记录 = 下次迭代重新踩坑
- ❌ 制造指导模糊（'请注意焊接质量'）= 工厂无法执行
- ❌ 文档和实际设计不同步 = 误导后续开发
- ❌ 不记录已知问题 = 下一版本忘记修复
- ❌ GPIO 表缺失或与原理图不一致 = 软件开发走弯路

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "This part is probably fine" | MUST compare ≥3 candidates with datasheet-cited parameters (`component-selection.md`) — 无数据支撑的选型 = FAIL |
| "I'll write typical power numbers" | MUST cite datasheet page for every current value, active AND sleep — invented data is an automatic FAIL |
| "ERC warnings are just noise" | MUST decide fix/waive per WARNING with reason (`schematic-design.md` §3) — suppressed warnings hide broken nets |
| "Layout looks reasonable" | MUST pass DRC 0-violation + manual antenna-keepout and decoupling-distance checks (`pcb-layout.md` §3) |
| "BOM prices are roughly right" | MUST quote real supplier prices with date and quantity tier (`bom-management.md`) — [ESTIMATED] only when marked |
| "Battery will last long enough" | MUST compute runtime with 0.8 derating + temperature effect across ≥3 scenarios (`power-design.md`) |
| "Design is done, send to fab" | MUST run full `design-review.md` flow: ERC/DRC + anti-pattern scan + 4-phase review, 0 CRITICAL before ordering |
| "Deliverable done, moving on" | MUST run the matching persona checklist in `references/review-checklist.md` before marking any capability complete |
