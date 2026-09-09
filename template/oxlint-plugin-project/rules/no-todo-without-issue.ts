import { defineRule } from "@oxlint/plugins";

// Shape follows pingdotgg/t3code's rules (defineRule, meta, create(context), context.report).
// An unticketed note is a plan committed to the repo. Reference an issue, or file one and delete the note.
const TODO = /\b(TODO|FIXME|HACK)\b(?![^\n]*#\d+)/u;

/** True when a comment carries a TODO, FIXME or HACK with no `#123` beside it. */
export function needsIssueReference(comment: string): boolean {
  return TODO.test(comment);
}

/**
 * Theo's debt ceiling: the first N occurrences pass and the (N+1)th is reported.
 * The rule's options arrive as unvalidated JSON, so read the number out rather than casting.
 */
export function debtCeiling(option: unknown): number {
  if (typeof option !== "object" || option === null) return 0;
  if (!("maxOccurrences" in option)) return 0;
  const value = option.maxOccurrences;
  return typeof value === "number" ? value : 0;
}

export default defineRule({
  meta: {
    type: "problem",
    docs: {
      description:
        "Disallow TODO/FIXME/HACK comments that do not reference a tracker issue (#123).",
    },
    schema: [
      {
        type: "object",
        properties: {
          maxOccurrences: {
            type: "integer",
            minimum: 0,
            description: "Legacy debt ceiling for this file.",
          },
        },
        additionalProperties: false,
      },
    ],
  },
  create(context) {
    const allowed = debtCeiling(context.options[0]);
    let seen = 0;
    return {
      Program() {
        for (const comment of context.sourceCode.getAllComments()) {
          if (!needsIssueReference(comment.value)) continue;
          seen++;
          if (seen <= allowed) continue;
          context.report({
            node: comment,
            message:
              "Reference a tracker issue: `TODO(#123): ...`, or file the ticket and delete the note.",
          });
        }
      },
    };
  },
});
