import assert from "node:assert/strict";
import { stableSlug } from "./util.mjs";

assert.strictEqual(stableSlug(" Hello, WORLD! "), "hello-world");
assert.strictEqual(stableSlug("foo---bar__baz"), "foo-bar-baz");
assert.strictEqual(stableSlug(""), "");

console.log("tests ok");
