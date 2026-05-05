// Subscription Repository — Data access layer for subscriptions
// Enforces tenant_id filtering for multi-tenancy

import { PrismaClient, Subscription, SubscriptionStatus, PlanFeature } from '@prisma/client';

export class SubscriptionRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<Subscription | null> {
    return this.prisma.subscription.findUnique({
      where: { id },
      include: {
        plan: { include: { features: true } },
        items: { include: { planFeature: true } },
      },
    });
  }

  async findByStripeId(stripeSubscriptionId: string): Promise<Subscription | null> {
    return this.prisma.subscription.findUnique({
      where: { stripeSubscriptionId },
      include: { plan: true },
    });
  }

  async findActiveByTenantId(tenantId: string): Promise<Subscription | null> {
    return this.prisma.subscription.findFirst({
      where: {
        tenantId,
        status: { in: ['ACTIVE', 'TRIALING', 'PAST_DUE'] },
      },
      include: { plan: { include: { features: true } } },
    });
  }

  async findByTenantId(
    tenantId: string,
    options?: { status?: SubscriptionStatus; cursor?: string; limit?: number },
  ) {
    const limit = options?.limit || 20;
    return this.prisma.subscription.findMany({
      where: {
        tenantId,
        ...(options?.status ? { status: options.status } : {}),
      },
      include: { plan: true },
      orderBy: { createdAt: 'desc' },
      take: limit + 1, // Fetch one extra for cursor pagination
      ...(options?.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
    });
  }

  async create(data: {
    tenantId: string;
    planId: string;
    status: SubscriptionStatus;
    currentPeriodStart: Date;
    currentPeriodEnd: Date;
    trialEnd?: Date | null;
    stripeSubscriptionId?: string | null;
  }): Promise<Subscription> {
    return this.prisma.subscription.create({
      data,
      include: { plan: { include: { features: true } } },
    });
  }

  async createItems(subscriptionId: string, features: PlanFeature[]): Promise<void> {
    await this.prisma.subscriptionItem.createMany({
      data: features.map((f) => ({
        subscriptionId,
        planFeatureId: f.id,
        quantity: 1,
      })),
    });
  }

  async update(id: string, data: Partial<Subscription>): Promise<Subscription> {
    return this.prisma.subscription.update({
      where: { id },
      data,
      include: { plan: true },
    });
  }

  /**
   * Update with optimistic locking.
   * Returns null if version mismatch (concurrent modification).
   */
  async updateWithVersion(
    id: string,
    expectedVersion: number,
    data: Partial<Subscription> & { version: number },
  ): Promise<Subscription | null> {
    try {
      return await this.prisma.subscription.update({
        where: {
          id,
          version: expectedVersion, // Optimistic lock check
        },
        data,
        include: { plan: true },
      });
    } catch (error: any) {
      // Prisma P2025: Record not found (version mismatch)
      if (error.code === 'P2025') {
        return null;
      }
      throw error;
    }
  }

  /**
   * Find subscriptions expiring soon (for cron-based lifecycle management).
   */
  async findExpiring(beforeDate: Date): Promise<Subscription[]> {
    return this.prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        currentPeriodEnd: { lte: beforeDate },
      },
      include: { plan: true, tenant: true },
    });
  }

  /**
   * Find canceled subscriptions past grace period (for data access revocation).
   */
  async findPastGracePeriod(beforeDate: Date): Promise<Subscription[]> {
    return this.prisma.subscription.findMany({
      where: {
        status: 'CANCELED',
        gracePeriodEnd: { lte: beforeDate },
      },
    });
  }
}
