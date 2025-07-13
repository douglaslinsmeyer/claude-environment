---
description: Follow Test-Driven Development (TDD) workflow for all coding tasks
---

# Objective
At the end of this message, I will ask you to do something. Please follow this Development workflow: "Explore, Plan, Test (Red), Code (Green), Refactor (Re-Test)".

## Explore
First, use parallel subagents to find and read all files that may be useful for implementing the ticket, either as examples or as edit targets. The subagents should return relevant file paths, and any other info that may be useful.

## Plan
Next, create a detailed implementation plan that follows TDD principles:

**Your plan MUST include:**
1. What tests you'll write first (specific test cases)
2. The order of test implementation (start simple, build complexity)
3. Expected behaviors to test
4. Edge cases and error scenarios to cover

**Planning considerations:**
• Think about the test suite structure
• Identify the smallest testable units
• Plan the TDD cycles you'll follow
• Consider integration tests after unit tests

If there are things you are not sure about, use parallel subagents to do some web research. They should only return useful information, no noise.

**Ask questions:** If there are things you still do not understand or questions you have for the user, pause here to ask them before continuing.

## Test (Red Phase - Write Failing Tests First)
**IMPORTANT: All development MUST follow Test-Driven Development (TDD) principles. Write tests BEFORE implementation.**

**TDD is mandatory - follow this process:**
1. Write a failing test that describes the desired behavior
2. Run the test to ensure it fails (Red phase)
3. Only then proceed to write code

**Writing Initial Tests:**
• Start with the simplest test case - the "happy path"
• Write ONE failing test at a time
• Test behavior and outcomes, not implementation details
• Use descriptive test names that explain what the feature should do
• Keep tests minimal and focused - test one thing per test
• Write just enough test to fail meaningfully
• Use Given-When-Then or Arrange-Act-Assert structure
• Consider edge cases and error scenarios after the happy path

**Example Initial Test (Must Fail First):**
```javascript
test('calculates total price including 8.25% tax', () => {
  // Given - setup test data
  const cart = new ShoppingCart();
  cart.addItem({ price: 100 });
  
  // When - execute the behavior
  const total = cart.calculateTotal();
  
  // Then - assert expected outcome
  expect(total).toBe(108.25); // This MUST fail initially
});
```

**Remember: If the test doesn't fail first, you're not doing TDD!**

## Code (Green Phase - Make Tests Pass)
**IMPORTANT: Only write implementation code AFTER you have a failing test. This is the Green phase of TDD.**

**TDD Implementation Rules:**
1. Write the MINIMAL code needed to make the test pass
2. Don't add functionality that isn't tested
3. Resist the urge to write more than necessary
4. If you think of additional features, write a test for them first

**When implementing to pass tests:**
• Write the simplest solution that makes the test green
• Don't optimize or refactor yet - just make it work
• Follow the existing codebase style
• Use clear, descriptive names

**Source code contributions should:**
- Be driven by failing tests
- Prioritize making tests pass over elegance (initially)
- Follow existing naming conventions
- Implement only what's needed for current tests

**After making a test pass:**
- Run all tests to ensure nothing broke
- Commit your work with both test and implementation
- Consider writing the next failing test

## Re-Test (Refactor Phase - Improve Code with Tests as Safety Net)
**IMPORTANT: This is the Refactor phase of TDD. With all tests passing, you can now safely improve the code.**

**TDD Refactoring Process:**
1. Run ALL tests - ensure everything is green
2. Refactor code while keeping tests green
3. Run tests after each refactoring step
4. If tests fail during refactoring, revert and try again

**Refactoring activities (with tests as your safety net):**
• Remove duplication (DRY principle)
• Improve naming and readability
• Extract methods or components
• Apply design patterns where appropriate
• Optimize performance if needed
• Add error handling
• Apply SOLID principles

**Continuous testing during refactoring:**
• Use parallel subagents to run test suites
• Run tests after EVERY refactoring change
• Never refactor with failing tests
• If tests fail, immediately fix or revert

**Additional testing:**
• For UI changes, verify in browser with test scenarios
• Run linters and fix any issues
• Check test coverage - aim for high coverage
• Consider adding more tests for edge cases discovered

**TDD Cycle Complete:**
After refactoring with all tests green, you can either:
- Start the next TDD cycle with a new failing test
- Move to documentation and write-up

**Remember: The tests ARE your specification. If behavior needs to change, change the test first!**

## TDD Cycle Repeat
**Continue the TDD cycle for each feature:**
1. Write next failing test
2. Implement minimal code to pass
3. Refactor with tests as safety net
4. Repeat until feature is complete

**Important reminders:**
• Never write code without a failing test
• Keep each cycle small and focused
• Let tests drive the design
• Tests are living documentation

## Write up your work
When you are happy with your work:
- write up a short report that could be used as the PR description. Include what you set out to do, the choices you made with their brief justification, and any commands you ran in the process that may be useful for future developers to know about.
- If applicable, update the README to reflect your changes
- If applicable, update project documentation in ./docs to reflect your changes.
- If applicable, update CHANGELOG.md to reflect your changes.
- Update CLAUDE.md to reflect your changes.

## Memory usage
* Make use of your memory (mcp) tools, making memories and recalling them
* When using parallel subagents make sure they are coordinated in their approach to memory usage
* Reconcile subagent learnings and context following parallel subagent activities
* When using your memory, ALWAYS do AT LEAST a minimal double check to make sure your memory isn't out of date