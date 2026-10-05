export function stableSlug(s) {
  return s
    .trim()
    .replace(/[A-Z]/g, (c) => c.toLowerCase())
    .replace(/[^A-Za-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
