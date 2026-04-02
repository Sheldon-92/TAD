// Webhook Event Repository — Idempotent webhook event storage

import { PrismaClient, WebhookEvent, WebhookEventStatus } from '@prisma/client';

export class WebhookEventRepository {
  constructor(private prisma: PrismaClient) {}

  async findByStripeEventId(stripeEventId: string): Promise<WebhookEvent | null> {
    return this.prisma.webhookEvent.findUnique({
      where: { stripeEventId },
    });
  }

  async create(data: {
    stripeEventId: string;
    eventType: string;
    payload: any;
    status: WebhookEventStatus;
  }): Promise<WebhookEvent> {
    return this.prisma.webhookEvent.create({ data });
  }

  async updateStatus(
    id: string,
    status: WebhookEventStatus,
    processedAt?: Date,
  ): Promise<WebhookEvent> {
    return this.prisma.webhookEvent.update({
      where: { id },
      data: { status, processedAt },
    });
  }

  async markFailed(id: string, errorMessage: string): Promise<WebhookEvent> {
    return this.prisma.webhookEvent.update({
      where: { id },
      data: {
        status: 'FAILED',
        errorMessage,
        retryCount: { increment: 1 },
      },
    });
  }

  /**
   * Cleanup old processed events (retention policy).
   * [ASSUMPTION] Run via cron job, retain events for 90 days.
   */
  async cleanupOld(retentionDays: number = 90): Promise<number> {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - retentionDays);

    const result = await this.prisma.webhookEvent.deleteMany({
      where: {
        status: 'PROCESSED',
        createdAt: { lt: cutoff },
      },
    });
    return result.count;
  }
}
