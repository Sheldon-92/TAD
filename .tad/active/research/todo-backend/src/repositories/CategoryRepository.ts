/**
 * CategoryRepository — Data access layer for Category model
 */

import { PrismaClient, Category } from "@prisma/client";

// ─── Types ────────────────────────────────────────────────

export type CategoryData = Category;

export interface CreateCategoryData {
  name: string;
  color: string | null;
  userId: string;
}

// ─── Repository ───────────────────────────────────────────

export class CategoryRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<Category | null> {
    return this.prisma.category.findUnique({ where: { id } });
  }

  async findByUser(
    userId: string,
    page: number,
    pageSize: number
  ): Promise<Category[]> {
    return this.prisma.category.findMany({
      where: { userId },
      skip: (page - 1) * pageSize,
      take: pageSize,
      orderBy: { name: "asc" },
    });
  }

  async countByUser(userId: string): Promise<number> {
    return this.prisma.category.count({ where: { userId } });
  }

  async create(data: CreateCategoryData): Promise<Category> {
    return this.prisma.category.create({ data });
  }

  async update(
    id: string,
    data: Record<string, unknown>
  ): Promise<Category> {
    return this.prisma.category.update({
      where: { id },
      data: data as any,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.category.delete({ where: { id } });
  }
}
