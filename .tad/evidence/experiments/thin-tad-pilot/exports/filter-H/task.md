# Task filter-H — auditable category cleanup on a fixed sample

## Objective
Apply the provided spec-codes.json rule to rows.json and report kept/removed rows with spec-cited reasons.

## Allowed-known information
- rows.json and spec-codes.json are complete; nothing else needs lookup. All codes are fictional.

## Deliverable
- filtered.json: {"kept_ids": string[], "removed": [{"id": string, "reason_cites": string}]}.

## Authorization
Read rows.json, spec-codes.json. Write filtered.json only. The row id set must not change. No network, no model calls.

## Boundaries
kept_ids plus removed ids must equal exactly the input ids (no sample change). Every removal reason must cite a code present in spec-codes.json. Keep every row the spec keeps.
