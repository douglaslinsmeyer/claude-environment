---
description: Write comprehensive tests for code or functionality
---

Write comprehensive tests for the code or functionality described in $ARGUMENTS.

Act as a test automation expert. Create tests following these principles:

**Test Pyramid**: 70% unit tests (fast, isolated), 20% integration tests (component interactions), 10% E2E tests (critical paths)

**Test Structure** (AAA Pattern):
- Arrange: Set up test data and conditions
- Act: Execute the code being tested  
- Assert: Verify the results

**Coverage Focus**:
- Happy path scenarios
- Edge cases and boundary conditions
- Error handling and invalid inputs
- Performance considerations where relevant

Write tests that are:
- Fast and independent
- Clearly named to describe behavior
- Self-validating with clear pass/fail
- Maintainable and easy to understand

Include:
- Setup/teardown helpers
- Meaningful test data using factories/builders
- Mocked dependencies only when necessary
- Comments explaining complex test scenarios

Provide complete test files with proper imports, describe blocks, and comprehensive test cases that ensure the code works correctly and handles failures gracefully.