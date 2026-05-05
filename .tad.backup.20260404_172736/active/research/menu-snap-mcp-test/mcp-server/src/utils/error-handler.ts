/**
 * Centralized error handling for actionable MCP error messages.
 *
 * Rule: Never return raw "error 400". Always suggest what the user can do.
 */

export class DishNotFoundError extends Error {
  constructor(id: string) {
    super(
      `Dish with ID "${id}" not found. ` +
        `Try using search_dishes to find the correct dish ID.`
    );
    this.name = "DishNotFoundError";
  }
}

export class ValidationError extends Error {
  constructor(field: string, detail: string) {
    super(
      `Invalid value for "${field}": ${detail}. ` +
        `Check the tool's input schema for allowed values.`
    );
    this.name = "ValidationError";
  }
}

export class DuplicateDishError extends Error {
  constructor(name: string) {
    super(
      `A dish named "${name}" already exists. ` +
        `Use a different name or update the existing dish.`
    );
    this.name = "DuplicateDishError";
  }
}

/**
 * Format an error into an MCP-compatible error content response.
 */
export function formatErrorResponse(error: unknown): {
  content: Array<{ type: "text"; text: string }>;
  isError: true;
} {
  const message =
    error instanceof Error ? error.message : "An unexpected error occurred.";

  return {
    content: [{ type: "text" as const, text: `Error: ${message}` }],
    isError: true,
  };
}
