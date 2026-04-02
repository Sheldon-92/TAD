/**
 * CategoryService — User-defined category management
 *
 * Business rules:
 * - Categories are scoped to the authenticated user
 * - Category name must be unique per user (enforced at DB layer)
 * - Deleting a category sets todos' categoryId to null (DB: onDelete: SetNull)
 */

import { CategoryRepository, CategoryData } from "../repositories/CategoryRepository";
import { AppError } from "../errors/AppError";

// ─── Types ────────────────────────────────────────────────

export interface CreateCategoryInput {
  name: string;
  color?: string | null;
}

export interface UpdateCategoryInput {
  name?: string;
  color?: string | null;
}

export interface PaginatedResult<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
  };
}

// ─── Service ──────────────────────────────────────────────

export class CategoryService {
  constructor(private categoryRepo: CategoryRepository) {}

  /**
   * Create a new category.
   * DB enforces @@unique([userId, name]) — Prisma P2002 error on duplicate.
   */
  async create(
    userId: string,
    input: CreateCategoryInput
  ): Promise<CategoryData> {
    return this.categoryRepo.create({
      name: input.name,
      color: input.color ?? null,
      userId,
    });
  }

  /**
   * List all categories for the authenticated user.
   */
  async list(
    userId: string,
    page: number = 1,
    pageSize: number = 20
  ): Promise<PaginatedResult<CategoryData>> {
    const [data, total] = await Promise.all([
      this.categoryRepo.findByUser(userId, page, pageSize),
      this.categoryRepo.countByUser(userId),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        pageSize,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  /**
   * Get a single category by ID.
   * Enforces ownership.
   */
  async getById(
    categoryId: string,
    userId: string
  ): Promise<CategoryData> {
    const category = await this.categoryRepo.findById(categoryId);

    if (!category) {
      throw AppError.notFound("Category not found.", "RESOURCE_NOT_FOUND");
    }

    if (category.userId !== userId) {
      throw AppError.forbidden(
        "You do not have permission to access this category.",
        "RESOURCE_FORBIDDEN"
      );
    }

    return category;
  }

  /**
   * Update a category.
   * Ownership check + unique name validation (DB layer).
   */
  async update(
    categoryId: string,
    userId: string,
    input: UpdateCategoryInput
  ): Promise<CategoryData> {
    // Verify ownership
    await this.getById(categoryId, userId);

    return this.categoryRepo.update(categoryId, {
      ...(input.name !== undefined && { name: input.name }),
      ...(input.color !== undefined && { color: input.color }),
    });
  }

  /**
   * Delete a category.
   * Ownership check. Todos with this category get categoryId = null (DB cascade).
   */
  async delete(categoryId: string, userId: string): Promise<void> {
    // Verify ownership
    await this.getById(categoryId, userId);
    await this.categoryRepo.delete(categoryId);
  }
}
