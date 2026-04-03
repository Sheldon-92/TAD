# Environmental Test Standards Research: Wayo Elephant Tracker

## Product Classification
- **Category**: Outdoor portable electronics (wildlife tracking device)
- **Environment**: Tropical/savanna, attached to or near elephants
- **Exposure**: Rain, dust, extreme heat, UV, mechanical shock (elephant movement)
- **Expected lifetime**: 2–5 years field deployment

---

## Applicable Standards

### IEC 60068 Series (Environmental Testing for Electronic Equipment)

| Standard | Title | Relevance to Wayo | Source |
|----------|-------|-------------------|--------|
| IEC 60068-2-1 | Cold test (Test Ab/Ad) | Low temp operation (-20C for outdoor) | [IEC 60068 Wikipedia](https://en.wikipedia.org/wiki/IEC_60068), [Megalab Guide](https://megalabinc.com/environmental/temperature/maximizing-reliability-with-temperature-testing-a-guide-to-iec-60068-2-1-iec-60068-2-2/) |
| IEC 60068-2-2 | Dry heat test (Test Bb/Bd) | High temp operation (+60C for outdoor) | [ANSI Blog IEC 60068-2-2](https://blog.ansi.org/ansi/iec-60068-2-2-ed-6-0-b-2025-environmental-testing/) |
| IEC 60068-2-14 | Temperature cycling (Test Na/Nb) | Thermal stress from day/night cycles | [ANSI Blog IEC 60068-2-14](https://blog.ansi.org/ansi/iec-60068-2-14-ed-7-0-b-2023-temperature-testing/) |
| IEC 60068-2-78 | Damp heat steady state (Test Cab) | Humidity exposure (tropical rain environment) | [Cybernet IEC 60068 guide](https://www.cybernetman.com/blog/iec-60068-testing/) |
| IEC 60068-2-31 | Drop test (Test Ec) | Mechanical shock from handling/mounting | [DE Solutions IEC 60068-2](https://www.desolutions.com/testing-services/test-standards/iec-60068-2) |
| IEC 60068-2-6 | Vibration sinusoidal (Test Fc) | Vibration from transport and elephant movement | [DE Solutions](https://www.desolutions.com/testing-services/test-standards/iec-60068-2) |
| IEC 60068-2-27 | Shock (Test Ea) | Sudden impact (animal interaction) | Standard reference |

### IEC 60529 (Ingress Protection)

| Rating | Meaning | Test Procedure | Relevance |
|--------|---------|----------------|-----------|
| IP65 | Dust-tight + water jets | Dust: 8h chamber, Water: 12.5L/min nozzle from 3m | Minimum for outdoor tracker |
| IP67 | Dust-tight + 1m immersion 30min | Dust: 8h, Water: 1m depth, 30 minutes | Recommended for Wayo (river crossings) |

Sources:
- [IEC IP Ratings](https://www.iec.ch/ip-ratings)
- [Intertek IP Testing](https://www.intertek.com/lighting/performance/ingress-protection/)
- [Castle Compliance IEC 60529](https://castle-compliance.com/iec-60529-testing/)

**Important note from IEC 60529**: IP67 does NOT automatically cover IP65/IP66. Immersion protection (IPX7) is a different test from jet spray (IPX5/IPX6). If both are needed, must test for both: IP65+IP67 = IP6X + IPX5 + IPX7.

### MIL-STD-810H (Optional — Higher Severity)

| Method | Title | Applicable? | Notes |
|--------|-------|-------------|-------|
| 501.7 | High Temperature | Optional | IEC 60068-2-2 is sufficient for consumer outdoor |
| 502.7 | Low Temperature | Optional | Aligns with IEC 60068-2-1 |
| 514.8 | Vibration | Consider | More comprehensive vibration profiles than IEC |
| 516.8 | Shock | Consider | Addresses operational shock scenarios |

**Recommendation**: Use IEC 60068 series as primary. MIL-STD-810H is overkill for a wildlife tracker — designed for military equipment. Cost and complexity significantly higher.

---

## 18650 Battery-Specific Environmental Concerns

| Concern | Standard/Source | Detail |
|---------|----------------|--------|
| High temp safety | Li-ion discharge spec | Max discharge temp 60C. Above 45C: accelerated aging | 
| Low temp capacity | Battery University BU-501a | At 0C: ~80% capacity. At -10C: ~60% capacity [UNVALIDATED for all chemistries] |
| Thermal runaway | UL 2054, IEC 62133 | Mandatory safety standard for Li-ion batteries |
| Transport regulations | UN 38.3 | Required for shipping batteries internationally |

Source: [Battery University](https://www.batteryuniversity.com/article/bu-501a-discharge-characteristics-of-li-ion/)
