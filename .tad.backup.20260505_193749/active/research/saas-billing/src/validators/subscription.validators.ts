// Zod Validators — Subscription domain input validation

import { z } from 'zod';

// ═══════════════════════════════════════
// Enums
// ═══════════════════════════════════════

export const UserRoleSchema = z.enum([
  'SUPER_ADMIN',
  'TENANT_ADMIN',
  'BILLING_ADMIN',
  'MEMBER',
]);

export const SubscriptionStatusSchema = z.enum([
  'TRIALING',
  'ACTIVE',
  'PAST_DUE',
  'CANCELED',
  'EXPIRED',
]);

// ═══════════════════════════════════════
// Tenant Validators
// ═══════════════════════════════════════

export const CreateTenantSchema = z.object({
  name: z.string().min(1).max(255),
  slug: z.string().min(3).max(63).regex(/^[a-z0-9-]+$/, 'Slug must be lowercase alphanumeric with hyphens'),
  billingEmail: z.string().email(),
});

export const UpdateTenantSchema = z.object({
  name: z.string().min(1).max(255).optional(),
  billingEmail: z.string().email().optional(),
}).refine((data) => Object.keys(data).length > 0, 'At least one field must be provided');

// ═══════════════════════════════════════
// User Validators
// ═══════════════════════════════════════

export const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(255),
  role: UserRoleSchema,
});

export const UpdateUserSchema = z.object({
  name: z.string().min(1).max(255).optional(),
  role: UserRoleSchema.optional(),
}).refine((data) => Object.keys(data).length > 0, 'At least one field must be provided');

// ═══════════════════════════════════════
// Plan Validators
// ═══════════════════════════════════════

export const PlanFeatureSchema = z.object({
  name: z.string().min(1).max(100),
  limit: z.number().int().min(-1), // -1 = unlimited
  unit: z.string().min(1).max(50),
  overagePrice: z.number().int().min(0).optional(),
});

export const CreatePlanSchema = z.object({
  name: z.string().min(1).max(255),
  slug: z.string().min(1).max(63).regex(/^[a-z0-9-]+$/),
  description: z.string().max(1000).optional(),
  priceMonthly: z.number().int().min(0), // Cents
  priceYearly: z.number().int().min(0).optional(),
  currency: z.string().length(3).default('usd'),
  trialDays: z.number().int().min(0).default(0),
  features: z.array(PlanFeatureSchema).optional(),
});

export const UpdatePlanSchema = z.object({
  name: z.string().min(1).max(255).optional(),
  description: z.string().max(1000).optional(),
  priceMonthly: z.number().int().min(0).optional(),
  priceYearly: z.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
});

// ═══════════════════════════════════════
// Subscription Validators
// ═══════════════════════════════════════

export const CreateSubscriptionSchema = z.object({
  planId: z.string().cuid(),
  paymentMethodId: z.string().optional(),
});

export const ChangePlanSchema = z.object({
  newPlanId: z.string().cuid(),
  version: z.number().int().min(1), // Optimistic locking version
});

export const CancelSubscriptionSchema = z.object({
  cancelImmediately: z.boolean().default(false),
  reason: z.string().max(500).optional(),
});

// ═══════════════════════════════════════
// Usage Validators
// ═══════════════════════════════════════

export const CreateUsageRecordSchema = z.object({
  tenantId: z.string().cuid(),
  subscriptionId: z.string().cuid(),
  featureName: z.string().min(1).max(100),
  quantity: z.number().int().min(1),
  transactionId: z.string().min(1).max(255), // Client-provided for idempotency
  timestamp: z.string().datetime().optional(),
});

// ═══════════════════════════════════════
// Pagination Validators
// ═══════════════════════════════════════

export const PaginationSchema = z.object({
  cursor: z.string().optional(),
  limit: z.number().int().min(1).max(100).default(20),
});

// ═══════════════════════════════════════
// Type Exports
// ═══════════════════════════════════════

export type CreateTenantInput = z.infer<typeof CreateTenantSchema>;
export type UpdateTenantInput = z.infer<typeof UpdateTenantSchema>;
export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UpdateUserInput = z.infer<typeof UpdateUserSchema>;
export type CreatePlanInput = z.infer<typeof CreatePlanSchema>;
export type UpdatePlanInput = z.infer<typeof UpdatePlanSchema>;
export type CreateSubscriptionInput = z.infer<typeof CreateSubscriptionSchema>;
export type ChangePlanInput = z.infer<typeof ChangePlanSchema>;
export type CreateUsageRecordInput = z.infer<typeof CreateUsageRecordSchema>;
