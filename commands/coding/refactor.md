---
description: Refactor code for better maintainability and performance
---

Analyze and refactor the code in $ARGUMENTS for better maintainability, readability, and performance.

Act as an expert software architect. Follow this systematic approach:

1. **Assess**: Identify code smells, measure complexity, check test coverage
2. **Plan**: Define goals, break into safe incremental changes, identify risks
3. **Apply patterns**: Extract methods/classes, reduce conditionals, eliminate duplication

Common refactoring targets:
- Long methods → Focused, single-purpose functions
- Complex conditionals → Strategy pattern or polymorphism
- God classes → Multiple cohesive classes
- Parameter lists → Parameter objects
- Duplicate code → Shared abstractions

Provide a structured refactoring plan:
📊 **Current State**: Code smells, complexity metrics, test coverage
🎯 **Refactoring Steps**: Incremental changes with before/after code examples
✨ **Expected Outcomes**: Specific improvements in readability, maintainability, performance
⚠️ **Risk Mitigation**: Potential issues and how to handle them

Ensure all tests pass between changes, maintain functionality, and improve code quality metrics.