// Usage Service — Track API calls, storage, and trigger overage alerts

import { UsageRecordRepository } from '../repositories/UsageRecordRepository';
import { SubscriptionRepository } from '../repositories/SubscriptionRepository';
import { PlanRepository } from '../repositories/PlanRepository';
import { WebSocketService } from './WebSocketService';
import { AppError } from '../errors/AppError';

// ═══════════════════════════════════════
// Types
// ═══════════════════════════════════════

export interface RecordUsageInput {
  tenantId: string;
  subscriptionId: string;
  featureName: string;
  quantity: number;
  transactionId: string;
  timestamp?: Date;
}

export interface UsageFeatureSummary {
  name: string;
  used: number;
  limit: number;
  percentUsed: number;
  overage: number;
  unit: string;
}

export interface UsageSummary {
  tenantId: string;
  period: string;       // "2026-04"
  features: UsageFeatureSummary[];
}

// Overage alert thresholds
const ALERT_THRESHOLDS = [80, 90, 100]; // percent

// ═══════════════════════════════════════
// Service
// ═══════════════════════════════════════

export class UsageService {
  constructor(
    private usageRepo: UsageRecordRepository,
    private subscriptionRepo: SubscriptionRepository,
    private planRepo: PlanRepository,
    private wsService: WebSocketService,
  ) {}

  /**
   * Record a usage event. Idempotent via transactionId.
   * Checks plan limits and triggers overage alerts via WebSocket.
   */
  async recordUsage(input: RecordUsageInput) {
    // 1. Idempotency check
    const existing = await this.usageRepo.findByTransactionId(input.transactionId);
    if (existing) {
      return existing; // Already processed — return existing record
    }

    // 2. Validate subscription is active
    const subscription = await this.subscriptionRepo.findById(input.subscriptionId);
    if (!subscription || !['ACTIVE', 'TRIALING'].includes(subscription.status)) {
      throw AppError.unprocessable(
        'Subscription is not active. Cannot record usage.',
        'SUBSCRIPTION_NOT_ACTIVE',
      );
    }

    // 3. Validate feature exists in plan
    const plan = await this.planRepo.findByIdWithFeatures(subscription.planId);
    const feature = plan?.features.find((f) => f.name === input.featureName);
    if (!feature) {
      throw AppError.unprocessable(
        `Feature "${input.featureName}" is not included in the current plan.`,
        'FEATURE_NOT_IN_PLAN',
      );
    }

    // 4. Record usage
    const record = await this.usageRepo.create({
      tenantId: input.tenantId,
      subscriptionId: input.subscriptionId,
      featureName: input.featureName,
      quantity: input.quantity,
      transactionId: input.transactionId,
      timestamp: input.timestamp || new Date(),
    });

    // 5. Check limits and trigger alerts
    await this.checkAndAlert(input.tenantId, input.subscriptionId, input.featureName, feature);

    return record;
  }

  /**
   * Get usage summary for a tenant in the current billing period.
   */
  async getUsageSummary(tenantId: string, period: 'current' | 'previous' = 'current'): Promise<UsageSummary> {
    // Get active subscription
    const subscription = await this.subscriptionRepo.findActiveByTenantId(tenantId);
    if (!subscription) {
      throw AppError.notFound('No active subscription found for tenant.');
    }

    const plan = await this.planRepo.findByIdWithFeatures(subscription.planId);
    if (!plan) throw AppError.notFound('Plan not found.');

    // Calculate period boundaries
    let periodStart: Date;
    let periodEnd: Date;

    if (period === 'current') {
      periodStart = subscription.currentPeriodStart;
      periodEnd = subscription.currentPeriodEnd;
    } else {
      // Previous period: go back one cycle
      periodEnd = subscription.currentPeriodStart;
      periodStart = new Date(periodEnd);
      periodStart.setDate(periodStart.getDate() - 30); // [ASSUMPTION] 30-day cycle
    }

    // Aggregate usage per feature
    const features: UsageFeatureSummary[] = await Promise.all(
      plan.features.map(async (feature) => {
        const totalUsed = await this.usageRepo.sumQuantity(
          tenantId,
          feature.name,
          periodStart,
          periodEnd,
        );

        const limit = feature.limit;
        const percentUsed = limit === -1 ? 0 : Math.round((totalUsed / limit) * 1000) / 10;
        const overage = limit === -1 ? 0 : Math.max(0, totalUsed - limit);

        return {
          name: feature.name,
          used: totalUsed,
          limit,
          percentUsed,
          overage,
          unit: feature.unit,
        };
      }),
    );

    const periodStr = `${periodStart.getFullYear()}-${String(periodStart.getMonth() + 1).padStart(2, '0')}`;

    return { tenantId, period: periodStr, features };
  }

  /**
   * Check usage against plan limits and send WebSocket alerts.
   */
  private async checkAndAlert(
    tenantId: string,
    subscriptionId: string,
    featureName: string,
    feature: { limit: number; unit: string },
  ) {
    if (feature.limit === -1) return; // Unlimited — no alerts

    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) return;

    const totalUsed = await this.usageRepo.sumQuantity(
      tenantId,
      featureName,
      subscription.currentPeriodStart,
      subscription.currentPeriodEnd,
    );

    const percentUsed = (totalUsed / feature.limit) * 100;

    for (const threshold of ALERT_THRESHOLDS) {
      if (percentUsed >= threshold) {
        // Send WebSocket alert to tenant admins
        this.wsService.sendToTenant(tenantId, {
          type: 'USAGE_ALERT',
          data: {
            featureName,
            used: totalUsed,
            limit: feature.limit,
            percentUsed: Math.round(percentUsed * 10) / 10,
            threshold,
            unit: feature.unit,
            isOverage: percentUsed >= 100,
          },
          timestamp: new Date().toISOString(),
        });
        break; // Send highest applicable alert only
      }
    }
  }
}
