/**
 * In-memory dish store with seed data.
 * Production replacement: database client (Postgres, SQLite, etc.)
 */

import crypto from "node:crypto";
import type { Dish, DishCategory, DishStatus, Allergen } from "./types.js";

const dishes: Map<string, Dish> = new Map();

/** Generate a new UUID */
function newId(): string {
  return crypto.randomUUID();
}

/** Get ISO timestamp */
function now(): string {
  return new Date().toISOString();
}

// ---------------------------------------------------------------------------
// Seed data — 6 representative dishes across cuisines
// ---------------------------------------------------------------------------
function seed(): void {
  const seedDishes: Omit<Dish, "id" | "created_at" | "updated_at">[] = [
    {
      name: "Margherita Pizza",
      cuisine: "Italian",
      category: "main",
      price: 14.99,
      ingredients: [
        "pizza dough",
        "san marzano tomatoes",
        "fresh mozzarella",
        "basil",
        "olive oil",
      ],
      allergens: ["gluten", "dairy"],
      nutrition: {
        calories: 820,
        protein_g: 28,
        fat_g: 32,
        carbs_g: 96,
        fiber_g: 4,
        sodium_mg: 1480,
      },
      status: "active",
      description: "Classic Neapolitan pizza with fresh mozzarella and basil",
      image_url: null,
    },
    {
      name: "Salmon Teriyaki Bowl",
      cuisine: "Japanese",
      category: "main",
      price: 18.5,
      ingredients: [
        "salmon fillet",
        "sushi rice",
        "teriyaki sauce",
        "edamame",
        "seaweed",
        "sesame seeds",
      ],
      allergens: ["fish", "soybeans", "sesame", "gluten"],
      nutrition: {
        calories: 680,
        protein_g: 42,
        fat_g: 22,
        carbs_g: 74,
        fiber_g: 3,
        sodium_mg: 1120,
      },
      status: "active",
      description: "Grilled salmon over sushi rice with teriyaki glaze",
      image_url: null,
    },
    {
      name: "Caesar Salad",
      cuisine: "American",
      category: "appetizer",
      price: 11.0,
      ingredients: [
        "romaine lettuce",
        "parmesan cheese",
        "croutons",
        "caesar dressing",
        "anchovy paste",
      ],
      allergens: ["gluten", "dairy", "fish", "eggs"],
      nutrition: {
        calories: 380,
        protein_g: 12,
        fat_g: 28,
        carbs_g: 18,
        fiber_g: 3,
        sodium_mg: 820,
      },
      status: "active",
      description:
        "Crisp romaine with house-made caesar dressing and shaved parmesan",
      image_url: null,
    },
    {
      name: "Mango Sticky Rice",
      cuisine: "Thai",
      category: "dessert",
      price: 9.0,
      ingredients: [
        "glutinous rice",
        "coconut milk",
        "ripe mango",
        "palm sugar",
        "sesame seeds",
      ],
      allergens: ["sesame"],
      nutrition: {
        calories: 420,
        protein_g: 6,
        fat_g: 14,
        carbs_g: 72,
        fiber_g: 2,
        sodium_mg: 45,
      },
      status: "seasonal",
      description: "Sweet coconut sticky rice with fresh Thai mango",
      image_url: null,
    },
    {
      name: "Falafel Wrap",
      cuisine: "Middle Eastern",
      category: "main",
      price: 12.5,
      ingredients: [
        "chickpeas",
        "tahini",
        "pita bread",
        "tomatoes",
        "cucumber",
        "pickled turnips",
        "parsley",
      ],
      allergens: ["gluten", "sesame"],
      nutrition: {
        calories: 560,
        protein_g: 18,
        fat_g: 24,
        carbs_g: 68,
        fiber_g: 12,
        sodium_mg: 980,
      },
      status: "active",
      description:
        "Crispy falafel in warm pita with tahini sauce and fresh vegetables",
      image_url: null,
    },
    {
      name: "Matcha Latte",
      cuisine: "Japanese",
      category: "beverage",
      price: 5.5,
      ingredients: ["matcha powder", "oat milk", "vanilla syrup"],
      allergens: [],
      nutrition: {
        calories: 180,
        protein_g: 3,
        fat_g: 5,
        carbs_g: 30,
        fiber_g: 1,
        sodium_mg: 120,
      },
      status: "active",
      description: "Ceremonial-grade matcha whisked with steamed oat milk",
      image_url: null,
    },
  ];

  for (const d of seedDishes) {
    const id = newId();
    const timestamp = now();
    dishes.set(id, { ...d, id, created_at: timestamp, updated_at: timestamp });
  }
}

// Initialize seed data on module load
seed();

// ---------------------------------------------------------------------------
// Store operations
// ---------------------------------------------------------------------------

export function searchDishes(filters: {
  query?: string;
  cuisine?: string;
  category?: DishCategory;
  allergen_free?: Allergen[];
  status?: DishStatus;
  max_results?: number;
}): Dish[] {
  let results = Array.from(dishes.values());

  // Text search on name + description
  if (filters.query) {
    const q = filters.query.toLowerCase();
    results = results.filter(
      (d) =>
        d.name.toLowerCase().includes(q) ||
        d.description.toLowerCase().includes(q)
    );
  }

  // Filter by cuisine (case-insensitive)
  if (filters.cuisine) {
    const c = filters.cuisine.toLowerCase();
    results = results.filter((d) => d.cuisine.toLowerCase() === c);
  }

  // Filter by category
  if (filters.category) {
    results = results.filter((d) => d.category === filters.category);
  }

  // Filter by allergen-free (exclude dishes containing any listed allergen)
  if (filters.allergen_free && filters.allergen_free.length > 0) {
    results = results.filter(
      (d) => !d.allergens.some((a) => filters.allergen_free!.includes(a))
    );
  }

  // Filter by status
  if (filters.status) {
    results = results.filter((d) => d.status === filters.status);
  }

  // Limit results
  const limit = filters.max_results ?? 20;
  return results.slice(0, limit);
}

export function getDishById(id: string): Dish | undefined {
  return dishes.get(id);
}

export function addDish(
  data: Omit<Dish, "id" | "created_at" | "updated_at">
): Dish {
  // Check for duplicate name
  for (const existing of dishes.values()) {
    if (existing.name.toLowerCase() === data.name.toLowerCase()) {
      throw new Error(`DUPLICATE:${data.name}`);
    }
  }

  const id = newId();
  const timestamp = now();
  const dish: Dish = { ...data, id, created_at: timestamp, updated_at: timestamp };
  dishes.set(id, dish);
  return dish;
}

export function updateDishStatus(
  id: string,
  status: DishStatus
): Dish | undefined {
  const dish = dishes.get(id);
  if (!dish) return undefined;

  dish.status = status;
  dish.updated_at = now();
  dishes.set(id, dish);
  return dish;
}

export function getAllDishIds(): string[] {
  return Array.from(dishes.keys());
}
