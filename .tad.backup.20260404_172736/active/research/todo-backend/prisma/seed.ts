/**
 * Prisma Seed Script — Deterministic test data for Todo App
 *
 * Usage:
 *   npx tsx prisma/seed.ts
 *   npx tsx prisma/seed.ts --profile staging
 *   npx tsx prisma/seed.ts --profile stress
 *
 * Dependencies:
 *   npm install -D @faker-js/faker tsx
 *
 * Add to package.json:
 *   "prisma": { "seed": "tsx prisma/seed.ts" }
 */

import { PrismaClient } from "@prisma/client";
import { faker } from "@faker-js/faker";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

// ─── Deterministic seed ───────────────────────────────────
faker.seed(42);

// ─── Profile configuration ────────────────────────────────

type Profile = "dev" | "staging" | "stress";

const PROFILES: Record<Profile, { users: number; todosPerUser: number; categoriesPerUser: number }> = {
  dev: { users: 5, todosPerUser: 4, categoriesPerUser: 3 },
  staging: { users: 50, todosPerUser: 10, categoriesPerUser: 5 },
  stress: { users: 1000, todosPerUser: 50, categoriesPerUser: 8 },
};

const profile: Profile = (process.argv[3] as Profile) || "dev";
const config = PROFILES[profile] || PROFILES.dev;

// ─── Constants ────────────────────────────────────────────

const PRIORITIES = ["low", "medium", "high", "urgent"] as const;
const DEFAULT_PASSWORD = "TestPass123"; // All seed users share this password
const CATEGORY_PRESETS = [
  { name: "Work", color: "#1565C0" },
  { name: "Personal", color: "#2E7D32" },
  { name: "Shopping", color: "#FF6B6B" },
  { name: "Health", color: "#E65100" },
  { name: "Learning", color: "#7B1FA2" },
  { name: "Finance", color: "#F9A825" },
  { name: "Home", color: "#00838F" },
  { name: "Travel", color: "#AD1457" },
];

// ─── Helpers ──────────────────────────────────────────────

function randomPriority(): string {
  return faker.helpers.arrayElement([...PRIORITIES]);
}

function randomDueDate(): Date | null {
  // 30% chance of no due date
  if (faker.number.int({ min: 1, max: 10 }) <= 3) return null;

  return faker.date.between({
    from: new Date("2026-03-01"),
    to: new Date("2026-06-30"),
  });
}

// ─── Main Seed Function ───────────────────────────────────

async function main() {
  console.log(`Seeding database with profile: ${profile}`);
  console.log(`  Users: ${config.users}`);
  console.log(`  Todos per user: ${config.todosPerUser}`);
  console.log(`  Categories per user: ${config.categoriesPerUser}`);

  // Step 0: Clean existing data (idempotent)
  await prisma.todo.deleteMany();
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();
  console.log("Cleaned existing data.");

  // Step 1: Hash the shared password once
  const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 12);

  // Step 2: Create Owner user (always first)
  const owner = await prisma.user.create({
    data: {
      email: "owner@todoapp.test",
      name: "Admin Owner",
      passwordHash,
      role: "owner",
    },
  });
  console.log(`Created owner: ${owner.email} (${owner.id})`);

  // Step 3: Create Member users
  const members = [];
  for (let i = 0; i < config.users - 1; i++) {
    const member = await prisma.user.create({
      data: {
        email: faker.internet.email().toLowerCase(),
        name: faker.person.fullName(),
        passwordHash,
        role: "member",
      },
    });
    members.push(member);
  }
  console.log(`Created ${members.length} members.`);

  // Step 4: Create one soft-deleted user (edge case)
  const deletedUser = await prisma.user.create({
    data: {
      email: "deleted@todoapp.test",
      name: "Deleted User",
      passwordHash,
      role: "member",
      deletedAt: new Date("2026-03-15T00:00:00Z"),
    },
  });
  console.log(`Created soft-deleted user: ${deletedUser.email}`);

  const allActiveUsers = [owner, ...members];

  // Step 5: Create categories for each user
  const categoryMap = new Map<string, string[]>(); // userId -> categoryIds

  for (const user of allActiveUsers) {
    const userCategories: string[] = [];
    const selectedPresets = faker.helpers.arrayElements(
      CATEGORY_PRESETS,
      Math.min(config.categoriesPerUser, CATEGORY_PRESETS.length)
    );

    for (const preset of selectedPresets) {
      const category = await prisma.category.create({
        data: {
          name: preset.name,
          color: preset.color,
          userId: user.id,
        },
      });
      userCategories.push(category.id);
    }
    categoryMap.set(user.id, userCategories);
  }
  console.log(`Created categories for ${allActiveUsers.length} users.`);

  // Step 6: Create todos for each user
  let totalTodos = 0;
  for (const user of allActiveUsers) {
    const userCategoryIds = categoryMap.get(user.id) || [];

    for (let i = 0; i < config.todosPerUser; i++) {
      // Assign category to ~70% of todos
      const categoryId =
        faker.number.int({ min: 1, max: 10 }) <= 7 && userCategoryIds.length > 0
          ? faker.helpers.arrayElement(userCategoryIds)
          : null;

      await prisma.todo.create({
        data: {
          title: generateTodoTitle(),
          description: faker.number.int({ min: 1, max: 10 }) <= 6
            ? faker.lorem.sentence({ min: 5, max: 20 })
            : null, // 40% have no description
          completed: faker.datatype.boolean({ probability: 0.3 }), // 30% completed
          priority: randomPriority(),
          dueDate: randomDueDate(),
          userId: user.id,
          categoryId,
        },
      });
      totalTodos++;
    }
  }
  console.log(`Created ${totalTodos} todos.`);

  // Step 7: Edge case todos for the owner
  // Todo with maximum length title
  await prisma.todo.create({
    data: {
      title: faker.string.alpha(255),
      description: faker.string.alpha(2000), // max description
      completed: false,
      priority: "urgent",
      dueDate: new Date("2026-04-01T00:00:00Z"),
      userId: owner.id,
    },
  });

  // Todo with Unicode characters (CJK + emoji)
  await prisma.todo.create({
    data: {
      title: "Buy milk from the store",
      description: "Notes with unicode chars",
      completed: false,
      priority: "low",
      userId: owner.id,
    },
  });

  // Overdue todo (due date in the past)
  await prisma.todo.create({
    data: {
      title: "Overdue task from last month",
      description: "This task was due and not completed",
      completed: false,
      priority: "high",
      dueDate: new Date("2026-03-01T00:00:00Z"),
      userId: owner.id,
    },
  });

  console.log("Created edge case todos.");

  // Summary
  const counts = {
    users: await prisma.user.count(),
    categories: await prisma.category.count(),
    todos: await prisma.todo.count(),
  };
  console.log("\nSeed complete:");
  console.log(`  Users: ${counts.users} (1 owner, ${counts.users - 2} members, 1 soft-deleted)`);
  console.log(`  Categories: ${counts.categories}`);
  console.log(`  Todos: ${counts.todos}`);
}

// ─── Todo Title Generator ──────────────────────────────────

function generateTodoTitle(): string {
  const templates = [
    () => `Buy ${faker.commerce.product()}`,
    () => `Call ${faker.person.firstName()}`,
    () => `Review ${faker.company.buzzNoun()} report`,
    () => `Schedule ${faker.word.noun()} meeting`,
    () => `Fix ${faker.hacker.noun()} issue`,
    () => `Update ${faker.word.noun()} documentation`,
    () => `Plan ${faker.word.adjective()} ${faker.word.noun()}`,
    () => `Research ${faker.company.buzzNoun()} options`,
    () => `Clean ${faker.word.noun()}`,
    () => `Prepare ${faker.word.noun()} presentation`,
  ];
  return faker.helpers.arrayElement(templates)();
}

// ─── Execute ──────────────────────────────────────────────

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
