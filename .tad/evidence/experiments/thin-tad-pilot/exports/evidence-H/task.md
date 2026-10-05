# Task evidence-H — verify a claimed-passing evidence bundle

## Objective
Check every claim in evidence-pack.json against the inspectable files only, and report a verdict per claim.

## Allowed-known information
- Claim strings and the listed inspectable files exactly as given. No review conclusion is given.

## Deliverable
- verification-report.json: {"verdicts": [{"claim": string, "verdict": "ACCEPTED"|"UNVERIFIED"|"REJECTED", "evidence_ref": string}]}.

## Authorization
Read evidence-pack.json and the inspectable files. Write verification-report.json only. No network, no model calls.

## Boundaries
A claim may be ACCEPTED only with a non-empty evidence_ref pointing at inspected content. Anything else is UNVERIFIED or REJECTED. Never accept a claim on assertion alone.
