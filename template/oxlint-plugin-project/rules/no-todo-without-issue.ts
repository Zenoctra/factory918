import { defineRule } from "@oxlint/plugins";

// DRAFT. Shape follows pingdotgg/t3code's rules (defineRule, meta, create(context), context.report).
// A TODO without a ticket is a plan committed to the repo. Reference an issue or file one and delete the note.
const TODO = /\b(TODO|FIXME|HACK)\b(?![^\n]*#\d+)/u;

export default defineRule({
  meta: {
    type: "problem",
    docs: { description: "Disallow TODO/FIXME/HACK comments that do not reference a tracker issue (#123)." },
    schema: [
      {
        type: "object",
        properties: { maxOccurrences: { type: "integer", minimum: 0, description: "Legacy debt ceiling for this file." } },
        additionalProperties: false,
      },
    ],
  },
  create(context) {
    const allowed = context.options[0]?.maxOccurrences ?? 0;
    let seen = 0;
    return {
      Program() {
        for (const comment of context.sourceCode.getAllComments()) {
          if (!TODO.test(comment.value)) continue;
          seen++;
          if (seen <= allowed) continue;
          context.report({
            node: comment,
            message: "Reference a tracker issue: `TODO(#123): ...`, or file the ticket and delete the note.",
          });
        }
      },
    };
  },
});
