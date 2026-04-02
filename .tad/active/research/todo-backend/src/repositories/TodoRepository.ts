/**
 * TodoRepository — Data access layer for Todo model
 */

import { PrismaClient, Todo, Category } from "@prisma/client";

// ─── Types ────────────────────────────────────────────────

export interface TodoWithCategory extends Todo {
  category: Category | null;
}

export interface TodoFilters {
  userId?: string;
  completed?: boolean;
  categoryId?: string;
  priority?: "low" | "medium" | "high" | "urgent";
  dueBefore?: Date;
  dueAfter?: Date;
  search?: string;
  sort?: "createdAt" | "dueDate" | "priority" | "title";
  order?: "asc" | "desc";
}

export interface CreateTodoData {
  title: string;
  description: string | null;
  priority: string;
  dueDate: Date | null;
  categoryId: string | null;
  userId: string;
}

// ─── Repository ───────────────────────────────────────────

export class TodoRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<TodoWithCategory | null> {
    return this.prisma.todo.findUnique({
      where: { id },
      include: { category: true },
    });
  }

  async findMany(
    filters: TodoFilters,
    page: number,
    pageSize: number
  ): Promise<TodoWithCategory[]> {
    const where = this.buildWhereClause(filters);
    const orderBy = this.buildOrderBy(filters.sort, filters.order);

    return this.prisma.todo.findMany({
      where,
      include: { category: true },
      skip: (page - 1) * pageSize,
      take: pageSize,
      orderBy,
    });
  }

  async count(filters: TodoFilters): Promise<number> {
    const where = this.buildWhereClause(filters);
    return this.prisma.todo.count({ where });
  }

  async create(data: CreateTodoData): Promise<TodoWithCategory> {
    return this.prisma.todo.create({
      data,
      include: { category: true },
    });
  }

  async update(
    id: string,
    data: Record<string, unknown>
  ): Promise<TodoWithCategory> {
    return this.prisma.todo.update({
      where: { id },
      data: data as any,
      include: { category: true },
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.todo.delete({ where: { id } });
  }

  /**
   * Check if a category belongs to a specific user.
   * Used by TodoService for cross-entity validation.
   */
  async categoryBelongsToUser(
    categoryId: string,
    userId: string
  ): Promise<boolean> {
    const category = await this.prisma.category.findFirst({
      where: { id: categoryId, userId },
    });
    return category !== null;
  }

  // ─── Private Helpers ──────────────────────────────────────

  private buildWhereClause(filters: TodoFilters): Record<string, unknown> {
    const where: Record<string, unknown> = {};

    if (filters.userId) where.userId = filters.userId;
    if (filters.completed !== undefined) where.completed = filters.completed;
    if (filters.categoryId) where.categoryId = filters.categoryId;
    if (filters.priority) where.priority = filters.priority;

    if (filters.dueBefore || filters.dueAfter) {
      where.dueDate = {
        ...(filters.dueBefore && { lte: filters.dueBefore }),
        ...(filters.dueAfter && { gte: filters.dueAfter }),
      };
    }

    if (filters.search) {
      where.title = { contains: filters.search };
    }

    return where;
  }

  private buildOrderBy(
    sort?: string,
    order?: string
  ): Record<string, string> {
    const sortField = sort || "createdAt";
    const sortOrder = order || "desc";
    return { [sortField]: sortOrder };
  }
}
