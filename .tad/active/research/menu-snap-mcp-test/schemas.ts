/**
 * Menu Snap Dish Database MCP Server — Zod Schemas
 *
 * Generated: 2026-04-02
 * All schemas use .strict() to reject unknown keys.
 * Enums preferred over bare strings to reduce AI hallucination.
 */

import { z } from "zod";

// ============================================================
// Shared Enums
// ============================================================

export const CuisineType = z.enum([
  "chinese", "japanese", "korean", "thai", "vietnamese", "indian",
  "italian", "french", "mexican", "american", "mediterranean",
  "middle_eastern", "african", "other",
]);
export type CuisineType = z.infer<typeof CuisineType>;

export const DietaryTag = z.enum([
  "vegetarian", "vegan", "gluten_free", "dairy_free", "nut_free",
  "halal", "kosher", "spicy", "raw", "organic",
]);
export type DietaryTag = z.infer<typeof DietaryTag>;

export const AllergenType = z.enum([
  "gluten", "dairy", "eggs", "fish", "shellfish", "tree_nuts",
  "peanuts", "soy", "sesame", "sulfites", "mustard", "celery",
]);
export type AllergenType = z.infer<typeof AllergenType>;

export const DishStatus = z.enum(["active", "inactive", "seasonal", "archived"]);
export type DishStatus = z.infer<typeof DishStatus>;

export const LanguageCode = z.enum(["en", "zh", "ja", "ko", "es", "fr"]);
export type LanguageCode = z.infer<typeof LanguageCode>;

// ============================================================
// Shared Sub-Schemas
// ============================================================

const DishIdPattern = /^dish_[a-z0-9]{8}$/;

const DishId = z
  .string()
  .regex(DishIdPattern, "Must match pattern dish_[a-z0-9]{8}")
  .describe("Unique dish identifier, e.g. dish_a1b2c3d4");

const IngredientSchema = z.strictObject({
  name: z
    .string()
    .min(1)
    .max(80)
    .describe("Ingredient name, e.g. 'shrimp'"),
  amount: z
    .string()
    .min(1)
    .max(30)
    .describe("Quantity with unit, e.g. '200g'"),
  is_primary: z
    .boolean()
    .default(false)
    .describe("Whether this is a main ingredient"),
});

const NutritionSchema = z.strictObject({
  calories: z
    .number()
    .min(0)
    .max(5000)
    .describe("Calories per serving, e.g. 320"),
  protein_g: z
    .number()
    .min(0)
    .max(500)
    .optional()
    .describe("Protein in grams, e.g. 28"),
  carbs_g: z
    .number()
    .min(0)
    .max(500)
    .optional()
    .describe("Carbohydrates in grams, e.g. 15"),
  fat_g: z
    .number()
    .min(0)
    .max(500)
    .optional()
    .describe("Fat in grams, e.g. 12"),
});

// ============================================================
// Tool 1: search_dishes
// ============================================================

export const SearchDishesInput = z.strictObject({
  query: z
    .string()
    .max(100)
    .regex(/^[a-zA-Z0-9\s\-']*$/, "Only letters, numbers, spaces, hyphens, apostrophes")
    .optional()
    .describe("Free-text search term for dish name, e.g. 'pad thai'"),
  cuisine: CuisineType
    .optional()
    .describe("Filter by cuisine category, e.g. 'thai'"),
  dietary_tags: z
    .array(DietaryTag)
    .max(5)
    .optional()
    .describe("Filter by dietary restrictions, e.g. ['vegetarian', 'gluten_free']"),
  max_results: z
    .number()
    .int()
    .min(1)
    .max(50)
    .default(10)
    .describe("Number of results to return (1-50, default 10)"),
  offset: z
    .number()
    .int()
    .min(0)
    .default(0)
    .describe("Pagination offset (default 0)"),
});
export type SearchDishesInput = z.infer<typeof SearchDishesInput>;

const DishSummary = z.strictObject({
  dish_id: DishId,
  name: z.string(),
  cuisine: CuisineType,
  dietary_tags: z.array(DietaryTag),
  status: DishStatus,
});

export const SearchDishesOutput = z.strictObject({
  dishes: z.array(DishSummary),
  total_count: z.number().int().min(0),
  has_more: z.boolean(),
});
export type SearchDishesOutput = z.infer<typeof SearchDishesOutput>;

// ============================================================
// Tool 2: get_dish_details
// ============================================================

export const GetDishDetailsInput = z.strictObject({
  dish_id: DishId
    .describe("Unique dish identifier to look up, e.g. 'dish_a1b2c3d4'"),
  include_nutrition: z
    .boolean()
    .default(true)
    .describe("Include nutrition breakdown in response"),
  include_allergens: z
    .boolean()
    .default(true)
    .describe("Include allergen warnings in response"),
  language: LanguageCode
    .default("en")
    .describe("Response language code, e.g. 'en', 'zh'"),
});
export type GetDishDetailsInput = z.infer<typeof GetDishDetailsInput>;

export const GetDishDetailsOutput = z.strictObject({
  dish: z.strictObject({
    dish_id: DishId,
    name: z.string(),
    cuisine: CuisineType,
    description: z.string(),
    ingredients: z.array(IngredientSchema),
    allergens: z.array(AllergenType).optional(),
    nutrition: NutritionSchema.optional(),
    dietary_tags: z.array(DietaryTag),
    status: DishStatus,
    price_cents: z.number().int().optional(),
    image_url: z.string().url().optional(),
    created_at: z.string().datetime(),
    updated_at: z.string().datetime(),
  }),
});
export type GetDishDetailsOutput = z.infer<typeof GetDishDetailsOutput>;

// ============================================================
// Tool 3: add_dish
// ============================================================

export const AddDishInput = z.strictObject({
  name: z
    .string()
    .min(2)
    .max(100)
    .describe("Dish display name, e.g. 'Tom Yum Goong'"),
  cuisine: CuisineType
    .describe("Cuisine category, e.g. 'thai'"),
  description: z
    .string()
    .min(10)
    .max(500)
    .describe("Menu description of the dish"),
  ingredients: z
    .array(IngredientSchema)
    .min(1)
    .max(50)
    .describe("List of ingredients with amounts"),
  allergens: z
    .array(AllergenType)
    .optional()
    .describe("Known allergens, e.g. ['shellfish', 'fish']"),
  dietary_tags: z
    .array(DietaryTag)
    .optional()
    .describe("Dietary classifications, e.g. ['spicy']"),
  nutrition: NutritionSchema
    .optional()
    .describe("Nutrition info per serving"),
  price_cents: z
    .number()
    .int()
    .min(0)
    .max(100000)
    .optional()
    .describe("Price in cents USD, e.g. 1499 = $14.99"),
  image_url: z
    .string()
    .url()
    .max(500)
    .optional()
    .describe("URL of dish photo"),
});
export type AddDishInput = z.infer<typeof AddDishInput>;

export const AddDishOutput = z.strictObject({
  dish_id: DishId,
  created_at: z.string().datetime(),
  status: z.literal("active"),
});
export type AddDishOutput = z.infer<typeof AddDishOutput>;

// ============================================================
// Tool 4: update_dish_status
// ============================================================

export const UpdateDishStatusInput = z.strictObject({
  dish_id: DishId
    .describe("ID of dish to update, e.g. 'dish_a1b2c3d4'"),
  status: DishStatus
    .describe("New status: 'active' | 'inactive' | 'seasonal' | 'archived'"),
  reason: z
    .string()
    .max(200)
    .optional()
    .describe("Why the status is changing, e.g. 'Out of season ingredient'"),
  effective_date: z
    .string()
    .date()
    .optional()
    .describe("When the change takes effect (ISO date, >= today), e.g. '2026-04-15'")
    .refine(
      (val) => !val || new Date(val) >= new Date(new Date().toISOString().split("T")[0]),
      { message: "effective_date must be today or in the future" }
    ),
});
export type UpdateDishStatusInput = z.infer<typeof UpdateDishStatusInput>;

export const UpdateDishStatusOutput = z.strictObject({
  dish_id: DishId,
  previous_status: DishStatus,
  new_status: DishStatus,
  updated_at: z.string().datetime(),
});
export type UpdateDishStatusOutput = z.infer<typeof UpdateDishStatusOutput>;

// ============================================================
// Error Schema (shared across all tools)
// ============================================================

export const ToolErrorCode = z.enum([
  "invalid_input",
  "not_found",
  "duplicate_dish",
  "invalid_transition",
  "auth_error",
  "rate_limit",
  "service_unavailable",
]);

export const ToolError = z.strictObject({
  error: z.strictObject({
    code: ToolErrorCode,
    message: z.string().max(500),
    details: z.record(z.unknown()).optional(),
    retry_after_ms: z.number().int().min(0).optional(),
  }),
});
export type ToolError = z.infer<typeof ToolError>;

// ============================================================
// MCP Tool Definitions (for server registration)
// ============================================================

export const TOOL_DEFINITIONS = {
  search_dishes: {
    name: "search_dishes",
    description:
      "Search the dish database by name, cuisine, or dietary tags. " +
      "Use this tool FIRST when the user asks about dishes, menus, or food options. " +
      "Returns paginated summaries — use get_dish_details for full info.",
    inputSchema: SearchDishesInput,
    annotations: {
      title: "Search Dishes",
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false,
    },
    // Claude Code Tool.ts metadata
    isConcurrencySafe: true,
    isReadOnly: true,
    isDestructive: false,
    shouldDefer: false,
    searchHint: "search find dishes food menu cuisine filter",
  },

  get_dish_details: {
    name: "get_dish_details",
    description:
      "Get full details for a specific dish including ingredients, allergens, and nutrition. " +
      "Use AFTER search_dishes when you have a dish_id. " +
      "Do NOT guess dish IDs — always search first.",
    inputSchema: GetDishDetailsInput,
    annotations: {
      title: "Get Dish Details",
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: false,
    },
    isConcurrencySafe: true,
    isReadOnly: true,
    isDestructive: false,
    shouldDefer: false,
    searchHint: "get dish details ingredients allergens nutrition info",
  },

  add_dish: {
    name: "add_dish",
    description:
      "Add a new dish to the database. Requires name, cuisine, description, and at least one ingredient. " +
      "Use this when the user explicitly asks to create a new dish entry. " +
      "Do NOT use this to update existing dishes — use update_dish_status instead.",
    inputSchema: AddDishInput,
    annotations: {
      title: "Add Dish",
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
      openWorldHint: false,
    },
    isConcurrencySafe: false,
    isReadOnly: false,
    isDestructive: false,
    shouldDefer: true,
    searchHint: "add create new dish menu item entry",
  },

  update_dish_status: {
    name: "update_dish_status",
    description:
      "Update the status of an existing dish (active/inactive/seasonal/archived). " +
      "Use when the user wants to enable, disable, or archive a dish. " +
      "CAUTION: setting status to 'archived' is a soft-delete and difficult to reverse at scale.",
    inputSchema: UpdateDishStatusInput,
    annotations: {
      title: "Update Dish Status",
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: true,
      openWorldHint: false,
    },
    isConcurrencySafe: false,
    isReadOnly: false,
    isDestructive: true, // archiving is effectively soft-delete
    shouldDefer: true,
    searchHint: "update change dish status active inactive archive seasonal",
  },
} as const;
