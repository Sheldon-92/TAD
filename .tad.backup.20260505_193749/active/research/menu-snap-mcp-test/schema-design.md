# Menu Snap Dish Database MCP Server — Tool Schema Design

> Generated: 2026-04-02
> Capability: `tool_schema_design` from ai-tool-integration Domain Pack
> Target: Menu Snap dish database MCP server

---

## Step 1: Research Findings

### 1.1 Anthropic tool_use input_schema Best Practices

Sources: [Anthropic Tool Use Docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use), [Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use)

- **Descriptions are king**: Every parameter needs a clear description explaining what it does, when to use it, and edge cases.
- **Strict mode**: `strict: true` compiles the schema into a grammar that constrains token generation at inference time — the model literally cannot produce invalid output.
- **Input examples**: For complex tools, provide `input_examples` showing concrete usage patterns (which combinations of optional params make sense).
- **Consolidate related operations**: Fewer, more capable tools reduce selection ambiguity. But for MCP servers with clear CRUD semantics, 4 focused tools is appropriate.
- **Efficient responses**: Return only high-signal information. Use stable identifiers (slugs/UUIDs), not opaque internal refs.

### 1.2 MCP Tool Annotations

Sources: [MCP Blog — Tool Annotations](https://blog.modelcontextprotocol.io/posts/2026-03-16-tool-annotations/), [MCP Tool Annotations Introduction](https://blog.marcnuri.com/mcp-tool-annotations-introduction)

MCP ToolAnnotations interface:
```typescript
interface ToolAnnotations {
  title?: string;
  readOnlyHint?: boolean;    // default: false
  destructiveHint?: boolean; // default: true
  idempotentHint?: boolean;  // default: false
  openWorldHint?: boolean;   // default: true
}
```

Key design rules:
- `readOnlyHint: true` tools can be auto-approved by clients
- `destructiveHint: true` tools should trigger confirmation dialogs
- Annotations are **hints** — untrusted servers can lie, so clients must not rely solely on them for security

### 1.3 Zod Strict Schema Patterns

Sources: [Zod API Docs](https://zod.dev/api), [Advanced Zod Patterns](https://valentinprugnaud.dev/posts/zod-series/3/advanced-zod-designing-complex-validation-schemas)

- `z.strictObject()` rejects unknown keys (vs default strip behavior)
- `.refine()` / `.superRefine()` for cross-field validation
- `.transform()` for normalizing input (e.g., trim whitespace, lowercase cuisine names)
- `.safeParse()` returns discriminated union for error handling
- Enum schemas (`z.enum()`) preferred over bare strings to reduce AI hallucination

### 1.4 Claude Code Tool.ts Interface

Sources: [Claude Code Source Analysis](https://gist.github.com/yanchuk/0c47dd351c2805236e44ec3935e9095d)

```typescript
interface Tool {
  name: string;
  description: string;
  inputSchema: JSONSchema;
  isConcurrencySafe(): boolean;  // Can run in parallel?
  isReadOnly(): boolean;         // No side effects?
  isDestructive(): boolean;      // Irreversible operation?
  shouldDefer: boolean;          // Hidden until searched for?
  searchHint: string;            // 3-10 word keyword hint (+4 score weight)
}
```

---

## Step 2: Interface Analysis — 4 Tools

### Tool 1: search_dishes

| Parameter | Type | Required | Constraint | Description | Example |
|-----------|------|----------|------------|-------------|---------|
| query | string | No | maxLength: 100, pattern: `^[a-zA-Z0-9\s\-']+$` | Free-text search term for dish name | `"pad thai"` |
| cuisine | enum | No | See CuisineType enum | Filter by cuisine category | `"thai"` |
| dietary_tags | enum[] | No | max 5 items, unique | Filter by dietary restrictions | `["vegetarian", "gluten_free"]` |
| max_results | integer | No | min: 1, max: 50, default: 10 | Number of results to return | `10` |
| offset | integer | No | min: 0, default: 0 | Pagination offset | `0` |

**Output Schema:**

| Field | Type | Description |
|-------|------|-------------|
| dishes | DishSummary[] | Array of matching dish summaries |
| total_count | integer | Total matches (for pagination) |
| has_more | boolean | Whether more results exist |

maxResultSizeChars: 8000

**Error Conditions:**

| Error Code | Meaning | Recovery |
|------------|---------|----------|
| invalid_input | Query contains invalid characters or params out of range | Fix input per constraint |
| rate_limit | Too many requests (>60/min) | Retry after 1s with exponential backoff |
| service_unavailable | Database temporarily unreachable | Retry after 5s |

**Tool Metadata (Claude Code Tool.ts):**
- `isConcurrencySafe()`: **true** — read-only, no state mutation
- `isReadOnly()`: **true** — pure query
- `isDestructive()`: **false**
- `shouldDefer`: **false** — primary discovery tool, always loaded
- `searchHint`: "search find dishes food menu cuisine filter"

**MCP Annotations:**
```json
{ "readOnlyHint": true, "destructiveHint": false, "idempotentHint": true, "openWorldHint": false }
```

---

### Tool 2: get_dish_details

| Parameter | Type | Required | Constraint | Description | Example |
|-----------|------|----------|------------|-------------|---------|
| dish_id | string | Yes | pattern: `^dish_[a-z0-9]{8}$` | Unique dish identifier | `"dish_a1b2c3d4"` |
| include_nutrition | boolean | No | default: true | Include nutrition breakdown | `true` |
| include_allergens | boolean | No | default: true | Include allergen warnings | `true` |
| language | enum | No | See LanguageCode enum, default: "en" | Response language | `"en"` |

**Output Schema:**

| Field | Type | Description |
|-------|------|-------------|
| dish | DishFull | Complete dish object |
| dish.name | string | Dish display name |
| dish.cuisine | CuisineType | Cuisine category |
| dish.ingredients | Ingredient[] | Ingredient list with amounts |
| dish.allergens | AllergenType[] | Allergen flags (if requested) |
| dish.nutrition | NutritionInfo | Calories, macros (if requested) |
| dish.status | DishStatus | active/inactive/seasonal |
| dish.image_url | string | Dish photo URL |

maxResultSizeChars: 4000

**Error Conditions:**

| Error Code | Meaning | Recovery |
|------------|---------|----------|
| not_found | dish_id does not exist | Verify ID via search_dishes first |
| invalid_input | dish_id format invalid | Use pattern `dish_[a-z0-9]{8}` |
| rate_limit | Too many requests | Retry with backoff |

**Tool Metadata (Claude Code Tool.ts):**
- `isConcurrencySafe()`: **true** — read-only
- `isReadOnly()`: **true** — pure lookup
- `isDestructive()`: **false**
- `shouldDefer`: **false** — core tool, always loaded
- `searchHint`: "get dish details ingredients allergens nutrition info"

**MCP Annotations:**
```json
{ "readOnlyHint": true, "destructiveHint": false, "idempotentHint": true, "openWorldHint": false }
```

---

### Tool 3: add_dish

| Parameter | Type | Required | Constraint | Description | Example |
|-----------|------|----------|------------|-------------|---------|
| name | string | Yes | minLength: 2, maxLength: 100, pattern: `^[\p{L}\p{N}\s\-'&]+$` | Dish display name | `"Tom Yum Goong"` |
| cuisine | enum | Yes | See CuisineType enum | Cuisine category | `"thai"` |
| description | string | Yes | minLength: 10, maxLength: 500 | Dish description for menu | `"Spicy and sour shrimp soup..."` |
| ingredients | object[] | Yes | minItems: 1, maxItems: 50 | Ingredient list | See below |
| ingredients[].name | string | Yes | maxLength: 80 | Ingredient name | `"shrimp"` |
| ingredients[].amount | string | Yes | maxLength: 30 | Quantity with unit | `"200g"` |
| ingredients[].is_primary | boolean | No | default: false | Is this a main ingredient? | `true` |
| allergens | enum[] | No | See AllergenType enum | Known allergens | `["shellfish", "fish"]` |
| dietary_tags | enum[] | No | See DietaryTag enum | Dietary classifications | `["spicy"]` |
| nutrition | object | No | — | Nutrition per serving | See below |
| nutrition.calories | number | Yes (if nutrition) | min: 0, max: 5000 | Calories per serving | `320` |
| nutrition.protein_g | number | No | min: 0, max: 500 | Protein in grams | `28` |
| nutrition.carbs_g | number | No | min: 0, max: 500 | Carbohydrates in grams | `15` |
| nutrition.fat_g | number | No | min: 0, max: 500 | Fat in grams | `12` |
| price_cents | integer | No | min: 0, max: 100000 | Price in cents (USD) | `1499` |
| image_url | string | No | format: url, maxLength: 500 | Dish photo URL | `"https://..."` |

**Output Schema:**

| Field | Type | Description |
|-------|------|-------------|
| dish_id | string | Generated dish ID |
| created_at | string (ISO 8601) | Creation timestamp |
| status | DishStatus | Initial status (always "active") |

maxResultSizeChars: 500

**Error Conditions:**

| Error Code | Meaning | Recovery |
|------------|---------|----------|
| invalid_input | Missing required field or constraint violation | Fix per field constraints |
| duplicate_dish | Dish with same name+cuisine already exists | Use update or change name |
| rate_limit | Too many write requests (>10/min) | Retry with backoff |
| auth_error | Missing or invalid authentication | Re-authenticate |

**Tool Metadata (Claude Code Tool.ts):**
- `isConcurrencySafe()`: **false** — writes to database, potential duplicate conflicts
- `isReadOnly()`: **false** — creates new record
- `isDestructive()`: **false** — additive, not destructive
- `shouldDefer`: **true** — less common operation, load on demand
- `searchHint`: "add create new dish menu item entry"

**MCP Annotations:**
```json
{ "readOnlyHint": false, "destructiveHint": false, "idempotentHint": false, "openWorldHint": false }
```

---

### Tool 4: update_dish_status

| Parameter | Type | Required | Constraint | Description | Example |
|-----------|------|----------|------------|-------------|---------|
| dish_id | string | Yes | pattern: `^dish_[a-z0-9]{8}$` | Dish to update | `"dish_a1b2c3d4"` |
| status | enum | Yes | "active" \| "inactive" \| "seasonal" \| "archived" | New status value | `"inactive"` |
| reason | string | No | maxLength: 200 | Why status is changing | `"Out of season ingredient"` |
| effective_date | string | No | format: date (ISO 8601), must be >= today | When change takes effect | `"2026-04-15"` |

**Output Schema:**

| Field | Type | Description |
|-------|------|-------------|
| dish_id | string | Confirmed dish ID |
| previous_status | DishStatus | Status before update |
| new_status | DishStatus | Status after update |
| updated_at | string (ISO 8601) | Update timestamp |

maxResultSizeChars: 500

**Error Conditions:**

| Error Code | Meaning | Recovery |
|------------|---------|----------|
| not_found | dish_id does not exist | Verify via search_dishes |
| invalid_input | Invalid status value or date in past | Fix per constraints |
| invalid_transition | Status transition not allowed (e.g., archived -> active) | Check allowed transitions |
| auth_error | Insufficient permissions | Need admin role |
| rate_limit | Too many updates | Retry with backoff |

**Tool Metadata (Claude Code Tool.ts):**
- `isConcurrencySafe()`: **false** — mutates state, risk of race condition on same dish
- `isReadOnly()`: **false** — changes dish status
- `isDestructive()`: **true** (when status = "archived") — archiving is soft-delete, hard to reverse at scale
- `shouldDefer`: **true** — administrative operation, not common
- `searchHint`: "update change dish status active inactive archive seasonal"

**MCP Annotations:**
```json
{ "readOnlyHint": false, "destructiveHint": true, "idempotentHint": true, "openWorldHint": false }
```

---

## Step 2 Appendix: Shared Enums

```typescript
CuisineType = "chinese" | "japanese" | "korean" | "thai" | "vietnamese" | "indian"
            | "italian" | "french" | "mexican" | "american" | "mediterranean"
            | "middle_eastern" | "african" | "other"

DietaryTag = "vegetarian" | "vegan" | "gluten_free" | "dairy_free" | "nut_free"
           | "halal" | "kosher" | "spicy" | "raw" | "organic"

AllergenType = "gluten" | "dairy" | "eggs" | "fish" | "shellfish" | "tree_nuts"
             | "peanuts" | "soy" | "sesame" | "sulfites" | "mustard" | "celery"

DishStatus = "active" | "inactive" | "seasonal" | "archived"

LanguageCode = "en" | "zh" | "ja" | "ko" | "es" | "fr"
```

---

## Step 3: Tool Classification Matrix

| Tool | Read/Write | Destructive | Concurrency Safe | Idempotent | Defer | MCP readOnlyHint | MCP destructiveHint |
|------|-----------|-------------|-------------------|------------|-------|-------------------|---------------------|
| search_dishes | Read | No | Yes | Yes | No | true | false |
| get_dish_details | Read | No | Yes | Yes | No | true | false |
| add_dish | Write | No | No | No | Yes | false | false |
| update_dish_status | Write | Conditional | No | Yes | Yes | false | true |

### Loading Strategy

**Always Loaded** (shouldDefer: false):
- `search_dishes` — primary entry point for discovery
- `get_dish_details` — frequently needed after search

**Deferred** (shouldDefer: true):
- `add_dish` — administrative, loaded when agent needs to create
- `update_dish_status` — administrative, loaded on demand

### Schema Evolution Rules
1. New fields: always optional with defaults (backward compatible)
2. Removing fields: mark deprecated in description for 2 versions, then remove
3. Enum expansion: add new values (never remove existing)
4. Enum contraction: move to deprecated, keep accepting for 2 versions
