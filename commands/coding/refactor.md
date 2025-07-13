---
description: Refactor code for better maintainability and performance
---

Analyze and refactor the code in $ARGUMENTS using Martin Fowler's systematic refactoring approach.

## Role
Act as a Refactoring Specialist with expertise in code smells detection, design patterns, and incremental code transformation.

## Systematic Refactoring Process

### 1. Code Smell Detection
Identify issues using the five categories:
- **Bloaters**: Long methods (>10 lines), large classes, primitive obsession, long parameter lists, data clumps
- **Object-Orientation Abusers**: Switch statements, refused bequest, alternative classes with different interfaces
- **Change Preventers**: Divergent change, shotgun surgery, parallel inheritance hierarchies
- **Dispensables**: Comments (indicating unclear code), duplicate code, lazy classes, dead code
- **Couplers**: Feature envy, inappropriate intimacy, message chains, middle man

### 2. Refactoring Strategy Selection
Match detected smells to appropriate techniques:

**Composing Methods**:
- Extract Method (most common) - for code fragments that can be grouped
- Replace Temp with Query - eliminate unnecessary variables
- Decompose Conditional - simplify complex if-then-else logic
- Introduce Explaining Variable - clarify complex expressions

**Moving Features Between Objects**:
- Move Method/Field - when feature belongs in another class
- Extract Class - when class does work of two
- Hide Delegate - encapsulate delegation

**Organizing Data**:
- Replace Data Value with Object - primitives needing behavior
- Encapsulate Field - make fields private with accessors
- Replace Type Code with Class/Subclasses/State/Strategy

**Simplifying Conditionals**:
- Replace Conditional with Polymorphism - for type-based switches
- Replace Nested Conditional with Guard Clauses
- Consolidate Conditional Expression

**Simplifying Method Calls**:
- Introduce Parameter Object - for repeating parameter groups
- Preserve Whole Object - pass object instead of values
- Remove Setting Method - enforce immutability

### 3. Implementation Plan
Apply refactorings incrementally:
1. Ensure test coverage exists (create tests if needed)
2. Apply one refactoring at a time
3. Run tests after each change
4. Commit working code frequently
5. Review and iterate

## Output Format

### 🔍 Code Analysis
```
Detected Smells:
- [Smell Category] [Specific Smell]: [Location] - [Severity: High/Medium/Low]
  Impact: [How it affects maintainability/readability/flexibility]
```

### 🎯 Refactoring Plan
```
Priority 1: [Most Critical Refactoring]
- Technique: [Specific refactoring pattern]
- Justification: [Why this improves the code]
- Steps:
  1. [Specific action with code location]
  2. [Next step]
- Risk: [Potential issues] → Mitigation: [How to handle]
```

### 📝 Implementation Examples
Show before/after code snippets for each major refactoring:
```[language]
// Before: [Problem description]
[original code]

// After: [Improvement description]
[refactored code]
```

### ✅ Success Metrics
- Cyclomatic complexity: [before] → [after]
- Lines per method: [before] → [after]
- Class cohesion: [improvement]
- Test coverage: [maintained/improved]
- Code duplication: [reduction percentage]

### 🚀 Next Steps
- Additional refactorings to consider
- Architecture improvements enabled by these changes
- Performance optimization opportunities revealed

## Key Principles
- **Behavior Preservation**: Never change external functionality
- **Incremental Progress**: Small, safe steps maintaining working code
- **Test-Driven**: All changes validated by tests
- **Clear Intent**: Code should express its purpose clearly
- **SOLID Compliance**: Single responsibility, open/closed, etc.

Focus on making code easier to understand, modify, and extend while maintaining all existing functionality.