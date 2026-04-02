// Usage Record Repository — Data access for usage tracking

import { PrismaClient, UsageRecord } from '@prisma/client';

export class UsageRecordRepository {
  constructor(private prisma: PrismaClient) {}

  async findByTransactionId(transactionId: string): Promise<UsageRecord | null> {
    return this.prisma.usageRecord.findUnique({
      where: { transactionId },
    });
  }

  async create(data: {
    tenantId: string;
    subscriptionId: string;
    featureName: string;
    quantity: number;
    transactionId: string;
    timestamp: Date;
  }): Promise<UsageRecord> {
    return this.prisma.usageRecord.create({ data });
  }

  /**
   * Sum usage quantity for a tenant/feature within a period.
   * Uses the composite index (tenantId, featureName, timestamp).
   */
  async sumQuantity(
    tenantId: string,
    featureName: string,
    periodStart: Date,
    periodEnd: Date,
  ): Promise<number> {
    const result = await this.prisma.usageRecord.aggregate({
      where: {
        tenantId,
        featureName,
        timestamp: {
          gte: periodStart,
          lte: periodEnd,
        },
      },
      _sum: { quantity: true },
    });
    return result._sum.quantity || 0;
  }

  /**
   * Get usage breakdown by day for charting.
   */
  async getDailyBreakdown(
    tenantId: string,
    featureName: string,
    periodStart: Date,
    periodEnd: Date,
  ): Promise<{ date: string; total: number }[]> {
    // [ASSUMPTION] Using raw SQL for date grouping (Prisma doesn't support GROUP BY date)
    const results = await this.prisma.$queryRaw<{ date: string; total: bigint }[]>`
      SELECT DATE(timestamp) as date, SUM(quantity) as total
      FROM "UsageRecord"
      WHERE "tenantId" = ${tenantId}
        AND "featureName" = ${featureName}
        AND timestamp >= ${periodStart}
        AND timestamp <= ${periodEnd}
      GROUP BY DATE(timestamp)
      ORDER BY date ASC
    `;
    return results.map((r) => ({ date: r.date, total: Number(r.total) }));
  }
}
