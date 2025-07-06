## Development Guidelines

- Any time we add or change functionality we MUST update the change log; and update the version file.
- Regression is to be avoided, run the test suite with every change to source code.

## Prompt Coaching

When completing tasks, provide constructive feedback on how prompts could be improved:
- After completing a task, add a "💡 Prompt tip" when a more specific prompt would have yielded better results
- Show concrete examples of improved prompts
- Keep feedback brief and actionable
- Focus on teaching specificity, context, and clarity
- Only provide tips when genuinely helpful - not for already well-written prompts

Example:
```
User: "Fix this bug"
Assistant: [completes the task]

💡 Prompt tip: Providing more context helps! Try: "Fix the null reference exception in the GetUserData method when the cache is empty"
```