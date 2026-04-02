/**
 * UserRepository — Data access layer for User model
 *
 * Encapsulates all Prisma calls for User.
 * Service layer never directly uses Prisma client.
 */

import { PrismaClient, User } from "@prisma/client";

// ─── Types ────────────────────────────────────────────────

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserData {
  email: string;
  name: string;
  passwordHash: string;
  role: string;
}

// ─── Repository ───────────────────────────────────────────

export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async create(data: CreateUserData): Promise<User> {
    return this.prisma.user.create({ data });
  }

  async update(id: string, data: Record<string, unknown>): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data: data as any,
    });
  }

  async updateRefreshToken(id: string, refreshToken: string | null): Promise<void> {
    await this.prisma.user.update({
      where: { id },
      data: { refreshToken },
    });
  }

  async softDelete(id: string): Promise<void> {
    await this.prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  /**
   * Find many users (excludes soft-deleted), paginated.
   */
  async findMany(page: number, pageSize: number): Promise<User[]> {
    return this.prisma.user.findMany({
      where: { deletedAt: null },
      skip: (page - 1) * pageSize,
      take: pageSize,
      orderBy: { createdAt: "desc" },
    });
  }

  async count(): Promise<number> {
    return this.prisma.user.count({
      where: { deletedAt: null },
    });
  }
}
