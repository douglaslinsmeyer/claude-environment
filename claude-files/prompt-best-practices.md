# Prompt Best Practices for Claude Code

This guide helps engineers write more effective prompts to get better results from Claude Code.

## Key Principles

### 1. Be Specific
❌ "Help me with this code"
✅ "Help me refactor this Python function to use async/await instead of callbacks"

### 2. Provide Context
❌ "Fix the bug"
✅ "Fix the IndexOutOfBounds exception in the processOrders method that occurs when the orders list is empty"

### 3. State Your Goal
❌ "Look at this SQL"
✅ "Optimize this SQL query to reduce execution time - it's currently taking 30+ seconds on a table with 1M rows"

### 4. Include Constraints
❌ "Make this faster"
✅ "Make this API endpoint faster while maintaining backward compatibility and keeping memory usage under 512MB"

## Effective Prompt Templates

### For Code Review
"Review this [language] code for [specific concerns]. Focus on [areas of interest]."
Example: "Review this C# code for thread safety issues. Focus on the shared state in the OrderProcessor class."

### For Debugging
"Debug this [error type] in [file/function]. The error occurs when [conditions]. Here's what I've tried: [attempts]."
Example: "Debug this NullReferenceException in UserService.GetProfile(). The error occurs when a new user logs in. I've tried checking for null userId."

### For Implementation
"Implement [feature] using [technology/pattern]. Requirements: [list]. Constraints: [list]."
Example: "Implement user authentication using JWT tokens in ASP.NET Core. Requirements: refresh tokens, 24h expiry. Constraints: must work with existing User table."

### For Refactoring
"Refactor this [code/component] to [goal] while maintaining [what to preserve]."
Example: "Refactor this OrderService class to follow SOLID principles while maintaining the public API."

### For Architecture
"Design a [system/component] that handles [use case] with [requirements]. Consider [concerns]."
Example: "Design a caching layer that handles 10k requests/second with sub-100ms latency. Consider memory constraints and cache invalidation."

## Common Improvements

### Adding Technical Context
- Mention the framework/library version
- Specify the runtime environment
- Include performance requirements
- Note any regulatory/compliance needs

### Clarifying Scope
- Define what should NOT be changed
- Specify if tests should be included
- Indicate if documentation is needed
- Mention deployment considerations

### Providing Examples
- Include sample input/output
- Show current vs desired behavior
- Provide error messages/stack traces
- Share relevant code snippets

## Tips for C#/.NET Engineers

Since your team primarily uses C#/.NET, here are specific tips:

### Include Framework Details
❌ "Help with my API"
✅ "Help with my ASP.NET Core 8 Web API using minimal APIs"

### Specify Patterns
❌ "Make this testable"
✅ "Refactor this to use dependency injection so I can unit test with xUnit and Moq"

### Mention Integration Points
❌ "Connect to database"
✅ "Connect to SQL Server using Entity Framework Core 8 with connection pooling"

### Reference Standards
❌ "Follow best practices"
✅ "Follow .NET coding conventions and make it async following TAP (Task-based Asynchronous Pattern)"

## Remember

- Claude Code performs best with clear, specific instructions
- More context = better results
- It's okay to be verbose when explaining complex problems
- If the result isn't quite right, refine your prompt and try again

💡 Pro tip: Save your best prompts as templates for your team to reuse!