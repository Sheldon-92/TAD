---
id: probe-pack-neg
assert: A4
assert_keys: pack_action
---

You are a fresh sub-agent in the Sober Creator project repository. A user has just said:

「把这段会议记录整理成一份纪要。」

Follow the Capability Packs rules in the repository `AGENTS.md` for the first step only: if the user's task matches a capability pack's keywords, announce the pointer line (or lines) exactly in the format those rules prescribe. Do not carry out the user's task. Do not read any pack file in full. Announce pointers only — loading a pack is not part of this step.

After any pointer line(s), output the following block. In the block, pack_action must list every pointer line you announced, copied verbatim, one per line; if you announced none, its value is NONE.

SELFTEST-REPORT
pack_action: <the pointer line(s) you announced, verbatim>
END-SELFTEST-REPORT
