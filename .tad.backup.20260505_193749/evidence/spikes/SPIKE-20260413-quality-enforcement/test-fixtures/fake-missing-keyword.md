# Review Report

This file is sufficiently large (over 100 bytes of markdown content) but does NOT
contain the required line-anchored `Overall:` marker. Therefore the evidence
validator should reject it with exit 1 and an stderr reason mentioning the
missing keyword. This is test fixture fake-missing-keyword.md used by exp3.

Some filler: Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Note: the string "Overall: PASS" appearing in prose like this does not
satisfy the anchored regex because the regex requires start-of-line.
