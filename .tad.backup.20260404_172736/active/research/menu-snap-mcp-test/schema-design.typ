#set document(title: "Menu Snap MCP Server — Tool Schema Design Report", author: "TAD AI Tool Integration Domain Pack")
#set page(margin: (x: 2cm, y: 2.5cm), numbering: "1")
#set text(font: "New Computer Modern", size: 10pt)
#set heading(numbering: "1.1")
#set par(justify: true)

#align(center)[
  #text(size: 20pt, weight: "bold")[Menu Snap Dish Database MCP Server]
  #v(0.3em)
  #text(size: 14pt, fill: gray)[Tool Schema Design Report]
  #v(0.8em)
  #text(size: 10pt)[Generated: 2026-04-02 #h(1em) | #h(1em) Capability: `tool_schema_design`]
  #v(0.3em)
  #text(size: 10pt)[AI Tool Integration Domain Pack]
]

#v(1em)
#line(length: 100%, stroke: 0.5pt + gray)
#v(1em)

= Executive Summary

This report defines complete tool schemas for the Menu Snap Dish Database MCP server, covering 4 tools across the CRUD spectrum. Each schema includes strict Zod validation, MCP annotations, Claude Code Tool.ts metadata, and error conditions.

*Key decisions:*
- Enum-first design to minimize AI hallucination (14 cuisine types, 10 dietary tags, 12 allergen types)
- Two always-loaded tools (search, details) + two deferred tools (add, update) for context efficiency
- `strict()` mode on all schemas to reject unknown keys
- Conditional destructive classification: `update_dish_status` is destructive only when archiving

= Research Findings

== Anthropic tool_use Best Practices

The `input_schema` field uses JSON Schema with several critical requirements:
- *Strict mode* (`strict: true`) compiles the schema into a grammar that constrains token generation at inference time
- *Input examples* help with complex parameter combinations
- *Descriptions* must explain both "what" and "when" to use the tool
- *Efficient responses* return only high-signal information with stable identifiers

== MCP Tool Annotations

The MCP `ToolAnnotations` interface provides behavioral hints:

#table(
  columns: (auto, auto, auto),
  align: (left, center, left),
  stroke: 0.5pt,
  inset: 6pt,
  [*Annotation*], [*Default*], [*Purpose*],
  [`readOnlyHint`], [false], [Can be auto-approved by clients],
  [`destructiveHint`], [true], [Should trigger confirmation dialog],
  [`idempotentHint`], [false], [Safe to retry on failure],
  [`openWorldHint`], [true], [Accesses external systems],
)

#text(size: 9pt, fill: gray)[Note: Annotations are hints. Untrusted servers can lie.]

== Zod Strict Schema Patterns

- `z.strictObject()` rejects unknown keys (vs default strip behavior)
- `.refine()` / `.superRefine()` for cross-field validation
- `.transform()` for input normalization
- `.safeParse()` returns discriminated union for safe error handling
- `z.enum()` preferred over `z.string()` to constrain AI output

== Claude Code Tool.ts Interface

#table(
  columns: (auto, auto),
  align: (left, left),
  stroke: 0.5pt,
  inset: 6pt,
  [*Property*], [*Purpose*],
  [`isConcurrencySafe()`], [Can run in parallel with other tools],
  [`isReadOnly()`], [No side effects on state],
  [`isDestructive()`], [Irreversible operation],
  [`shouldDefer`], [Hidden until explicitly searched for],
  [`searchHint`], [3-10 word keywords for tool discovery (+4 score weight)],
)

= Tool Classification Matrix

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  align: (left, center, center, center, center, center),
  stroke: 0.5pt,
  inset: 6pt,
  [*Tool*], [*R/W*], [*Destructive*], [*Concurrent*], [*Idempotent*], [*Defer*],
  [`search_dishes`], [Read], [No], [Yes], [Yes], [No],
  [`get_dish_details`], [Read], [No], [Yes], [Yes], [No],
  [`add_dish`], [Write], [No], [No], [No], [Yes],
  [`update_dish_status`], [Write], [Conditional], [No], [Yes], [Yes],
)

#v(0.5em)
*Loading strategy:* Read-only tools are always loaded (high usage frequency). Write tools are deferred (administrative, infrequent).

= Tool Schemas

== Tool 1: search_dishes

*Description:* Search the dish database by name, cuisine, or dietary tags. Use this tool FIRST when the user asks about dishes, menus, or food options.

*Input Parameters:*
#table(
  columns: (auto, auto, auto, auto, 1fr, auto),
  align: (left, left, center, left, left, left),
  stroke: 0.5pt,
  inset: 5pt,
  [*Param*], [*Type*], [*Req*], [*Constraint*], [*Description*], [*Example*],
  [`query`], [string], [No], [max 100, alphanumeric], [Free-text search term], [`"pad thai"`],
  [`cuisine`], [enum], [No], [CuisineType], [Filter by cuisine], [`"thai"`],
  [`dietary_tags`], [enum\[\]], [No], [max 5, DietaryTag], [Dietary filters], [`["vegan"]`],
  [`max_results`], [integer], [No], [1--50, default 10], [Result count], [`10`],
  [`offset`], [integer], [No], [min 0, default 0], [Pagination offset], [`0`],
)

*MCP Annotations:* `readOnlyHint: true`, `destructiveHint: false`, `idempotentHint: true`

*Error conditions:* `invalid_input`, `rate_limit`, `service_unavailable`

== Tool 2: get_dish_details

*Description:* Get full details for a specific dish. Use AFTER search_dishes when you have a dish_id.

*Input Parameters:*
#table(
  columns: (auto, auto, auto, auto, 1fr, auto),
  align: (left, left, center, left, left, left),
  stroke: 0.5pt,
  inset: 5pt,
  [*Param*], [*Type*], [*Req*], [*Constraint*], [*Description*], [*Example*],
  [`dish_id`], [string], [Yes], [`dish_[a-z0-9]{8}`], [Unique dish ID], [`"dish_a1b2c3d4"`],
  [`include_nutrition`], [bool], [No], [default true], [Include nutrition], [`true`],
  [`include_allergens`], [bool], [No], [default true], [Include allergens], [`true`],
  [`language`], [enum], [No], [LanguageCode, default "en"], [Response language], [`"en"`],
)

*MCP Annotations:* `readOnlyHint: true`, `destructiveHint: false`, `idempotentHint: true`

*Error conditions:* `not_found`, `invalid_input`, `rate_limit`

== Tool 3: add_dish

*Description:* Add a new dish to the database. Requires name, cuisine, description, and at least one ingredient.

*Input Parameters:*
#table(
  columns: (auto, auto, auto, auto, 1fr, auto),
  align: (left, left, center, left, left, left),
  stroke: 0.5pt,
  inset: 5pt,
  [*Param*], [*Type*], [*Req*], [*Constraint*], [*Description*], [*Example*],
  [`name`], [string], [Yes], [2--100 chars], [Dish display name], [`"Tom Yum"`],
  [`cuisine`], [enum], [Yes], [CuisineType], [Cuisine category], [`"thai"`],
  [`description`], [string], [Yes], [10--500 chars], [Menu description], [`"Spicy soup..."`],
  [`ingredients`], [object\[\]], [Yes], [1--50 items], [Ingredient list], [See schema],
  [`allergens`], [enum\[\]], [No], [AllergenType], [Known allergens], [`["shellfish"]`],
  [`dietary_tags`], [enum\[\]], [No], [DietaryTag], [Dietary labels], [`["spicy"]`],
  [`nutrition`], [object], [No], [NutritionSchema], [Per-serving info], [See schema],
  [`price_cents`], [integer], [No], [0--100000], [Price in cents], [`1499`],
  [`image_url`], [string], [No], [URL, max 500], [Photo URL], [`"https://..."`],
)

*MCP Annotations:* `readOnlyHint: false`, `destructiveHint: false`, `idempotentHint: false`

*Error conditions:* `invalid_input`, `duplicate_dish`, `rate_limit`, `auth_error`

== Tool 4: update_dish_status

*Description:* Update the status of an existing dish. CAUTION: archiving is a soft-delete.

*Input Parameters:*
#table(
  columns: (auto, auto, auto, auto, 1fr, auto),
  align: (left, left, center, left, left, left),
  stroke: 0.5pt,
  inset: 5pt,
  [*Param*], [*Type*], [*Req*], [*Constraint*], [*Description*], [*Example*],
  [`dish_id`], [string], [Yes], [`dish_[a-z0-9]{8}`], [Dish to update], [`"dish_a1b2c3d4"`],
  [`status`], [enum], [Yes], [DishStatus], [New status value], [`"inactive"`],
  [`reason`], [string], [No], [max 200], [Change reason], [`"Out of season"`],
  [`effective_date`], [string], [No], [ISO date, >= today], [When change applies], [`"2026-04-15"`],
)

*MCP Annotations:* `readOnlyHint: false`, `destructiveHint: true`, `idempotentHint: true`

*Error conditions:* `not_found`, `invalid_input`, `invalid_transition`, `auth_error`, `rate_limit`

= Schema Evolution Rules

#enum(
  [*New fields:* Always add as optional with defaults (backward compatible)],
  [*Removing fields:* Mark deprecated in description for 2 versions, then remove],
  [*Enum expansion:* Add new values freely (never remove existing)],
  [*Enum contraction:* Move to deprecated status, keep accepting for 2 versions],
)

= Anti-Patterns Avoided

#table(
  columns: (auto, 1fr),
  align: (center, left),
  stroke: 0.5pt,
  inset: 6pt,
  [*No.*], [*Anti-Pattern*],
  [1], [No schema at all (AI hallucinates parameters)],
  [2], [All-string types with no validation (no safety)],
  [3], [Tool description says only "what" but not "when" (agent mis-triggers)],
  [4], [No `maxResultSizeChars` (output grows unbounded, fills context)],
  [5], [No error conditions defined (agent cannot recover from failures)],
)

= Sources

- Anthropic Tool Use Documentation: https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use
- Anthropic Advanced Tool Use: https://www.anthropic.com/engineering/advanced-tool-use
- MCP Tool Annotations Blog: https://blog.modelcontextprotocol.io/posts/2026-03-16-tool-annotations/
- MCP Annotations Introduction: https://blog.marcnuri.com/mcp-tool-annotations-introduction
- Zod API Documentation: https://zod.dev/api
- Advanced Zod Patterns: https://valentinprugnaud.dev/posts/zod-series/3/advanced-zod-designing-complex-validation-schemas
- Claude Code Source Analysis: https://gist.github.com/yanchuk/0c47dd351c2805236e44ec3935e9095d
