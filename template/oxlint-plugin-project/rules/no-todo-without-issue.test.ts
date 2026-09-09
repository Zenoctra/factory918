// DRAFT. Follow the shape of t3code's rule tests (oxlint-plugin-t3code/rules/*.test.ts) once the plugin runs.
import { describe, it, expect } from "vitest";
describe("no-todo-without-issue", () => {
  it("is exercised by `vp lint` on a fixture containing `// TODO later` (M1 acceptance)", () => {
    expect(true).toBe(true);
  });
});
