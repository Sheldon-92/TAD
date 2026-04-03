# Material Selection Report: Wayo 大象追踪器外壳

> Domain Pack: hw-enclosure / material_selection (Doc A)
> Date: 2026-04-02
> Project: Wayo Elephant Tracker Enclosure
> Constraints: ESP32-C3 + 5.65" E-ink + 18650 battery, outdoor IP54, temp -10~55°C

---

## Step 1: search_materials — Candidate Material Properties

### Product Requirements Summary
- **Environment**: Outdoor, -10°C to 55°C operating range, rain exposure (IP54+)
- **UV Exposure**: High — mounted outdoors on wildlife tracking infrastructure
- **Manufacturing**: Prototype FDM, small-batch SLA
- **Mechanical**: Must protect E-ink display + electronics, resist drops from ~1m

### Candidate Materials (FDM Prototype Phase)

| Property | PLA | PETG | ABS | ASA | Nylon (PA6) |
|----------|-----|------|-----|-----|-------------|
| Tensile Strength (MPa) | 60 | 50 | 40 | 44 | 70 |
| Flexural Modulus (GPa) | 3.5 | 2.0 | 2.1 | 2.0 | 1.4 |
| HDT @ 0.45 MPa (°C) | 55 | 63-80 | 98 | 85-96 | 180 |
| UV Resistance | Poor | Moderate | Poor | Excellent | Poor |
| Moisture Absorption (%) | 0.5 | 0.2 | 0.3 | 0.2 | 2.5 |
| Impact Resistance | Low (brittle) | Good | Good | Good | Excellent |
| Print Difficulty | Easy | Easy | Medium (warps) | Medium (warps) | Hard (hygroscopic) |
| Enclosed Printer Needed | No | No | Yes | Yes | Yes |

**Data Sources:**
- Tensile/flexural: [UnionFab ASA vs ABS vs PETG vs PLA comparison](https://www.unionfab.com/blog/2025/05/asa-vs-abs-vs-petg-vs-pla)
- HDT values: [Ultimaker PETG TDS](https://um-support-files.ultimaker.com/materials/2.85mm/tds/PETG/Ultimaker-PETG-TDS-v1.00.pdf), [Wevolver ASA article](https://www.wevolver.com/article/what-is-asa-filament-properties-uses-3d-printing-tips)
- UV resistance: [Filalab outdoor comparison](https://filalab.shop/abs-vs-asa-vs-petg-for-outdoor-3d-printing-which-filament-truly-survives-sun-heat-and-weather/)
- PLA HDT commonly cited as 55°C in manufacturer datasheets

### Candidate Materials (SLA Small-Batch Phase)

| Property | Standard Resin | ABS-like Resin | Tough Resin | Nylon-like (SLS) |
|----------|---------------|----------------|-------------|-------------------|
| Tensile Strength (MPa) | 50-65 | 40-55 | 45-55 | 48 |
| HDT (°C) | 50-65 | 60-80 | 50-70 | 175 |
| UV Resistance | Poor (yellows) | Poor | Moderate | Moderate |
| Impact Resistance | Low (brittle) | Good | Good | Excellent |
| Post-processing | UV cure required | UV cure required | UV cure required | Bead blast |
| Surface Finish | Excellent | Good | Good | Slightly rough |

**Note**: SLA resin outdoor durability data is limited. Most SLA resins degrade under prolonged UV exposure without protective coating. [UNVALIDATED — limited manufacturer data for outdoor resin longevity >6 months]

### Supplier Pricing (FDM Filament)

| Material | Brand | Price/kg | Source |
|----------|-------|----------|--------|
| PETG | Hatchbox | ~$20-22 | [Amazon listing](https://www.amazon.com/HATCHBOX-Printer-Filament-Dimensional-Accuracy/dp/B08D2FTPS7) |
| PETG | eSUN | ~$18-20 | [Filament price guide](https://filament-prices.com/2025/03/18/navigating-the-petg-filament-jungle-brands-and-costs-in-2025/) |
| ASA | Polymaker | ~$25-30 | [Amazon ASA listings](https://www.amazon.com/Polymaker-Filament-Resistant-Weather-Cardboard/dp/B09DKPYYBP) |
| ASA | OVERTURE | ~$20-25 | [Amazon listing](https://www.amazon.com/OVERTURE-Filament-Consumables-Dimensional-Accuracy/dp/B08PF938JJ) |
| Nylon | eSUN ePA | ~$35-45 | [ESTIMATED — based on typical market range] |

### SLA/Injection Service Pricing

| Service | Provider | Starting Price | Notes |
|---------|----------|---------------|-------|
| SLA 3D printing | JLC3DP | From $0.30/piece | [JLC3DP quote page](https://jlc3dp.com/3d-printing-quote) — actual price depends on volume |
| Injection molding (mold) | PCBWay | $1,500-5,000 | [PCBWay IM service](https://www.pcbway.com/rapid-prototyping/injection-molding/) — single-cavity aluminum mold |
| Injection molding (per piece) | PCBWay | ~$0.50-3.00 | After mold cost, material-dependent |
| Injection molding cost guide | Jaycon 2025 | Varies | [Jaycon IM pricing guide](https://www.jaycon.com/injection-moulding-price-a-2025-guide-for-engineers-procurement/) |

---

## Step 2: analyze_requirements — Decision Matrix

### Weight Justification

For Wayo 大象追踪器 (outdoor wildlife tracker):
- **UV resistance (W=0.25)**: Highest weight — device is exposed to direct sunlight daily. Material degradation = device failure.
- **Heat resistance (W=0.20)**: Operating temp up to 55°C. Direct sun can push surface temp to 70°C+. Material must not soften.
- **Strength (W=0.15)**: Must survive ~1m drop onto soil/rock. Not extreme but non-trivial.
- **Print difficulty (W=0.15)**: Prototype phase — reliable printing saves time. Wildlife research teams often in remote locations.
- **Moisture resistance (W=0.15)**: IP54 = rain splash protection. Material must not absorb water and swell.
- **Cost (W=0.10)**: Low weight — small batch (<100 units), material cost per unit is small vs total project cost.

### Weighted Decision Matrix

| Criterion | Weight | PLA | PETG | ABS | ASA | Nylon |
|-----------|--------|-----|------|-----|-----|-------|
| UV Resistance | 0.25 | 1 | 3 | 1 | 5 | 1 |
| Heat Resistance (HDT) | 0.20 | 1 | 3 | 5 | 4 | 5 |
| Strength (tensile) | 0.15 | 4 | 3 | 2 | 3 | 5 |
| Print Difficulty (5=easy) | 0.15 | 5 | 5 | 3 | 3 | 1 |
| Moisture Resistance | 0.15 | 3 | 5 | 4 | 5 | 1 |
| Cost (5=cheap) | 0.10 | 5 | 4 | 4 | 3 | 2 |
| **Weighted Total** | **1.00** | **2.80** | **3.70** | **2.95** | **3.95** | **2.45** |

Scoring: 1=poor, 3=adequate, 5=excellent

### So What Analysis

- **PLA is disqualified** (score 2.80): HDT of 55°C means the enclosure could soften in direct sunlight on a hot day. UV degradation will cause brittleness within weeks outdoors. Despite easy printing, PLA is fundamentally unsuitable for this application.
- **PETG is a strong runner-up** (score 3.70): Easy to print, good moisture resistance, adequate UV for short-term. But HDT of 63-80°C is marginal for direct sun exposure in tropical/subtropical climates where elephants live.
- **ASA is the winner** (score 3.95): Best UV resistance in the FDM lineup, HDT of 85-96°C handles heat, low moisture absorption. The tradeoff is needing an enclosed printer (warping risk), which is manageable in a lab setting.
- **ABS scores poorly on UV** (score 2.95): Similar heat resistance to ASA but will yellow and crack outdoors.
- **Nylon is overkill** (score 2.45): Excellent strength and heat resistance but hygroscopic (2.5% moisture absorption) — fatal for an outdoor device. Requires dry storage and dried filament.

---

## Step 3: derive_recommendation — Material + Manufacturing Roadmap

### Primary Recommendation: ASA (FDM Prototype)

| Parameter | Value | Source |
|-----------|-------|--------|
| Material | ASA (e.g., Polymaker PolyLite ASA) | [Polymaker product page](https://www.amazon.com/Polymaker-Filament-Resistant-Weather-Cardboard/dp/B09DKPYYBP) |
| Print temp | 240-260°C | Manufacturer TDS |
| Bed temp | 90-110°C | Manufacturer TDS |
| Enclosed printer | Required (reduce warping) | Common ASA printing guidance |
| Wall thickness | ≥1.5mm (FDM minimum) | Domain Pack constraint |
| Tolerance | 0.2mm (FDM) | Domain Pack constraint |
| Color recommendation | Dark gray or olive green (wildlife context, hide dirt) | Design judgment |

### Fallback: PETG (if no enclosed printer available)

PETG is the fallback if the team cannot access an enclosed printer. UV resistance is moderate — apply UV-resistant clear coat (e.g., Krylon UV-Resistant Clear) for outdoor longevity. [UNVALIDATED — coating longevity data varies by brand, typical claim is 1-2 years]

### Switch Condition: ASA → PETG

If warping issues are unresolvable (no enclosed printer, large flat surfaces), switch to PETG + UV clear coat. Accept reduced heat margin.

### Manufacturing Phase Plan

| Phase | Method | Material | Unit Cost (est.) | Tooling Cost | MOQ | Lead Time | Use Case |
|-------|--------|----------|-------------------|-------------|-----|-----------|----------|
| Prototype (1-10 units) | FDM self-print | ASA | $3-8/unit | $0 (printer owned) | 1 | 1-2 days | Design validation, field testing |
| Small batch (10-50) | SLA external | ABS-like resin + UV coating | $10-25/unit | $0 | 1 | 3-5 days | Deployment to research teams |
| Medium batch (50-200) | SLS | Nylon PA12 | $15-35/unit | $0 | 1 | 5-7 days | Wider deployment [ESTIMATED] |
| Mass production (500+) | Injection molding | ABS or PC/ABS | $1-3/unit | $2,000-8,000 (mold) | 500 | 3-6 weeks | Only if demand justifies mold cost |

**Cost Sources:**
- FDM unit cost: material weight (~50-80g ASA at $25-30/kg) + electricity + labor
- SLA pricing: [JLC3DP](https://jlc3dp.com/) starting $0.30 but actual enclosure-sized parts $10-25 [ESTIMATED based on volume]
- Injection mold: [Jaycon 2025 guide](https://www.jaycon.com/injection-moulding-price-a-2025-guide-for-engineers-procurement/) — $1.5K-$5K for single-cavity aluminum
- Per-piece injection: [PCBWay](https://www.pcbway.com/rapid-prototyping/injection-molding/) — from $0.50/kg material

### Honest Assessment

- **Injection molding is NOT recommended** for Wayo unless production exceeds 500 units. Mold cost of $2K-8K divided across <100 units = $20-80/unit in tooling alone, more expensive than SLA.
- **SLA outdoor durability is uncertain.** Standard resins yellow and become brittle under UV. Post-curing + UV coating required. No reliable >1-year outdoor data found. [UNVALIDATED]
- **ASA + FDM is the practical sweet spot** for a wildlife research project with <100 units anticipated.

---

## Sources

- [UnionFab: ASA vs ABS vs PETG vs PLA comparison](https://www.unionfab.com/blog/2025/05/asa-vs-abs-vs-petg-vs-pla)
- [Filalab: ABS vs ASA vs PETG for outdoor printing](https://filalab.shop/abs-vs-asa-vs-petg-for-outdoor-3d-printing-which-filament-truly-survives-sun-heat-and-weather/)
- [Wevolver: ASA filament properties](https://www.wevolver.com/article/what-is-asa-filament-properties-uses-3d-printing-tips)
- [Ultimaker PETG TDS](https://um-support-files.ultimaker.com/materials/2.85mm/tds/PETG/Ultimaker-PETG-TDS-v1.00.pdf)
- [JLC3DP 3D printing service](https://jlc3dp.com/)
- [PCBWay injection molding](https://www.pcbway.com/rapid-prototyping/injection-molding/)
- [Jaycon injection molding price guide 2025](https://www.jaycon.com/injection-moulding-price-a-2025-guide-for-engineers-procurement/)
- [Filament prices 2025: PETG brands](https://filament-prices.com/2025/03/18/navigating-the-petg-filament-jungle-brands-and-costs-in-2025/)
- [18650 battery dimensions — Wikipedia](https://en.wikipedia.org/wiki/18650_battery)
