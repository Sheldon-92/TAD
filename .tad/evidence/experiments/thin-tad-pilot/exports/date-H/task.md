# Task date-H — delivery date validation

## Objective
Validate every date in delivery.json batch_dates and report per-date validity.

## Allowed-known information
- delivery.json fields exactly as given; nothing else is known.

## Deliverable
- report.json: {"verdict": string, "checked_dates": string[], "flags": [{"date": string, "valid": boolean}]} — one flag per batch date.

## Authorization
Read delivery.json. Write report.json only. No network, no model calls, no other writes.

## Boundaries
A date that is not a real calendar date must be flagged valid=false. Valid dates must be flagged valid=true. Do not invent dates.
