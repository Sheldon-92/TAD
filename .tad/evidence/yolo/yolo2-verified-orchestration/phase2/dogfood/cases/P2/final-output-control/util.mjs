export function stableSlug(s) {
  return s
    .trim()
    .replace(/[A-Z]/g, (letter) => letter.toLowerCase())
    .replace(/[^A-Za-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
