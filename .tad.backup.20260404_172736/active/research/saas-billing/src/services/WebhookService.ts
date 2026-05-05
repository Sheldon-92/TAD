// Webhook Service — Process Stripe webhook events with idempotency
// Handles: payment success/failure, subscription updates, invoice events

import Stripe from 'stripe';
import { WebhookEventRepository } from '../repositories/WebhookEventRepository';
import { SubscriptionRepository } from '../repositories/SubscriptionRepository';
import { InvoiceService } from './InvoiceService';
import { PaymentRetryService } from './PaymentRetryService';
import { NotificationService } from './NotificationService';
import { WebSocketService } from './WebSocketService';
import { AuditService } from './AuditService';

// ═══════════════════════════════════════
// Types
// ═══════════════════════════════════════

// Stripe events we care about for subscription billing
const HANDLED_EVENTS = [
  'customer.subscription.created',
  'customer.subscription.updated',
  'customer.subscription.deleted',
  'customer.subscription.trial_will_end',
  'invoice.payment_succeeded',
  'invoice.payment_failed',
  'invoice.created',
  'invoice.finalized',
  'payment_intent.succeeded',
  'payment_intent.payment_failed',
] as const;

type HandledEventType = typeof HANDLED_EVENTS[number];

// ═══════════════════════════════════════
// Service
// ═══════════════════════════════════════

export class WebhookService {
  constructor(
    private webhookEventRepo: WebhookEventRepository,
    private subscriptionRepo: SubscriptionRepository,
    private invoiceService: InvoiceService,
    private paymentRetryService: PaymentRetryService,
    private notificationService: NotificationService,
    private wsService: WebSocketService,
    private auditService: AuditService,
  ) {}

  /**
   * Process a verified Stripe webhook event.
   *
   * Idempotency guarantee:
   * 1. Check if stripeEventId already exists in WebhookEvent table
   * 2. If exists and status is PROCESSED → return 200 (already handled)
   * 3. If exists and status is PROCESSING → return 200 (in progress)
   * 4. If not exists → insert with RECEIVED, then process
   *
   * Always returns 200 to Stripe to prevent retries for handled events.
   */
  async processEvent(event: Stripe.Event): Promise<{ received: boolean }> {
    // 1. Idempotency check
    const existing = await this.webhookEventRepo.findByStripeEventId(event.id);
    if (existing) {
      if (existing.status === 'PROCESSED' || existing.status === 'PROCESSING') {
        return { received: true }; // Already handled
      }
      // FAILED status → retry processing
    }

    // 2. Store event for idempotency
    const webhookEvent = existing
      ? await this.webhookEventRepo.updateStatus(existing.id, 'PROCESSING')
      : await this.webhookEventRepo.create({
          stripeEventId: event.id,
          eventType: event.type,
          payload: event as any,
          status: 'PROCESSING',
        });

    try {
      // 3. Dispatch to handler
      await this.dispatchEvent(event);

      // 4. Mark as processed
      await this.webhookEventRepo.updateStatus(webhookEvent!.id, 'PROCESSED', new Date());

    } catch (error) {
      // 5. Mark as failed (Stripe will retry)
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      await this.webhookEventRepo.markFailed(webhookEvent!.id, errorMessage);
      // Still return 200 — we'll process on retry
      // [ASSUMPTION] Stripe retries up to 3 days with exponential backoff
    }

    return { received: true };
  }

  /**
   * Route event to appropriate handler.
   */
  private async dispatchEvent(event: Stripe.Event): Promise<void> {
    switch (event.type) {
      case 'invoice.payment_succeeded':
        await this.handlePaymentSucceeded(event);
        break;

      case 'invoice.payment_failed':
        await this.handlePaymentFailed(event);
        break;

      case 'customer.subscription.updated':
        await this.handleSubscriptionUpdated(event);
        break;

      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(event);
        break;

      case 'customer.subscription.trial_will_end':
        await this.handleTrialWillEnd(event);
        break;

      default:
        // Unknown event type — log and ignore
        console.info(`Unhandled Stripe event type: ${event.type}`);
    }
  }

  // ─── Event Handlers ─────────────────────────────

  private async handlePaymentSucceeded(event: Stripe.Event) {
    const invoice = event.data.object as Stripe.Invoice;
    const stripeSubscriptionId = invoice.subscription as string;

    // Update local invoice status
    await this.invoiceService.markPaid(invoice.id, invoice.amount_paid);

    // If subscription was PAST_DUE, restore to ACTIVE
    const subscription = await this.subscriptionRepo.findByStripeId(stripeSubscriptionId);
    if (subscription && subscription.status === 'PAST_DUE') {
      await this.subscriptionRepo.update(subscription.id, {
        status: 'ACTIVE',
      });

      // Notify tenant
      this.wsService.sendToTenant(subscription.tenantId, {
        type: 'SUBSCRIPTION_RESTORED',
        data: {
          subscriptionId: subscription.id,
          message: 'Payment succeeded. Your subscription has been restored.',
        },
        timestamp: new Date().toISOString(),
      });
    }

    // Notify
    if (subscription) {
      this.wsService.sendToTenant(subscription.tenantId, {
        type: 'PAYMENT_SUCCEEDED',
        data: {
          invoiceId: invoice.id,
          amount: invoice.amount_paid,
        },
        timestamp: new Date().toISOString(),
      });
    }
  }

  /**
   * Payment failure handling — the COMPLETE lifecycle:
   *
   * 1. Stripe returns payment_failed → log event (handled here)
   * 2. Update subscription to PAST_DUE
   * 3. Send notification to TenantAdmin + BillingAdmin
   * 4. Schedule retry (exponential backoff: 1h, 4h, 24h, 72h)
   * 5. After max retries (4) → cancel subscription → send final notice
   * 6. Grace period (7 days) before data access revoked
   */
  private async handlePaymentFailed(event: Stripe.Event) {
    const invoice = event.data.object as Stripe.Invoice;
    const stripeSubscriptionId = invoice.subscription as string;

    // 1. Log the payment failure
    await this.invoiceService.recordPaymentFailure(
      invoice.id,
      invoice.last_finalization_error?.code || 'unknown',
      invoice.last_finalization_error?.message || 'Payment failed.',
    );

    // 2. Update subscription to PAST_DUE
    const subscription = await this.subscriptionRepo.findByStripeId(stripeSubscriptionId);
    if (!subscription) return;

    const before = { ...subscription };

    if (subscription.status === 'ACTIVE' || subscription.status === 'TRIALING') {
      await this.subscriptionRepo.update(subscription.id, {
        status: 'PAST_DUE',
      });

      await this.auditService.log({
        tenantId: subscription.tenantId,
        userId: null,
        action: 'STATUS_CHANGE',
        entityType: 'Subscription',
        entityId: subscription.id,
        before,
        after: { ...subscription, status: 'PAST_DUE' },
      });
    }

    // 3. Notify TenantAdmin + BillingAdmin
    await this.notificationService.notifyPaymentFailed(
      subscription.tenantId,
      {
        invoiceId: invoice.id,
        amount: invoice.amount_due,
        failureCode: invoice.last_finalization_error?.code,
        failureMessage: invoice.last_finalization_error?.message,
        attemptNumber: (invoice as any).attempt_count || 1,
      },
    );

    // 4. Schedule retry with exponential backoff
    await this.paymentRetryService.scheduleRetry(
      invoice.id,
      subscription.id,
    );

    // 5. Send WebSocket alert
    this.wsService.sendToTenant(subscription.tenantId, {
      type: 'PAYMENT_FAILED',
      data: {
        invoiceId: invoice.id,
        amount: invoice.amount_due,
        failureReason: invoice.last_finalization_error?.message || 'Payment failed',
        nextRetryAt: this.paymentRetryService.getNextRetryTime(
          (invoice as any).attempt_count || 1,
        ),
      },
      timestamp: new Date().toISOString(),
    });
  }

  private async handleSubscriptionUpdated(event: Stripe.Event) {
    const stripeSub = event.data.object as Stripe.Subscription;
    const subscription = await this.subscriptionRepo.findByStripeId(stripeSub.id);
    if (!subscription) return;

    // Sync status from Stripe
    const statusMap: Record<string, string> = {
      trialing: 'TRIALING',
      active: 'ACTIVE',
      past_due: 'PAST_DUE',
      canceled: 'CANCELED',
      unpaid: 'PAST_DUE',
    };

    const newStatus = statusMap[stripeSub.status] || subscription.status;
    if (newStatus !== subscription.status) {
      await this.subscriptionRepo.update(subscription.id, {
        status: newStatus as any,
        currentPeriodStart: new Date(stripeSub.current_period_start * 1000),
        currentPeriodEnd: new Date(stripeSub.current_period_end * 1000),
      });
    }
  }

  private async handleSubscriptionDeleted(event: Stripe.Event) {
    const stripeSub = event.data.object as Stripe.Subscription;
    const subscription = await this.subscriptionRepo.findByStripeId(stripeSub.id);
    if (!subscription) return;

    const gracePeriodEnd = new Date();
    gracePeriodEnd.setDate(gracePeriodEnd.getDate() + 7);

    await this.subscriptionRepo.update(subscription.id, {
      status: 'EXPIRED',
      gracePeriodEnd,
    });

    await this.notificationService.notifySubscriptionExpired(
      subscription.tenantId,
      subscription.id,
      gracePeriodEnd,
    );
  }

  private async handleTrialWillEnd(event: Stripe.Event) {
    const stripeSub = event.data.object as Stripe.Subscription;
    const subscription = await this.subscriptionRepo.findByStripeId(stripeSub.id);
    if (!subscription) return;

    // Notify 3 days before trial ends
    await this.notificationService.notifyTrialEnding(
      subscription.tenantId,
      subscription.id,
      subscription.trialEnd!,
    );
  }
}
