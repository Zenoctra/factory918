import { describe, expect, it } from "vite-plus/test";
import { debtCeiling, needsIssueReference } from "./no-todo-without-issue.ts";

describe("needsIssueReference", () => {
  it("reports a bare TODO", () => {
    expect(needsIssueReference(" TODO later")).toBe(true);
  });

  it("reports FIXME and HACK the same way", () => {
    expect(needsIssueReference(" FIXME this breaks on empty input")).toBe(true);
    expect(needsIssueReference(" HACK works around the upstream bug")).toBe(true);
  });

  it("accepts a TODO that names an issue", () => {
    expect(needsIssueReference(" TODO(#123): drop once the migration lands")).toBe(false);
  });

  it("accepts an issue reference anywhere on the line", () => {
    expect(needsIssueReference(" TODO drop once #42 ships")).toBe(false);
  });

  it("leaves ordinary comments alone", () => {
    expect(needsIssueReference(" Parses the header before the body.")).toBe(false);
  });

  it("does not match TODO inside a longer word", () => {
    expect(needsIssueReference(" TODOS.md lists the open work")).toBe(false);
  });
});

describe("debtCeiling", () => {
  it("is zero when the rule takes no options", () => {
    expect(debtCeiling(undefined)).toBe(0);
  });

  it("reads maxOccurrences", () => {
    expect(debtCeiling({ maxOccurrences: 12 })).toBe(12);
  });

  it("is zero for a non-numeric ceiling", () => {
    expect(debtCeiling({ maxOccurrences: "12" })).toBe(0);
  });
});
