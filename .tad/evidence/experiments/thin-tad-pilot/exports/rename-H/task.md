# Task rename-H — storage key and SKU prefix migration

## Objective
Migrate the persisted storage key and the SKU prefix to the new brand, and retire the old ones.

## Allowed-known information
- New storage key: "cv-cart-v2". New SKU prefix: "CV-".
- storage.js and sku.list contents exactly as given.

## Deliverables
- storage.js carrying the new key (old key string absent).
- sku.list with the new prefix; no retired SKU remains active.
- migration-report.json: {"old_key", "new_key", "sku_prefix_old", "sku_prefix_new", "retired_sku_active": boolean}.

## Authorization
Read storage.js, sku.list. Write storage.js, sku.list, migration-report.json only. No network, no model calls.

## Boundaries
The old key must not remain readable anywhere. A retired SKU staying active is a failure.
