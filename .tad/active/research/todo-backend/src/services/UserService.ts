/**
 * UserService — User profile management
 *
 * Business rules:
 * - Any authenticated user can view/update their own profile
 * - Only Owner role can list/view/delete other users
 * - Password change requires current password verification
 */

import bcrypt from "bcryptjs";
import { UserRepository, UserProfile } from "../repositories/UserRepository";
import { AppError } from "../errors/AppError";

// ─── Types ────────────────────────────────────────────────

export interface UpdateProfileInput {
  name?: string;
  password?: string;
  currentPassword?: string;
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

export class UserService {
  constructor(private userRepo: UserRepository) {}

  /**
   * Get current user's profile.
   */
  async getProfile(userId: string): Promise<UserProfile> {
    const user = await this.userRepo.findById(userId);
    if (!user || user.deletedAt) {
      throw AppError.notFound("User not found.", "RESOURCE_NOT_FOUND");
    }
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  /**
   * Update current user's profile.
   *
   * Business rules:
   * - Password change requires currentPassword
   * - Name update is straightforward
   */
  async updateProfile(
    userId: string,
    input: UpdateProfileInput
  ): Promise<UserProfile> {
    const user = await this.userRepo.findById(userId);
    if (!user || user.deletedAt) {
      throw AppError.notFound("User not found.", "RESOURCE_NOT_FOUND");
    }

    // If changing password, verify current password
    if (input.password) {
      if (!input.currentPassword) {
        throw AppError.badRequest(
          "Current password is required to set a new password.",
          "REQUIRED"
        );
      }

      const passwordValid = await bcrypt.compare(
        input.currentPassword,
        user.passwordHash
      );
      if (!passwordValid) {
        throw AppError.badRequest(
          "Current password is incorrect.",
          "INVALID_CREDENTIALS"
        );
      }
    }

    const updateData: Record<string, unknown> = {};
    if (input.name !== undefined) updateData.name = input.name;
    if (input.password) {
      updateData.passwordHash = await bcrypt.hash(input.password, 12);
    }

    const updated = await this.userRepo.update(userId, updateData);
    return {
      id: updated.id,
      email: updated.email,
      name: updated.name,
      role: updated.role,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    };
  }

  /**
   * List all users (Owner only).
   * Excludes soft-deleted users.
   */
  async listUsers(
    page: number = 1,
    pageSize: number = 20
  ): Promise<PaginatedResult<UserProfile>> {
    const [users, total] = await Promise.all([
      this.userRepo.findMany(page, pageSize),
      this.userRepo.count(),
    ]);

    return {
      data: users.map((u) => ({
        id: u.id,
        email: u.email,
        name: u.name,
        role: u.role,
        createdAt: u.createdAt,
        updatedAt: u.updatedAt,
      })),
      meta: {
        total,
        page,
        pageSize,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  /**
   * Get user by ID (Owner only).
   */
  async getUserById(userId: string): Promise<UserProfile> {
    return this.getProfile(userId);
  }

  /**
   * Soft-delete a user (Owner only).
   * Sets deletedAt timestamp instead of removing from DB.
   */
  async deleteUser(userId: string): Promise<void> {
    const user = await this.userRepo.findById(userId);
    if (!user || user.deletedAt) {
      throw AppError.notFound("User not found.", "RESOURCE_NOT_FOUND");
    }
    await this.userRepo.softDelete(userId);
  }
}
