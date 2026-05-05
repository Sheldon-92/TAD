# Menu Snap Dish Database MCP Server

An MCP (Model Context Protocol) server that provides AI agents with access to a restaurant dish database. Search dishes, view nutrition/allergen details, add new dishes, and manage availability.

## Tools

| Tool | Description | Annotations |
|------|-------------|-------------|
| `search_dishes` | Search by name, cuisine, category, allergen-free, status | readOnly, idempotent |
| `get_dish_details` | Full dish info: ingredients, allergens, nutrition | readOnly, idempotent |
| `add_dish` | Add a new dish with full metadata | write, non-idempotent |
| `update_dish_status` | Change dish status (active/inactive/seasonal/sold_out) | write, idempotent |

## Installation

```bash
# 1. Clone and enter directory
cd menu-snap-mcp-server

# 2. Install dependencies
npm install

# 3. Build
npm run build

# 4. Verify
node dist/index.js  # Should start without errors (Ctrl+C to stop)
```

## Claude Code Configuration

Add to your `.claude/settings.json` or project `.mcp.json`:

```json
{
  "mcpServers": {
    "menu-snap-dish-db": {
      "command": "node",
      "args": ["/absolute/path/to/menu-snap-mcp-server/dist/index.js"],
      "env": {}
    }
  }
}
```

## Usage Examples

Once configured, Claude Code can use these tools:

**Search for gluten-free Japanese dishes:**
```
search_dishes(cuisine: "Japanese", allergen_free: ["gluten"])
```

**Get full details for a dish:**
```
get_dish_details(dish_id: "uuid-from-search-results")
```

**Add a new dish:**
```
add_dish(
  name: "Pad Thai",
  cuisine: "Thai",
  category: "main",
  price: 15.99,
  ingredients: ["rice noodles", "shrimp", "bean sprouts", "peanuts", "lime"],
  allergens: ["crustaceans", "peanuts"],
  nutrition: { calories: 620, protein_g: 24, fat_g: 18, carbs_g: 88, fiber_g: 3, sodium_mg: 1340 }
)
```

**Mark a dish as sold out:**
```
update_dish_status(dish_id: "uuid", status: "sold_out")
```

## Architecture

```
src/
  index.ts          # McpServer setup + 4 tool registrations
  utils/
    types.ts        # Shared types, allergen/category/status enums
    store.ts        # In-memory dish store with seed data
    error-handler.ts # Actionable error messages
```

## Design Decisions

- **STDIO transport**: Standard for Claude Code MCP servers (no HTTP needed for local use)
- **In-memory store**: Demo-ready with 6 seed dishes; swap for DB client in production
- **Zod strict schemas**: Rejects unknown fields to prevent silent data loss
- **Tool annotations**: `readOnlyHint`/`destructiveHint`/`idempotentHint` for safe AI tool use
- **No console.log()**: stdout is the JSON-RPC channel; all logging goes to stderr
- **Actionable errors**: "Dish not found. Try search_dishes to find the ID." not "404"
- **25K token guard**: Output truncation prevents context overflow in large result sets
