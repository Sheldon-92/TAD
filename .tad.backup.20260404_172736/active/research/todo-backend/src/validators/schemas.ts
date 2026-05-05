/**
 * Zod Validation Schemas — Input validation for all API endpoints
 *
 * Validation happens at the Route/Controller layer BEFORE
 * data reaches the Service layer.
 *
 * Dependencies: npm install zod
 */

import { z } from "zod";

// ─── Common ───────────────────────────────────────────────

export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
});

// ─── Auth ─────────────────────────────────────────────────

export const registerSchema = z.object({
  email: z.string().email("Must be a valid email address."),
  password: z
    .string()
    .min(8, "Password must be at least 8 characters.")
    .max(128, "Password must be at most 128 characters.")
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      "Password must contain uppercase, lowercase, and a number."
    ),
  name: z
    .string()
    .min(1, "Name is required.")
    .max(100, "Name must be at most 100 characters."),
});

export const loginSchema = z.object({
  email: z.string().email("Must be a valid email address."),
  password: z.string().min(1, "Password is required."),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1, "Refresh token is required."),
});

// ─── User ─────────────────────────────────────────────────

export const updateUserSchema = z
  .object({
    name: z
      .string()
      .min(1, "Name must not be empty.")
      .max(100, "Name must be at most 100 characters.")
      .optional(),
    password: z
      .string()
      .min(8, "Password must be at least 8 characters.")
      .max(128)
      .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .optional(),
    currentPassword: z.string().optional(),
  })
  .refine(
    (data) => {
      // If password is provided, currentPassword is required
      if (data.password && !data.currentPassword) return false;
      return true;
    },
    {
      message: "Current password is required when setting a new password.",
      path: ["currentPassword"],
    }
  );

// ─── Todo ─────────────────────────────────────────────────

const priorityEnum = z.enum(["low", "medium", "high", "urgent"]);

export const createTodoSchema = z.object({
  title: z
    .string()
    .min(1, "Title is required.")
    .max(255, "Title must be at most 255 characters."),
  description: z
    .string()
    .max(2000, "Description must be at most 2000 characters.")
    .nullable()
    .optional(),
  priority: priorityEnum.default("medium"),
  dueDate: z.coerce.date().nullable().optional(),
  categoryId: z.string().nullable().optional(),
});

export const updateTodoSchema = z.object({
  title: z
    .string()
    .min(1, "Title must not be empty.")
    .max(255, "Title must be at most 255 characters.")
    .optional(),
  description: z
    .string()
    .max(2000, "Description must be at most 2000 characters.")
    .nullable()
    .optional(),
  completed: z.boolean().optional(),
  priority: priorityEnum.optional(),
  dueDate: z.coerce.date().nullable().optional(),
  categoryId: z.string().nullable().optional(),
});

export const todoFiltersSchema = z.object({
  status: z.enum(["pending", "completed"]).optional(),
  categoryId: z.string().optional(),
  priority: priorityEnum.optional(),
  dueBefore: z.coerce.date().optional(),
  dueAfter: z.coerce.date().optional(),
  search: z.string().max(100).optional(),
  sort: z.enum(["createdAt", "dueDate", "priority", "title"]).default("createdAt"),
  order: z.enum(["asc", "desc"]).default("desc"),
});

// ─── Category ─────────────────────────────────────────────

const hexColorRegex = /^#[0-9A-Fa-f]{6}$/;

export const createCategorySchema = z.object({
  name: z
    .string()
    .min(1, "Name is required.")
    .max(50, "Name must be at most 50 characters."),
  color: z
    .string()
    .regex(hexColorRegex, "Color must be a valid hex code (e.g., #FF6B6B).")
    .nullable()
    .optional(),
});

export const updateCategorySchema = z.object({
  name: z
    .string()
    .min(1, "Name must not be empty.")
    .max(50, "Name must be at most 50 characters.")
    .optional(),
  color: z
    .string()
    .regex(hexColorRegex, "Color must be a valid hex code (e.g., #FF6B6B).")
    .nullable()
    .optional(),
});

// ─── Path Params ──────────────────────────────────────────

export const userIdParamSchema = z.object({
  userId: z.string().min(1, "User ID is required."),
});

export const todoIdParamSchema = z.object({
  todoId: z.string().min(1, "Todo ID is required."),
});

export const categoryIdParamSchema = z.object({
  categoryId: z.string().min(1, "Category ID is required."),
});
