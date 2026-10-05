import assert from "node:assert";
import { stableSlug } from "./util.mjs";

assert.strictEqual(stableSlug(""), "");
assert.strictEqual(stableSlug(" Hello, WORLD! "), "hello-world");
assert.strictEqual(stableSlug("foo___bar"), "foo-bar");

console.log("tests ok");
