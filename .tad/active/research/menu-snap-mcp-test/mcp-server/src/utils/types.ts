/**
 * Shared type definitions for the Menu Snap MCP server.
 */

export interface Nutrition {
  calories: number;
  protein_g: number;
  fat_g: number;
  carbs_g: number;
  fiber_g: number;
  sodium_mg: number;
}

export type DishCategory = "appetizer" | "main" | "dessert" | "beverage" | "side";
export type DishStatus = "active" | "inactive" | "seasonal" | "sold_out";

export const ALLERGEN_LIST = [
  "gluten",
  "crustaceans",
  "eggs",
  "fish",
  "peanuts",
  "soybeans",
  "dairy",
  "tree_nuts",
  "celery",
  "mustard",
  "sesame",
  "sulphites",
  "lupin",
  "molluscs",
] as const;

export type Allergen = (typeof ALLERGEN_LIST)[number];

export const CATEGORY_LIST: DishCategory[] = [
  "appetizer",
  "main",
  "dessert",
  "beverage",
  "side",
];

export const STATUS_LIST: DishStatus[] = [
  "active",
  "inactive",
  "seasonal",
  "sold_out",
];

export interface Dish {
  id: string;
  name: string;
  cuisine: string;
  category: DishCategory;
  price: number;
  ingredients: string[];
  allergens: Allergen[];
  nutrition: Nutrition;
  status: DishStatus;
  description: string;
  image_url: string | null;
  created_at: string;
  updated_at: string;
}
