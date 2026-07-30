# Journal: tad-lite-channel (2026-07-30)

- Spec compliance reviewer correctly caught missing evidence artifacts (AC12 raw transcript, AC13 cost evidence file) even though structural checks passed — validates that "file exists + lifecycle mv done" is not the same as "evidence is complete". This is the Validation Theater principle in action: the reviewer saw through the structural pass to the behavioral gap.

- Dogfood lite cycle completed at ~23K tokens (8K real reviewer + 15K estimated main flow) vs full TAD 300K-1M. Confirms the one-order-of-magnitude cost reduction claim is achievable for simple tasks. The real bottleneck is the single reviewer spawn (~8K), which is the irreducible cost of the "non-self review" principle.
