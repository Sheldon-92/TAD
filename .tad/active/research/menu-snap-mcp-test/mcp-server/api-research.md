# Menu Snap Dish Database — API Research

## 1. Target API Analysis

Menu Snap's dish database serves restaurant menu digitization. The MCP server exposes CRUD + search over dishes with rich metadata (ingredients, allergens, nutrition).

### Core Data Model: Dish

Based on industry patterns (Edamam, Spoonacular, Allergy Menu, Google FoodMenus):

| Field | Type | Notes |
|-------|------|-------|
| id | string (UUID) | Primary key |
| name | string | Dish display name |
| cuisine | string | e.g. "Italian", "Japanese" |
| category | enum | appetizer, main, dessert, beverage, side |
| price | number | In local currency |
| ingredients | string[] | Ingredient list |
| allergens | string[] | From standard set of 14 EU allergens |
| nutrition | object | calories, protein_g, fat_g, carbs_g, fiber_g, sodium_mg |
| status | enum | active, inactive, seasonal, sold_out |
| image_url | string? | Optional photo URL |
| description | string? | Optional long description |
| created_at | ISO 8601 | Auto-generated |
| updated_at | ISO 8601 | Auto-generated |

### Standard Allergen Set (14 EU + common)

Gluten, Crustaceans, Eggs, Fish, Peanuts, Soybeans, Dairy, Tree Nuts, Celery, Mustard, Sesame, Sulphites, Lupin, Molluscs

## 2. High-Value Endpoints (Workflow-Oriented)

Following ComposioHQ "Build for Workflows, Not API Endpoints" principle:

| Tool | Merges | Workflow |
|------|--------|---------|
| `search_dishes` | list + filter + search | "Find dishes by name, cuisine, or allergen-free" |
| `get_dish_details` | get + nutrition + allergens | "Full detail view for a specific dish" |
| `add_dish` | create + validate | "Add new dish with full metadata" |
| `update_dish_status` | update status field | "Mark dish as sold_out, seasonal, etc." |

4 tools total — well under the 15-tool ceiling.

## 3. Shared Infrastructure Needs

- **In-memory store**: Array-based for demo (no external DB dependency)
- **Error handling**: Typed errors with actionable messages
- **Validation**: Zod strict schemas — reject unknown fields
- **Output formatting**: JSON with Markdown summary, respecting 25K token limit
- **No console.log**: STDIO transport — stdout is JSON-RPC channel

## 4. Authentication

For this demo MCP server: none required (local in-memory data).
Production would add API key via environment variable.

## Sources

- [Edamam Food Database API](https://developer.edamam.com/food-database-api-docs)
- [Spoonacular Food API](https://spoonacular.com/food-api)
- [Allergy Menu API](https://allergymenu.app/apidocs/)
- [Google FoodMenus API](https://developers.google.com/my-business/reference/rest/v4/FoodMenus)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
