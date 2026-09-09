import { definePlugin } from "@oxlint/plugins";

import noTodoWithoutIssue from "./rules/no-todo-without-issue.ts";

export default definePlugin({
  meta: { name: "project" },
  rules: { "no-todo-without-issue": noTodoWithoutIssue },
});
