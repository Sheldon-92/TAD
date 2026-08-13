# Environmental Test (Doc A: search → analyze → derive → generate)

Environmental test plan — temperature, humidity, mechanical shock, vibration. Design the test matrix before sending to test lab.

## 1. Search Applicable Standards

1. Product category → applicable standards:
   - Consumer electronics (indoor): IEC 60068 series, EN 60068
   - Outdoor/industrial: MIL-STD-810H, IP67/IP68 (IEC 60529)
   - Automotive: ISO 16750, AEC-Q100 (components)
   - Medical: IEC 60601 environmental requirements
2. Search for specific test conditions (web research):
   - "IEC 60068-2-1 cold test conditions" (operating -20°C for outdoor)
   - "IEC 60068-2-2 dry heat test conditions" (operating +60°C for outdoor)
   - "IEC 60068-2-78 humidity test 85/85" (85°C, 85% RH for reliability)
   - "IEC 60068-2-31 drop test portable electronics"
   - "MIL-STD-810H temperature humidity vibration test methods"
   - "IP67 test procedure IEC 60529"
3. Identify product-specific requirements:
   - Operating temperature range (consumer: 0~40°C, outdoor: -20~60°C, industrial: -40~85°C)
   - Storage temperature range (typically wider: -40~85°C)
   - Ingress protection target (IP54 splash-proof, IP67 submersible)
   - Drop height (handheld: 1.5m, desktop: 0.75m)

Quality bar: Standards must be cited with specific clause numbers. Do not guess test conditions — look them up.
Output: `environmental-test-research.md`.

## 2. Analyze Which Tests Apply to THIS Product

1. Product environment classification:
   - Where will it be used? (indoor controlled, outdoor exposed, vehicle, pocket/wearable)
   - What abuse will it see? (dropped, shaken, rained on, left in hot car)
   - What is the expected lifetime? (1 year consumer, 5 year industrial, 10+ year infrastructure)
2. Test selection matrix:

   | Test | Applicable? | Standard | Severity Level | Reason |
   |------|------------|----------|---------------|--------|
   | High temperature operation | Yes | IEC 60068-2-2 | +60°C, 8h | Outdoor use |
   | Low temperature operation | Yes | IEC 60068-2-1 | -20°C, 8h | Winter outdoor |
   | Temperature cycling | Yes | IEC 60068-2-14 | -20↔+60°C, 10 cycles | Thermal stress |
   | Humidity | Depends | IEC 60068-2-78 | 40°C/93%RH, 96h | If not sealed |
   | Drop/shock | Yes | IEC 60068-2-31 | 1.5m, 6 faces | Handheld device |
   | Vibration | If shipped | IEC 60068-2-6 | 10-500Hz sweep | Transport simulation |
   | Dust/water | If outdoor | IEC 60529 | IP rating test | Ingress protection |

3. For each test: document sample size (minimum 3 units), test duration, pass/fail criteria.

Quality bar: Test conditions must match product environment. Don't apply automotive specs to a desk gadget.
Output: `environmental-test-analysis.md`.

## 3. Derive the Complete Test Plan

── TEMPERATURE TESTS ──
High temp operation:
- Condition: +60°C (or product-specific), 8 hours minimum
- Pre-test: functional test at room temperature (baseline)
- During test: monitor for display anomalies, sensor drift, wireless performance
- Post-test: functional test at room temperature (compare to baseline)
- Pass criteria: all functions work during AND after exposure, no physical damage

Low temp operation:
- Condition: -20°C (or product-specific), 8 hours minimum
- Specific concern: LiPo battery performance degrades below 0°C
- Pass criteria: device boots, display readable, battery can power device for ≥50% of room-temp duration

Temperature cycling:
- Profile: -20°C (30min soak) → ramp 5°C/min → +60°C (30min soak), 10 cycles
- Inspect after: solder joint cracks, display delamination, seal integrity

── MECHANICAL TESTS ──
Drop test:
- Height: 1.5m (pocket height) onto concrete
- Orientations: 6 faces + 4 edges + 4 corners = 14 drops (or per standard: 6 faces)
- Pass criteria: enclosure intact, display uncracked, device boots, all functions work

── INGRESS PROTECTION (if applicable) ──
IP67 test:
- Dust: 8 hours in dust chamber, no ingress to enclosure
- Water: 1m submersion for 30 minutes, no water ingress

Document: test lab requirements, estimated cost, lead time (typically 2-4 weeks).
Output: `environmental-test-plan.md`.

## 4. Generate the Test Plan Document

Generate comprehensive environmental test plan as PDF:
1. Cover page: product name, revision, test plan version, date
2. Test summary table: all tests, conditions, sample sizes, estimated duration
3. Per-test detailed procedure (from derive step)
4. Test equipment requirements:
   - Temperature chamber (range must cover test extremes)
   - Drop test fixture or measured height
   - IP test equipment (if applicable)
5. Sample allocation plan: which units for which tests (some tests are destructive)
6. Timeline: test sequence (non-destructive first, destructive last)
7. Reporting template: per-test results form

Generate environmental test flow diagram with D2 (test sequence visualization).
Output: `environmental-test-plan.pdf`.

## Quality Criteria (pass/fail for this capability's artifacts)

- All test conditions traceable to specific IEC/MIL/ISO standard clauses
- Temperature ranges match product's intended operating environment
- Sample sizes specified per test (minimum 3 for statistical relevance)
- Pass/fail criteria quantitative (not just "still works")
- Test sequence considers destructive vs non-destructive ordering
- Battery behavior at temperature extremes explicitly addressed
- 编造数据 = FAIL — standard references, test conditions must be verified from actual standards
