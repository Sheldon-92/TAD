/**
 * TodoService — Business logic for Todo CRUD operations
 *
 * Responsibilities:
 * - Enforce business rules (ownership, validation)
 * - Coordinate with TodoRepository for data access
 * - Never directly use Prisma client
 */

import { TodoRepository, TodoFilters, TodoWithCategory } from "../repositories/TodoRepository";
import { AppError } from "../errors/AppError";

// ─── Types ────────────────────────────────────────────────

export interface CreateTodoInput {
  title: string;
  description?: string | null;
  priority?: "low" | "medium" | "high" | "urgent";
  dueDate?: Date | null;
  categoryId?: string | null;
}

export interface UpdateTodoInput {
  title?: string;
  description?: string | null;
  completed?: boolean;
  priority?: "low" | "medium" | "high" | "urgent";
  dueDate?: Date | null;
  categoryId?: string | null;
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

export class TodoService {
  constructor(private todoRepo: TodoRepository) {}

  /**
   * Create a new todo for the authenticated user.
   *
   * Business rules:
   * - Title is required, max 255 chars (validated at Zod layer)
   * - Default priority: "medium"
   * - categoryId must belong to the same user (if provided)
   */
  async create(
    userId: string,
    input: CreateTodoInput
  ): Promise<TodoWithCategory> {
    // [ASSUMPTION] Category ownership validation is done here
    // In production, CategoryRepository.findById would verify userId match
    if (input.categoryId) {
      const categoryExists = await this.todoRepo.categoryBelongsToUser(
        input.categoryId,
        userId
      );
      if (!categoryExists) {
        throw AppError.badRequest(
          "Category not found or does not belong to you.",
          "INVALID_CATEGORY"
        );
      }
    }

    return this.todoRepo.create({
      title: input.title,
      description: input.description ?? null,
      priority: input.priority ?? "medium",
      dueDate: input.dueDate ?? null,
      categoryId: input.categoryId ?? null,
      userId,
    });
  }

  /**
   * List todos with filtering and pagination.
   *
   * Business rules:
   * - Member: only sees own todos (userId filter enforced)
   * - Owner: can see all todos (no userId filter)
   */
  async list(
    userId: string,
    role: "owner" | "member",
    filters: TodoFilters,
    page: number = 1,
    pageSize: number = 20
  ): Promise<PaginatedResult<TodoWithCategory>> {
    // Enforce ownership scope for members
    const scopedFilters: TodoFilters = {
      ...filters,
      userId: role === "member" ? userId : filters.userId,
    };

    const [data, total] = await Promise.all([
      this.todoRepo.findMany(scopedFilters, page, pageSize),
      this.todoRepo.count(scopedFilters),
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
   * Get a single todo by ID.
   *
   * Business rules:
   * - Member: can only get own todos
   * - Owner: can get any todo
   */
  async getById(
    todoId: string,
    userId: string,
    role: "owner" | "member"
  ): Promise<TodoWithCategory> {
    const todo = await this.todoRepo.findById(todoId);

    if (!todo) {
      throw AppError.notFound("Todo not found.", "RESOURCE_NOT_FOUND");
    }

    if (role === "member" && todo.userId !== userId) {
      throw AppError.forbidden(
        "You do not have permission to access this todo.",
        "RESOURCE_FORBIDDEN"
      );
    }

    return todo;
  }

  /**
   * Update a todo.
   *
   * Business rules:
   * - Member: can only update own todos
   * - Owner: can update any todo
   * - If changing categoryId, new category must belong to the todo's owner
   */
  async update(
    todoId: string,
    userId: string,
    role: "owner" | "member",
    input: UpdateTodoInput
  ): Promise<TodoWithCategory> {
    // Verify existence and ownership
    const existing = await this.getById(todoId, userId, role);

    // Validate new category ownership if changing
    if (input.categoryId !== undefined && input.categoryId !== null) {
      const categoryOwner = role === "member" ? userId : existing.userId;
      const categoryExists = await this.todoRepo.categoryBelongsToUser(
        input.categoryId,
        categoryOwner
      );
      if (!categoryExists) {
        throw AppError.badRequest(
          "Category not found or does not belong to the todo owner.",
          "INVALID_CATEGORY"
        );
      }
    }

    return this.todoRepo.update(todoId, input);
  }

  /**
   * Delete a todo.
   *
   * Business rules:
   * - Member: can only delete own todos
   * - Owner: can delete any todo
   */
  async delete(
    todoId: string,
    userId: string,
    role: "owner" | "member"
  ): Promise<void> {
    // Verify existence and ownership
    await this.getById(todoId, userId, role);
    await this.todoRepo.delete(todoId);
  }
}
