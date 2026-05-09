#!/usr/bin/env node

/**
 * Menu Snap Dish Database MCP Server
 *
 * Provides 4 tools for managing restaurant dish data:
 * - search_dishes: Search and filter dishes by name, cuisine, allergens, etc.
 * - get_dish_details: Get full details for a specific dish (nutrition, allergens)
 * - add_dish: Add a new dish to the database
 * - update_dish_status: Change a dish's availability status
 *
 * Transport: STDIO (JSON-RPC over stdin/stdout)
 * IMPORTANT: Never use console.log() — stdout is the JSON-RPC channel.
 *            Use console.error() for debug logging only.
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

import {
  ALLERGEN_LIST,
  CATEGORY_LIST,
  STATUS_LIST,
  type Allergen,
  type DishCategory,
  type DishStatus,
  type Dish,
} from "./utils/types.js";
import {
  DishNotFoundError,
  DuplicateDishError,
  ValidationError,
  formatErrorResponse,
} from "./utils/error-handler.js";
import {
  searchDishes,
  getDishById,
  addDish,
  updateDishStatus,
} from "./utils/store.js";

// ---------------------------------------------------------------------------
// Server initialization
// ---------------------------------------------------------------------------

const server = new McpServer({
  name: "menu-snap-dish-db",
  version: "1.0.0",
});

// ---------------------------------------------------------------------------
// Helper: format dish for display (JSON + Markdown summary)
// ---------------------------------------------------------------------------

function formatDishSummary(dish: Dish): string {
  const allergenStr =
    dish.allergens.length > 0 ? dish.allergens.join(", ") : "None";
  return [
    `## ${dish.name}`,
    `**Cuisine:** ${dish.cuisine} | **Category:** ${dish.category} | **Status:** ${dish.status}`,
    `**Price:** $${dish.price.toFixed(2)}`,
    `**Description:** ${dish.description}`,
    `**Allergens:** ${allergenStr}`,
    `**Calories:** ${dish.nutrition.calories} kcal`,
    `_ID: ${dish.id}_`,
  ].join("\n");
}

function formatDishDetail(dish: Dish): string {
  const allergenStr =
    dish.allergens.length > 0 ? dish.allergens.join(", ") : "None";
  const n = dish.nutrition;
  return [
    `# ${dish.name}`,
    "",
    `| Field | Value |`,
    `|-------|-------|`,
    `| Cuisine | ${dish.cuisine} |`,
    `| Category | ${dish.category} |`,
    `| Price | $${dish.price.toFixed(2)} |`,
    `| Status | ${dish.status} |`,
    `| Description | ${dish.description} |`,
    "",
    `## Ingredients`,
    dish.ingredients.map((i) => `- ${i}`).join("\n"),
    "",
    `## Allergens`,
    allergenStr,
    "",
    `## Nutrition (per serving)`,
    `| Nutrient | Amount |`,
    `|----------|--------|`,
    `| Calories | ${n.calories} kcal |`,
    `| Protein | ${n.protein_g}g |`,
    `| Fat | ${n.fat_g}g |`,
    `| Carbs | ${n.carbs_g}g |`,
    `| Fiber | ${n.fiber_g}g |`,
    `| Sodium | ${n.sodium_mg}mg |`,
    "",
    `---`,
    `_ID: ${dish.id} | Created: ${dish.created_at} | Updated: ${dish.updated_at}_`,
  ].join("\n");
}

// ---------------------------------------------------------------------------
// Tool 1: search_dishes
// ---------------------------------------------------------------------------

server.tool(
  "search_dishes",
  "Search dishes by name, cuisine, category, allergen-free filters, or status. Returns a list of matching dishes with summary info.",
  {
    query: z
      .string()
      .optional()
      .describe("Text search on dish name and description"),
    cuisine: z
      .string()
      .optional()
      .describe('Filter by cuisine, e.g. "Italian", "Japanese", "Thai"'),
    category: z
      .enum(CATEGORY_LIST as unknown as [string, ...string[]])
      .optional()
      .describe("Filter by dish category"),
    allergen_free: z
      .array(z.enum(ALLERGEN_LIST as unknown as [string, ...string[]]))
      .optional()
      .describe(
        "Exclude dishes containing these allergens. Example: ['gluten', 'dairy'] returns only gluten-free AND dairy-free dishes"
      ),
    status: z
      .enum(STATUS_LIST as unknown as [string, ...string[]])
      .optional()
      .describe("Filter by availability status"),
    max_results: z
      .number()
      .int()
      .min(1)
      .max(50)
      .optional()
      .describe("Maximum number of results (default: 20, max: 50)"),
  },
  async (params) => {
    try {
      const results = searchDishes({
        query: params.query,
        cuisine: params.cuisine,
        category: params.category as DishCategory | undefined,
        allergen_free: params.allergen_free as Allergen[] | undefined,
        status: params.status as DishStatus | undefined,
        max_results: params.max_results,
      });

      if (results.length === 0) {
        const suggestions: string[] = [];
        if (params.query)
          suggestions.push("Try a broader search term");
        if (params.allergen_free)
          suggestions.push("Try fewer allergen restrictions");
        if (params.cuisine)
          suggestions.push("Try without the cuisine filter");

        return {
          content: [
            {
              type: "text" as const,
              text:
                `No dishes found matching your criteria.\n\n` +
                (suggestions.length > 0
                  ? `Suggestions:\n${suggestions.map((s) => `- ${s}`).join("\n")}`
                  : "Try searching without filters to see all available dishes."),
            },
          ],
        };
      }

      const header = `Found **${results.length}** dish${results.length > 1 ? "es" : ""}:\n\n`;
      const body = results.map(formatDishSummary).join("\n\n---\n\n");

      // Truncation guard: 25K token ~= 100K chars
      const output = header + body;
      const truncated =
        output.length > 100_000
          ? output.slice(0, 100_000) +
            "\n\n_[Output truncated. Use filters to narrow results.]_"
          : output;

      return {
        content: [{ type: "text" as const, text: truncated }],
      };
    } catch (error) {
      return formatErrorResponse(error);
    }
  },
  {
    annotations: {
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false,
    },
  }
);

// ---------------------------------------------------------------------------
// Tool 2: get_dish_details
// ---------------------------------------------------------------------------

server.tool(
  "get_dish_details",
  "Get complete details for a specific dish including full ingredient list, allergen information, and detailed nutrition facts.",
  {
    dish_id: z
      .string()
      .uuid()
      .describe(
        "The UUID of the dish. Use search_dishes first to find the ID."
      ),
  },
  async (params) => {
    try {
      const dish = getDishById(params.dish_id);
      if (!dish) {
        throw new DishNotFoundError(params.dish_id);
      }

      return {
        content: [{ type: "text" as const, text: formatDishDetail(dish) }],
      };
    } catch (error) {
      return formatErrorResponse(error);
    }
  },
  {
    annotations: {
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false,
    },
  }
);

// ---------------------------------------------------------------------------
// Tool 3: add_dish
// ---------------------------------------------------------------------------

const NutritionSchema = z
  .object({
    calories: z.number().nonnegative().describe("Total calories (kcal)"),
    protein_g: z.number().nonnegative().describe("Protein in grams"),
    fat_g: z.number().nonnegative().describe("Total fat in grams"),
    carbs_g: z.number().nonnegative().describe("Total carbohydrates in grams"),
    fiber_g: z.number().nonnegative().describe("Dietary fiber in grams"),
    sodium_mg: z.number().nonnegative().describe("Sodium in milligrams"),
  })
  .strict();

server.tool(
  "add_dish",
  "Add a new dish to the Menu Snap database with full metadata including ingredients, allergens, and nutrition information.",
  {
    name: z
      .string()
      .min(1)
      .max(200)
      .describe("Dish name, e.g. 'Spicy Tuna Roll'"),
    cuisine: z
      .string()
      .min(1)
      .max(100)
      .describe("Cuisine type, e.g. 'Japanese', 'Italian'"),
    category: z.enum(
      CATEGORY_LIST as unknown as [string, ...string[]]
    ).describe("Dish category"),
    price: z
      .number()
      .positive()
      .describe("Price in local currency, e.g. 14.99"),
    ingredients: z
      .array(z.string().min(1))
      .min(1)
      .describe("List of ingredients, e.g. ['tuna', 'rice', 'nori']"),
    allergens: z
      .array(z.enum(ALLERGEN_LIST as unknown as [string, ...string[]]))
      .describe(
        "Allergens present in this dish. Use empty array [] if allergen-free."
      ),
    nutrition: NutritionSchema.describe(
      "Nutrition facts per serving"
    ),
    description: z
      .string()
      .max(500)
      .optional()
      .describe("Short description of the dish (max 500 chars)"),
    image_url: z
      .string()
      .url()
      .optional()
      .describe("URL to a dish photo (optional)"),
    status: z
      .enum(STATUS_LIST as unknown as [string, ...string[]])
      .optional()
      .describe("Initial status (default: 'active')"),
  },
  async (params) => {
    try {
      const dish = addDish({
        name: params.name,
        cuisine: params.cuisine,
        category: params.category as DishCategory,
        price: params.price,
        ingredients: params.ingredients,
        allergens: params.allergens as Allergen[],
        nutrition: params.nutrition,
        description: params.description ?? "",
        image_url: params.image_url ?? null,
        status: (params.status as DishStatus) ?? "active",
      });

      return {
        content: [
          {
            type: "text" as const,
            text:
              `Dish added successfully!\n\n` + formatDishDetail(dish),
          },
        ],
      };
    } catch (error) {
      // Handle duplicate name from store
      if (error instanceof Error && error.message.startsWith("DUPLICATE:")) {
        const name = error.message.replace("DUPLICATE:", "");
        return formatErrorResponse(new DuplicateDishError(name));
      }
      return formatErrorResponse(error);
    }
  },
  {
    annotations: {
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
      openWorldHint: false,
    },
  }
);

// ---------------------------------------------------------------------------
// Tool 4: update_dish_status
// ---------------------------------------------------------------------------

server.tool(
  "update_dish_status",
  "Update the availability status of an existing dish. Use this to mark dishes as sold out, seasonal, inactive, or active.",
  {
    dish_id: z
      .string()
      .uuid()
      .describe(
        "The UUID of the dish to update. Use search_dishes to find the ID."
      ),
    status: z
      .enum(STATUS_LIST as unknown as [string, ...string[]])
      .describe(
        "New status: 'active' (available), 'inactive' (removed from menu), 'seasonal' (limited time), 'sold_out' (temporarily unavailable)"
      ),
  },
  async (params) => {
    try {
      const dish = updateDishStatus(
        params.dish_id,
        params.status as DishStatus
      );
      if (!dish) {
        throw new DishNotFoundError(params.dish_id);
      }

      return {
        content: [
          {
            type: "text" as const,
            text:
              `Status updated successfully!\n\n` +
              `**${dish.name}** is now **${dish.status}**.\n\n` +
              `_Updated at: ${dish.updated_at}_`,
          },
        ],
      };
    } catch (error) {
      return formatErrorResponse(error);
    }
  },
  {
    annotations: {
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false,
    },
  }
);

// ---------------------------------------------------------------------------
// Start server
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  // Log to stderr only — stdout is JSON-RPC
  console.error("Menu Snap MCP server started (STDIO transport)");
}

main().catch((error) => {
  console.error("Fatal error starting server:", error);
  process.exit(1);
});
