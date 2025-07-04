# Claude Configuration

This is your main Claude configuration file. Customize this file to define how Claude should work with your codebase and development workflow.

## Project Context

### Overview
[Describe your project, its purpose, and key technologies used]

### Tech Stack
- **Languages**: [e.g., TypeScript, Python, Go]
- **Frameworks**: [e.g., React, Django, Express]
- **Database**: [e.g., PostgreSQL, MongoDB]
- **Tools**: [e.g., Docker, Kubernetes, CI/CD]

### Architecture
[Describe the high-level architecture of your system]

## Development Guidelines

### Code Style
- **Naming Conventions**: [e.g., camelCase for variables, PascalCase for components]
- **File Organization**: [How files should be structured]
- **Import Order**: [Preferred import ordering]
- **Comments**: [When and how to comment code]

### Best Practices
- [Practice 1]: [Description]
- [Practice 2]: [Description]
- [Practice 3]: [Description]

### Common Patterns
```[language]
// Example of a common pattern in your codebase
```

## Claude Instructions

### General Behavior
- Always follow the existing code style in the project
- Prioritize readability and maintainability
- Write comprehensive tests for new features
- Update documentation when changing functionality
- Consider performance implications
- Handle errors gracefully

### Code Generation
When generating code:
1. Follow established patterns in the codebase
2. Include appropriate error handling
3. Add unit tests for new functions
4. Update relevant documentation
5. Consider edge cases

### Code Review
When reviewing code:
1. Check for security vulnerabilities
2. Ensure consistent style
3. Verify test coverage
4. Look for performance issues
5. Suggest improvements constructively

## Project-Specific Rules

### Do's
- ✅ Use dependency injection
- ✅ Write descriptive commit messages
- ✅ Keep functions small and focused
- ✅ Handle all error cases
- ✅ Document complex logic

### Don'ts
- ❌ Commit sensitive data
- ❌ Use magic numbers
- ❌ Ignore linting errors
- ❌ Skip writing tests
- ❌ Leave TODO comments without tickets

## Testing Guidelines

### Unit Tests
- Test one thing per test
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies
- Aim for 80%+ coverage

### Integration Tests
- Test critical user paths
- Use realistic test data
- Clean up after tests
- Test error scenarios
- Keep tests independent

## Documentation Standards

### Code Documentation
- Document all public APIs
- Include examples in docstrings
- Explain complex algorithms
- Note any assumptions
- Keep docs up-to-date

### README Updates
When to update the README:
- Adding new features
- Changing setup process
- Modifying API
- Adding dependencies
- Changing deployment

## Workflow Integration

### Git Workflow
- **Branch Naming**: `feature/description`, `bugfix/description`, `hotfix/description`
- **Commit Messages**: Use conventional commits (feat:, fix:, docs:, etc.)
- **PR Process**: All code must be reviewed before merging

### CI/CD
- All tests must pass
- Linting must pass
- Build must succeed
- Documentation must be updated
- Security scans must pass

## Performance Considerations

### Optimization Guidelines
- Profile before optimizing
- Focus on bottlenecks
- Consider caching strategies
- Minimize network calls
- Use appropriate data structures

### Monitoring
- Log important events
- Track performance metrics
- Set up alerts for anomalies
- Monitor error rates
- Track user experience metrics

## Security Guidelines

### Best Practices
- Never commit secrets
- Validate all inputs
- Use parameterized queries
- Implement rate limiting
- Keep dependencies updated
- Follow OWASP guidelines

### Code Review Focus
- Check for injection vulnerabilities
- Verify authentication/authorization
- Look for sensitive data exposure
- Check error handling
- Verify secure communication

## Communication

### When Working with Claude
- Be specific about requirements
- Provide context for changes
- Share relevant code examples
- Clarify ambiguous requests
- Review generated code carefully

### Collaboration Notes
[Any specific notes about how Claude should interact with your development process]

---

*This configuration helps Claude understand your project's specific needs and constraints. Update it as your project evolves.*