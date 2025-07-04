# Claude Configuration for [Project Name]

This file configures Claude's behavior for this specific project. Customize it based on your project's needs, technologies, and conventions.

## 🎯 Project Overview

**Project Type**: [Web App / API / Library / CLI Tool / Mobile App]  
**Primary Language**: [JavaScript/TypeScript/Python/Go/etc.]  
**Started**: [Date]  
**Team Size**: [Number of developers]  
**Stage**: [Planning / Development / Testing / Production]

### Project Description
[2-3 sentences describing what this project does, its main features, and target users]

### Business Context
[Brief explanation of business goals and constraints]

## 🛠️ Technical Stack

### Core Technologies
- **Language**: [e.g., TypeScript 5.0]
- **Runtime**: [e.g., Node.js 18+]
- **Framework**: [e.g., Next.js 14]
- **Database**: [e.g., PostgreSQL 15]
- **Cache**: [e.g., Redis]
- **Queue**: [e.g., Bull/RabbitMQ]

### Infrastructure
- **Hosting**: [e.g., AWS/GCP/Azure/Vercel]
- **CI/CD**: [e.g., GitHub Actions]
- **Monitoring**: [e.g., Datadog/New Relic]
- **Error Tracking**: [e.g., Sentry]

### Development Tools
- **Package Manager**: [npm/yarn/pnpm]
- **Testing**: [Jest/Mocha/pytest]
- **Linting**: [ESLint/Prettier]
- **Git Flow**: [GitHub Flow/GitFlow]

## 📐 Architecture Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Frontend  │────▶│     API     │────▶│   Database  │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    Cache    │
                    └─────────────┘
```

### Key Design Decisions
1. **Pattern**: [e.g., MVC, Clean Architecture, Microservices]
2. **State Management**: [e.g., Redux, MobX, Context API]
3. **API Style**: [REST/GraphQL/gRPC]
4. **Authentication**: [e.g., JWT, OAuth, Session-based]

## 📂 Project Structure

```
project-root/
├── src/
│   ├── [describe main directories]
│   └── ...
├── tests/
├── docs/
└── [other key directories]
```

### Important Files
- `[file]`: [What it does]
- `[file]`: [What it does]

## 💻 Development Guidelines

### Code Style Preferences
```javascript
// PREFERRED: Named exports for better refactoring
export const myFunction = () => { };

// AVOID: Default exports except for pages/components
export default function() { }

// PREFERRED: Async/await over promises
const data = await fetchData();

// PREFERRED: Early returns
if (!isValid) return null;
// ... rest of logic
```

### Naming Conventions
- **Files**: `kebab-case.ts` for utilities, `PascalCase.tsx` for components
- **Variables**: `camelCase` for regular vars, `UPPER_SNAKE_CASE` for constants
- **Functions**: `camelCase` for functions, `useCamelCase` for hooks
- **Types/Interfaces**: `PascalCase` with `I` prefix for interfaces (optional)
- **CSS Classes**: `kebab-case` or `BEM` methodology

### Component Patterns
```typescript
// Preferred component structure
interface ComponentProps {
  // Props interface
}

export const Component: React.FC<ComponentProps> = ({ prop1, prop2 }) => {
  // Hooks first
  const [state, setState] = useState();
  
  // Computed values
  const computedValue = useMemo(() => {}, []);
  
  // Effects
  useEffect(() => {}, []);
  
  // Handlers
  const handleClick = useCallback(() => {}, []);
  
  // Render
  return <div>...</div>;
};
```

## ✅ Quality Standards

### Testing Requirements
- **Unit Test Coverage**: Minimum 80%
- **Integration Tests**: For all API endpoints
- **E2E Tests**: For critical user paths
- **Test File Location**: Next to source files with `.test.ts` extension

### Code Review Checklist
- [ ] Follows project conventions
- [ ] Includes appropriate tests
- [ ] Updates documentation if needed
- [ ] No console.logs or debug code
- [ ] Handles errors appropriately
- [ ] Considers performance implications
- [ ] Includes necessary type definitions
- [ ] Updates changelog if applicable

### Performance Targets
- **Page Load**: < 3 seconds
- **API Response**: < 200ms (p95)
- **Bundle Size**: < 200KB gzipped
- **Lighthouse Score**: > 90

## 🔒 Security Guidelines

### Critical Security Rules
1. **Never** commit secrets or API keys
2. **Always** validate and sanitize user input
3. **Use** parameterized queries for database operations
4. **Implement** rate limiting on all endpoints
5. **Keep** dependencies updated (monthly review)

### Security Checklist
- [ ] Input validation on all forms
- [ ] XSS prevention measures
- [ ] CSRF tokens implemented
- [ ] SQL injection prevention
- [ ] Proper authentication checks
- [ ] Sensitive data encryption

## 🚀 Deployment Process

### Pre-deployment Checklist
1. All tests passing
2. Code review approved
3. Documentation updated
4. Database migrations ready
5. Environment variables configured
6. Performance tested

### Deployment Steps
```bash
# 1. Run tests
npm test

# 2. Build
npm run build

# 3. Deploy
npm run deploy:production
```

## 🐛 Debugging & Troubleshooting

### Common Issues
1. **Issue**: [Description]
   - **Solution**: [How to fix]
   
2. **Issue**: [Description]
   - **Solution**: [How to fix]

### Debugging Tools
- Browser DevTools for frontend
- `DEBUG=app:*` for backend logging
- [Specific tools for this project]

## 📈 Monitoring & Metrics

### Key Metrics to Track
- Response time (p50, p95, p99)
- Error rate
- Active users
- Database query performance
- Cache hit rate

### Alert Thresholds
- Error rate > 1%
- Response time > 500ms (p95)
- Memory usage > 80%
- Disk usage > 90%

## 🤖 Claude-Specific Instructions

### When Generating Code
1. **Always** follow the established patterns in the codebase
2. **Include** comprehensive error handling
3. **Write** tests for new functionality
4. **Update** relevant documentation
5. **Consider** backwards compatibility
6. **Optimize** for readability over cleverness

### When Reviewing Code
1. **Check** for security vulnerabilities first
2. **Verify** test coverage
3. **Ensure** consistent code style
4. **Look for** performance bottlenecks
5. **Validate** error handling
6. **Confirm** documentation updates

### When Debugging
1. **Start** with error logs and stack traces
2. **Check** recent changes in git history
3. **Verify** environment configurations
4. **Test** in isolation when possible
5. **Document** the fix for future reference

### Project-Specific Behaviors
- [Any specific instructions for Claude when working on this project]
- [Patterns to always follow]
- [Things to always avoid]

## 📚 Resources & Documentation

### Internal Documentation
- [API Documentation](./docs/api.md)
- [Architecture Decision Records](./docs/adr/)
- [Setup Guide](./docs/setup.md)

### External Resources
- [Framework Documentation](https://example.com)
- [Library Reference](https://example.com)
- [Team Wiki](https://wiki.example.com)

## 👥 Team Conventions

### Communication
- Use clear, descriptive commit messages
- Update tickets with progress
- Document decisions in ADRs
- Ask questions early and often

### Git Workflow
- Branch from `main`
- Prefix branches: `feature/`, `bugfix/`, `hotfix/`
- Squash commits on merge
- Delete branches after merge

---

*Last Updated: [Date]*  
*Maintained by: [Team/Person Name]*