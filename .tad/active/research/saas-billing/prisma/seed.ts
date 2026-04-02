// Seed Data — Multi-Tenant SaaS Billing System
// Covers ALL subscription statuses, multiple tenants, usage near limits, failed payments
// Deterministic: faker.seed(42)

import { PrismaClient } from '@prisma/client';
import { faker } from '@faker-js/faker';
import crypto from 'crypto';

faker.seed(42);

const prisma = new PrismaClient();

// ═══════════════════════════════════════
// Helper Functions
// ═══════════════════════════════════════

function hashPassword(plain: string): string {
  // [ASSUMPTION] In production, use bcrypt. For seed, SHA-256 placeholder.
  return crypto.createHash('sha256').update(plain).digest('hex');
}

function daysAgo(n: number): Date {
  const d = new Date('2026-04-01T00:00:00Z');
  d.setDate(d.getDate() - n);
  return d;
}

function daysFromNow(n: number): Date {
  const d = new Date('2026-04-01T00:00:00Z');
  d.setDate(d.getDate() + n);
  return d;
}

// ═══════════════════════════════════════
// Seed Main Function
// ═══════════════════════════════════════

async function main() {
  console.log('Seeding multi-tenant SaaS billing data...');

  // Clean existing data (idempotent)
  await prisma.auditLog.deleteMany();
  await prisma.webhookEvent.deleteMany();
  await prisma.usageRecord.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.invoiceLineItem.deleteMany();
  await prisma.invoice.deleteMany();
  await prisma.subscriptionItem.deleteMany();
  await prisma.subscription.deleteMany();
  await prisma.planFeature.deleteMany();
  await prisma.plan.deleteMany();
  await prisma.apiKey.deleteMany();
  await prisma.user.deleteMany();
  await prisma.tenant.deleteMany();

  // ═══════ 1. Plans (Platform-wide) ═══════

  const freePlan = await prisma.plan.create({
    data: {
      name: 'Free',
      slug: 'free',
      description: 'For individuals getting started',
      priceMonthly: 0,
      priceYearly: 0,
      currency: 'usd',
      trialDays: 0,
      isActive: true,
      sortOrder: 1,
      stripePriceId: 'price_free_monthly',
      features: {
        create: [
          { name: 'api_calls', limit: 1000, unit: 'calls/month', overagePrice: 0 },
          { name: 'storage', limit: 1, unit: 'GB', overagePrice: 0 },
          { name: 'team_members', limit: 2, unit: 'seats', overagePrice: 0 },
        ],
      },
    },
    include: { features: true },
  });

  const proPlan = await prisma.plan.create({
    data: {
      name: 'Pro',
      slug: 'pro',
      description: 'For growing teams',
      priceMonthly: 4900, // $49/month
      priceYearly: 49000, // $490/year
      currency: 'usd',
      trialDays: 14,
      isActive: true,
      sortOrder: 2,
      stripePriceId: 'price_pro_monthly',
      features: {
        create: [
          { name: 'api_calls', limit: 100000, unit: 'calls/month', overagePrice: 1 },
          { name: 'storage', limit: 50, unit: 'GB', overagePrice: 50 },
          { name: 'team_members', limit: 25, unit: 'seats', overagePrice: 500 },
        ],
      },
    },
    include: { features: true },
  });

  const enterprisePlan = await prisma.plan.create({
    data: {
      name: 'Enterprise',
      slug: 'enterprise',
      description: 'For large organizations',
      priceMonthly: 19900, // $199/month
      priceYearly: 199000, // $1,990/year
      currency: 'usd',
      trialDays: 30,
      isActive: true,
      sortOrder: 3,
      stripePriceId: 'price_enterprise_monthly',
      features: {
        create: [
          { name: 'api_calls', limit: -1, unit: 'calls/month', overagePrice: 0 }, // unlimited
          { name: 'storage', limit: 500, unit: 'GB', overagePrice: 25 },
          { name: 'team_members', limit: -1, unit: 'seats', overagePrice: 0 }, // unlimited
        ],
      },
    },
    include: { features: true },
  });

  // Archived plan (inactive)
  await prisma.plan.create({
    data: {
      name: 'Starter (Deprecated)',
      slug: 'starter-deprecated',
      description: 'Legacy plan — no longer available',
      priceMonthly: 1900,
      currency: 'usd',
      trialDays: 7,
      isActive: false,
      sortOrder: 99,
    },
  });

  console.log('  Plans created: Free, Pro, Enterprise, Starter (archived)');

  // ═══════ 2. Tenants ═══════

  // Tenant 1: Acme Corp — Active Pro subscription, heavy usage
  const acme = await prisma.tenant.create({
    data: {
      name: 'Acme Corp',
      slug: 'acme-corp',
      billingEmail: 'billing@acme.example.com',
      stripeCustomerId: 'cus_acme_001',
    },
  });

  // Tenant 2: Globex Inc — Enterprise, past_due payment
  const globex = await prisma.tenant.create({
    data: {
      name: 'Globex Inc',
      slug: 'globex-inc',
      billingEmail: 'finance@globex.example.com',
      stripeCustomerId: 'cus_globex_002',
    },
  });

  // Tenant 3: Initech — Trialing, new customer
  const initech = await prisma.tenant.create({
    data: {
      name: 'Initech',
      slug: 'initech',
      billingEmail: 'admin@initech.example.com',
      stripeCustomerId: 'cus_initech_003',
    },
  });

  // Tenant 4: Umbrella Corp — Canceled, in grace period
  const umbrella = await prisma.tenant.create({
    data: {
      name: 'Umbrella Corp',
      slug: 'umbrella-corp',
      billingEmail: 'billing@umbrella.example.com',
      stripeCustomerId: 'cus_umbrella_004',
    },
  });

  // Tenant 5: Soylent Corp — Expired (past grace period)
  const soylent = await prisma.tenant.create({
    data: {
      name: 'Soylent Corp',
      slug: 'soylent-corp',
      billingEmail: 'ops@soylent.example.com',
      stripeCustomerId: 'cus_soylent_005',
    },
  });

  // Tenant 6: Soft-deleted tenant
  const deletedTenant = await prisma.tenant.create({
    data: {
      name: 'Defunct LLC',
      slug: 'defunct-llc',
      billingEmail: 'gone@defunct.example.com',
      deletedAt: daysAgo(30),
    },
  });

  console.log('  Tenants created: 6 (including 1 soft-deleted)');

  // ═══════ 3. Users (All Roles Covered) ═══════

  // SuperAdmin (platform-wide)
  const superAdmin = await prisma.user.create({
    data: {
      email: 'admin@platform.example.com',
      name: 'Platform Admin',
      passwordHash: hashPassword('super-secret-admin'),
      role: 'SUPER_ADMIN',
      tenantId: acme.id, // SuperAdmin still belongs to a tenant
    },
  });

  // Acme users (all roles)
  const acmeAdmin = await prisma.user.create({
    data: {
      email: 'alice@acme.example.com',
      name: faker.person.fullName(),
      passwordHash: hashPassword('password123'),
      role: 'TENANT_ADMIN',
      tenantId: acme.id,
    },
  });

  const acmeBilling = await prisma.user.create({
    data: {
      email: 'bob@acme.example.com',
      name: faker.person.fullName(),
      passwordHash: hashPassword('password123'),
      role: 'BILLING_ADMIN',
      tenantId: acme.id,
    },
  });

  const acmeMember = await prisma.user.create({
    data: {
      email: 'charlie@acme.example.com',
      name: faker.person.fullName(),
      passwordHash: hashPassword('password123'),
      role: 'MEMBER',
      tenantId: acme.id,
    },
  });

  // Soft-deleted user
  await prisma.user.create({
    data: {
      email: 'ex-employee@acme.example.com',
      name: 'Former Employee',
      passwordHash: hashPassword('password123'),
      role: 'MEMBER',
      tenantId: acme.id,
      deletedAt: daysAgo(15),
    },
  });

  // Globex users
  const globexAdmin = await prisma.user.create({
    data: {
      email: 'hank@globex.example.com',
      name: faker.person.fullName(),
      passwordHash: hashPassword('password123'),
      role: 'TENANT_ADMIN',
      tenantId: globex.id,
    },
  });

  // Initech, Umbrella, Soylent — one admin each
  for (const tenant of [initech, umbrella, soylent]) {
    await prisma.user.create({
      data: {
        email: `admin@${tenant.slug}.example.com`,
        name: faker.person.fullName(),
        passwordHash: hashPassword('password123'),
        role: 'TENANT_ADMIN',
        tenantId: tenant.id,
      },
    });
  }

  console.log('  Users created: 9 (SuperAdmin, TenantAdmin, BillingAdmin, Member, soft-deleted)');

  // ═══════ 4. API Keys ═══════

  await prisma.apiKey.create({
    data: {
      keyHash: crypto.createHash('sha256').update('sk_live_acme_test_key_123').digest('hex'),
      name: 'Acme Production Key',
      tenantId: acme.id,
    },
  });

  await prisma.apiKey.create({
    data: {
      keyHash: crypto.createHash('sha256').update('sk_live_globex_key_456').digest('hex'),
      name: 'Globex API Key',
      tenantId: globex.id,
      expiresAt: daysFromNow(60),
    },
  });

  // Revoked key
  await prisma.apiKey.create({
    data: {
      keyHash: crypto.createHash('sha256').update('sk_live_acme_old_key').digest('hex'),
      name: 'Acme Old Key (Revoked)',
      tenantId: acme.id,
      revokedAt: daysAgo(10),
    },
  });

  console.log('  API Keys created: 3 (1 active, 1 with expiry, 1 revoked)');

  // ═══════ 5. Subscriptions (All Statuses) ═══════

  // Acme: ACTIVE Pro subscription
  const acmeSub = await prisma.subscription.create({
    data: {
      tenantId: acme.id,
      planId: proPlan.id,
      status: 'ACTIVE',
      currentPeriodStart: daysAgo(15),
      currentPeriodEnd: daysFromNow(15),
      stripeSubscriptionId: 'sub_acme_active_001',
      version: 3, // Has been upgraded before
    },
  });

  // Create subscription items for Acme
  for (const feature of proPlan.features) {
    await prisma.subscriptionItem.create({
      data: { subscriptionId: acmeSub.id, planFeatureId: feature.id, quantity: 1 },
    });
  }

  // Globex: PAST_DUE Enterprise subscription
  const globexSub = await prisma.subscription.create({
    data: {
      tenantId: globex.id,
      planId: enterprisePlan.id,
      status: 'PAST_DUE',
      currentPeriodStart: daysAgo(20),
      currentPeriodEnd: daysFromNow(10),
      stripeSubscriptionId: 'sub_globex_pastdue_002',
      version: 1,
    },
  });

  for (const feature of enterprisePlan.features) {
    await prisma.subscriptionItem.create({
      data: { subscriptionId: globexSub.id, planFeatureId: feature.id, quantity: 1 },
    });
  }

  // Initech: TRIALING Pro subscription
  const initechSub = await prisma.subscription.create({
    data: {
      tenantId: initech.id,
      planId: proPlan.id,
      status: 'TRIALING',
      currentPeriodStart: daysAgo(3),
      currentPeriodEnd: daysFromNow(11), // 14-day trial
      trialEnd: daysFromNow(11),
      stripeSubscriptionId: 'sub_initech_trial_003',
      version: 1,
    },
  });

  // Umbrella: CANCELED (in 7-day grace period)
  const umbrellaSub = await prisma.subscription.create({
    data: {
      tenantId: umbrella.id,
      planId: proPlan.id,
      status: 'CANCELED',
      currentPeriodStart: daysAgo(25),
      currentPeriodEnd: daysFromNow(5),
      canceledAt: daysAgo(2),
      cancelReason: 'Switching to competitor',
      gracePeriodEnd: daysFromNow(5), // 7 days from cancellation
      stripeSubscriptionId: 'sub_umbrella_canceled_004',
      version: 2,
    },
  });

  // Soylent: EXPIRED (past grace period)
  const soylentSub = await prisma.subscription.create({
    data: {
      tenantId: soylent.id,
      planId: proPlan.id,
      status: 'EXPIRED',
      currentPeriodStart: daysAgo(60),
      currentPeriodEnd: daysAgo(30),
      canceledAt: daysAgo(37),
      cancelReason: 'Payment failed after maximum retry attempts.',
      gracePeriodEnd: daysAgo(30),
      stripeSubscriptionId: 'sub_soylent_expired_005',
      version: 1,
    },
  });

  console.log('  Subscriptions: ACTIVE, PAST_DUE, TRIALING, CANCELED, EXPIRED');

  // ═══════ 6. Invoices & Payments ═══════

  // Acme: Paid invoice
  const acmeInvoice1 = await prisma.invoice.create({
    data: {
      subscriptionId: acmeSub.id,
      tenantId: acme.id,
      status: 'PAID',
      amountDue: 4900,
      amountPaid: 4900,
      currency: 'usd',
      dueDate: daysAgo(15),
      paidAt: daysAgo(15),
      stripeInvoiceId: 'in_acme_paid_001',
      lineItems: {
        create: [
          {
            description: 'Pro plan — Mar 2026',
            quantity: 1,
            unitPrice: 4900,
            amount: 4900,
            type: 'SUBSCRIPTION',
          },
        ],
      },
      payments: {
        create: [
          {
            amount: 4900,
            status: 'SUCCEEDED',
            stripePaymentIntentId: 'pi_acme_success_001',
            attemptNumber: 1,
          },
        ],
      },
    },
  });

  // Acme: Current open invoice
  await prisma.invoice.create({
    data: {
      subscriptionId: acmeSub.id,
      tenantId: acme.id,
      status: 'OPEN',
      amountDue: 4900,
      amountPaid: 0,
      currency: 'usd',
      dueDate: daysFromNow(15),
      stripeInvoiceId: 'in_acme_open_002',
      lineItems: {
        create: [
          {
            description: 'Pro plan — Apr 2026',
            quantity: 1,
            unitPrice: 4900,
            amount: 4900,
            type: 'SUBSCRIPTION',
          },
        ],
      },
    },
  });

  // Globex: Failed payment with retry history
  const globexInvoice = await prisma.invoice.create({
    data: {
      subscriptionId: globexSub.id,
      tenantId: globex.id,
      status: 'OPEN',
      amountDue: 19900,
      amountPaid: 0,
      currency: 'usd',
      dueDate: daysAgo(5),
      stripeInvoiceId: 'in_globex_failed_001',
      lineItems: {
        create: [
          {
            description: 'Enterprise plan — Mar 2026',
            quantity: 1,
            unitPrice: 19900,
            amount: 19900,
            type: 'SUBSCRIPTION',
          },
        ],
      },
      payments: {
        create: [
          {
            amount: 19900,
            status: 'FAILED',
            stripePaymentIntentId: 'pi_globex_fail_001',
            failureCode: 'card_declined',
            failureMessage: 'Your card was declined.',
            attemptNumber: 1,
            createdAt: daysAgo(5),
          },
          {
            amount: 19900,
            status: 'FAILED',
            stripePaymentIntentId: 'pi_globex_fail_002',
            failureCode: 'insufficient_funds',
            failureMessage: 'Your card has insufficient funds.',
            attemptNumber: 2,
            createdAt: daysAgo(4),
          },
          {
            amount: 19900,
            status: 'FAILED',
            stripePaymentIntentId: 'pi_globex_fail_003',
            failureCode: 'card_declined',
            failureMessage: 'Your card was declined.',
            attemptNumber: 3,
            createdAt: daysAgo(3),
          },
        ],
      },
    },
  });

  // Soylent: Uncollectible invoice
  await prisma.invoice.create({
    data: {
      subscriptionId: soylentSub.id,
      tenantId: soylent.id,
      status: 'UNCOLLECTIBLE',
      amountDue: 4900,
      amountPaid: 0,
      currency: 'usd',
      dueDate: daysAgo(45),
      stripeInvoiceId: 'in_soylent_uncollectible_001',
      lineItems: {
        create: [
          {
            description: 'Pro plan — Feb 2026',
            quantity: 1,
            unitPrice: 4900,
            amount: 4900,
            type: 'SUBSCRIPTION',
          },
        ],
      },
      payments: {
        create: [
          { amount: 4900, status: 'FAILED', failureCode: 'expired_card', failureMessage: 'Card expired.', attemptNumber: 1, createdAt: daysAgo(45) },
          { amount: 4900, status: 'FAILED', failureCode: 'expired_card', failureMessage: 'Card expired.', attemptNumber: 2, createdAt: daysAgo(44) },
          { amount: 4900, status: 'FAILED', failureCode: 'expired_card', failureMessage: 'Card expired.', attemptNumber: 3, createdAt: daysAgo(43) },
          { amount: 4900, status: 'FAILED', failureCode: 'expired_card', failureMessage: 'Card expired.', attemptNumber: 4, createdAt: daysAgo(40) },
        ],
      },
    },
  });

  console.log('  Invoices: PAID, OPEN, OPEN (failed), UNCOLLECTIBLE');
  console.log('  Payments: 1 SUCCEEDED, 7 FAILED (retry history)');

  // ═══════ 7. Usage Records ═══════

  // Acme: Heavy API usage (85% of limit — near overage)
  for (let day = 0; day < 15; day++) {
    const date = new Date(daysAgo(15 - day));
    const quantity = Math.floor(faker.number.int({ min: 4000, max: 7000 }));
    await prisma.usageRecord.create({
      data: {
        tenantId: acme.id,
        subscriptionId: acmeSub.id,
        featureName: 'api_calls',
        quantity,
        transactionId: `txn_acme_api_${faker.string.uuid()}`,
        timestamp: date,
      },
    });
  }

  // Acme: Storage at 84% (42 GB of 50 GB)
  await prisma.usageRecord.create({
    data: {
      tenantId: acme.id,
      subscriptionId: acmeSub.id,
      featureName: 'storage',
      quantity: 42,
      transactionId: `txn_acme_storage_${faker.string.uuid()}`,
      timestamp: daysAgo(1),
    },
  });

  // Globex: Enterprise — heavy but no limit issues (unlimited API calls)
  for (let day = 0; day < 10; day++) {
    await prisma.usageRecord.create({
      data: {
        tenantId: globex.id,
        subscriptionId: globexSub.id,
        featureName: 'api_calls',
        quantity: faker.number.int({ min: 20000, max: 50000 }),
        transactionId: `txn_globex_api_${faker.string.uuid()}`,
        timestamp: daysAgo(10 - day),
      },
    });
  }

  // Initech: Minimal trial usage
  await prisma.usageRecord.create({
    data: {
      tenantId: initech.id,
      subscriptionId: initechSub.id,
      featureName: 'api_calls',
      quantity: 250,
      transactionId: `txn_initech_api_${faker.string.uuid()}`,
      timestamp: daysAgo(1),
    },
  });

  console.log('  Usage records: ~27 records (Acme near limit, Globex heavy, Initech minimal)');

  // ═══════ 8. Webhook Events ═══════

  await prisma.webhookEvent.create({
    data: {
      stripeEventId: 'evt_payment_succeeded_001',
      eventType: 'invoice.payment_succeeded',
      status: 'PROCESSED',
      payload: { type: 'invoice.payment_succeeded', data: { object: { id: 'in_acme_paid_001' } } },
      processedAt: daysAgo(15),
    },
  });

  await prisma.webhookEvent.create({
    data: {
      stripeEventId: 'evt_payment_failed_001',
      eventType: 'invoice.payment_failed',
      status: 'PROCESSED',
      payload: { type: 'invoice.payment_failed', data: { object: { id: 'in_globex_failed_001' } } },
      processedAt: daysAgo(5),
    },
  });

  await prisma.webhookEvent.create({
    data: {
      stripeEventId: 'evt_sub_trial_end_001',
      eventType: 'customer.subscription.trial_will_end',
      status: 'RECEIVED', // Not yet processed
      payload: { type: 'customer.subscription.trial_will_end', data: { object: { id: 'sub_initech_trial_003' } } },
    },
  });

  console.log('  Webhook events: 3 (PROCESSED, PROCESSED, RECEIVED)');

  // ═══════ 9. Audit Logs ═══════

  await prisma.auditLog.create({
    data: {
      tenantId: acme.id,
      userId: acmeAdmin.id,
      action: 'CREATE',
      entityType: 'Subscription',
      entityId: acmeSub.id,
      after: { planId: proPlan.id, status: 'TRIALING' },
      ipAddress: '203.0.113.50',
    },
  });

  await prisma.auditLog.create({
    data: {
      tenantId: acme.id,
      userId: acmeBilling.id,
      action: 'STATUS_CHANGE',
      entityType: 'Subscription',
      entityId: acmeSub.id,
      before: { status: 'TRIALING', version: 1 },
      after: { status: 'ACTIVE', version: 2 },
      ipAddress: '203.0.113.51',
    },
  });

  await prisma.auditLog.create({
    data: {
      tenantId: umbrella.id,
      userId: null, // System action
      action: 'STATUS_CHANGE',
      entityType: 'Subscription',
      entityId: umbrellaSub.id,
      before: { status: 'ACTIVE' },
      after: { status: 'CANCELED', cancelReason: 'Switching to competitor' },
    },
  });

  console.log('  Audit logs: 3 entries');

  // ═══════ Summary ═══════

  console.log('\n--- Seed Summary ---');
  console.log(`Plans: 4 (3 active, 1 archived)`);
  console.log(`Tenants: 6 (5 active, 1 soft-deleted)`);
  console.log(`Users: 9 (all 4 roles represented, 1 soft-deleted)`);
  console.log(`API Keys: 3 (1 active, 1 expiring, 1 revoked)`);
  console.log(`Subscriptions: 5 (ACTIVE, PAST_DUE, TRIALING, CANCELED, EXPIRED)`);
  console.log(`Invoices: 4 (PAID, OPEN, OPEN+failed, UNCOLLECTIBLE)`);
  console.log(`Payments: 8 (1 succeeded, 7 failed across retries)`);
  console.log(`Usage Records: ~27 (near-limit, heavy, minimal)`);
  console.log(`Webhook Events: 3 (processed + pending)`);
  console.log(`Audit Logs: 3`);
  console.log('Seed complete!');
}

main()
  .catch((e) => {
    console.error('Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
