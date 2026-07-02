// Payment Retry Service — Exponential backoff for failed payments
// Schedule: 1h → 4h → 24h → 72h → cancel subscription

import { SubscriptionRepository } from '../repositories/SubscriptionRepository';
import { InvoiceService } from './InvoiceService';
import { NotificationService } from './NotificationService';
import { WebSocketService } from './WebSocketService';
import { AuditService } from './AuditService';

// ═══════════════════════════════════════
// Constants
// ═══════════════════════════════════════

// Retry delays in milliseconds (exponential backoff)
const RETRY_DELAYS_MS = [
  1 * 60 * 60 * 1000,    // 1 hour
  4 * 60 * 60 * 1000,    // 4 hours
  24 * 60 * 60 * 1000,   // 24 hours
  72 * 60 * 60 * 1000,   // 72 hours (3 days)
];

const MAX_RETRIES = RETRY_DELAYS_MS.length; // 4 retries total
const GRACE_PERIOD_DAYS = 7;

// ═══════════════════════════════════════
// Service
// ═══════════════════════════════════════

export class PaymentRetryService {
  constructor(
    private subscriptionRepo: SubscriptionRepository,
    private invoiceService: InvoiceService,
    private notificationService: NotificationService,
    private wsService: WebSocketService,
    private auditService: AuditService,
  ) {}

  /**
   * Schedule a payment retry with exponential backoff.
   * Called by WebhookService when invoice.payment_failed is received.
   *
   * [ASSUMPTION] Uses a job queue (e.g., BullMQ) for delayed execution.
   * This is the handler that runs when the delayed job fires.
   */
  async scheduleRetry(stripeInvoiceId: string, subscriptionId: string): Promise<void> {
    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) return;

    const invoice = await this.invoiceService.findByStripeId(stripeInvoiceId);
    if (!invoice) return;

    const currentAttempt = invoice.payments.length; // Number of attempts so far

    if (currentAttempt >= MAX_RETRIES) {
      // Max retries exceeded → cancel subscription
      await this.handleMaxRetriesExceeded(subscriptionId, stripeInvoiceId);
      return;
    }

    const delayMs = RETRY_DELAYS_MS[currentAttempt] || RETRY_DELAYS_MS[MAX_RETRIES - 1];
    const nextRetryAt = new Date(Date.now() + delayMs);

    // [ASSUMPTION] Enqueue delayed job — pseudocode for BullMQ:
    // await retryQueue.add('retry-payment', { stripeInvoiceId, subscriptionId, attempt: currentAttempt + 1 }, { delay: delayMs });

    console.info(
      `Scheduled payment retry #${currentAttempt + 1} for invoice ${stripeInvoiceId} at ${nextRetryAt.toISOString()}`,
    );
  }

  /**
   * Execute a payment retry attempt.
   * Called by the job queue worker when the delayed job fires.
   */
  async executeRetry(stripeInvoiceId: string, subscriptionId: string, attempt: number): Promise<void> {
    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) return;

    // Skip if subscription is no longer PAST_DUE (e.g., user paid manually)
    if (subscription.status !== 'PAST_DUE') {
      console.info(`Skipping retry — subscription ${subscriptionId} is ${subscription.status}`);
      return;
    }

    try {
      // Attempt payment via Stripe
      // [ASSUMPTION] Stripe.invoices.pay() retries the payment
      await this.invoiceService.retryPayment(stripeInvoiceId);

      // If we get here, payment succeeded — Stripe will send invoice.payment_succeeded webhook
      console.info(`Payment retry #${attempt} succeeded for ${stripeInvoiceId}`);

    } catch (error) {
      console.warn(`Payment retry #${attempt} failed for ${stripeInvoiceId}: ${error}`);

      // Notify tenant about failed retry
      await this.notificationService.notifyPaymentRetryFailed(
        subscription.tenantId,
        {
          invoiceId: stripeInvoiceId,
          attempt,
          maxRetries: MAX_RETRIES,
          nextRetryAt: attempt < MAX_RETRIES
            ? new Date(Date.now() + RETRY_DELAYS_MS[attempt])
            : null,
        },
      );

      if (attempt >= MAX_RETRIES) {
        await this.handleMaxRetriesExceeded(subscriptionId, stripeInvoiceId);
      }
    }
  }

  /**
   * Handle max retries exceeded:
   * 1. Cancel subscription
   * 2. Set grace period (7 days before data access revoked)
   * 3. Send final notice
   */
  private async handleMaxRetriesExceeded(
    subscriptionId: string,
    stripeInvoiceId: string,
  ): Promise<void> {
    const subscription = await this.subscriptionRepo.findById(subscriptionId);
    if (!subscription) return;

    const before = { ...subscription };
    const gracePeriodEnd = new Date();
    gracePeriodEnd.setDate(gracePeriodEnd.getDate() + GRACE_PERIOD_DAYS);

    // Cancel subscription with grace period
    await this.subscriptionRepo.update(subscriptionId, {
      status: 'CANCELED',
      canceledAt: new Date(),
      cancelReason: 'Payment failed after maximum retry attempts.',
      gracePeriodEnd,
    });

    // Audit
    await this.auditService.log({
      tenantId: subscription.tenantId,
      userId: null,
      action: 'STATUS_CHANGE',
      entityType: 'Subscription',
      entityId: subscriptionId,
      before,
      after: {
        ...subscription,
        status: 'CANCELED',
        cancelReason: 'Payment failed after maximum retry attempts.',
      },
    });

    // Send final notice
    await this.notificationService.notifySubscriptionCanceled(
      subscription.tenantId,
      {
        subscriptionId,
        reason: 'payment_failure',
        gracePeriodEnd,
        message: `Your subscription has been canceled due to payment failure after ${MAX_RETRIES} retry attempts. You have ${GRACE_PERIOD_DAYS} days to resolve payment before data access is revoked.`,
      },
    );

    // WebSocket alert
    this.wsService.sendToTenant(subscription.tenantId, {
      type: 'SUBSCRIPTION_CANCELED',
      data: {
        subscriptionId,
        reason: 'payment_failure_max_retries',
        gracePeriodEnd: gracePeriodEnd.toISOString(),
      },
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * Get the next retry time based on attempt number.
   * Used for display in notifications and WebSocket alerts.
   */
  getNextRetryTime(currentAttempt: number): string | null {
    if (currentAttempt >= MAX_RETRIES) return null;
    const delayMs = RETRY_DELAYS_MS[currentAttempt];
    return new Date(Date.now() + delayMs).toISOString();
  }
}
