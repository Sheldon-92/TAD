/**
 * AuthService — Registration, Login, Token Refresh, Logout
 *
 * Business logic layer. Does NOT directly use Prisma —
 * delegates to UserRepository for data access.
 */

import bcrypt from "bcryptjs";
import {
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
} from "../auth-middleware";
import { UserRepository } from "../repositories/UserRepository";
import { AppError } from "../errors/AppError";

// ─── Types ────────────────────────────────────────────────

export interface RegisterInput {
  email: string;
  password: string;
  name: string;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface AuthResult {
  accessToken: string;
  refreshToken: string;
  expiresIn: number; // seconds
  user: {
    id: string;
    email: string;
    name: string;
    role: string;
  };
}

export interface TokenResult {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

// ─── Service ──────────────────────────────────────────────

export class AuthService {
  constructor(private userRepo: UserRepository) {}

  /**
   * Register a new user.
   * - Hash password with bcrypt (12 rounds)
   * - Default role: "member"
   * - Return tokens + user profile
   */
  async register(input: RegisterInput): Promise<AuthResult> {
    // Check if email already exists
    const existing = await this.userRepo.findByEmail(input.email);
    if (existing) {
      throw AppError.conflict(
        "A user with this email already exists.",
        "RESOURCE_ALREADY_EXISTS"
      );
    }

    // Hash password
    const passwordHash = await bcrypt.hash(input.password, 12);

    // Create user
    const user = await this.userRepo.create({
      email: input.email,
      name: input.name,
      passwordHash,
      role: "member",
    });

    // Generate tokens
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role as "owner" | "member",
    });
    const refreshToken = generateRefreshToken({ userId: user.id });

    // Store refresh token hash in DB
    const refreshHash = await bcrypt.hash(refreshToken, 10);
    await this.userRepo.updateRefreshToken(user.id, refreshHash);

    return {
      accessToken,
      refreshToken,
      expiresIn: 900, // 15 minutes
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    };
  }

  /**
   * Login with email + password.
   * - Verify credentials (constant-time comparison)
   * - Return tokens + user profile
   * - SECURITY: Do NOT reveal whether email or password was wrong
   */
  async login(input: LoginInput): Promise<AuthResult> {
    const user = await this.userRepo.findByEmail(input.email);

    // Constant-time: always hash even if user not found (prevent timing attack)
    if (!user) {
      await bcrypt.hash(input.password, 12); // dummy hash
      throw AppError.unauthorized(
        "Invalid email or password.",
        "INVALID_CREDENTIALS"
      );
    }

    // Check if user is soft-deleted
    if (user.deletedAt) {
      throw AppError.unauthorized(
        "Invalid email or password.",
        "INVALID_CREDENTIALS"
      );
    }

    const passwordValid = await bcrypt.compare(input.password, user.passwordHash);
    if (!passwordValid) {
      throw AppError.unauthorized(
        "Invalid email or password.",
        "INVALID_CREDENTIALS"
      );
    }

    // Generate tokens
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role as "owner" | "member",
    });
    const refreshToken = generateRefreshToken({ userId: user.id });

    // Store refresh token hash (rotation)
    const refreshHash = await bcrypt.hash(refreshToken, 10);
    await this.userRepo.updateRefreshToken(user.id, refreshHash);

    return {
      accessToken,
      refreshToken,
      expiresIn: 900,
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    };
  }

  /**
   * Refresh access token using refresh token.
   * - Validate refresh token
   * - Rotate: invalidate old, issue new
   */
  async refresh(refreshTokenInput: string): Promise<TokenResult> {
    let payload: { userId: string };
    try {
      payload = verifyToken(refreshTokenInput) as { userId: string };
    } catch {
      throw AppError.unauthorized(
        "Refresh token is invalid or expired.",
        "INVALID_TOKEN"
      );
    }

    const user = await this.userRepo.findById(payload.userId);
    if (!user || !user.refreshToken) {
      throw AppError.unauthorized(
        "Refresh token is invalid or expired.",
        "INVALID_TOKEN"
      );
    }

    // Verify stored hash matches
    const tokenValid = await bcrypt.compare(refreshTokenInput, user.refreshToken);
    if (!tokenValid) {
      // Potential token reuse attack — invalidate all tokens
      await this.userRepo.updateRefreshToken(user.id, null);
      throw AppError.unauthorized(
        "Refresh token has been revoked.",
        "INVALID_TOKEN"
      );
    }

    // Issue new tokens (rotation)
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role as "owner" | "member",
    });
    const newRefreshToken = generateRefreshToken({ userId: user.id });

    const refreshHash = await bcrypt.hash(newRefreshToken, 10);
    await this.userRepo.updateRefreshToken(user.id, refreshHash);

    return {
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: 900,
    };
  }

  /**
   * Logout — invalidate refresh token.
   */
  async logout(userId: string): Promise<void> {
    await this.userRepo.updateRefreshToken(userId, null);
  }
}
