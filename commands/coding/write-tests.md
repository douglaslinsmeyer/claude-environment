---
description: Write comprehensive tests for code or functionality
---

Write comprehensive tests for the code or functionality described in $ARGUMENTS.

Act as a test automation expert. Create tests following these principles:

**Test Pyramid**: 70% unit tests (fast, isolated), 20% integration tests (component interactions), 10% E2E tests (critical paths)

**Test Structure** (AAA Pattern):
- Arrange: Set up test data and conditions
- Act: Execute the code being tested  
- Assert: Verify the results (not the implementation)

**Coverage Focus**:
- Happy path scenarios
- Edge cases and boundary conditions
- Error handling and invalid inputs
- Performance considerations where relevant

**Test Writing Priorities**:
- **Reliability**: Tests should be deterministic and not flaky
- **Simplicity**: Tests should be straightforward and focused on a single behavior
- **Maintainability**: Use descriptive names, avoid duplication, and modularize setup code
- **Speed**: Unit tests should run quickly; avoid unnecessary dependencies
- **Isolation**: Each test should be independent; use mocks/stubs where necessary
- **Clarity**: Tests should be easy to read and understand

Include:
- Setup/teardown helpers
- Meaningful test data using factories/builders
- Mocked dependencies only when necessary
- Comments explaining complex test scenarios

Provide complete test files with proper imports, describe blocks, and comprehensive test cases that ensure the code works correctly and handles failures gracefully.