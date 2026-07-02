// Subscription Service — Core business logic for subscription lifecycle
// Handles: creation, cancellation, plan changes (proration), reactivation

import { SubscriptionStatus } from '@prisma/client';
import { SubscriptionRepository } from '../repositories/SubscriptionRepository';
import { PlanRepository } from '../repositories/PlanRepository';
import { InvoiceService } from './InvoiceService';
import { StripeService } from './StripeService';
import { UsageService } from './UsageService';
import { AuditService } from './AuditService';
import { AppError } from '../errors/AppError';
import { AuthContext } from '../../auth-middleware';

// ═══════════════════════════════════════
// Types
// ═══════════════════════════════════════

export interface CreateSubscriptionInput {
  tenantId: string;
  planId: string;
  paymentMethodId?: string;
}

export interface ChangePlanInput {
  subscriptionId: string;
  newPlanId: string;
  version: number; // Optimistic locking
}

export interface ProrationPreview {
  currentPlan: { id: string; name: string; priceMonthly: number };
  newPlan: { id: string; name: string; priceMonthly: number };
  prorationAmount: number;  // Net in cents (positive = charge, negative = credit)
  credit: number;           // Credit for unused time
  charge: number;           // Charge for remaining time on new plan
  remainingDays: number;
  totalDays: number;
  effectiveDate: Date;
}

// ═══════════════════════════════════════
// Service
// ═══════════════════════════════════════

export class SubscriptionService {
  constructor(
    private subscriptionRepo: SubscriptionRepository,
    private planRepo: PlanRepository,
    private invoiceService: InvoiceService,
    private stripeService: StripeService,
    private usageService: UsageService,
    private auditService: AuditService,
  ) {}

  // ─── Create Subscription ────────────────────────

  async createSubscription(
    input: CreateSubscriptionInput,
    auth: AuthContext,
  ) {
    // 1. Validate plan exists and is active
    const plan = await this.planRepo.findById(input.planId);
    if (!plan || !plan.isActive) {
      throw AppError.notFound('Plan not found or inactive.');
    }

    // 2. Check tenant doesn't already have an active subscription
    const existing = await this.subscriptionRepo.findActiveByTenantId(input.tenantId);
    if (existing) {
      throw AppError.conflict(
        'Tenant already has an active subscription. Cancel existing subscription first.',
        'SUBSCRIPTION_ALREADY_EXISTS',
      );
    }

    // 3. Determine initial status
    const hasTrialPeriod = plan.trialDays > 0;
    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setDate(periodEnd.getDate() + 30); // [ASSUMPTION] 30-day billing cycle

    const trialEnd = hasTrialPeriod
      ? new Date(now.getTime() + plan.trialDays * 24 * 60 * 60 * 1000)
      : null;

    // 4. Create Stripe subscription (if payment method provided)
    let stripeSubscriptionId: string | null = null;
    if (input.paymentMethodId) {
      const stripeSub = await this.stripeService.createSubscription({
        tenantId: input.tenantId,
        planStripePriceId: plan.stripePriceId!,
        paymentMethodId: input.paymentMethodId,
        trialDays: plan.trialDays,
      });
      stripeSubscriptionId = stripeSub.id;
    }

    // 5. Create local subscription record
    const subscription = await this.subscriptionRepo.create({
      tenantId: input.tenantId,
      planId: plan.id,
      status: hasTrialPeriod ? SubscriptionStatus.TRIALING : SubscriptionStatus.ACTIVE,
      currentPeriodStart: now,
      currentPeriodEnd: hasTrialPeriod ? trialEnd! : periodEnd,
      trialEnd,
      stripeSubscriptionId,
    });

    // 6. Create subscription items for each plan feature
    await this.subscriptionRepo.createItems(subscription.id, plan.features);

    // 7. Audit log
    await this.auditService.log({
      tenantId: input.tenantId,
      userId: auth.userId,
      action: 'CREATE',
      entityType: 'Subscription',
      entityId: subscription.id,
      after: subscription,
    });

    return subscription;
  }

  // ─── Cancel Subscription ────────────────────────

  async cancelSubscription(
    subscriptionId: string,
    options: { cancelImmediately?: boolean; reason?: string },
    auth: AuthContext,
  ) {
    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) {
      throw AppError.notFound('Subscription not found.');
    }

    // Validate state transition
    const cancelableStatuses: SubscriptionStatus[] = ['TRIALING', 'ACTIVE', 'PAST_DUE'];
    if (!cancelableStatuses.includes(subscription.status)) {
      throw AppError.conflict(
        `Cannot cancel subscription in ${subscription.status} status.`,
        'INVALID_STATUS_TRANSITION',
      );
    }

    const before = { ...subscription };
    const now = new Date();
    const gracePeriodEnd = new Date(now);
    gracePeriodEnd.setDate(gracePeriodEnd.getDate() + 7); // 7-day grace period

    // Cancel in Stripe
    if (subscription.stripeSubscriptionId) {
      await this.stripeService.cancelSubscription(
        subscription.stripeSubscriptionId,
        options.cancelImmediately ?? false,
      );
    }

    // Update local record
    const updated = await this.subscriptionRepo.update(subscriptionId, {
      status: options.cancelImmediately ? SubscriptionStatus.CANCELED : subscription.status,
      canceledAt: now,
      cancelReason: options.reason || null,
      gracePeriodEnd,
      // If not immediate, status will change to CANCELED at period end (via cron)
    });

    await this.auditService.log({
      tenantId: subscription.tenantId,
      userId: auth.userId,
      action: 'STATUS_CHANGE',
      entityType: 'Subscription',
      entityId: subscriptionId,
      before,
      after: updated,
    });

    return updated;
  }

  // ─── Reactivate Subscription ────────────────────

  async reactivateSubscription(subscriptionId: string, auth: AuthContext) {
    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) {
      throw AppError.notFound('Subscription not found.');
    }

    if (subscription.status !== SubscriptionStatus.CANCELED) {
      throw AppError.conflict(
        'Only canceled subscriptions can be reactivated.',
        'INVALID_STATUS_TRANSITION',
      );
    }

    // Check grace period
    if (subscription.gracePeriodEnd && subscription.gracePeriodEnd < new Date()) {
      throw AppError.conflict(
        'The 7-day grace period has expired. Please create a new subscription.',
        'GRACE_PERIOD_EXPIRED',
      );
    }

    // Reactivate in Stripe
    if (subscription.stripeSubscriptionId) {
      await this.stripeService.reactivateSubscription(subscription.stripeSubscriptionId);
    }

    const before = { ...subscription };
    const updated = await this.subscriptionRepo.update(subscriptionId, {
      status: SubscriptionStatus.ACTIVE,
      canceledAt: null,
      cancelReason: null,
      gracePeriodEnd: null,
    });

    await this.auditService.log({
      tenantId: subscription.tenantId,
      userId: auth.userId,
      action: 'STATUS_CHANGE',
      entityType: 'Subscription',
      entityId: subscriptionId,
      before,
      after: updated,
    });

    return updated;
  }

  // ─── Change Plan (Proration) ────────────────────

  /**
   * Upgrade or downgrade subscription with proration.
   *
   * Proration formula:
   *   remaining_fraction = remaining_days / total_days_in_period
   *   credit = old_price × remaining_fraction  (refund for unused time)
   *   charge = new_price × remaining_fraction  (charge for remaining time on new plan)
   *   net = charge - credit  (positive = pay more, negative = credit)
   *
   * Upgrade: immediate effect, prorated charge now
   * Downgrade: credit applied, change effective at next billing cycle
   *
   * Edge cases:
   * - Same-day change: remaining_fraction ≈ 1.0 (full period)
   * - Last-day change: remaining_fraction ≈ 0 (minimal proration)
   * - Free→Paid: credit = 0, charge = new_price × remaining_fraction
   * - Same plan: rejected (no-op)
   */
  async changePlan(input: ChangePlanInput, auth: AuthContext) {
    const subscription = await this.subscriptionRepo.findById(input.subscriptionId);
    if (!subscription) {
      throw AppError.notFound('Subscription not found.');
    }

    // Only active subscriptions can change plans
    if (subscription.status !== SubscriptionStatus.ACTIVE) {
      throw AppError.conflict(
        `Cannot change plan while subscription is ${subscription.status}.`,
        'INVALID_STATUS_TRANSITION',
      );
    }

    // Optimistic locking check
    if (subscription.version !== input.version) {
      throw AppError.conflict(
        `Subscription was modified by another request. Expected version ${input.version}, found ${subscription.version}.`,
        'CONCURRENT_MODIFICATION',
      );
    }

    // Validate new plan
    const newPlan = await this.planRepo.findById(input.newPlanId);
    if (!newPlan || !newPlan.isActive) {
      throw AppError.notFound('Target plan not found or inactive.');
    }

    if (subscription.planId === input.newPlanId) {
      throw AppError.badRequest('Already subscribed to this plan.', 'SAME_PLAN');
    }

    // Calculate proration
    const currentPlan = await this.planRepo.findById(subscription.planId);
    const proration = this.calculateProration(
      currentPlan!.priceMonthly,
      newPlan.priceMonthly,
      subscription.currentPeriodStart,
      subscription.currentPeriodEnd,
    );

    const isUpgrade = newPlan.priceMonthly > currentPlan!.priceMonthly;

    // Execute in Stripe
    if (subscription.stripeSubscriptionId && newPlan.stripePriceId) {
      await this.stripeService.updateSubscription(
        subscription.stripeSubscriptionId,
        newPlan.stripePriceId,
        isUpgrade ? 'always_invoice' : 'create_prorations',
      );
    }

    const before = { ...subscription };

    // Update local subscription with version increment
    const updated = await this.subscriptionRepo.updateWithVersion(
      input.subscriptionId,
      input.version,
      {
        planId: isUpgrade ? input.newPlanId : subscription.planId, // Downgrade deferred
        version: input.version + 1,
        // [ASSUMPTION] For downgrade: planId changes at period end via cron job
        // Store pending plan change metadata if needed
      },
    );

    if (!updated) {
      throw AppError.conflict(
        'Concurrent modification detected. Please retry.',
        'CONCURRENT_MODIFICATION',
      );
    }

    // Create proration invoice line items
    if (isUpgrade && proration.prorationAmount > 0) {
      await this.invoiceService.createProrationInvoice(
        subscription,
        proration,
      );
    }

    await this.auditService.log({
      tenantId: subscription.tenantId,
      userId: auth.userId,
      action: 'UPDATE',
      entityType: 'Subscription',
      entityId: input.subscriptionId,
      before,
      after: { ...updated, proration },
    });

    return { subscription: updated, proration };
  }

  // ─── Proration Preview ──────────────────────────

  async previewProration(subscriptionId: string, newPlanId: string): Promise<ProrationPreview> {
    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) throw AppError.notFound('Subscription not found.');

    const currentPlan = await this.planRepo.findById(subscription.planId);
    const newPlan = await this.planRepo.findById(newPlanId);
    if (!newPlan || !newPlan.isActive) throw AppError.notFound('Target plan not found.');

    const proration = this.calculateProration(
      currentPlan!.priceMonthly,
      newPlan.priceMonthly,
      subscription.currentPeriodStart,
      subscription.currentPeriodEnd,
    );

    return {
      currentPlan: { id: currentPlan!.id, name: currentPlan!.name, priceMonthly: currentPlan!.priceMonthly },
      newPlan: { id: newPlan.id, name: newPlan.name, priceMonthly: newPlan.priceMonthly },
      ...proration,
      effectiveDate: new Date(),
    };
  }

  // ─── Proration Calculation (Pure) ───────────────

  /**
   * Calculate proration amounts.
   *
   * Formula:
   *   remaining_fraction = remaining_days / total_days
   *   credit = old_price × remaining_fraction
   *   charge = new_price × remaining_fraction
   *   net = charge - credit
   *
   * All amounts in cents (integer arithmetic to avoid floating point issues).
   */
  calculateProration(
    oldPriceCents: number,
    newPriceCents: number,
    periodStart: Date,
    periodEnd: Date,
  ): { prorationAmount: number; credit: number; charge: number; remainingDays: number; totalDays: number } {
    const now = new Date();
    const totalMs = periodEnd.getTime() - periodStart.getTime();
    const remainingMs = periodEnd.getTime() - now.getTime();

    const totalDays = Math.max(1, Math.round(totalMs / (24 * 60 * 60 * 1000)));
    const remainingDays = Math.max(0, Math.round(remainingMs / (24 * 60 * 60 * 1000)));

    // Integer arithmetic: multiply first, then divide (avoid precision loss)
    const credit = Math.round((oldPriceCents * remainingDays) / totalDays);
    const charge = Math.round((newPriceCents * remainingDays) / totalDays);
    const prorationAmount = charge - credit;

    return { prorationAmount, credit, charge, remainingDays, totalDays };
  }
}
