# Fixture Pattern: greeting-cli-flag (scenario S1)

Sentinel: LITE_SENTINEL_KNOWLEDGE_20260731

- **Discovery**: CLI flag additions must define the negative case (flag absent) before the positive case.
- **Action**: In any LITE handoff for a CLI flag, write one AC for flag-present behavior and one AC for flag-absent default behavior.
- **failure_mode**: Naive default: only test the flag-present path. Why wrong: the default path is the one every existing user hits.
